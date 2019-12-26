# A: Data collection -----------------------
# Load the data
col <- c("sex","length","diameter","height","whole.weight","shucked.weight","viscera.weight","shell.weight","rings")
data <- read.table("abalone.txt", sep=",", header = FALSE, col.names = col)

# B: Exploratory Data Analysis ########
# Type of each variable?
# Distribution of each variable: symmetric or skewed? outliers?
  # Quantitative: histogram, boxplot, summary statistics, etc.
  # Qualitative: pie chart, frequency table, etc.
# Relationships among variables.
  # scatter plot matrix, correlation matrix,
  # nonlinear pattern? clusters? outliers
 

# View the first 5 rows of the data
head(data)

# Check class 
sapply(data,class)
# Quantitative: length, diameter,height,whole.weight,shucked.weight,viscera.weight, shell.weight, rings
# Qualitative: sex

# Check missing data
any(is.na(data))

# B1: Histogram for all quantitative variables==========
# Histogram: the response variable is left skewed, no obvious outliers in predictor variables
par(mfrow=c(3,3))
for (i in 2:ncol(data)) 
{
  hist(data[,names(data)[i]], xlab=names(data)[i], main=paste("Histogram of", names(data)[i]))
}
par(mfrow=c(1,1))


# B2: Different transformations for response variable==========
# Comment: square root works best
par(mfrow=c(2,2))
hist(data$rings)
hist(log(data$rings))
hist(1/(data$rings))
hist(sqrt(data$rings))

# B3: Boxplot: ring by sex (full data)==============
boxplot(data$rings~data$sex,main="Rings by Sex",xlab="Sex",ylab="Rings",col=rainbow(3))

# B4: Pie chart for sex distribution (full data)========
lbls=c("Female","Infant","Male")
n= nrow(data)
pct=round(100*table(data$sex)/n)
lab=paste(lbls,pct)
lab=paste(lab,"%",sep="")
pie(table(data$sex),labels=lab,col=c("red","green","blue"),main="Sex distribution")

# C: Preliminary Investigation---------------------

# C1: Fit linear regression model========
# unequal variance, outliers discovered, heavy-tailed
fit <- lm(rings~.,data=data)
summary(fit)
par(mfrow=c(2,2))
plot(fit)
par(mfrow=c(1,1))

# Outlier
data[data$height==1.130,]

# C2: Boxcox procedure===============

library(MASS)
boxcox(rings~.,data=data) # suggests a log transformation for the response variable

# C3: Log-rings summary=============

fit_logY <- lm(log(rings)~.,data=data)
summary(fit_logY)
par(mfrow=c(2,2))
plot(fit_logY)
par(mfrow=c(1,1))

# C4: Scatterplot matrix after transformation===============

# Before log transform: pairwise scatter plots among quantitative variables
plot(cbind(data$rings, data[c("length", "diameter","height","whole.weight","shucked.weight","viscera.weight", "shell.weight")]))

# Aefore log transform: pairwise scatter plots among quantitative variables
plot(cbind(log(data$rings), data[c("length", "diameter","height","whole.weight","shucked.weight","viscera.weight", "shell.weight")]))

# Pairwise correlation matrix with log-transformed response variable
cor(cbind(log(data$rings), data[c("length", "diameter","height","whole.weight","shucked.weight","viscera.weight", "shell.weight")]))

# C5: Correlation matrix after transformation===============

# Visualize the pairwise correlation
library(corrplot)
corrplot(cor(cbind(log(data$rings), data[c("length", "diameter","height","whole.weight","shucked.weight","viscera.weight", "shell.weight")]))
,method="number")

# Distribution of log-rings with each class of sex
boxplot(log(data$rings)~data$sex,main="Log-rings by Sex",xlab="Sex",ylab="Rings",col=rainbow(3))
# The distribution of rings is more symmetric in within each class of sex


# D: Model Selection----------------------------

# D1: Split training and testing data==============
set.seed(100)
# Randomly select index from 1 to 4177 for 3341 times
trainIndex <- sample(1: n, size=n*0.8, replace=FALSE)
trainData <- data[trainIndex,] # 3341 cases
testData <- data[-trainIndex,] # 836 cases

# D2: Examine training and testing data distribution==============
# Examine the distribution of both training and testing data
# Training and validation sets have similar distribution
par(mfrow=c(3,3))
for (i in 2:ncol(trainData)){
  name <- names(trainData)[i]
  boxplot(trainData[,name],testData[,name],main=name,names=c("Training","Validation"))
} 
par(mfrow=c(1,1))

# Pie chart for sex distribution for training and test sets
par(mfrow=c(1,2))
train_lbls <- c("Female","Infant","Male")
train_n <- nrow(trainData)
train_pct <- round(100*table(trainData$sex)/train_n)
train_lab <- paste(train_lbls,train_pct)
train_lab <- paste(train_lab,"%",sep="")
pie(table(trainData$sex),labels=train_lab,col=c("red","green","blue"),main="Sex distribution (Training)")

test_lbls <- c("Female","Infant","Male")
test_n <- nrow(testData)
test_pct <- round(100*table(testData$sex)/test_n)
test_lab <- paste(test_lbls,test_pct)
test_lab <- paste(test_lab,"%",sep="")
pie(table(trainData$sex),labels=test_lab,col=c("red","green","blue"),main="Sex distribution (Validation)")
par(mfrow=c(1,1))

# D3: Stepwise selection ======================
# None model
none_mod = lm(log(rings)~1, data=trainData)
# Full model
model1 = lm(log(rings)~.,data=trainData)

#forward selection based on AIC
stepAIC(none_mod, scope=list(upper=model1), direction="forward", k=2)
# Best: log(rings) ~ diameter + shucked.weight + shell.weight +  sex + height + whole.weight + viscera.weight + length

#backward elimination based on AIC
stepAIC(model1, direction="backward", k=2)
# Best: log(rings) ~ sex + length + diameter + height +  whole.weight + shucked.weight + viscera.weight + shell.weight

# forward stepwise selection based on AIC
stepAIC(none_mod, scope=list(upper=model1), direction="both", k=2)
# Best: log(rings) ~ diameter + shucked.weight + shell.weight +  sex + height + whole.weight + viscera.weight + length,

# E: Model Validation---------------------

train1 = lm(log(rings) ~., data = trainData)
valid1 = lm(log(rings)~., data = testData)
# Set seed for reproducibility

mod_sum = cbind(coef(summary(train1))[,1], coef(summary(valid1))[,1],coef(summary(train1))[,2], coef(summary(valid1))[,2])
colnames(mod_sum) = c("Train Est","Valid Est","Train s.e.","Valid s.e.")
mod_sum # Comment: Most of the estimated coefficients as well as 
# their standard errors agree quite closely on the two data sets, which implies the consistency in parameter estimation.

# Examine the SSE and adjusted R squares using both the training dataand validation data.
sse_t = sum(train1$residuals^2)
sse_v = sum(valid1$residuals^2)
Radj_t = summary(train1)$adj.r.squared
Radj_v = summary(valid1)$adj.r.squared
train_sum = c(sse_t,Radj_t)
valid_sum = c(sse_v,Radj_v)
criteria = rbind(train_sum,valid_sum)
colnames(criteria) = c("SSE","R2_adj")
criteria
# The SSE in training set is much larger than that of the validation set

# Examine the predictive ability of the model
# Compute MSPE_v from new data
mspe <- function(model, x_train, y_train, y_test){
  y.hat = predict(model, y_train)
  MSPE = mean((y_test - y.hat)^2)
  table <- rbind(MSPE, sse_t/(nrow(x_train)))
  rownames(table) <- c("MSPE", "SSE/n")
  return (table)
}
mspe(train1, trainData, testData[,names(testData)[1:8]], testData$rings)


# Severe overfitting by using the full model. 

# F: Model Diagonstics---------------------

# F1: Outlying Y observations=============
outY<- function(model, data, alpha){
  stu.res.del <- studres(model)
  stu.res.dels <- sort(abs(stu.res.del), decreasing=TRUE)
  p <- length(unlist(model[names(model)=="coefficients"]))# number of coefficient
  n <- nrow(data) # sample size
  threshold <- qt(1-(alpha/(2*n)), n-p-1)
  # Return all absolute values that are greater than threshold
  return (stu.res.dels[abs(stu.res.dels)>threshold])
}

outY(train1,trainData,0.1)


# F2: Outlying X observations===========
outX<- function(model, data){
  influ <- influence(model)
  h <- as.vector(unlist(influ[names(influ)=="hat"]))
  p <- length(unlist(model[names(model)=="coefficients"]))
  n <- nrow(data)
  index.X <- which(h>(2*p/n))
  return(index.X)
}
index.X <- outX(train1,trainData)
length(outX(train1,trainData)) # 218 outliers in terms of X

# F3: Cook distance ====================

cook <- function(model){
  influ <- influence(model)
  h <- as.vector(unlist(influ[names(influ)=="hat"]))
  res <- unlist(model[names(model)=="residuals"])
  mse <- anova(model)["Residuals", 3]
  p <- length(unlist(model[names(model)=="coefficients"]))
  cook.d <- res^2*h/(p*mse*(1-h)^2)
  index.X <- which(h>(2*p/n))
  list.of.cook <- which(sort(cook.d[index.X], decreasing = TRUE)>(4/(n-p)))
  return(names(list.of.cook))
}
cook(train1)



# Cook distance plot
plot(train1, which=4)
plot(train1, which=5)



# Save the result
#save(fit, file=”name.RData”)
#load(”name.RData”)
#save.image(file=”name.RData”)

