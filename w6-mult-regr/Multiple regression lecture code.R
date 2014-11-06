# Введение в регрессионный анализ: Множественная регрессия
# Вадим Хайтов
# Осень 2014
---------------------------------

# Читаем данные 
plant <- read.csv("paruelo.csv")
plant <- plant[,-2]
head(plant)


# Корреляция между всем изученными параметрами

cor(plant)

# Исследование данных
library(car)
scatterplotMatrix(plant[,-2], spread=FALSE)


# Задание. Напишите самостоятельно R код, необходимый для подбора уравнения множественной регрессии и сразу проверьте модель на наличие автокорреляции остатков

# Здесь будет ваш код







# Разделяем датасет на два подмножества

plant1 <- plant[order(plant$LAT), ] # Упорядочиваем описания в соответствии с широтой

include <- seq(1, 73, 2) # Отбираем каждое второе описание
exclude <- seq(1, 73) [!(seq(1, 73) %in% include)] # Исключаем из списка отобранные описания

plant_modelling <- plant1[include, ]
plant_testing <- plant1[exclude, ]



# Строим линейную модель для сокращенного набора данных

model1 <- lm((C3)^(1/4) ~  MAP + MAT + JJAMAP + DJFMAP, data = plant_modelling)

durbinWatsonTest(model1, max.lag = 3)

# Проверяем валидность модели

library(ggplot2)

c3_diag <- fortify(model1)

pl_resid <- ggplot(c3_diag, aes(x = .fitted, y = .stdresid, size = .cooksd)) + 
  geom_point() + 
  geom_smooth(se=FALSE) + 
  geom_hline(eintercept=0)

pl_resid


# Проверяем на нормальность 

qqPlot(model1)


# Проверяем на гетероскедастичность
library(lmtest)
bptest(model1)


# Проверяем на мультиколлинеарность
vif(model1)

model2 <- update(model1, ~ . -DJFMAP)
vif(model2)

summary(model2)

# Здесь будет ваш код











model2_scaled <- lm((C3)^(1/4) ~ scale(MAP) + scale(MAT) + scale(JJAMAP), data = plant_modelling)
summary(model2_scaled)


predicted_C3_model2 <- predict(model2, newdata=plant_testing)
cor(predicted_C3_model2, plant_testing$C3)

urbinWatsonTest(model2_scaled)
bptest(model2_scaled)
vif(model2_scaled)
