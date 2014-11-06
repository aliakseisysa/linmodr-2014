birds <- read.csv("loyn.csv")
colnames(birds)

# all models are wrong but some are useful

# Сравнение моделей при помощи F-критерия
frm_full <- ABUND ~ L10AREA + L10DIST + YR.ISOL + L10LDIST + GRAZE
lm_full <- lm(frm_full, birds)
summary(lm_full)

frm_ldist <- ABUND ~ L10AREA + L10DIST + YR.ISOL + GRAZE
lm_ldist <- lm(frm_ldist, birds)
anova(lm_ldist, lm_full)
# ldist не улучшает модель - выбрасываем

frm_dist <- ABUND ~ L10AREA + YR.ISOL + GRAZE
lm_dist <- lm(frm_dist, birds)
anova(lm_dist, lm_ldist)
# dist не улучшает модель - выбрасываем

frm_yrisol <- ABUND ~ L10AREA + GRAZE
lm_yrisol <- lm(frm_yrisol, birds)
anova(lm_yrisol, lm_dist)
# yrisol не улучшает модель - выбрасываем

frm_graze <- ABUND ~ L10AREA
lm_graze <- lm(frm_graze, birds)
anova(lm_graze, lm_dist)
# graze улучшает модель - не можем выбросить

library(leaps)
# Cp
crit_cp <- leaps(x = birds[, c(3, 6:10)], y = birds$ABUND, names = names(birds[, c(3, 6:10)]), method = "Cp")
names(crit_cp)
head(crit_cp$which) # Перечень моделей
head(crit_cp$Cp) # Значения критерия
# Лучшая модель
n_mod <- length(crit_cp$size) # полную модель нужно исключить
best_cp <- which.min(abs(crit_cp$size[-n_mod] - crit_cp$Cp[-n_mod]))
# Какие переменные входят в модель?
crit_cp$which[best_cp, ]
frm_cp <- ABUND ~ GRAZE + L10DIST + L10AREA

# adjusted r^2
crit_ar2 <- leaps(x = birds[, c(3, 6:10)], y = birds$ABUND, names = names(birds[, c(3, 6:10)]), method = "adjr2")
data.frame(crit_ar2$size, crit_ar2$which, crit_ar2$adjr2)
# Лучшая модель
best_ar2 <- which.max(crit_ar2$adjr2)
# Какие переменные входят в модель?
crit_ar2$which[best_ar2, ]
frm_ar2 <- ABUND ~ YR.ISOL + GRAZE + ALT + L10AREA

# cross-validation
library(DAAG)
val_yrisol <- CVlm(df = birds, form.lm = frm_yrisol, m = 5)

sqrt(mean((val_yrisol$cvpred - val_yrisol$ABUND)^2))

# создаем функцию для RMSE
rmse <- function(cv_obj, y_name){
  sqrt(mean((cv_obj$cvpred - cv_obj[, y_name])^2))
}

rmse(val_yrisol, "ABUND")

val_cp <- CVlm(df = birds, form.lm = frm_cp, m = 5)
rmse(val_cp, "ABUND")

val_ar2 <- CVlm(df = birds, form.lm = frm_ar2, m = 5)
rmse(val_ar2, "ABUND")

val_full <- CVlm(df = birds, form.lm = frm_full, m = 5)
rmse(val_full, "ABUND")

# Модель выбранная по Cp лучше предсказывает

library(caret)
options(digits = 3)
inTrain <- createDataPartition(y = birds$ABUND, p = .75, list = FALSE)
training <- birds[inTrain, ]
validation <- birds[-inTrain, ]
ctrl <- trainControl(method = "cv", savePred=T, number = 3)

fit_cp <- train(form = frm_cp, data = training, method = "lm", trControl = ctrl)
fit_cp
fit_cp$resample
summary(fit_cp$finalModel)

fit_ar2 <- train(form = frm_ar2, data = training, method = "lm", trControl = ctrl)
fit_ar2
fit_ar2$resample
summary(fit_ar2$finalModel)



