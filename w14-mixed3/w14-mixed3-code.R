
# Пакеты ====
library(ggplot2)
library(nlme)


#Настройка темы для графиков =============
theme_set(theme_bw(base_size = 16) +
            theme(legend.key = element_blank()))
update_geom_defaults("point", list(shape = 19, size = 3))


#Читаем данные =============
kill <- read.table("RoadKills.txt", header=TRUE)

head(kill)
str(kill)

# Исследуем данные
# Для демонстрации рассмотрим связь между TOT.N  и D.PARK
ggplot(kill, aes(x = TOT.N , y = 1:nrow(kill))) + geom_point()

ggplot(kill, aes(x =  D.PARK , y = 1:nrow(kill))) + geom_point()

ggplot(kill, aes(x =  X , y = Y)) + geom_point()

# Смотрим на связь между зависимой переменной и предиктором

ggplot(kill, aes(x =  D.PARK , y = TOT.N )) + geom_point() 


# Подгоним линейную модель  
M1 <- glm(TOT.N ~ D.PARK, family="gaussian", data = kill)
summary(M1)




# Посмотрим на предсказанные значения

range(kill$D.PARK)
NewData <- data.frame(D.PARK = seq(250, 25000, 1000))
X <- model.matrix(~D.PARK, data=NewData)

NewData$lm_Pred <- X %*% coef(M1)

NewData$lm_SE <- sqrt(diag(X %*% vcov(M1) %*% t(X)))

ggplot(NewData, aes(x =  D.PARK , y = lm_Pred)) + geom_line() + geom_ribbon(aes(x=D.PARK, ymin = lm_Pred - lm_SE, ymax = lm_Pred + lm_SE), alpha=0.3, color="green") + geom_point(data = kill, aes(x=D.PARK, y=TOT.N)) + geom_hline(yintercept=0) 

# смотрим на график рассения остатков ==========
M1_diag <- fortify(M1)

ggplot(M1_diag, aes(x=.fitted, y=.stdresid)) + geom_point() + geom_hline(yintercept=0)

# В чем проблемы в данной модели?
# 1. Паттерн в рассеянии остатков
# 2. Гетероскедастичность
# 3. Модель предсказывает отрицаетльные численности

# Для такого типа данных гауссовское распределение не годится 

#################################
# ЧАСТЬ 1.
# Теоретический экскурc в Пуассоновскую регрессию (Poisson regression)
# см. презентацию с теорией
#################################

# Применяем пуассоновскую регресию

M2 <- update(M1, family = "poisson")
summary(M2)

G <- predict(M2, newdata = NewData, type = "link", se.fit = TRUE)

NewData$pois_Pred  <- exp(G$fit) 
NewData$pois_SEUP <- exp(G$fit + 1.96*G$se.fit) 
NewData$pois_SELOW <- exp(G$fit - 1.96*G$se.fit)

(pl_poisson <- ggplot(NewData, aes(x =  D.PARK , y = pois_Pred)) + geom_line() + geom_ribbon(aes(x=D.PARK, ymin = pois_SELOW, ymax = pois_SEUP), alpha=0.3, color="green") + geom_point(data = kill, aes(x=D.PARK, y=TOT.N)) + geom_hline(yintercept=0) + ggtitle("poisson model fitting")) 


###############################
# Небольшое отступление
# Иллюстрация того, как устроена модель в случае с пуассоновской регрессией
###############################

Points <- data.frame(D.PARK = rep(kill$D.PARK, each=100), Pred = rep(fitted(M2), each=100))


for (i in 1:nrow(Points)){Points$draw[i] <- rpois(100, lambda = Points$Pred[i])}

ggplot(NewData, aes(x =  D.PARK , y = pois_Pred))  + geom_point(data = kill, aes(x=D.PARK, y=TOT.N), size=4, color="blue4") + geom_hline(yintercept=0) + geom_point(data = Points, aes(x=D.PARK, y=draw), size=0.5, position = position_jitter(width = 50) ) + geom_line(size=2, color="red") 

# На полученном графике видно, что многие точки выскакивают за пределы рспределения, которое должно быть связано с линией регрессии, роходящей через "mu". значения mu лежат на линии регрессии.  


##############################


M2_diag <- fortify(M2)

ggplot(M2_diag, aes(x=.fitted, y=.stdresid)) + geom_point() + geom_hline(yintercept=0)

#########################
# ЧАСТЬ 2
# Множественная регрессия с пуассоновским распределением остатков 
#########################


library(car)

M4 <- glm(TOT.N ~  S.RICH + OPEN.L + OLIVE + MONT.S + MONT + POLIC+ SHRUB + URBAN + WAT.RES + L.WAT.C + L.D.ROAD + L.P.ROAD + D.WAT.RES + D.WAT.COUR +   D.PARK + N.PATCH + P.EDGE + L.SDI , data = kill)

vif(M4) #Отбраковываем коррелирующие предикторы

M4 <- glm(TOT.N ~  S.RICH + OPEN.L +  MONT.S + MONT + POLIC+ SHRUB + URBAN + WAT.RES + L.WAT.C + L.D.ROAD + L.P.ROAD + D.WAT.RES + D.WAT.COUR +   D.PARK + N.PATCH + P.EDGE + L.SDI , data = kill)

vif(M4)

M4 <- glm(TOT.N ~  S.RICH + OPEN.L +  MONT.S + MONT + POLIC+ SHRUB + URBAN + WAT.RES + L.WAT.C + L.D.ROAD + L.P.ROAD + D.WAT.RES + D.WAT.COUR +   D.PARK  + P.EDGE + L.SDI , data = kill)

vif(M4)

M4 <- glm(TOT.N ~  S.RICH + OPEN.L + MONT + POLIC+ SHRUB + URBAN + WAT.RES + L.WAT.C + L.D.ROAD + L.P.ROAD + D.WAT.RES + D.WAT.COUR +   D.PARK  + P.EDGE + L.SDI , data = kill)

vif(M4)


# и.д. .....

M4 <- glm(TOT.N ~  OPEN.L + MONT.S + POLIC + D.PARK + SHRUB + WAT.RES + L.WAT.C + L.P.ROAD + D.WAT.COUR , family = "poisson", data = kill)

vif(M4)

summary(M4)

# Можно удалить из модели еще и D.WAT.COUR

M5 <- glm(TOT.N ~  OPEN.L + MONT.S + POLIC + D.PARK + SHRUB + WAT.RES + L.WAT.C + L.P.ROAD , family = "poisson", data = kill)

# Сравним две вложенные модели с помощью Maximum likelihood ratio test
anova(M4, M5, test="Chi")

# Второй вариант - использовать функцию drop1(). 
# Внимание! drop1() работает с результатам подгонки моделей не всех пакетов! 

drop1(M4, test="Chi")

# Смотрим на результаты сокращенной модели
summary(M5)

# Не спешим радоваться тому, что все достоверно! Необходимо проверить условие применимсти пуассоновской регресии mu = sigma

#######################
#ЧАСТЬ 3
#Условия применимости пуассоновской регрессии
#######################

# Остатки в моделях подогнанных методом максимального правдоподобия бывают нескольких типов

# Hint: Запись residuals.glm() вместо residuals() позволяет вам посмотреть справку по функции residuals, связанной с классом 'glm'

residuals(M5, type = "pearson") #наиболее удобна для большинства анализов



# Избыточная дисперсия (Overdipersion)!!!!

Resid_M5 <- resid(M5, type = "pearson") # Пирсоновские остатки
N <- nrow(kill) # Объем выборки
p <- length(coef(M5)) # Число параметров в модели
df <- (N - p) # число степенейсвободы
fi <- sum(Resid_M5^2) /df  #Величина fi показывает во сколько раз в среднем sigma > mu для данной регрессионной модели
fi

# Если fi > 1 мы имеем дело с избыточностью дисперсии

sqrt(fi) #Запомните эту величину, она нам понадобится


# Причины избыточной дисперсии
################################
#A. Отскакивающие значения?    ==> Это мнимая избыточность дисперсии. Попробовать удалить отскакивающие значения.
#B. Пропущенные важные ковариаты или взаимодействия факторов?  ==> Это мнимая избыточность дисперсии. Надо переформатировать модель. 
#C. Слишком много нулей?       ==> Это мнимая избыточность дисперсии. Изучаем и применяем специальный раздел теориии под названием Zero inflated poisson (ZIP)

#D. Это свойство данных?       ==> Имеем дело с истинной избыточностью дисперсии. Применяем более сложную модель, основанную на Negative Binomial distribution
#E. Существуют какие-то внутригрупповые корреляции? ==> Применяем генерализованные смешанные линейные модели (GLMM)
#F. Зависимая переменная связана нелинейно с предикторами ==> Используем GAM(GAMM) 
#G. Ошибочно выбрана связывающая функция (link function)  ==> надо ее изменить и подогнать новую модель. 



# В чем причины избыточности дисперсии у нашей модели?

# Отскакивающих значений нет
# Ковариаты все на месте
# Проверяем количество нулей в данных

sum(kill$TOT.N==0)

# Нулей в избытке тоже нет


# В данном случае мы имеем дело с истинной избыточностью дисперсии.

###############################################################
# ПЕРВОЕ РЕШЕНИЕ проблемы избыточной дисперсии - "косметическое"
# Подгоняем квази-пуассоновскую модель (quasi-poisson GLM)
##############################################################


# Подгоняем модель

M5_q <- glm(TOT.N ~  OPEN.L + MONT.S + POLIC + D.PARK + SHRUB + WAT.RES + L.WAT.C + L.P.ROAD , family = "quasipoisson", data = kill)

summary(M5_q)

# Количество достоверно влияющих предикторов заметно сократилось!

#At! Не пишите в статье, что модель была основана на квази-пуассоновском распределении! Такого распределиня нет! Надо указать, что вы подгоняли квази-пуассоновскую модель, так как обнаружили избыточную дисперсию. 

# Подбор оптимальной модели в случае квази-пуассоновской регрессии несколько отличается от предыдущих случаев. AIC - не может быть вычислен! Кроме того, разность девианс сравнивается не с Хи-квадрат распределением, а с F-распределением. 

  drop1(M5_q, test = "F")

M5_q2 <- update(M5_q, .~.-POLIC)

  drop1(M5_q2, test = "F")

M5_q3 <- update(M5_q2, .~.-L.P.ROAD)

  drop1(M5_q3, test = "F")

M5_q4 <- update(M5_q3, .~.-WAT.RES)

  drop1(M5_q4, test = "F")

M5_q5 <- update(M5_q4, .~.-SHRUB)

  drop1(M5_q5, test = "F")

M5_q6 <- update(M5_q5, .~.-OPEN.L)
  
  drop1(M5_q6, test = "F")

M5_q7 <- update(M5_q6, .~.-MONT.S)

  drop1(M5_q7, test = "F")

M5_q8 <- update(M5_q7, .~.-L.WAT.C)

  drop1(M5_q8, test = "F")


# В итоге получаем такую финальную модель
M5_final <- glm(TOT.N ~  D.PARK, family = "quasipoisson", data = kill)


# Вычисляем предсказанные значения

G <- predict(M5_final, newdata = NewData, se.fit = TRUE)

# Обратите внимание, что результаты рботы функции predict(), не являются истинными значениями mu

NewData$quasipois_Pred  <- exp(G$fit) 
NewData$quasipois_SEUP <- exp(G$fit + 1.96*G$se.fit) 
NewData$quasipois_SELOW <- exp(G$fit - 1.96*G$se.fit)



(pl_quasipoisson <- ggplot(NewData, aes(x =  D.PARK , y = quasipois_Pred)) + geom_line() + geom_ribbon(aes(x=D.PARK, ymin = quasipois_SELOW, ymax = quasipois_SEUP), alpha=0.3, color="green") + geom_point(data = kill, aes(x=D.PARK, y=TOT.N), size=3) + geom_hline(yintercept=0) + ggtitle("quasi-poisson model fitting")) 

library(gridExtra)

# Сравним результаты пуассоновской и квази-пуассоновской модели
grid.arrange(pl_poisson, pl_quasipoisson)


# Проводим диагностику модели
M5_final_diag <- data.frame(Fit_M5_final = fitted(M5_final), Res_M5_final = residuals(M5_final, type="pearson"))

ggplot(M5_final_diag, aes(x=Fit_M5_final, y=Res_M5_final)) + geom_point() + geom_hline(yintercept=0)

# Проверяем на избыточность дисперсии

Resid_M5_final <- resid(M5_final, type = "pearson")
N <- nrow(kill)
p <- length(coef(M5_final))  
fi <- sum(Resid_M5_final^2) / (N - p)
fi


# Сравните результаты подгонки квази-пуассоновской и пуассоновской модели 
summary(M5_final)
summary(update(M5_final, family="poisson"))


# Избыточность дисперсии никуда не ушла и оценки параметров модели не изменились, но за счет введения в модель параметра fi, на который доможаются стандартные ошибки, увеличивается консервативность критериев.  


# Выгода от квази-пуассоновской регрессии : Не делаем неверных выводов о достоверности влияния тех или иных предикторов

# Недостаток : в модели все равно остается избыточная дисперсия




# ВТОРОЕ РЕШЕНИЕ проблемы избыточной дисперсии - модель, основанная на отрицательном биномиальном распределении  (Negative binimial distribution)


library(MASS)
M5_nb <- glm.nb(TOT.N ~  OPEN.L + MONT.S + POLIC + D.PARK + SHRUB + WAT.RES + L.WAT.C + L.P.ROAD, link = "log", data = kill)

summary(M5_nb, cor = FALSE)

  drop1(M5_nb, test="Chi")

M5_nb2 <- update(M5_nb, .~.-POLIC)
  
  drop1(M5_nb2, test="Chi")

M5_nb3 <- update(M5_nb2, .~.-WAT.RES)

  drop1(M5_nb3, test="Chi")

M5_nb4 <- update(M5_nb3, .~.-SHRUB)

  drop1(M5_nb4, test="Chi")

M5_nb5 <- update(M5_nb4, .~.-MONT.S)

  drop1(M5_nb5, test="Chi")

M5_nb6 <- update(M5_nb5, .~.-L.P.ROAD)

  drop1(M5_nb6, test="Chi")

# Можно выкинуть еще и L.WAT.C так как значения p вычисляются лишь приблизительно, а p=0.02 очень близко к p=0.05

M5_final_nb <- update(M5_nb6, .~.-L.WAT.C )

summary(M5_final_nb)

# Проверяем на избыточность дисперсии

Resid_M5_final_nb <- resid(M5_final_nb, type = "pearson")
N <- nrow(kill)
p <- length(coef(M5_final_nb)) + 1  
fi <- sum(Resid_M5_final_nb^2) / (N - p)
fi

# Избыточность дисперсии исчезла!


# Сравним модели полученные с помощью пуассоовской регрессии и NB-регресси

M_poisson <- glm(TOT.N ~ OPEN.L + D.PARK, family = poisson,data = kill)


llhNB = logLik(M5_final_nb)
llhPoisson = logLik(M_poisson)
d <- 2 * (llhNB - llhPoisson)
pval <- 0.5 * pchisq(as.numeric(d), df = 1,lower.tail = FALSE)
pval

AIC(M_poisson, M5_final_nb)

# Модель, основанная на отрицательном биномиальном распределении заметно лучше!


# Проводим диагностику модели

M5_final_nb_diag <- data.frame(Fit_M5_final_nb = fitted(M5_final_nb), Res_M5_final_nb = residuals(M5_final_nb, type="pearson"))

ggplot(M5_final_nb_diag, aes(x=Fit_M5_final_nb, y=Res_M5_final_nb)) + geom_point() + geom_hline(yintercept=0) 

# Кажется все хорошо
# Но...




#################################
# ЧАСТЬ 4. 
# Краткий экскурс в Generalised Additive Models (GAM)
# см. презентацию 
#################################

# Подгоняем GAM

library(mgcv) #Пакет, работающий с аддитивными моделями

M6 <- gam(TOT.N ~ s(D.PARK) + s(OPEN.L), family=nb, data = kill)

summary(M6)

plot(M6)


NewData <- data.frame(D.PARK = seq(250, 25000, 1000), OPEN.L = mean(kill$OPEN.L))
  
G <-  predict(M6, newdata = NewData, se.fit = TRUE)

NewData$nb_gam_Pred  <- exp(G$fit) 
NewData$nb_gam_SEUP <- exp(G$fit + 1.96*G$se.fit) 
NewData$nb_gam_SELOW <- exp(G$fit - 1.96*G$se.fit)


ggplot(NewData, aes(x =  D.PARK , y = nb_gam_Pred)) + geom_line() + geom_ribbon(aes(x=D.PARK, ymin = nb_gam_SELOW, ymax = nb_gam_SEUP), alpha=0.3, color="green") + geom_point(data = kill, aes(x=D.PARK, y=TOT.N)) + geom_hline(yintercept=0) 


# Задание
# Постройте график, предсказывающий, согласно модели M6, количество раздавленных амфибий в зависимости от величины открытого пространства (OPEN.L)








# Валидация модели 


Resid_M6 <- resid(M6, type = "pearson")
N <- nrow(kill)
p <- length(coef(M6)) 
fi <- sum(Resid_M6^2) / (N - p)
fi

M6_diag <- data.frame(Fit_M6 = fitted(M6), Res_M6 = residuals(M3, type="pearson"))

ggplot(M6_diag, aes(x=Fit_M6, y=Res_M3)) + geom_point() + geom_hline(yintercept=0)


# Необходимо рассмотреть связь остатков с другими ковариатами
ggplot(kill, aes(x=OPEN.L, y=Resid_M6)) + geom_point() 
ggplot(kill, aes(x=POLIC, y=Resid_M6)) + geom_point()
ggplot(kill, aes(x=D.WAT.COUR, y=Resid_M6)) + geom_point() 

# и т.д.

# В целом, все смотрится более или менее прилично

# Но...

############################
# ЧАСТЬ 5
# Смешанные аддитивные модели 
############################

acf(Resid_M6)
# Наблюдается явная пространственная автокорреляция остатков


ggplot(kill, aes(x=X, y=Y)) + geom_point(aes(size = Resid_M5_final_nb))



# Вариограмма - это еще один инструмент для выявленения зависимостей между остатками 

M7 <- gamm(TOT.N ~ s(D.PARK) , data = kill, family = nb)

M7Var <- Variogram(M7$lme, form = ~ D.PARK, data = kill)

plot(M7Var)




# Корреляционные струкутры, применимые для временных рядов (время идет в одном направлении) 
cs1 <- corCompSymm(form = ~ D.PARK)

cs2 <- corAR1(form = ~ D.PARK)


# Корреляционные струкутры, применимые для пространственных данных (пространство изменяется в любом направлении) 

#Все эти корреляционные структуры можно еще настраивать, меняя некоторые параметры 

cs3 <- corGaus(form = ~ D.PARK)

cs4 <- corExp(form = ~ D.PARK)

cs5 <- corSpher(form = ~ D.PARK)

cs6 <- corRatio(form = ~ D.PARK)

cs7 <- corLin(form = ~ D.PARK)




M8_cs1 <- gamm(TOT.N ~ s(D.PARK), data = kill, family = nb, correlation = cs1 )

M8_cs2 <- gamm(TOT.N ~ s(D.PARK) , data = kill, family = nb, correlation = cs2 )

M8_cs3 <- gamm(TOT.N ~ s(D.PARK) , data = kill, family = nb, correlation = cs3 )

M8_cs4 <- gamm(TOT.N ~ s(D.PARK) , data = kill, family = nb, correlation = cs4 )

M8_cs5 <- gamm(TOT.N ~ s(D.PARK) , data = kill, family = nb, correlation = cs5 )

M8_cs6 <- gamm(TOT.N ~ s(D.PARK) , data = kill, family = nb, correlation = cs6 )

M8_cs7 <- gamm(TOT.N ~ s(D.PARK) , data = kill, family = nb, correlation = cs7 )

AIC(M7$lme, M8_cs1$lme, M8_cs2$lme, M8_cs3$lme, M8_cs4$lme, M8_cs5$lme, M8_cs6$lme, M8_cs7$lme )

summary(M8_cs1$gam)
summary(M8_cs1$lme)


# Результаты подгонки GAMM c корреляционной структурой и без нее
ggplot(kill, aes(x=X, y=Y)) + geom_point(aes(size= residuals(M8_cs1$gam,type="pearson"))) + geom_point(data=kill, aes(x=X+400, y=Y, size= residuals(M7$gam,type="pearson")))

AIC(M7$lme,M8_cs1$lme)
