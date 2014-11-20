# ---
# title       : Регрессионный анализ для бинарных данных
# subtitle    : Линейные модели, осень 2014
# author      : Вадим Хайтов
# job         : Каф. Зоологии беспозвоночных, СПбГУ
# ---


# Читаем данные 
liz <- read.csv("polis.csv")
head(liz)


# Подбираем модель методом максимального правдоподобия
liz_model <- glm(PA ~ PARATIO , family="binomial", data = liz)
summary(liz_model)

# Значение функции правдоподобия
logLik(liz_model)

#Остаточная девианса
Dev_resid <- -2*as.numeric(logLik(liz_model))

#Нулевая девианса
Dev_nul <- -2*as.numeric(logLik(update(liz_model, ~ - PARATIO)))

# Вычисляем критерий G^2
G2 <- Dev_nul - Dev_resid

# Если G2 подчиняется распредеелению Chisq, то можно "вручную" оценить вероятность того, что любое другое значение из той де генеральной совокупности окажется больше эмпирического G2  

1 - pchisq (G2, 1)

# Все то же самое, но с помощью функции anova()
anova(liz_model, test="Chi")

# Вытащим из результатов anova() значение уровня значимости
str(anova(liz_model, test="Chi"))

anova(liz_model, test="Chi")$"Pr(>Chi)"

# Вычислите значеие критерия Акаике
# Здесь будет ваше решение




# Смотрим на коэффициенты модели
coef(liz_model)


exp(coef(liz_model)[2])


# Строим график логистической регрессии

ggplot(liz, aes(x=PARATIO, y=PA)) + geom_point() + 
  geom_smooth(method="glm", family="binomial", se=TRUE) + 
  ylab("Predicted probability of presence") + xlab("Island parameters (PARATIO")


# Читаем днные прреанимацию
surviv <- read.table("ICU.csv", header=TRUE, sep=";")
head(surviv)

# Строим модель
surv_model <- glm(STA ~ . , family = "binomial", data = surviv)
summary(surv_model)

# Анализ девиансы
anova(surv_model, test="Chi")


# Строим сокращенную модель

surv_model_reduced <- glm(STA ~ AGE + TYP + PH + PCO + LOC, family = "binomial", data = surviv)


# Сравниваем полную и редуцированную модель
anova(surv_model, surv_model_reduced, test = "Chi")

# Сравниваем AIC моделей
AIC(surv_model, surv_model_reduced)


summary(surv_model_reduced)


ggplot(surviv, aes(x=AGE, y=STA)) +   geom_point() +    geom_smooth(method="glm", family="binomial", se=TRUE) +   ylab("Predicted probability of death") + xlab("Age")

