---
title       : Дисперсионный анализ, часть 2
subtitle    : Линейные модели, осень 2014
author      : Марина Варфоломеева
job         : Каф. Зоологии беспозвоночных, СПбГУ
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : idea      # 
widgets     : [mathjax]            # {mathjax, quiz, bootstrap}
mode        : standalone # {selfcontained, standalone, draft}
---

## Многофакторный дисперсионный анализ

- Модель многофакторного дисперсионного анализа
- Взаимодействие факторов
- Несбалансированные данные, типы сумм квадратов
- Многофакторный дисперсионный анализ в R

### Вы сможете

- Проводить многофакторный дисперсионный анализ и интерпретироваот его результаты с учетом взаимодействия факторов



--- .segue

# Модель многофакторного дисперсионного анализа

---

## Линейные модели для факторных дисперсионных анализов

- Два фактора A и B, двухфакторное взаимодействие

$y _{ijk} = \mu + \alpha _i + \beta _j + (\alpha \beta) _{ij} + \epsilon _{ijk}$

<br /><br />

- Три фактора A, B и C, двухфакторные взаимодействия, трехфакторное взаимодействия

$y _{ijkl} = \mu + \alpha _i + \beta _j + \gamma _k + (\alpha \beta) _{ij} + (\alpha \gamma) _{ik} + (\beta \gamma) _{jk} + (\alpha \beta \gamma) _{ijk} + \epsilon _{ijkl}$

--- .segue

# Взаимодействие факторов

--- &twocol

## Взаимодействие факторов

Эффект фактора B разный в зависимости от уровней фактора A и наоборот

*** =left

На каких рисунках есть взаимодействие факторов?

>- b, c - нет взаимодействия 
- a, d - есть взаимодействие

*** =right

![Взаимодействие факторов](./assets/img/interaction.png "Взаимодействие факторов")

<div class = "footnote">Рисунок из Logan, 2010, fig.12.2</div>

---

## Влияют ли главные эффекты и взаимодействие?

![Взаимодействие факторов](./assets/img/interaction1a.png "Взаимодействие факторов")

> - взаимодействие достоверно, и не маскирует главные эффекты
- фактор А влияет
- фактор В влияет

<div class = "footnote">Рисунок из Quinn, Keough, 2002, fig.9.3</div>

---

## Влияют ли главные эффекты и взаимодействие?

![Взаимодействие факторов](./assets/img/interaction1b.png "Взаимодействие факторов")
> - взаимодействие достоверно и мешает интерпретировать влияние факторов отдельно:
    - для В2 зависимая переменная возрастает с изменением уровня А
    - для В1 зависимая переменная возрастает только на А2, но не различается на А1 и А3
> - если смотреть на главные эффекты, можно сделать неправильные выводы:
    - фактор А влияет, группы А2 и А3 не отличаются
    - фактор В влияет, в группе В2 зависимая переменная больше, чем в В1

<div class = "footnote">Рисунок из Quinn, Keough, 2002, fig.9.3</div>

---

## Влияют ли главные эффекты и взаимодействие?

![Взаимодействие факторов](./assets/img/interaction1c.png "Взаимодействие факторов")

> - взаимодействие достоверно и мешает интерпретировать влияние факторов отдельно:
    - А1В2, А3В2 и А2В1 не различаются, значение зависимой переменной в этих группах выше, чем в остальных
    - А1В1, А3В1 и А2В2 не различаются
> - если смотреть на главные эффекты, можно сделать неправильные выводы:
    - факторы А и В не влияют

<div class = "footnote">Рисунок из Quinn, Keough, 2002, fig.9.3</div>

--- &twocol

## Взаимодействие факторов может маскировать главные эффекты

*** =left

- Если есть значимое взаимодействие
  - главные эффекты обсуждать не имеет смысла  
  - пост хок тесты проводятся только для ваимодействия

*** =right

![Взаимодействие факторов](./assets/img/interaction1.png "Взаимодействие факторов")

<div class = "footnote">Рисунок из Quinn, Keough, 2002, fig.9.3</div>

---

## Задаем модель со взаимодействием в R

Взаимодействие обозначается `:` двоеточием

Если есть факторы A и B, то их взаимодействие A:B

Для такой модели $y _{ijk} = \mu + \alpha _i + \beta _j + (\alpha \beta) _{ij} + \epsilon _{ijk}$

### Полная запись

Y ~ A + B + A:B

### Сокращенная запись

обозначает, что модель включает все главные эффекты и их взаимодействия

Y ~ A*B

--- .segue

# Несбалансированные данные, типы сумм квадратов

--- &twocol

## Несбалансированные данные - когда численности в группах по факторам различаются

*** =left

Например так,

|    | A1 | A2 | A3 |
|----|----|----|----|
| B1 |  5 | 5  |  5 |
| B2 |  5 | 4  |  5 |

*** =right

или так,

|    | A1 | A2 | A3 |
|----|----|----|----|
| B1 |  3 | 8  |  4 |
| B2 |  4 | 7  |  4 |

---

## Проблемы несбалансированных дизайнов

> - Оценки средних в разных группах с разным уровнем точности (Underwood 1997)
- ANOVA менее устойчив к отклонениям от условий применимости (особенно от гомогенности дисперсий) при разных размерах групп (Quinn Keough 2002, section 8.3)
- Проблемы с рассчетом мощности. Если $\sigma _{\epsilon}^2 > 0$ и размеры выборок разные, то $MS _{groups} \over MS _{residuals}$ не следует F-распределению (Searle et al. 1992).

<br />
> - Cтарайтесь _планировать_ группы равной численности!
> - Но если не получилось - не страшно:
    - Для фикс. эффектов неравные размеры - проблема только если значения p близки к $\alpha$

---

## Типы сумм квадратов для несбалансированных данных

SSe и SSab - также как для сбалансированных данных, SSa и SSb - иначе

Типы сумм квадратов | I тип | II тип | III тип
------- | ------- | -------- | -------
Название | Последовательная | Без учета взаимодействий высоких порядков | Иерархическая
SS | SS(A),</br>SS(B &#8739; A)</br>SS(AB &#8739; B, A) | SS(A &#8739; B)</br>SS(B &#8739; A)</br>SS(AB &#8739; B, A) | SS(A &#8739; B, AB)</br>SS(B &#8739; A, AB)</br>SS(AB &#8739; B, A)
Величина эффекта зависит от выборки в группе | Да | Да | Нет
Результат зависит от порядка включения факторов в модель | Да | Нет | Нет
Результат зависит от параметризации | Нет | Нет | Да (только параметризация эффектов `contr.sum`, или Хельмерта `contr.helmert`)
Команда R | `aov()` | `Anova()` (пакет `car`) | `Anova()` (пакет `car`) 

>- Для сбалансированных дизайнов - результаты одинаковы
>- Для несбалансированных дизайнов рекомендуют __суммы квадратов III типа__ если есть взаимодействие факторов (Maxwell & Delaney 1990, Milliken, Johnson 1984, Searle 1993, Yandell 1997)

--- .segue

# Многофакторный дисперсионный анализ в R

--- &twocol

## Пример: Возраст и память

Почему пожилые не так хорошо запоминают? Может быть не так тщательно перерабатывают информацию? (Eysenck, 1974)

*** =left

Факторы:
- `Age` - Возраст:
  - `Younger` - 50 молодых
  - `Older` - 50 пожилых (55-65 лет)
- `Process` - тип активности:
  - `Counting` - посчитать число букв
  - `Rhyming` - придумать рифму к слову
  - `Adjective` - придумать прилагательное
  - `Imagery` - представить образ
  - `Intentional` - запомнить слово

Зависимая переменная - `Words` - сколько вспомнили слов

<div class = "footnote">http://www.statsci.org/data/general/eysenck.html</div>

*** =right


```r
memory <- read.delim(file="eysenck.csv")
head(memory, 10)
```

```
#        Age  Process Words
# 1  Younger Counting     8
# 2  Younger Counting     6
# 3  Younger Counting     4
# 4  Younger Counting     6
# 5  Younger Counting     7
# 6  Younger Counting     6
# 7  Younger Counting     5
# 8  Younger Counting     7
# 9  Younger Counting     9
# 10 Younger Counting     7
```

---

##   Посмотрим на боксплот


```r
library(ggplot2)
theme_set(theme_bw(base_size = 18) + theme(legend.key = element_blank()))
ggplot(data = memory, aes(x = Age, y = Words)) + 
  geom_boxplot(aes(fill = Process))
```

<img src="assets/fig/unnamed-chunk-2.png" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" style="display: block; margin: auto;" />

> - Некрасивый порядок уровней memory$Process

---

## Боксплот с правильным порядком уровней

переставляем порядок уровней в порядке следования средних значений `memory$Words`


```r
memory$Process <- reorder(memory$Process, memory$Words, FUN=mean)
mem_p <- ggplot(data = memory, aes(x = Age, y = Words)) + 
  geom_boxplot(aes(fill = Process))
mem_p
```

<img src="assets/fig/unnamed-chunk-3.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />

---

## Таблица результатов многофакторного дисперсионного анализа

Внимание: при использовании III типа сумм квадратов, нужно __обязательно указывать тип контрастов для факторов__. В данном случае - `contrasts=list(Age=contr.sum, Process=contr.sum)`


```r
memory_fit <- lm(formula = Words ~ Age * Process, data = memory, 
                 contrasts=list(Age=contr.sum, Process=contr.sum))
```

--- .prompt

## Задание: Проверьте условия применимости дисперсионного анализа

- Есть ли гомогенность дисперсий?
- Не видно ли трендов в остатках?
- Нормальное ли у остатков распределение?

---

## Решение: 1. Проверяем условия применимости

- Есть ли гомогенность дисперсий?
- Не видно ли трендов в остатках?


```r
library(car)
residualPlots(memory_fit)
```

<img src="assets/fig/unnamed-chunk-5.png" title="plot of chunk unnamed-chunk-5" alt="plot of chunk unnamed-chunk-5" style="display: block; margin: auto;" />

---

## Решение: 2. Проверяем условия применимости

- Нормальное ли у остатков распределение?


```r
qqPlot(memory_fit)
```

<img src="assets/fig/unnamed-chunk-6.png" title="plot of chunk unnamed-chunk-6" alt="plot of chunk unnamed-chunk-6" style="display: block; margin: auto;" />

--- &twocol

## Результаты дисперсионного анализа

*** =left


```r
Anova(memory_fit, type = 3)
```

```
# Anova Table (Type III tests)
# 
# Response: Words
#             Sum Sq Df F value    Pr(>F)    
# (Intercept)  13479  1 1679.54   < 2e-16 ***
# Age            240  1   29.94 0.0000004 ***
# Process       1515  4   47.19   < 2e-16 ***
# Age:Process    190  4    5.93   0.00028 ***
# Residuals      722 90                      
# ---
# Signif. codes:  
#   0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1  ' ' 1
```

>- Поскольку взаимодействие достоверно, факторы отдельно можно не тестировать. Проведем пост хок тест по взаимодействию, чтобы выяснить, какие именно группы различаются

*** =right

<img src="assets/fig/unnamed-chunk-8.png" title="plot of chunk unnamed-chunk-8" alt="plot of chunk unnamed-chunk-8" style="display: block; margin: auto;" />


---

## Пост хок тест


```r
# создаем переменную-взаимодействие 
memory$AgeProc <- interaction(memory$Age, memory$Process)
# подбираем модель без intercept 
mod <- lm(Words ~ AgeProc - 1, data = memory)
library(multcomp)
memory_tukey <- glht(mod, linfct = mcp(AgeProc = "Tukey"))
options(width = 90)
summary(memory_tukey)
```

```
# 
# 	 Simultaneous Tests for General Linear Hypotheses
# 
# Multiple Comparisons of Means: Tukey Contrasts
# 
# 
# Fit: lm(formula = Words ~ AgeProc - 1, data = memory)
# 
# Linear Hypotheses:
#                                              Estimate Std. Error t value Pr(>|t|)    
# Younger.Counting - Older.Counting == 0          -0.50       1.27   -0.39   1.0000    
# Older.Rhyming - Older.Counting == 0             -0.10       1.27   -0.08   1.0000    
# Younger.Rhyming - Older.Counting == 0            0.60       1.27    0.47   1.0000    
# Older.Adjective - Older.Counting == 0            4.00       1.27    3.16   0.0637 .  
# Younger.Adjective - Older.Counting == 0          7.80       1.27    6.16   <0.001 ***
# Older.Imagery - Older.Counting == 0              6.40       1.27    5.05   <0.001 ***
# Younger.Imagery - Older.Counting == 0           10.60       1.27    8.37   <0.001 ***
# Older.Intentional - Older.Counting == 0          5.00       1.27    3.95   0.0058 ** 
# Younger.Intentional - Older.Counting == 0       12.30       1.27    9.71   <0.001 ***
# Older.Rhyming - Younger.Counting == 0            0.40       1.27    0.32   1.0000    
# Younger.Rhyming - Younger.Counting == 0          1.10       1.27    0.87   0.9970    
# Older.Adjective - Younger.Counting == 0          4.50       1.27    3.55   0.0205 *  
# Younger.Adjective - Younger.Counting == 0        8.30       1.27    6.55   <0.001 ***
# Older.Imagery - Younger.Counting == 0            6.90       1.27    5.45   <0.001 ***
# Younger.Imagery - Younger.Counting == 0         11.10       1.27    8.76   <0.001 ***
# Older.Intentional - Younger.Counting == 0        5.50       1.27    4.34   0.0014 ** 
# Younger.Intentional - Younger.Counting == 0     12.80       1.27   10.10   <0.001 ***
# Younger.Rhyming - Older.Rhyming == 0             0.70       1.27    0.55   0.9999    
# Older.Adjective - Older.Rhyming == 0             4.10       1.27    3.24   0.0505 .  
# Younger.Adjective - Older.Rhyming == 0           7.90       1.27    6.24   <0.001 ***
# Older.Imagery - Older.Rhyming == 0               6.50       1.27    5.13   <0.001 ***
# Younger.Imagery - Older.Rhyming == 0            10.70       1.27    8.45   <0.001 ***
# Older.Intentional - Older.Rhyming == 0           5.10       1.27    4.03   0.0043 ** 
# Younger.Intentional - Older.Rhyming == 0        12.40       1.27    9.79   <0.001 ***
# Older.Adjective - Younger.Rhyming == 0           3.40       1.27    2.68   0.1961    
# Younger.Adjective - Younger.Rhyming == 0         7.20       1.27    5.68   <0.001 ***
# Older.Imagery - Younger.Rhyming == 0             5.80       1.27    4.58   <0.001 ***
# Younger.Imagery - Younger.Rhyming == 0          10.00       1.27    7.89   <0.001 ***
# Older.Intentional - Younger.Rhyming == 0         4.40       1.27    3.47   0.0259 *  
# Younger.Intentional - Younger.Rhyming == 0      11.70       1.27    9.23   <0.001 ***
# Younger.Adjective - Older.Adjective == 0         3.80       1.27    3.00   0.0947 .  
# Older.Imagery - Older.Adjective == 0             2.40       1.27    1.89   0.6728    
# Younger.Imagery - Older.Adjective == 0           6.60       1.27    5.21   <0.001 ***
# Older.Intentional - Older.Adjective == 0         1.00       1.27    0.79   0.9986    
# Younger.Intentional - Older.Adjective == 0       8.30       1.27    6.55   <0.001 ***
# Older.Imagery - Younger.Adjective == 0          -1.40       1.27   -1.11   0.9830    
# Younger.Imagery - Younger.Adjective == 0         2.80       1.27    2.21   0.4583    
# Older.Intentional - Younger.Adjective == 0      -2.80       1.27   -2.21   0.4576    
# Younger.Intentional - Younger.Adjective == 0     4.50       1.27    3.55   0.0207 *  
# Younger.Imagery - Older.Imagery == 0             4.20       1.27    3.32   0.0410 *  
# Older.Intentional - Older.Imagery == 0          -1.40       1.27   -1.11   0.9830    
# Younger.Intentional - Older.Imagery == 0         5.90       1.27    4.66   <0.001 ***
# Older.Intentional - Younger.Imagery == 0        -5.60       1.27   -4.42   0.0011 ** 
# Younger.Intentional - Younger.Imagery == 0       1.70       1.27    1.34   0.9408    
# Younger.Intentional - Older.Intentional == 0     7.30       1.27    5.76   <0.001 ***
# ---
# Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
# (Adjusted p values reported -- single-step method)
```

---

## Данные для графиков


```r
library(dplyr)
memory_summary <- memory %>% 
  group_by(Age, Process) %>% 
  summarise(.mean = mean(Words),
            .sd = sd(Words))
```

---

## Графики для результатов: Столбчатый график


```r
mem_barp <- ggplot(data = memory_summary, 
                   aes(x = Age, y = .mean, ymin = .mean - .sd, 
                       ymax = .mean + .sd, fill = Process)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  geom_errorbar(width = 0.3, position = position_dodge(width = 0.9))
mem_barp
```

<img src="assets/fig/unnamed-chunk-11.png" title="plot of chunk unnamed-chunk-11" alt="plot of chunk unnamed-chunk-11" style="display: block; margin: auto;" />

---

## Графики для результатов: Линии с точками


```r
pos <- position_dodge(width = 0.9)
mem_linep <- ggplot(data = memory_summary, 
                    aes(x = Age, y = .mean, ymin = .mean - .sd, 
                        ymax = .mean + .sd, colour = Process, 
                        group = Process)) + 
  geom_point(size = 3, position = pos) +
  geom_line(position = pos) +
  geom_errorbar(width = 0.3, position = pos) 
mem_linep
```

<img src="assets/fig/unnamed-chunk-12.png" title="plot of chunk unnamed-chunk-12" alt="plot of chunk unnamed-chunk-12" style="display: block; margin: auto;" />

---

## Какой график лучше выбрать?


```r
library(gridExtra)
grid.arrange(mem_barp, mem_linep, ncol = 2)
```

<img src="assets/fig/unnamed-chunk-13.png" title="plot of chunk unnamed-chunk-13" alt="plot of chunk unnamed-chunk-13" style="display: block; margin: auto;" />

>- Должен быть максимум данных в минимуме чернил (Tufte, 1983)

---

## Приводим понравившийся график в приличный вид


```r
mem_linep <- mem_linep + labs(x = "Возраст",  y = "Число запомненных слов") + 
  scale_x_discrete(labels = c("Пожилые", "Молодые")) + 
  scale_colour_brewer(name = "Процесс", palette = "Dark2", 
                      labels = c("Счет", "Рифма", "Прилагательное",
                                 "Образ", "Запоминание")) + 
  theme(legend.key = element_blank())
mem_linep
```

<img src="assets/fig/unnamed-chunk-14.png" title="plot of chunk unnamed-chunk-14" alt="plot of chunk unnamed-chunk-14" style="display: block; margin: auto;" />

---

## Take home messages

- Многофакторный дисперсионный анализ позволяет оценить взаимодействие факторов. Если оно значимо, то лучше воздержаться от интерпретации их индивидуальных эффектов
- Если численности групп равны - получаются одинаковые результаты с использованием I, II, III типы сумм квадратов
- В случае, если численности групп неравны (несбалансированные данные) по разному тестируется значимость факторов (I, II, III типы сумм квадратов)

---

## Дополнительные ресурсы

- Quinn, Keough, 2002, pp. 221-250
- Logan, 2010, pp. 313-359
- Sokal, Rohlf, 1995, pp. 321-362
- Zar, 2010, pp. 246-266
