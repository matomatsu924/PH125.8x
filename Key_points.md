# Data Science: Machine Learning


# Data Science: Machine Learning

## Section 2: Machine Learning Basics

### 2.1. Basics of Evaluating Machine Learning Algorithms

#### Key points

- To mimic the ultimate evaluation process, we randomly split our data
  into two — a training set and a test set — and act as if we don’t know
  the outcome of the test set. We develop algorithms using only the
  training set; the test set is used only for evaluation.

- The `createDataPartition()` function from the **caret** package can be
  used to generate indexes for randomly splitting data.

- Note: contrary to what the documentation says, this course will use
  the argument p as the percentage of data that goes to testing. The
  indexes made from `createDataPartition()` should be used to create the
  test set. Indexes should be created on the outcome and not a
  predictor.

- The simplest evaluation metric for categorical outcomes is overall
  accuracy: the proportion of cases that were correctly predicted in the
  test set.
