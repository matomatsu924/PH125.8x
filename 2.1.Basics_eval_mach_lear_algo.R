################################################################################
# Section 2: Machine Learning Basics
# 2.1 Basics of Evaluating Machine Learning Algorithms
################################################################################
library(tidyverse)
library(caret)
library(dslabs)

data(heights)


# Definir predictores y resultados

y <- heights$sex
x <- heights$height

# Create data partition

set.seed(2007)
test_index <- createDataPartition(y, times = 1, p = 0.5, list = FALSE)

# Crear set de entrenamiento y set de test
test_set <- heights[test_index, ]
train_set <- heights[-test_index, ]

################################################################################
y_hat <- sample(c("Male", "Female"), length(test_index), replace = TRUE) %>%
  factor(levels = levels(test_set$sex))

mean(y_hat == test_set$sex) # Overall accuracy - Proportion explained correctly

################################################################################
heights %>%
  group_by(sex) %>%
  summarize(mean(height), sd(height))

################################################################################

y_hat <- ifelse(x > 62, "Male", "Female") %>%
  factor(levels = levels(test_set$sex))

mean(y_hat == test_set$sex)

################################################################################

# Evaluar distintos valores de corte para x (de 61 a 70)
cutoff <- seq(61, 70)

accuracy <- map_dbl(cutoff, function(x) {
  y_hat <- ifelse(train_set$height > x, "Male", "Female") %>%
    factor(levels = levels(test_set$sex))
  mean(y_hat == train_set$sex)
})

plot(cutoff, accuracy)
lines(cutoff, accuracy)


# Max accuracy
max(accuracy)

# Best cutoff
best_cutoff <- cutoff[which.max(accuracy)]
best_cutoff


# Se utiliza este cutoff para ensayar la predicción

y_hat <- ifelse(test_set$height > best_cutoff, "Male", "Female") %>%
  factor(levels = levels(test_set$sex))

y_hat <- factor(y_hat)

mean(y_hat == test_set$sex)

################################################################################
# tabulate each combination of prediction and actual value
table(predicted = y_hat, actual = test_set$sex)
test_set %>% 
  mutate(y_hat = y_hat) %>%
  group_by(sex) %>% 
  summarize(accuracy = mean(y_hat == sex))
prev <- mean(y == "Male")

confusionMatrix(data = y_hat, reference = test_set$sex)

################################################################################

cm <- confusionMatrix(data= y_hat, reference = test_set$sex)

cm$overall["Accuracy"]

cm$byClass[c("Sensitivity", "Specificity", "Prevalence")]

################################################################################
#Maximizar F-score

cutoff <- seq(61,70)

F_1 <- map_dbl(cutoff, function(x){
  y_hat <- ifelse(train_set$height > x, "Male", "Female") %>% 
    factor(levels = levels(test_set$sex))
  F_meas(data= y_hat, reference = factor(train_set$sex))
})

data.frame(cutoff, F_1) %>% 
  ggplot(aes(cutoff, F_1)) +
  geom_point() +
  geom_line() +
  theme_bw()

max(F_1)


best_cutoff_2 <- cutoff[which.max(F_1)]
best_cutoff_2

y_hat <- ifelse(test_set$height > best_cutoff_2, "Male", "Female") %>% 
  factor(levels = levels(test_set$sex))

sensitivity(data= y_hat, reference = test_set$sex)
specificity(data = y_hat, reference = test_set$sex)


################################################################################
p <- 0.9
n <- length(test_index)
y_hat <- sample(c("Male", "Female"), n, replace = TRUE, prob=c(p, 1-p)) %>% 
  factor(levels = levels(test_set$sex))
mean(y_hat == test_set$sex)

# ROC curve
probs <- seq(0, 1, length.out = 10)
guessing <- map_df(probs, function(p){
  y_hat <- 
    sample(c("Male", "Female"), n, replace = TRUE, prob=c(p, 1-p)) %>% 
    factor(levels = c("Female", "Male"))
  list(method = "Guessing",
       FPR = 1 - specificity(y_hat, test_set$sex),
       TPR = sensitivity(y_hat, test_set$sex))
})
guessing %>% qplot(FPR, TPR, data =., xlab = "1 - Specificity", ylab = "Sensitivity")

cutoffs <- c(50, seq(60, 75), 80)
height_cutoff <- map_df(cutoffs, function(x){
  y_hat <- ifelse(test_set$height > x, "Male", "Female") %>% 
    factor(levels = c("Female", "Male"))
  list(method = "Height cutoff",
       FPR = 1-specificity(y_hat, test_set$sex),
       TPR = sensitivity(y_hat, test_set$sex))
})

# plot both curves together
bind_rows(guessing, height_cutoff) %>%
  ggplot(aes(FPR, TPR, color = method)) +
  geom_line() +
  geom_point() +
  xlab("1 - Specificity") +
  ylab("Sensitivity")

library(ggrepel)
map_df(cutoffs, function(x){
  y_hat <- ifelse(test_set$height > x, "Male", "Female") %>% 
    factor(levels = c("Female", "Male"))
  list(method = "Height cutoff",
       cutoff = x, 
       FPR = 1-specificity(y_hat, test_set$sex),
       TPR = sensitivity(y_hat, test_set$sex))
}) %>%
  ggplot(aes(FPR, TPR, label = cutoff)) +
  geom_line() +
  geom_point() +
  geom_text_repel(nudge_x = 0.01, nudge_y = -0.01)

# plot precision against recall
guessing <- map_df(probs, function(p){
  y_hat <- sample(c("Male", "Female"), length(test_index), 
                  replace = TRUE, prob=c(p, 1-p)) %>% 
    factor(levels = c("Female", "Male"))
  list(method = "Guess",
       recall = sensitivity(y_hat, test_set$sex),
       precision = precision(y_hat, test_set$sex))
})

height_cutoff <- map_df(cutoffs, function(x){
  y_hat <- ifelse(test_set$height > x, "Male", "Female") %>% 
    factor(levels = c("Female", "Male"))
  list(method = "Height cutoff",
       recall = sensitivity(y_hat, test_set$sex),
       precision = precision(y_hat, test_set$sex))
})

bind_rows(guessing, height_cutoff) %>%
  ggplot(aes(recall, precision, color = method)) +
  geom_line() +
  geom_point()
guessing <- map_df(probs, function(p){
  y_hat <- sample(c("Male", "Female"), length(test_index), replace = TRUE, 
                  prob=c(p, 1-p)) %>% 
    factor(levels = c("Male", "Female"))
  list(method = "Guess",
       recall = sensitivity(y_hat, relevel(test_set$sex, "Male", "Female")),
       precision = precision(y_hat, relevel(test_set$sex, "Male", "Female")))
})

height_cutoff <- map_df(cutoffs, function(x){
  y_hat <- ifelse(test_set$height > x, "Male", "Female") %>% 
    factor(levels = c("Male", "Female"))
  list(method = "Height cutoff",
       recall = sensitivity(y_hat, relevel(test_set$sex, "Male", "Female")),
       precision = precision(y_hat, relevel(test_set$sex, "Male", "Female")))
})
bind_rows(guessing, height_cutoff) %>%
  ggplot(aes(recall, precision, color = method)) +
  geom_line() +
  geom_point()



################################################################################
library(dslabs)
library(dplyr)
library(lubridate)
data(reported_heights)
#View(reported_heights)

dat <- mutate(reported_heights, date_time = ymd_hms(time_stamp)) %>%
  filter(date_time >= make_date(2016, 01, 25) & date_time < make_date(2016, 02, 1)) %>%
  mutate(type = ifelse(day(date_time) == 25 & hour(date_time) == 8 & between(minute(date_time), 15, 30), "inclass","online")) %>%
  select(sex, type)

#dat
#View(dat)

y <- factor(dat$sex, c("Female", "Male"))
#y
x <- dat$type
#x

y[which(x=="inclass")] 

inclass_data <- data.frame(y[which(x=="inclass")] ) 
mean(inclass_data[1]=="Female")


mean(y[which(x=="online")]=="Female")

table(y[which(x=="online")])

#Otra forma de hacerlo

dat %>% group_by(type) %>% 
  summarize(prop_female= mean(sex=="Female"))


################################################################################
y_hat <- ifelse(dat$type =="inclass", "Female", "Male") %>% 
  factor(levels = levels(y))

mean(y_hat == dat$sex)

table(y_hat, y)

sensitivity(y_hat,y)
specificity(y_hat,y)


mean(y=="Female")
confusionMatrix(y_hat,y)

################################################################################
library(caret)
data(iris)
iris <- iris[-which(iris$Species=='setosa'),]
y <- iris$Species
#y

set.seed(76)
test_index <- createDataPartition(y, times=1, p=0.5, list=FALSE)
test <- iris[test_index,]
train <- iris[-test_index,]
#View(train)


#Accuracy sepal length
range(test$Sepal.Length)

cutoff <- seq(4.9,7.9, 0.1)
cutoff


accuracy_sepal_l <- map_dbl(cutoff,function(x){
  y_hat = ifelse(train$Sepal.Length > x, "virginica", "versicolor")
  factor(levels = levels(train$Species))
  mean(y_hat==train$Species)
})

max(accuracy_sepal_l)

#Accuracy sepal width
range(train$Sepal.Width)

cutoff <- seq(2,3.8,.1)

accuracy_sepal_w <- map_dbl(cutoff,function(x){
  y_hat = ifelse(train$Sepal.Width > x, "virginica", "versicolor")
  factor(levels = levels(train$Species))
  mean(y_hat==train$Species)
})

max(accuracy_sepal_w)

#Accuracy petal length

range(train$Petal.Length)

cutoff <- seq(3,6.7,.1)

accuracy_petal_l <- map_dbl(cutoff,function(x){
  y_hat = ifelse(train$Petal.Length > x, "virginica", "versicolor")
  factor(levels = levels(train$Species))
  mean(y_hat==train$Species)
})

max(accuracy_petal_l)
cutoff[which.max(accuracy_petal_l)]

#Accuracy petal width

range(train$Petal.Width)

cutoff <- seq(1,2.5,.1)

accuracy_petal_w <- map_dbl(cutoff,function(x){
  y_hat = ifelse(train$Petal.Width > x, "virginica", "versicolor")
  factor(levels = levels(train$Species))
  mean(y_hat==train$Species)
})

max(accuracy_petal_w)

#Otra forma de hacerlo

foo <- function(x){
  rangedValues <- seq(range(x)[1], range(x)[2], by=0.1)
  sapply(rangedValues, function(i){
    y_hat <- ifelse(x>i, 'virginica', 'versicolor')
    mean(y_hat==train$Species)
  })
}

predictions <- apply(train[,-5], 2, foo)
sapply(predictions, max)	

################################################################################

range(train$Petal.Width)

cutoff <- seq(1,2.5,.1)

accuracy_petal_w <- map_dbl(cutoff,function(x){
  y_hat = ifelse(train$Petal.Width > x, "virginica", "versicolor")
  factor(levels = levels(train$Species))
  mean(y_hat==train$Species)
})


cutoff_max <- cutoff[which.max(accuracy_petal_w)]  
cutoff_max

#Con el resultado del valor máximo de los datos de entrenamiento, procedo a
#evaluar con los datos test

y_hat = ifelse(test$Petal.Width > cutoff_max, "virginica", "versicolor")
factor(levels = levels(test$Species))
mean(y_hat==test$Species)


#Otra forma de hacerlo

predictions <- foo(train[,4])
rangedValues <- seq(range(train[,4])[1], range(train[,4])[2], by=0.1)
cutoffs <-rangedValues[which(predictions==max(predictions))]

y_hat <- ifelse(test[,4]>cutoffs[1], 'virginica', 'versicolor')
mean(y_hat==test$Species)

################################################################################
plot(iris, pch=21, bg=iris$Species)
################################################################################
train[which.max(predictions$Petal.Length)]  



y_hat = ifelse(test$Petal.Length > 4.6 & test$Petal.Width > 1.5, "virginica", "versicolor")
factor(levels = levels(test$Species))
mean(y_hat==test$Species)

################################################################################
#Otra forma

library(caret)
data(iris)
iris <- iris[-which(iris$Species=='setosa'),]
y <- iris$Species

plot(iris, pch=21, bg=iris$Species)

set.seed(76) 
test_index <- createDataPartition(y, times=1, p=0.5, list=FALSE)
test <- iris[test_index,]
train <- iris[-test_index,]

petalLengthRange <- seq(range(train$Petal.Length)[1], range(train$Petal.Length)[2],by=0.1)
petalWidthRange <- seq(range(train$Petal.Width)[1], range(train$Petal.Width)[2],by=0.1)

length_predictions <- sapply(petalLengthRange, function(i){
  y_hat <- ifelse(train$Petal.Length>i, 'virginica', 'versicolor')
  mean(y_hat==train$Species)
})
length_cutoff <- petalLengthRange[which.max(length_predictions)] # 4.6

width_predictions <- sapply(petalWidthRange, function(i){
  y_hat <- ifelse(train$Petal.Width>i, 'virginica', 'versicolor')
  mean(y_hat==train$Species)
})
width_cutoff <- petalWidthRange[which.max(width_predictions)] # 1.5

y_hat <- ifelse(test$Petal.Length>length_cutoff & test$Petal.Width>width_cutoff, 'virginica', 'versicolor')
mean(y_hat==test$Species)



