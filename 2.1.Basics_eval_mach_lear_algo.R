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
