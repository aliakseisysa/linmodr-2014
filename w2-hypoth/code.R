# Код лекции "Тестирование статистических гипотез"

options(digits=3)

# ВНИМАНИЕ Весь код, который находится между линиями разбирайте самостоятельно. Для этого раскомментируйте его (Надо выделить все, что между линиями: Shift + стрелка вниз, а затем нажать "ctrl shift c")

# ===========================================
# # Рисуем график плотности вероятности нормального распределения
# 
# library (ggplot2)
# 
# xi <- seq(0,20,0.1) #Это мы создали вектор значений, которые будут откладываться по оси OX, это наши величины в генеральной совокупности, которую мы изучаем 
# 
# # Получаем вектор вероятностей, в соответствии с формулой Гаусса
# Mu <- 10 #Первый параметр
# Sigma <- 2 #Второй параметр
# p <- dnorm(xi, Mu, Sigma)
# 
# # Соединяем двавектора в единый датафрейм
# 
# Gaus <- data.frame(xi=xi, p=p) 
# 
# ggplot(Gaus, aes(x=xi, y=p)) + geom_line(color="blue", size=2) + geom_vline (xintercept = Mu)
# 
# # Все то же самое можно записать в виде функции (осваивайте код самостоятельно)
# 
# gaus_distribution <- function (xi, Mu, Sigma){
#   ggplot(data.frame(xi=xi, p=dnorm(xi, Mu, Sigma)), aes(x=xi, y=p)) + geom_line(color="blue", size=2) + geom_vline (xintercept = Mu)
#   
# }
# 
# # Теперь можно построить график для любого сочетания парметров
# 
# gaus_distribution(seq(0, 100, 0.5), 50, 10)
# 
# gaus_distribution(seq(0, 100, 0.5), 50, 1)
# 
# gaus_distribution(seq(0, 100, 0.5), 30, 20)
# 
# ===========================================

# Делаем выборку из генерального распределения с параметрам Mu=50, Sigma=5
set.seed(123)
sample <- rnorm(150, 50, 5)
sample <- data.frame(xi=sample)
head (sample)

# Строим частотное распределение по выборке

pl_sample_distribution <- ggplot(sample, aes(x=xi)) + 
  geom_histogram(binwidth = 5, fill = "blue", color = "black") + 
  xlab("Sampled values") + 
  ylab("Count") +
  ggtitle("Frequency distribution of sampled values")

pl_sample_distribution


# ===========================================
# # Смотрим на другие формы представления информации о выборке
# library(gridExtra)
# pl_hist <- ggplot(data.frame(xi=sample), aes(x=xi)) + geom_histogram(binwidth = 5, fill = "blue", color = "black") + ggtitle("Частотная гистограмма") + xlab("Изучаемая величина")
# 
# pl_polig <- ggplot(data.frame(xi=sample), aes(x=xi)) + geom_freqpoly(binwidth = 5, size=2) + ggtitle("Частотный полигон") + xlab("Изучаемая величина")
# 
# pl_box <- ggplot(data.frame(xi=sample, mark=" "), aes(x=mark, y=xi)) + geom_boxplot(fill="blue") + ggtitle("Ящик с усами (боксплот)") + xlab(" ") + ylab("Изучаемая величина")
# 
# pl_vio <- ggplot(data.frame(xi=sample, mark=" "), aes(x=mark, y=xi)) + geom_violin(fill="blue") + xlab(" ") + ggtitle(" ") + ylab("Изучаемая величина")
# 
# 
# grid.arrange(pl_hist, pl_polig, pl_box, pl_vio, nrow=2)

# ===========================================

# Пишем код для многократноо взятия выборок из одной и той же совокупности


# ЗДЕСЬ ВЫ НАПИШИТЕ СВОЙ КОД









# Стандатизируем выборку


z <- (sample - mean(sample))/sd(sample)

# ЗДЕСЬ ВЫ ПОЛУЧИТЕ СООБЩЕНИЕ ОБ ОШИБКЕ. 
# ПОДУМАТЕ ПОЧЕМУ. 



# Вычисляем срденее значение и среднеквадратичное отклонение для стандартизированной величины
mean(z)
sd(z)

# рисуем ее распределение
ggplot(data.frame(z=z), aes(x=z)) + geom_histogram(binwidth=0.5, fill="blue", color="black") + geom_vline(xintercept=0, size=2)


# Рисуем t-распределение стьюдента

t <- seq(-10,10,0.1) #Это мы создали вектор значений, которые будут откладываться по оси ОХ, то есть стандартизованные разности между средними

pt <- dt(t, 4) #Это мы вычилили вероятности соответствующих значений для генеральной совокупности.

# Строим график
ggplot(data.frame(t=t, pt=pt), aes(x=t, y=pt)) + geom_line(size=2) + geom_vline(xinercept=0) + xlab("Стандартизированные значения разности \nмежду средними") + ylab("Вероятость")


# Моделируем процесс повторных парных выборок из одной генеральной совокупности с параметрами Mu=50 и Sigma = 5

t_sample1 <- rep(0,1000) #Это мы содали вектор знчений t. Пока он состоит из 1000 нулей.


#Теперь мы 1000 раз будем брать по две выборки (по 10 объектов каждая) из генеральной совокупности с параметрами Mu=50 и Sigma=5
for (i in 1:1000) {
  samp1 <- rnorm(10, 50,5)
  samp2 <- rnorm(10, 50, 5)
  t_sample1[i] <- (mean(samp1) - mean(samp2))/sqrt(sd(samp1)^2/length(samp1) + sd(samp2)^2/length(samp2))
}


# Все то же самое, но с использованием функции rt()

t_sample2 <- rt(1000, df=(10 + 10 - 2))

# =================================
# Строим частотное распределение симулированных выборок
# 
# library(gridExtra)
# 
# pl_t_our <- ggplot(data.frame(t=t_sample1), aes(x=t)) + geom_histogram(binwidth=0.1, fill="blue", color="black") + geom_line(aes(x=seq(-5,4.99,0.01), y=dt(seq(-5,4.99,0.01), 18)*100), size=1) + geom_vline(xintercept=c(-2,2), linetype=5, size=1) + ggtitle("Распределение  величин t, смоделированных нами") + xlim(-5,5) + ylim(0, 60)
# 
# pl_t_r <- ggplot(data.frame(t=t_sample2), aes(x=t)) + geom_histogram(binwidth=0.1, fill="blue", color="black") + geom_line(aes(x=seq(-5,4.99,0.01), y=dt(seq(-5,4.99,0.01), 18)*100), size=1) + geom_vline(xintercept=c(-2,2), linetype=5, size=1) + ggtitle("Распределение величин t, полученных функцией rt()") + xlim(-5,5)+ ylim(0, 60)
# 
# grid.arrange(pl_t_our, pl_t_r, nrow=2) #С помощью функции grid.arrange() мы располагаем два графических объекта pl_t_our (частотное распределение значений t, симулированных нами) и pl_t_r (частотное распределение значний t, сгенерированных функцией rt())
# =================================


# Создаем две выборки из популяций с нормальным распределением признака, но разными параметрами Mu

set.seed(12345)
male <- rnorm(100, 130, 5)
female <- rnorm(100, 129,5)

# Рисуем частотное распределение признаков

# Объедияем оба вектора в один датафрейм
size <- data.frame(L=c(male, female), gender=factor(c(rep("M", length(male)), rep("F", length(female) ))))

# Рисуем частотное распределеине значений L
(pl_m <- ggplot(size [size$gender == "M",], aes(x=L)) + geom_histogram(binwidth=5, fill="blue", color="black") + xlab("Высота (см)") + ylab("Количество") + ggtitle("Частотное распределение значений длины тела у мальчиков") + theme_bw())

(pl_f <- ggplot(size [size$gender == "F",], aes(x=L)) + geom_histogram(binwidth=5, fill="pink", color="black") + xlab("Высота (см)") + ylab("Количество") + ggtitle("Частотное распределение значений длины тела у девочек") + theme_bw())


# Помечаем на гистограммах средние значения
(pl_m <- pl_m + geom_vline(xintercept=mean(male), color="darkblue", size=2))

(pl_f <- pl_f + geom_vline(xintercept=mean(female), color="red", size=2))

#========================================
# # Помещам оба рисунка на одну панель 
# grid.arrange(pl_m, pl_f, nrow=2)
# =================================


# ====================================
# # Рисуем бокс-плоты
# pl_box <- ggplot(size, aes(x=gender, y=L))
# pl_box + geom_boxplot(notch = TRUE, fill="blue") + theme_bw()
# ====================================


# Применяем t-критерий Стьюдента для сравнения средних значений
(t <- t.test(male, female))

# Смотрим на структуру значений, выводимых функцией t.test()
str(t)

# Вытаскиваем из результатов работы функции t.test() значения t и p.value 

t$statistic
t$p.value

# ПЕРМУТАЦИИ

# Вычисляем наблюдаемое значение статистики 

d_initial <- abs(mean(male) - mean(female))



Nperm=10000 #Задаем число пермутаций

dperm <- rep(NA, Nperm) #Подготавливаем вектор пермутационных оценок статистики d

set.seed(12345) 

# В цикле запускаем перемешивание изначальных векторов male и female и после каждого пермешивания вычисляем статистику d

for (i in 1:(Nperm-1)) 
{
  BOX <- c(male,female) #Это мы сложили всех male (длина вектора 100) и female (длина вектора 100) в одну кучу и получили вектор BOX длиой 200
  ord <-sample(1:200, 200) #Перемешали индексы 
  f <- BOX[ord[1:100]] #Вектоу f присвоили с 1 по 100 значения из смеси
  m <- BOX [ord[101:200]] # вектору m присвоили со 101 по 200 значения из смеси
  dperm[i]=abs(mean(m) - mean(f)) #Вычислили значение статистики d
}

# Смотим на начало и на конец вектора dperm
head(dperm)
tail(dperm)


# Записываем в конец этого вектора значение  d_initial
dperm [Nperm] <- d_initial


# Строим частотое распределение пермутационных оценок статистики d 

dperm <- data.frame(d_p=dperm)

dperm_pl <- ggplot(dperm, aes(x=d_p))
dperm_pl + geom_histogram (bin=0.05, fill="blue", colour="black") + xlab("Permutational d-values") + geom_vline(xintercept=c(d_initial), linetype=2) 

# Расчитаем величину уровня значимости 
p_perm <- length(dperm[dperm >= d_initial] ) / Nperm

p_perm
