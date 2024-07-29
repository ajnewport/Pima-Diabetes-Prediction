# 1 Introduction

## 1.1 Origin
Diabetes is an issue affecting a person’s blood sugar levels, due to the body
not producing enough insulin or cannot process insulin that the body produces. The data were collected by the USA’s National Institute of Diabetes
and Digestive and Kidney Diseases, and it consists of 768 women from the
Pima Indian population from Phoenix, Arizona [1]. This population was
investigated due to their heightened prevalence of diabetes, thus eight high
risk factors were considered as predictors:

• The number of pregnancies

• Plasma glucose level at 2 hours

• Diastolic blood pressure

• Triceps fold skin Thickness

• Insulin concentration at 2 hours

• Body Mass Index (BMI)

• Diabetes Pedigree - a score measuring the genetic influence of a woman’s
relatives’ status of diabetes.

• Age

The response variable is ‘Outcome’, with ‘1’ being tested positive for diabetes
and ‘0’ negative for diabetes. The purpose of this analysis is to predict the
outcome of future data.

The data is open-source and can be found at: https://www.kaggle.com/datasets/uciml/pima-indians-diabetes-database 

## 1.2 Data Quality
Originally, there were 768 observations; for the coursework, 750 were selected.
Looking at the dataset, there are values of zeroes in a number of predictors;
the table below shows these. From further research, we can look at predefined values
to see if these values are valid measurements. Insulin levels after 2 hours are
on average between 16-166 units [2], the average skin thickness for women is
18.7cm [3], diastolic blood pressure is zero under rare circumstances [4], the
BMI range is between 14.1-52.3 units [5], and glucose level under 70 units
can be fatal [6]. In addition to these predictors, there are 109 observations
with no pregnancies. One can determine that, especially for skin thickness
and insulin, that there are missing data, which can affect the accuracy of the
model chosen. Sorting the data by serum insulin shows that all zero observations of skin thickness also have a insulin value of 0 so the data is not Missing
Completely at Random (MCAR). Moreover, there are 490 negative diabetes
results, accounting for 65.3% of the whole data. This class imbalance could
have negative implications on the predictive model. No duplication of rows
were detected.

| Predictor        | Number of Zeroes |
|------------------|------------------|
| Insulin          | 362              |
| Skin Thickness   | 221              |
| Blood Pressure   | 35               |
| BMI              | 11               |
| Glucose          | 5                |

# 2 Exploratory Data Analysis

Before any potential imputation, transforming the missing values from 0
to null is important for any exploratory analysis. Next, we look for any
potential outliers in the data. The figure shows the boxplots of each predictor. There are 9 outliers for age
and 4 outliers for pregnancies, which I will not classify as outliers. Although
improbable for a woman to have 14-17 pregnancies, their age infers that it
is not impossible. In total, 70 outliers were omitted from the data.

![BoxplotNA](https://github.com/user-attachments/assets/64661fc5-1f88-40df-bc73-de95313ac985)

The correlation matrix is also shown below; from that we see that
glucose is the most correlated with outcome, with a value of 0.46. There
are also fairly high correlations between predictors (skin thickness/insulin,
age/pregnancies), so one should be aware of a possibility of multicolinearity
in the model.

![CorrPlotFINAL](https://github.com/user-attachments/assets/0239cd9d-7802-4e12-a1b3-7bb36bbf6c4a)

The plots showing the distribution of each predictor can be seen in the next figure. The visualisation shows that the data is approximately normally
distributed. However, some variables such as pregnancies, diabetes pedigree
and age are right-skewed. This can be solved using imputation.
I have decided to use mean and median imputation for the missing data;
we see from this figure that the assumption that the data are approximately
normal is satisfied, and median imputation is good when data is skewed. I
have used mean imputation only for blood pressure as the skew is minimal,
whereas the other variables (insulin, skin thickness, glucose and BMI) all
will be imputed by the median.

![distplotFINAL](https://github.com/user-attachments/assets/836918cb-6e92-44b0-acb0-d7e4d122769d)

# 3 Regression Models

Logistic regression is used when the response is binary but the explanatory
variables are continuous. Since this is the nature of the data, we will utilise
it.

## 3.1 Adding a New Variable

We create a variable, ‘SevenOrMorePregnancies’ and fit a logistic regression
model which predicts whether a woman will get diabetes based on their
number of pregnancies. To find the probability of developing diabetes given
the number of pregnancies, we use the equation:

![equationPima](https://github.com/user-attachments/assets/0290612b-efa6-4827-b860-e328e039f50a)

where:

- $\hat{p}$ is the positive class probability,
  
- $\beta_0$ is the intercept,
  
- $\beta_1$ is the coefficient for `SevenOrMorePregnancies`.

For our model, the intercept ($\beta_0$) is -1.03217, and the coefficient ($\beta_1$) is 1.2396. The variable `SevenOrMorePregnancies` has a value of 1 if the number of pregnancies is seven or more, and 0 if six or fewer. Plugging these values into the equation, we get the probabilities:

- 0.551 for seven or more pregnancies
  
- 0.263 for six or fewer

These probabilities are calculated to three significant figures.

## 3.2 The Chosen Model

Now, we incorporate all predictors in the logistic regression model, omitting variables that do not have enough statistical significance. Specifically,
I am looking at a p-value < 0.05, and taking into account the correlations between predictors. I have deleted the column `SevenOrMorePregnancies`. The table below shows the p-values, and it indicates that the variables
`Glucose`,`BMI`,`Pregnancies` and `DiabetesPedigree` are all statistically significant. The rest of the predictors have p values so high that we will not
consider them for the model.


| Predictor           | P-Value      |
|---------------------|--------------|
| Pregnancies         | 7.81e−5      |
| Glucose             | < 2e−16      |
| Blood Pressure      | 0.77926      |
| Skin Thickness      | 0.81341      |
| Insulin             | 0.98545      |
| BMI                 | 5.63e−6      |
| Diabetes Pedigree   | 0.00367      |
| Age                 | 0.60187      |


After experimentation, I have decided to include the predictors with low
p-values. The logistic equation is as follows:

![PimaEqu](https://github.com/user-attachments/assets/5cd12512-81ce-40e0-875c-3486ce760578)

And for the probabilities we use:

![PimaProb](https://github.com/user-attachments/assets/0ac55427-4e95-46f3-b5b0-28a976ba5f01)

Now let’s say a woman has had 10 pregnancies, her diabetes pedigree is
1.03, her glucose level is 130, and her BMI is 26. Plugging these values, we
get that the probability of her developing diabetes is 0.581. This could be
due to her pregnancies being higher than average and according to her BMI
she is overweight, which is a huge factor of developing diabetes. Her glucose
level, with reference to the boxplots, seems to be close to the
mean, and her diabetes pedigree is greater than average also.
Using another dataset containing 5 observations, we predict the outcome
based on their predictor values in the table below. The two rows with 0 outcomes
seem to have average values apart from row 2 having a BMI of 39. Other rows
have discerning factors that have made their probability of getting diabetes
> 0.5 (making their outcome 1), like pedigree (row 1), BMI (row 4) and
pregnancies (row 5).

| Pregnancies | Glucose | Blood Pressure | Skin Thickness | Insulin | BMI  | Diabetes Pedigree | Age | Predicted Outcome |
|-------------|---------|----------------|----------------|---------|------|-------------------|-----|-------------------|
| 4           | 136     | 70             | 0              | 0       | 31.2 | 1.182             | 22  | 1                 |
| 1           | 121     | 78             | 39             | 74      | 39.0 | 0.261             | 28  | 0                 |
| 3           | 108     | 62             | 24             | 0       | 26.0 | 0.223             | 25  | 0                 |
| 0           | 181     | 88             | 44             | 510     | 43.3 | 0.222             | 26  | 1                 |
| 8           | 154     | 78             | 32             | 0       | 32.4 | 0.443             | 45  | 1                 |

# 3.3 Model Accuracy

We simply cannot have a model without testing the accuracy of it. To test the accuracy, I have split the data into training and test data in a 70/30 split. I then trained my model on the training data then created confusion matrices for both training and test data to detect any over/underfitting. 
Seen in the next table, we have the training data:

| Actual \ Predicted | 0   | 1   |
|--------------------|-----|-----|
| 0                  | 278 | 39  |
| 1                  | 72  | 86  |

And the test data:

| Actual \ Predicted | 0   | 1   |
|--------------------|-----|-----|
| 0                  | 132 | 10  |
| 1                  | 27  | 36  |

The accuracy for the training data is 76.6%, and for the test data 82.0%.
There may be a concern of underfitting but more evaluation would need to
be done as the percentage difference is relatively small.

# References

[1] Jack Smith, J. Everhart, W. Dickson, W. Knowler, and Richard Johannes. Using the adap learning algorithm to forcast the onset of diabetes
mellitus. Proceedings - Annual Symposium on Computer Applications in
Medical Care, 10, 11 1988.

[2] MD Saranya Buppajarntham. Medscape - insulin reference
range, May 2023. https://emedicine.medscape.com/article/2089224overview?form=fpf.

[3] Weiya Li, Han Yin, Yilin Chen, Quanjun Liu, Yu Wang, Di Qiu, Huan
Ma, and Qingshan Geng. Associations between adult triceps skinfold
thickness and all-cause, cardiovascular and cerebrovascular mortality in
nhanes 1999–2010: A retrospective national study. Frontiers in Cardiovascular Medicine, 9, May 2022.

[4] Deepak Choudhary, Om Prakash Suthar, Pradeep Kumar Bhatia, and
Ghansham Biyani. “zero”diastolic blood pressure. The Indian Anaesthetists Forum, 17(1), 2016

[5] Unknown. Body mass index (bmi), Jan 2023.
https://www.nhsinform.scot/healthy-living/food-and-nutrition/healthy-eating-and-weight-loss/body-mass-index-bmi/.

[6] Sandeep K. Dhaliwal. Low blood sugar: Medlineplus medical encyclopedia. https://medlineplus.gov/ency/article/000386.htm.

