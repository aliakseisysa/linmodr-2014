# ---
# title       : Дисперсионный анализ, часть 2
# subtitle    : Линейные модели, осень 2014
# author      : Марина Варфоломеева
# job         : Каф. Зоологии беспозвоночных, СПбГУ
# ---
# Многофакторный дисперсионный анализ в R
## Пример: Возраст и память
# Почему пожилые не так хорошо запоминают? Может быть не так тщательно перерабатывают информацию? (Eysenck, 1974)
# Факторы:
# - `Age` - Возраст:
#   - `Younger` - 50 молодых
#   - `Older` - 50 пожилых (55-65 лет)
# - `Process` - тип активности:
#   - `Counting` - посчитать число букв
#   - `Rhyming` - придумать рифму к слову
#   - `Adjective` - придумать прилагательное
#   - `Imagery` - представить образ
#   - `Intentional` - запомнить слово
# Зависимая переменная - `Words` - сколько вспомнили слов

memory <- read.delim(file="eysenck.csv")
library(ggplot2)
theme_set(theme_bw() + theme(legend.key = element_blank()))
ggplot(data = memory, aes(x = Age, y = Words)) +
  geom_boxplot(aes(fill = Process))



# переставляем порядок уровней в порядке следования
# средних значений `memory$Words`
memory$Process <- reorder(memory$Process, memory$Words, FUN=mean)
mem_p <- ggplot(data = memory, aes(x = Age, y = Words)) +
  geom_boxplot(aes(fill = Process))
mem_p

## Таблица результатов многофакторного дисперсионного анализа
# Внимание: при использовании III типа сумм квадратов, нужно __обязательно указывать тип контрастов для факторов__. В данном случае - `contrasts=list(Age=contr.sum, Process=contr.sum)`
memory_fit <- lm(formula = Words ~ Age * Process, data = memory,
                 contrasts=list(Age=contr.sum, Process=contr.sum))

## Задание: Проверьте условия применимости дисперсионного анализа



## Результаты дисперсионного анализа
Anova(memory_fit, type = 3)



## Пост хок тест
# создаем переменную-взаимодействие
memory$AgeProc <- interaction(memory$Age, memory$Process)
# подбираем модель без intercept
mod <- lm(Words ~ AgeProc - 1, data = memory)
library(multcomp)
memory_tukey <- glht(mod, linfct = mcp(AgeProc = "Tukey"))
options(width = 90)
summary(memory_tukey)


## Данные для графиков
# Задание
# Посчитайте средние и стандартные отклонения во всех группах по факторам `Age` и `Process`
library(dplyr)
memory_summary <- memory %>%


## Графики для результатов: Столбчатый график
mem_barp <- ggplot(data = memory_summary,
                   aes(x = Age, y = .mean, ymin = .mean - .sd,
                       ymax = .mean + .sd, fill = Process)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_errorbar(width = 0.3, position = position_dodge(width = 0.9))
mem_barp


## Графики для результатов: Линии с точками
pos <- position_dodge(width = 0.9)
mem_linep <- ggplot(data = memory_summary,
                    aes(x = Age, y = .mean, ymin = .mean - .sd,
                        ymax = .mean + .sd, colour = Process,
                        group = Process)) +
  geom_point(size = 3, position = pos) +
  geom_line(position = pos) +
  geom_errorbar(width = 0.3, position = pos)
mem_linep

## Какой график лучше выбрать?
library(gridExtra)
grid.arrange(mem_barp, mem_linep, ncol = 2)

## Приводим понравившийся график в приличный вид
mem_linep <- mem_linep + labs(x = "Возраст",  y = "Число запомненных слов") +
  scale_x_discrete(labels = c("Пожилые", "Молодые")) +
  scale_colour_brewer(name = "Процесс", palette = "Dark2",
                      labels = c("Счет", "Рифма", "Прилагательное",
                                 "Образ", "Запоминание")) +
  theme(legend.key = element_blank())
mem_linep
