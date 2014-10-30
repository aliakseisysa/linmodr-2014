# Вам понадобятся пакеты ggplot2, ppcor


options(digits=3)
brain <- read.csv("IQ_brain.csv", header = T)

#Здесь должен появиться Ваш код



# Вычисляем частные корреляции 
library(ppcor)
brain_complete <- brain[complete.cases(brain),]
pcor.test(brain_complete$PIQ, brain_complete$MRINACount, brain_complete$Height, )



# Подбираем модель для зависимост IQ от размера головного мозга
brain_model <- lm(PIQ ~ MRINACount, data = brain)
brain_model

#Здесь должен появиться Ваш код для ответа на следующие вопросы
# 1. Чему равны угловой коэффициент и свободный член полученной модели brain_model?



# 2. Какое значеие IQ-теста предсказывает модель для человека с объемом  мозга равным 900000 




# 3. Чему равно значение остатка от модели для человека с порядковым номером 10 






# Проводим более детальный анализ модели
summary(brain_model)

# Графическое представление результатов. Постройте график при разных значениях параметра level
library(ggplot2)
pl_brain + geom_smooth(method="lm", level=0.95) 



# Оцениваем ожидаемое значение IQ для человека с заданным размером головного мозга

newdata <- data.frame(MRINACount = 900000)

predict(brain_model, newdata, interval = "confidence", level = 0.95, se = TRUE)


# Отражаем на графике область значений, в которую попадут 95% предсказанных величин IQ

# Подготавлваем данные
brain_predicted <- predict(brain_model, interval="prediction")
brain_predicted <- data.frame(brain, brain_predicted)
head(brain_predicted)

# Отражаем на графике область значений, в которую попадут 95% предсказанных величин IQ
pl_brain + 
  geom_ribbon(data=brain_predicted, aes(y=fit, ymin=lwr, ymax=upr, fill = "Conf. area for prediction"), alpha=0.2) + 
  geom_smooth(method="lm", aes(fill="Conf.interval"), alpha=0.4) + 
  scale_fill_manual("Intervals", values = c("green", "gray")) + 
  ggtitle("Confidence interval \n and confidence area for prediction")


