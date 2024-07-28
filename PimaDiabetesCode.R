library(dplyr)
library(corrplot)
library(moments)
library(mice)
library(car)

setwd("/Users/Milly/Documents/DATA70121/Assignment1")
pima = read.csv("PimaDiabetes.csv")
pimapred = read.csv("ToPredict.csv")
summary(pima) 

sum(is.na(pima)) # no NA values detected
pimaBMI0 <- pima[which(pima$BMI == 0),]
pimagluc0 <- pima[which(pima$Glucose == 0),]
pimaIns0 <- pima[which(pima$Insulin==0),]
pimaBP0 <- pima[which(pima$BloodPressure==0),]
pimaskin0 <- pima[which(pima$SkinThickness==0),]
pimapreg0 <- pima[which(pima$Pregnancies==0),]
pimaAge0 <- pima[which(pima$Age==0),]
pimaDia0 <- pima[which(pima$Outcome==0),]

columns_to_impute <- c("Insulin", "SkinThickness", "BloodPressure", "BMI", "Glucose")
pima[columns_to_impute][pima[columns_to_impute] == 0] <- NA


pima2 <- pima %>%
  select(-9)
list_outliers <- data.frame()
outlier_rows_df <- data.frame()
par(mfrow=c(2, 4))
for (i in 1:ncol(pima2)) {
  boxplot(pima2[,i], main = names(pima2)[i])
  
  outliers <- boxplot(pima2[,i], plot = FALSE)$out
  outlier_obs <- which(pima2[, i] %in% outliers)
  outlier_data <- pima[outlier_obs, i]
  list_outliers <-  data.frame(Column = rep(names(pima2)[i], length(outlier_data)), 
                               Row = outlier_obs, 
                               Outliers = outlier_data)
  outlier_rows_df <- rbind(outlier_rows_df, list_outliers)
}

outlier_rows_df <- outlier_rows_df %>%
  filter(!(Column %in% c("Pregnancies", "Age")))
all_outliers <- unique(outlier_rows_df$Row)
pima3 <- pima[-c(all_outliers),]

cor_matrix <- cor(pima3,use = "pairwise.complete.obs")
corrplot(cor_matrix, method = "color", type = "upper", tl.col = "black",
         tl.srt = 45, addCoef.col = "black", tl.cex=0.45)

plotcolumns <- colnames(pima3)[colnames(pima3) != "Outcome"]
par(mfrow = c(2, 4))
for (col in plotcolumns) {
  non_na_values <- na.omit(pima3[[col]])
  hist(pima3[[col]], main = col, xlab = col, prob = TRUE, col = "magenta", breaks = 20)
  lines(density(non_na_values), col = "purple4", lwd = 2)
}

skew <- skewness(pima3[,columns_to_impute], na.rm=T)
skew


# Imputation

# Performing mean imputation for 'BloodPressure', since skewness is small
pima3$BloodPressure[is.na(pima3$BloodPressure)] <- mean(pima3$BloodPressure, na.rm = TRUE)

# Performing median imputation for other columns, since their skewness is large (>0.5 or <-0.5)
for (col in setdiff(columns_to_impute, "BloodPressure")) {
  pima3[[col]][is.na(pima3[[col]])] <- median(pima3[[col]], na.rm = TRUE)
}



pima3 <- pima3 %>%
  mutate(SevenOrMorePregnancies = ifelse(pima3$Pregnancies >= 7, "Yes", "No"))

model_7preg <- glm(Outcome ~ SevenOrMorePregnancies, data = pima3, family = binomial)
summary(model_7preg)

logregpredict <- function(b0, b1, SevenOrMorePregnancies) {
  p <- 1 / (1 + exp(-(b0 + b1 * SevenOrMorePregnancies)))
  return(p)
}

b0 <- -1.03217
b1 <- 1.23696  
predicted_prob1 <- logregpredict(b0, b1, 1)
print(predicted_prob1)
predicted_prob0 <- logregpredict(b0, b1, 0)
print(predicted_prob0)
# another way to predict:
prob_six <- predict(model_7preg, newdata = data.frame(SevenOrMorePregnancies = "No"), type = "response")
print(prob_six)
prob_seven <- predict(model_7preg, newdata = data.frame(SevenOrMorePregnancies = "Yes"), type = "response")
print(prob_seven)

pima3 <- pima3[, !colnames(pima3) %in% c("SevenOrMorePregnancies")]

model <- glm(Outcome ~., data = pima3, family = binomial)
summary(model)

model1 <- glm(Outcome~BMI+Glucose+DiabetesPedigree+Pregnancies, data = pima3, family= binomial)
summary(model1)
vif(model1)

#predicting outcome in topredict.csv
predicted3 <- predict(model1, newdata = pimapred, type = "response")
pred <- ifelse(predicted3 > 0.5, 1, 0)
pimapred$Predicted_Outcome <- pred
print(pimapred)


# train/test data
set.seed(123) 
trainIndex <- sample(1:nrow(pima3), 0.7 * nrow(pima3))  # 70% train, 30% test
trainData <- pima3[trainIndex, ]
testData <- pima3[-trainIndex, ]
model2 <- glm(Outcome~BMI+Glucose+DiabetesPedigree+Pregnancies, data = trainData, family=binomial)
summary(model2)
predictedt <- predict(model2, newdata = trainData, type = "response")
predt <- ifelse(predictedt > 0.5, 1, 0 )
conf_matrixt <- table(Actual = trainData$Outcome, Predicted = predt)
conf_matrixt
predicted <- predict(model2, newdata = testData, type = "response")
pred <- ifelse(predicted > 0.5, 1, 0 )
conf_matrix <- table(Actual = testData$Outcome, Predicted = pred)
conf_matrix

