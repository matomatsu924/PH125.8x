# Data Science: Machine Learning


# Data Science: Machine Learning

## Section 2: Machine Learning Basics

### 2.1. Basics of Evaluating Machine Learning Algorithms

#### Evaluation metrics

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

#### Confusion matrix

- Overall accuracy can sometimes be a deceptive measure because of
  unbalanced classes.

- A general improvement to using overall accuracy is to study
  sensitivity and specificity separately. These will be defined in the
  next video.

- A confusion matrix tabulates each combination of prediction and actual
  value. You can create a confusion matrix in R using the `table()`
  function or the `confusionMatrix()` function from the **caret**
  package.

- If your training data is biased in some way, you are likely to develop
  algorithms that are biased as well. The problem of biased training
  sets is so commom that there are groups dedicated to study it.

#### Sensitivity, specificity and prevalence

![](images/clipboard-3831234289.png)

![](images/clipboard-3397224890.png)

#### Balanced accuracy and F1 score

- For optimization purposes, sometimes it is more useful to have a one
  number summary than studying both specificity and sensitivity. One
  preferred metric is **balanced accuracy**. Because specificity and
  sensitivity are rates, it is more appropriate to compute the
  ***harmonic*** average. In fact, the **F1-score**, a widely used
  one-number summary, is the harmonic average of precision and recall. 

- Depending on the context, some type of errors are more costly than
  others. The **F1-score** can be adapted to weigh specificity and
  sensitivity differently. 

- You can compute the **F1-score** using the `F_meas()` function in the
  **caret** package.

#### Prevalence matters in practice

- A machine learning algorithm with very high sensitivity and
  specificity may not be useful in practice when prevalence is close to
  either 0 or 1. For example, if you develop an algorithm for disease
  diagnosis with very high sensitivity, but the prevalence of the
  disease is pretty low, then the precision of your algorithm is
  probably very low based on Bayes’ theorem.

#### ROC and precision-recall curves

- A very common approach to evaluating accuracy and F1-score is to
  compare them graphically by plotting both. A widely used plot that
  does this is the **receiver operating characteristic (ROC) curve**.
  The ROC curve plots sensitivity (TPR) versus 1 - specificity, also
  known as the false positive rate (FPR).

- However, ROC curves have one weakness and it is that neither of the
  measures plotted depend on prevalence. In cases in which prevalence
  matters, we may instead make a **precision-recall plot**, which has a
  similar idea with ROC curve.

#### Loss Function

- The most commonly used loss function is the squared loss function.
  Because we often have a test set with many observations, say N, we use
  the mean squared error (MSE). In practice, we often report the root
  mean squared error (RMSE), which is the square root of MSE, because it
  is in the same units as the outcomes.

- If the outcomes are binary, both RMSE and MSE are equivalent to one
  minus accuracy

- Note that there are loss functions other than the squared loss. For
  example, the Mean Absolute Error uses absolute values instead of
  squaring the errors. However, we focus on minimizing square loss since
  it is the most widely used.
