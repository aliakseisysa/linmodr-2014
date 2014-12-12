# Пакеты

library(ggplot2)
library(car)
# Настройк для графики

theme_set(theme_bw(base_size = 16) +
            theme(legend.key = element_blank()))
update_geom_defaults("point", list(shape = 19, size = 3))


# Прочитайте файл "RedSquirrels.txt" и создайте на его основе датафрейм SQ 

SQ <- read.table(file   = "RedSquirrels.txt", header = TRUE, dec    = ".")
plot(SQ$Ntrees, SQ$SqCones)

# Мы будем строить модель, где в качестве зависимой перменной будет количество погрызенных шишек (SqCones), а независимыми прдикорам - Число деревьев на площадке (Ntrees), средняя высота деревьев (TreeHeight) и проективное покрытие травы (CanopyCover).
# Уберите из датафрейма лишние переменные

SQ <- SQ[, -c(1,4)]

# Постройте дотплоты для диагностики всех переменных

ggplot(SQ, aes(x=SqCones, y=1:nrow(SQ))) + geom_point()
ggplot(SQ, aes(x=Ntrees, y=1:nrow(SQ))) + geom_point()
ggplot(SQ, aes(x=TreeHeight, y=1:nrow(SQ))) + geom_point()
ggplot(SQ, aes(x= CanopyCover, y=1:nrow(SQ))) + geom_point()


# Определите есть ли в датасете избыток нулей

plot(table(SQ$SqCones))

mean(SQ$SqCones == 0) * 100

# # Создайте переменные Ntrees_st, TreeHeight_st,  CanopyCover_st, содержащие стандартизованные значения соответствующих предикторов
# 
# SQ$Ntrees_st <- (SQ$Ntrees - mean(SQ$Ntrees)) / sd(SQ$Ntrees)
# SQ$TreeHeight_st <- scale(SQ$TreeHeight)
# SQ$CanopyCover_st <- scale(SQ$CanopyCover) 
# 

# Подберите линейную модель M1 вида SqCones ~ Ntrees + TreeHeight + CanopyCover методом максимального правдопдобия, исходя из предположения о нормальном распределении остатков 

M1 <- glm(SqCones ~ Ntrees + TreeHeight + CanopyCover, family="gaussian", data=SQ)

summary(M1)

# Проведите диагностику этой модели, построив график рассеяния остатков 

plot(M1)

M1_diag <- fortify(M1)

ggplot(M1_diag, aes(x=.fitted, y=.stdresid)) + geom_point() + geom_hline(yintercept=0)

# Определите, есть ли мультиколлинеарность между предикторами

vif(M1)


# Подберите параметры модели M2, имеющей ту же фиксированную часть, что и M1, но основаную на предположении о распределении остатков в соответствии с распределением Пуассона

M2 <- update(M1, family="poisson")

summary(M2)

# Постройте график рассеяния остатков для данной модели 

M2_diag <- fortify(M2)

ggplot(M2_diag, aes(x=.fitted, y=.stdresid)) + geom_point() + geom_hline(yintercept=0)

# Определите, есть ли в данной модели избыточность дисперсии

Resid_M2 <- resid(M2, type = "pearson") 
N <- nrow(SQ)
p <- length(coef(M2)) 
df <- (N - p) 
fi <- sum(Resid_M2^2) /df 
fi


# Постройте квази-пуассоновскую модель M3

M3 <- update(M2, family="quasipoisson")
summary(M3)

# Какие из предикторов этой модели можно убрать?
# Hint: используйте drop1()

drop1(M3, test="F")

M3_2 <- update(M3, ~.-TreeHeight)

drop1(M3_2, test="F")

M3_3 <- update(M3_2, ~.-Ntrees)

drop1(M3_3, test="F")

summary(M3_3)

# Постройте график рассеяния остатков для финальной модели. Есть ли в модели отрицаетльные предсказанные значения?

M3_3_diag <- fortify(M3_3)

ggplot(M3_3_diag, aes(x=.fitted, y=.stdresid)) + geom_point() + geom_hline(yintercept=0)


F3 <- fitted(M3, type = "response")
plot(y = SQ$SqCones, 
     x = F3,
     xlab = "Fitted values",
     ylab = "Observed data",
     cex.lab = 1.5,
     xlim = c(0,60), 
     ylim = c(0,60) )
abline(coef = c(0, 1), lty = 2)   


# Подберите мдель M4 вида SqCones ~ Ntrees + TreeHeight + CanopyCover, основанную на предположении о распределении остатков в соответстии с отрицательноам биномиальным распределинем


library(MASS)
M4 <- glm.nb(SqCones ~ Ntrees + TreeHeight + CanopyCover,data = SQ)
summary(M4)

# Есть ли избыточная дисперсия в этой модели?

Resid_M4 <- resid(M4, type = "pearson") 
N <- nrow(SQ)
p <- length(coef(M4)) + 1
df <- (N - p) 
fi <- sum(Resid_M4^2) /df 
fi



# Какие предикторы можно выкинуть из этой модели?

drop1(M4, test="Chi")

M4_2 <- update(M4, ~.-TreeHeight)

drop1(M4_2, test="Chi")

M4_3 <- update(M4_2, ~.-Ntrees)

drop1(M4_3, test="Chi")



# Визуализируйте зависимость SqCones от предиктора в финальной модели

range(SQ$CanopyCover)
NewData <- data.frame(CanopyCover = seq(54,95, 1))

pred <- predict(M4_3, newdata=NewData, se.fit = TRUE)$fit
se <- predict(M4_3, newdata=NewData, se.fit = TRUE)$se.fit

NewData$pred <- exp(pred)  
NewData$se_low <- exp(pred - 1.96 * se)  
NewData$se_up <- exp(pred + 1.96 * se)  

ggplot(NewData, aes(x=CanopyCover, y=pred)) + geom_line() + geom_point(data=SQ, aes(x=CanopyCover, y=SqCones)) + geom_ribbon(aes(x=CanopyCover, ymin=se_low, ymax=se_up), color="gray", alpha=0.1)

# Постройте график рассеяния остатков для финалной модели

M4_3_diag <- data.frame(fit = fitted(M4_3), resid = residuals(M4_3, type="pearson"))

ggplot(M4_3_diag, aes(x=fit, y=resid)) + geom_point() + geom_hline(yintercept=0)
