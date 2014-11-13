# ---
# title       : Линейные модели, содержащие непрерывные и дискретные предикторы
# subtitle    : Линейные модели, осень 2014
# author      : Вадим Хайтов
# job         : Каф. Зоологии беспозвоночных, СПбГУ
# ---

# Читаем данные
tv <- read.csv("eyecolorgenderdata.csv", header = TRUE)
head(tv)


# Отржаем связь между зависимой переменной и значениями предиктора 
library(ggplot2)
ggplot(tv, aes(x = year, y = log(watchtv + 1)))  +   geom_boxplot(color = "red") + geom_point(size=0.5) +   geom_jitter(position = position_jitter(width = 0.1)) +   stat_summary(fun.y=mean, colour="blue", geom="point", size=5, show_guide = FALSE)

# Строим линейую модель, связывающую зависимую переменную и предиктор
tv_model1 <- lm(watchtv ~ year, data = tv)
summary(tv_model1)

# Дисперсионный анализ по модели
anova(tv_model1)

# Извлекаем коэффициенты из модели
coefficients(tv_model1)


# Задание: используя знание коэффициентов линейной модели, вычислите средние значения зависимой переменной для каждого уровня предиктора `year`
# Здесь будет ваше решение





# Расче средних значений для разных уровней предиктора

means <- function(x) mean(x, na.rm=TRUE)

mean_year <- tapply(tv$watchtv, tv$year, FUN = means)
mean_year


# Меняем базовый уровень

tv_model2 <- lm(watchtv ~ relevel(year, ref="other"), data = tv)
coefficients(tv_model2)


summary(tv_model2)



# Диагностика модели

library(car)
residualPlots(tv_model1)

tv_model_diag <- fortify(tv_model1)
head(tv_model_diag)

# Строим модель, включающую дискретные и нпрерывные предикоры
tv_model3 <- lm(watchtv ~  age + miles + gender + year, data = tv)
summary(tv_model3)





# Читаем данные про коз
goat <- read.csv("Goat_treatment_1.csv")


# Строим модель дя ANCOVA
goat_model_cov <- lm(Weightgain ~ Treatment + Initial_wt, data = goat)
summary(goat_model_cov)

ggplot(goat, aes(x = Initial_wt, y = Weightgain, color = Treatment)) + geom_point(size=3) + geom_smooth(method = "lm", se = FALSE, size=2) 