# ---
# title       : Дисперсионный анализ
# subtitle    : Линейные модели, осень 2014
# author      : Марина Варфоломеева
# ---
## Пример: яйца кукушек
library(DAAG)
data(cuckoos)
levels(cuckoos$species)
levels(cuckoos$species) <- c("лес_зав", "луг_кон", "бел_тряс", "малин", "лес_кон", "крапив")

## Задание: Постройте график зависимости размера
#яиц кукушек от вида птиц-хозяев, в гнездах
#которых были обнаружены яйца. Какой геом лучше
#подойдет для изображения (`geom_point`,
#`geom_boxplot`)?
library(ggplot2)
p <- ggplot(data = cuckoos, aes(x = species, y = length))
library(gridExtra)
grid.arrange(p+geom_boxplot(aes(colour = species)),
             p+geom_point(aes(fill = species)),
             p+geom_jitter(width = 0.5),
             ncol = 1)
gg_box <- p+geom_boxplot(aes(colour = species))

# Раскрасьте график в зависимости от вида
# птиц-хозяев (используйте эстетики `fill` или
# `colour` - чем отличаются результаты?)

### Дополнительное задание:

# Попробуйте сменить палитру раскраски, используя
# `scale_colour_brewer` Варианты можно посмотреть
# в справке в подразделе примеров или в интернете
# http://www.cookbook-r.com/Graphs/Colors_(ggplot2\)/#palettes-color-brewer

gg_box + scale_colour_brewer(palette = "Dark2")
gg_box + scale_colour_brewer(palette = "Set1")

#Дисперсионный анализ - это линейная модель #
#Вопрос: В каком виде включаются дискретные
#предикторы в линейную модель?


## Модель фиктивных переменных # Задание:
#Подберите линейную модель зависимости длины яиц
#кукушек в гнездах от вида птиц-хозяев Что значат
#коэффициенты этой линейной модели? Помните ли вы,
#как изменить уровень, который считается базовым?

fit <- lm(length ~ species, data = cuckoos)
summary(fit)
levels(cuckoos$species)

cuckoos$species_r <- relevel(cuckoos$species, "крапив")

fitr <- lm(length ~ species_r, data = cuckoos)
summary(fitr)

## Модель эффектов
options('contrasts')
options(contrasts = rep("contr.sum", 2))

mod1 <- lm(length ~ species, data=cuckoos)
summary(mod1)


# Собственно дисперсионный анализ: влияет ли фактор целиком
library(car)
cuckoos_anova <- Anova(fit)
cuckoos_anova

## Вопрос: Назовите условия применимости
#дисперсионного анализа. Подсказка: дисперсионный
#анализ - линейная модель, как и регрессия


## Задание: Проверьте условия применимости

residualPlots(fit)
qqPlot(fit)

## Мы узнали, что фактор влияет, т.е. какие-то
#пары средних различаются. Теперь хотим узнать,
#какие именно группы различаются
## Пост-хок тест Тьюки в R
library(multcomp)
cuckoos_pht <- glht(fit, linfct = mcp(species = "Tukey"))
summary(cuckoos_pht)

# Представление результатов
## Таблица с описательной статистикой по группам
### Код с `dplyr`
library(dplyr)
cuckoos_summary <- cuckoos %>%
  group_by(species) %>%
  summarise(n = n(),
            mean = mean(length),
            variance = var(length),
            sd = sd(length))
cuckoos_summary



### Код только с базовыми функциями
cuckoos_summary <- aggregate(length ~ species, data = cuckoos,
          FUN = function(x) {
            c(n = length(x), mean=mean(x),
              variance = var(x), sd=sd(x))
            }
          )
colnames(cuckoos_summary) <- c("species", "n", "mean", "variance", "sd")

## Столбчатый график
gg_means <- ggplot(cuckoos_summary,
                   aes(x = species, y = mean)) +
  geom_bar(stat = "identity", width = 0.5) +
  geom_errorbar(aes(ymin = mean - sd,
                    ymax = mean + sd),
                width = 0.2) +
  labs(x = "Вид птиц-хозяев",
       y = "Длина яиц кукушек")
gg_means


ggplot(cuckoos_summary,
       aes(x = species, y = mean, fill = species)) +
  geom_bar(stat = "identity", width = 0.5) +
  geom_errorbar(aes(ymin = mean - sd,
                    ymax = mean + sd),
                width = 0.2) +
  labs(x = "Вид птиц-хозяев",
       y = "Длина яиц кукушек",
       fill = "Вид птиц-хозяев")


gg_means <- gg_means %+% aes(fill = species)
gg_means %+% aes(colour = species, fill = species)

## Можно привести результаты пост-хок теста на столбчатом графике
gg_means_coded <- gg_means +
  geom_text(aes(y = 1.5,  label = c("A", "B", "A", "A", "A", "C")), colour = "white", size = 10)
gg_means_coded

## Если не нравится, как висят столбцы, можно настроить развертку оси $y$
gg_means_coded + scale_y_continuous(expand = c(0,0), limits = c(0, 25))

## И наконец, можно переименовать уровни фактора species прямо внутри графика
gg_means_coded + scale_y_continuous(expand = c(0,0), limits = c(0, 25)) +
  scale_x_discrete(labels = c("Лесная\nзавирушка", "Луговой\nконек", "Белая\nтрясогузка", "Малиновка", "Лесной\nконек", "Крапивник")) +
  scale_fill_discrete(labels = c("Лесная\nзавирушка", "Луговой\nконек", "Белая\nтрясогузка", "Малиновка", "Лесной\nконек", "Крапивник"))


## Сохраняем таблицу дисперсионного анализа в файл
# 1) в csv
write.table(file = "cuckoos_res.csv", x = cuckoos_anova, sep = "\t")

# 2) в xls или xlsx с помощью XLConnect
# library(XLConnect)
# writeWorksheetToFile(data = cuckoos_anova, file = "cuckoos_res.xls", sheet = "anova_table")

# 3) или отправляем в буфер обмена (только Windows) для вставки в Word-Excel
write.table(file = "clipboard", x = cuckoos_anova, sep = "\t", row.names = FALSE)
