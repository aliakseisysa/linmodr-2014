#---- Загрузка пакетов и настройка
# Для графиков
library(ggplot2)
theme_set(theme_bw(base_size = 16) +
            theme(legend.key = element_blank()))
update_geom_defaults("point", list(shape = 19, size = 3))
# для смешанных моделей
library(nlme)

#----- Загрузка данных -----
# Пример: разные способы определения возраста китообразных
cet <- read.table("cetaceans.csv", header = TRUE, sep = "\t")

#---- I. Знакомство с данными -----
head(cet, 3)
str(cet)

# Факторы
cet$DolphinID <- factor(cet$DolphinID)
cet$Sex <- factor(cet$Sex)

# у некоторых не определен пол
levels(cet$Sex)
# исключаем их из анализа
cet2 <- cet[cet$Sex != "0", ]

# Сколько всего точек данных?
sum(complete.cases(cet2))

# Какие объемы выборок в группах
with(cet2, table(Species, Location))
with(cet2, table(Species, Stain))
with(cet2, table(interaction(Species, Location), Stain))
# Два вида встречаются только в Шотландии, два только в Испании
# Препараты красили тремя красками, вне зависимости от локации

# Диапазон и разброс возрастов для разных видов
ggplot(cet2, aes(x = Species, y = Age)) + geom_boxplot(aes(fill = Stain)) + facet_wrap(~Location, scales = "free_x", ncol = 1)
ggplot(cet2, aes(x = DolphinID, y = Age)) + geom_boxplot() + facet_wrap(~Location, scales = "free_x", ncol = 1)

#---- 1. Подбор смешанной модели -----

F1 <- formula(Age ~ Stain + Location + Stain : Location)
F1 <- formula(Age ~ Stain * Location)
M1 <- lme(F1, random =~1 | Species/DolphinID,
          data = cet2, method="ML")
summary(M1)

# Все ли в порядке с моделью? Анализ остатков

# 1) График остатков от предсказанных значений
plot(M1)
cet2$.stdresid <- resid(M1, type = "n")
cet2$.fitted <- fitted(M1)
ggplot(cet2, aes(x = .fitted, y = .stdresid)) + geom_point()
# Есть большие остатки, намек на гетерогенность дисперсий

# 2) График остатков от ковариат в модели
p <- ggplot(cet2, aes(y = .stdresid))
p + geom_jitter(aes(x = Location), width = 0.5) + aes(colour = Stain)
p + geom_boxplot(aes(x = Location))
p + geom_boxplot(aes(x = Stain)) + facet_wrap(~ Location)
p + geom_jitter(aes(x = Stain, colour = Age)) + facet_wrap(~ Location)
# Есть два больших остатка, все в Испании
# В Шотландии разброс остатков разный между тремя красителями
# Гетерогенность дисперсий:
# Разброс остатков меняется между локациями
# По-видимому, разброс остатков зависит от возраста дельфина

# 3) График остатков от ковариат не вошедших в модель (нет ли других нужных переменных?), если есть
# 4) График остатков от времени, если есть
# 5) График остатков от координат проб, если есть

# Боремся с гетерогенностью дисперсий - пробуем разные структуры ковариационной матрицы

# Name of the
# function in R       What does it do?
#
# VarFixed        Fixed variance
# VarIdent        Different variances per stratum
# VarPower        Power of the variance covariate
# VarExp          Exponential of the variance covariate
# VarConstPower   Constant plus power of the variance covariate
# VarComb         A combination of variance functions

# 1) Дисперсия - функция от возраста - Не сходится
# epsilon_i ∼ N(0, sigma^2 * Age_i) 1.103388
# M2 <- update(M1, weights = varFixed(~Age))

# 2) Дисперсия у каждого своя
M2 <- update(M1, weights = varIdent(form = ~1 | Location))
# epsilon_ij ∼ N(0, sigma^2 _j), где j - локация
summary(M2)
# Variance function:
#   Structure: Different standard deviations per stratum
# Formula: ~1 | Location
# Parameter estimates:
#   Scotland    Spain
# 1.000000 1.590845

M3 <- update(M1, weights = varIdent(form = ~1 | Species)) #
# epsilon_ij ∼ N(0, sigma^2 _j), где j - вид
summary(M3)
# Variance function:
#   Structure: Different standard deviations per stratum
# Formula: ~1 | Species
# Parameter estimates:
#   Delphinusdelphis    1.000000
# Lagenorhynchusacutus  1.724325
# Phocoenaphocoena      1.103388
# Stenellacoeruleoalba  1.734151
# Stenellafrontalis     1.295338
# Tursiopstruncatus     2.635201


# 3) Дисперсия - степенная функция
# epsilon_ij ∼ N (0,  sigma^2 * abs(Covariate)^(2*delta)
# Здесь не сходится с ковариатой
M4 <- update(M1, weights = varPower())
summary(M4)
# Variance function:
#   Structure: Power of variance covariate
# Formula: ~fitted(.)
# Parameter estimates:
#   power
# 0.6657189


# 4) Дисперсия меняется экспоненциально в зависимости от возраста, независимо между локациями
# epsilon_ij ∼ N (0,  sigma^2 * exp(2*delta*Age_i)
M5 <- update(M1, weights = varExp(form = ~Age | Location))
summary(M5)
# Variance function:
#   Structure: Exponential of variance covariate, different strata
# Formula: ~Age | Location
# Parameter estimates:
#   Scotland     Spain
# 0.1797656 0.1434080

# Сравниваем модели с разными структурами ковариаций
AIC(M1, M2, M3, M4, M5)
# M5 лучше всех


#----- 2. Какие из фиксированных факторов влияют? -----
# Один из трех вариантов:

#A. По значениям t-(или -z) статистики (REML оценка)
# приблизительный результат
# годится для факторов, если не больше 2 уровней
# summary(M5.reml)
# здесь не годится - у красителя больше 2 уровней

#B. F-критерий - приблизительный результат (REML оценка)
# зависит от порядка включения предикторов в модель
# anova(M5.reml)
# Не годится, т.к. несколько предикторов

#C. likelihood ratio test или AIC (ML оценка)
# Один из двух вариантов:

# С.1. Попарное сравнение вложенных моделей при помощи likelihood ratio test дает более точные выводы, чем F и t(z)
F1
# На первом этапе не можем начать с Stain или Location, потому что есть взаимодействие
# Сначала пробуем исключить взаимодействие факторов
M5.1 <- update(M5, . ~ . - Stain:Location)
anova(M5, M5.1)
# Без взаимодействия модель становится хуже, придется его оставить
# (L = 12.69, df = 2, p < 0.01)

# С.2. Сравнение моделей по AIC
AIC(M5, M5.1)
# Без взаимодействия модель становится хуже (AIC больше), придется его оставить

#----- 3. Представление результатов -----

# REML оценка параметров (более точна)
MFinal <- lme(F1, random= ~1 | Species/DolphinID, method = "REML", weights = varExp(form = ~Age | Location), data = cet2)

summary(MFinal)

# Проверка финальной модели (те же графики, что и в п.1)
# 1) График остатков от предсказанных значений
plot(MFinal)
cet2$.stdresid <- resid(MFinal, type = "n")
cet2$.fitted <- fitted(MFinal)
ggplot(cet2, aes(x = .fitted, y = .stdresid)) + geom_point()
# Есть большие остатки, намек на гетерогенность дисперсий

# 2) График остатков от ковариат в модели
p <- ggplot(cet2, aes(y = .stdresid))
p + geom_jitter(aes(x = Location), width = 0.5) + aes(colour = Stain)
p + geom_boxplot(aes(x = Location))
p + geom_boxplot(aes(x = Stain)) + facet_wrap(~ Location)
p + geom_jitter(aes(x = Stain, colour = Age)) + facet_wrap(~ Location)
# На вид стало немного лучше. Доверимся значениям AIC и поверим, что мы исправили ту небольшую гетерогенность, что была здесь

# 3) График остатков от ковариат не вошедших в модель (нет ли других нужных переменных?), если есть
# 4) График остатков от времени, если есть
# 5) График остатков от координат проб, если есть

#----- Внутриклассовая корреляция -----
# Random effects:
#   Formula: ~1 | Species
# (Intercept)
# StdDev:    1.568494
#
# Formula: ~1 | DolphinID %in% Species
# (Intercept)  Residual
# StdDev:    4.999528 0.2194995

# Насколько похожи оценки возраста одного дельфина?
sds <- c(1.568494, 4.999528, 0.2194995)
4.999528 / sum(sds)
# Оценки возраста одного и того же дельфина разными методами очень похожи

# Насколько похожи оценки возраста особей одного вида?
1.568494 / sum(sds)
# Не так похожи

#----- Структура ковариаций -----
summary(MFinal)
# Variance function:
#   Structure: Exponential of variance covariate, different strata
# Formula: ~Age | Location
# Parameter estimates:
#   Scotland     Spain
# 0.1758778 0.1408924

ggplot(cet2, aes(x = DolphinID, y = Age, fill = Species)) + geom_boxplot() + facet_wrap(~Location, scales = "free_x", ncol = 2)

#----- Компоненты дисперсии (Variance components)-----

# Доля общей дисперсии, связанная с фактором
vars <- sds^2
100 * vars / sum(vars)
# Большая изменчивость связана с видами, а индивидуальные оценки возраста особей разными способами очень похожи

#---- График предсказанных значений для результатов -----

# 1) Создаем новый датафрейм, для которого будем предсказывать
new_data <- expand.grid(Stain = levels(cet2$Stain),
                        Location = levels(cet2$Location))

# 2) Матрица линейной модели
X <- model.matrix(~ Stain*Location, data = new_data)

# 3) Вычисляем предсказанные значения одним из двух способов
# level = 0 - для фиксированных эффектов (т.е. без учета пляжа)
new_data$.fitted <- predict(MFinal, new_data, level = 0)
# или то же самое при помощи матриц
# Y = X * BETA
# BETA = fixef(MFinal) # это вектор значений коэффициентов при фикс. факторах
# т.е. предсказанные значения по фикс. части модели:
new_data$.fitted <- X %*% fixef(MFinal)

# 4) Вычисляем стандартные ошибки предсказанных значений
# это квадратный корень из диагональных элементов
# матрицы ковариаций предсказанных значений X * cov(BETA) * t(X)
new_data$.se <- sqrt( diag(X %*% vcov(MFinal) %*% t(X)) )

# 5) Строим график предсказанных значений
head(new_data)
# a) график где по одной точке для каждого уровня фактора,
# +/- 95% доверит. интервал (1.98 * стандартная ошибка, которая учитывает различия между пляжами)
ggplot(new_data) +
  geom_jitter(data = cet2,
              aes(x = Stain,
                  y = Age,
                  colour = Species),
              alpha = 0.5) +
  facet_wrap(~Location) +
  geom_pointrange(data = new_data,
                  aes(x = Stain,
                      y = .fitted,
                      ymin = .fitted - 1.98 * .se,
                      ymax = .fitted + 1.98 * .se))

#----- Задание ------
# Подберите оптимальную модель для(из) данной полной модели
F2 <- formula(Age ~ Stain * Location * Sex)
F21 <- formula(Age ~ Stain + Location + Sex +
                Stain:Location + Stain:Sex + Location:Sex)
#---
F22a <- formula(Age ~ Stain + Location + Sex +
                 Stain:Sex + Location:Sex)
F22b <- formula(Age ~ Stain + Location + Sex +
                  Stain:Location + Location:Sex)
F22c <- formula(Age ~ Stain + Location + Sex +
                  Stain:Location + Stain:Sex)
#---
F23 <- formula(Age ~ Stain + Location + Sex +
                  Stain:Sex)
F23 <- formula(Age ~ Stain + Location + Sex +
                  Stain:Location)
#---
F24 <- formula(Age ~ Stain + Location +
                 Stain:Location)
F24 <- formula(Age ~ Stain + Location + Sex)
#---
F25 <- formula(Age ~ Stain + Location +
                 Stain:Location)


