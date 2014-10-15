# ---
# title       : Анализ мощности
# subtitle    : Линейные модели, осень 2014
# author      : Марина Варфоломеева
# job         : Каф. Зоологии беспозвоночных, СПбГУ

# A priory анализ мощности

## Величина эффекта из общих соображений

# сильные, умеренные и слабые эффекты
library(pwr)
cohen.ES(test = "t", size = "large")

# ## Задача:
# Рассчитайте величину умеренных и слабых эффектов для t-критерия
#     library()
#     cohen.ES()
# Обозначения можно посмотреть в файлах справки
#     help(cohen.ES)
#     ?cohen.ES
#     cohen.ES # курсор на слове, нажать F1



## Величина эффекта из пилотных данных

## Пример: Заповедник спасает халиотисов * Лов халиотисов
#(коммерческий и любительский) запретили, организовав заповедник.
#Стало ли больше моллюсков через несколько лет? (Keough, King, 1991)

alpha <- 0.05
power <- 0.80
sigma <- 27.7 # варьирование плотности халиотисов
diff <- 23.2 # ожидаемые различия плотности халиотисов
(effect <- diff/sigma) # величина эффекта

## Считаем объем выборки
# Функции для анализа мощности t-критерия
# - при одинаковых объемах групп `pwr.t.test()`
# - при разных объемах групп `pwr.t2n.test()`
pwr.t.test(n = NULL, d = effect, power = power,
           sig.level = alpha, type = "two.sample",
           alternative = "two.sided")

# ## Задача:
# Рассчитайте сколько нужно обследовать мест, чтобы обнаружить слабый эффект
# с вероятностью 0.8, при уровне значимости 0.01
#     cohen.ES()
#     pwr.t.test()


## Пример: Улитки на устрицах в мангровых зарослях (Minchinton, Ross,
#1999) Сколько нужно проб, чтобы показать, что плотность улиток
#различается между сайтами?

## Читаем данные из файла
# Не забудте сначала войти в вашу директорию для матметодов
# Чтение из csv
minch <- read.table("./data/minch.csv",
                    header = TRUE, sep = "\t")
# Чтение из xls
# library(XLConnect)
# minch <- readWorksheetFromFile("./data/minch.xls",
#                                sheet = 1)

## Боксплот числа улиток в двух сайтах
library(ggplot2)
gglimp <- ggplot(data = minch, aes(x = site, y = limpt100))
gglimp + geom_boxplot()

## Раскрашиваем график
# эстетика `fill`
gglimp + geom_boxplot(aes(fill = site))

# ## Задание: Поэкспериментируйте с эстетиками
# Чем отличаются результаты применения эстетик `fill` и `colour`?
# ggplot()
# aes()
# geom_boxplot()

## Не нравится тема? Можно привинтить другую! `theme_bw()`,
#`theme_classic()`, `theme_grey()`, `theme_minimal()`, `theme_light()`
gglimp + geom_boxplot(aes(fill = site)) + theme_classic()

# Можно установить для всех последующих графиков `theme_set()`
theme_set(theme_bw()) # тема до конца сеанса
gglimp + geom_boxplot(aes(fill = site))

# A priory анализ мощности по данным пилотного исследования

# Величина эффекта по исходным данным
library(effsize)
effect <- cohen.d(minch$limpt100, minch$site)
effect

# ## Задача: # Рассчитайте объем выборки, чтобы показать различия
# плотности улиток между сайтами с вероятностью 0.8? pwr.t.test()

# Post hoc анализ мощности

## На самом деле различия действительно не были найдены
t.test(limpt100 ~ site, data = minch,
       var.equal = FALSE)
# Какова была реальная величина эффекта?
effect_real <- cohen.d(minch$limpt100, minch$site)
effect_real <- abs(effect_real$estimate)

# Хватило ли нам мощности, чтобы выявлять такие незначительные
# различия?
pwr.t.test(n = 20, d = effect_real,
           power = NULL, sig.level = 0.05,
           type = "two.sample",
           alternative = "two.sided")
