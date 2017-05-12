---
title: "Propensity score matching with R"
layout: post
bibliography: /home/jrl/text/library.bib
---



In impact evalations it is often necessary to measure the effect of a treatment, be it a support measure, training program or some other action. To make unbiased conclusions about the true effect, it is then neccessary to take into account what would have happened without a treatment, i.e. evaluate a counterfactual situation. Subtracting the outcome of a control group from the result of treated observatons allows us to do just that but it is crucial to control for selection bias. Impact evaluations are usually carried out retrospectively and many treatments permit random assignment of invdividuals into treatment and control groups. Thus, experimental research design (most prominently randomized controlled trials) can not be employed in such cases and we need to adopt non- or quasi-experimental methods. In the latter case, a pseudo control group is created so that it accurately reflects the counterfactual situation. Perhaps the most popular method for this purpose is  propensity score matching (PSM). The propensity of each observation to be treated (i.e. propensity score) is assessed and then observatons with close values of this assessment are compared. This allows us to compare observations where treatment can be the only source of differences in outome, thus mitigating selection bias.

There are at least two R packages that help performing the matching, namely [MatchIt](https://cran.r-project.org/package=MatchIt) and [Matching](https://cran.r-project.org/package=Matching). However, I felt like taking a more hands-on approach.

# Data entry

In order to carry out PSM analysis we need a rather specific data set. Unfortunately, data that contains non-experimental treatment and control group as well as confounding variables predicting treatment and the outcome is rather hard to come by. Thus, we'll be using data set provided by @Lalonde1986 that includes the resuls of an employment and training program. This data set has previously been used by @Sekhon2011a to demonstrate some functions related to PSM. The data is available for treament and control group observations as separate tables. So we will load these tables and bind them into a data frame using only columnns that are present in both tables. The last variables contain earnings of individuals in respective years.


```r
treated <- read.table('http://users.nber.org/~rdehejia/data/nsw_treated.txt',
                      col.names = c('treated', 'age', 'education', 'black', 'hispanic', 'married',
                      'nodegree', 're75', 're78'))
control <- read.table('http://users.nber.org/~rdehejia/data/cps_controls.txt',
                      col.names = c('treated', 'age', 'education', 'black', 'hispanic', 'married',
                      'nodegree', 're74', 're75', 're78'))
lalonde <- rbind(treated[intersect(colnames(treated), colnames(control))],
                 control[intersect(colnames(treated), colnames(control))])
head(lalonde)
```

```
##   treated age education black hispanic married nodegree re75       re78
## 1       1  37        11     1        0       1        1    0  9930.0460
## 2       1  22         9     0        1       0        1    0  3595.8940
## 3       1  30        12     1        0       0        0    0 24909.4500
## 4       1  27        11     1        0       0        1    0  7506.1460
## 5       1  33         8     1        0       0        1    0   289.7899
## 6       1  22         9     1        0       0        1    0  4056.4940
```

# The problem

We use `by` to get the summary of different variables separately for treated and other individuals.


```r
by(lalonde, lalonde$treated, summary)
```

```
## lalonde$treated: 0
##     treated       age          education         black        
##  Min.   :0   Min.   :16.00   Min.   : 0.00   Min.   :0.00000  
##  1st Qu.:0   1st Qu.:24.00   1st Qu.:11.00   1st Qu.:0.00000  
##  Median :0   Median :31.00   Median :12.00   Median :0.00000  
##  Mean   :0   Mean   :33.23   Mean   :12.03   Mean   :0.07354  
##  3rd Qu.:0   3rd Qu.:42.00   3rd Qu.:13.00   3rd Qu.:0.00000  
##  Max.   :0   Max.   :55.00   Max.   :18.00   Max.   :1.00000  
##     hispanic          married          nodegree           re75      
##  Min.   :0.00000   Min.   :0.0000   Min.   :0.0000   Min.   :    0  
##  1st Qu.:0.00000   1st Qu.:0.0000   1st Qu.:0.0000   1st Qu.: 4399  
##  Median :0.00000   Median :1.0000   Median :0.0000   Median :14557  
##  Mean   :0.07204   Mean   :0.7117   Mean   :0.2958   Mean   :13651  
##  3rd Qu.:0.00000   3rd Qu.:1.0000   3rd Qu.:1.0000   3rd Qu.:22924  
##  Max.   :1.00000   Max.   :1.0000   Max.   :1.0000   Max.   :25244  
##       re78      
##  Min.   :    0  
##  1st Qu.: 5669  
##  Median :16422  
##  Mean   :14847  
##  3rd Qu.:25565  
##  Max.   :25565  
## -------------------------------------------------------- 
## lalonde$treated: 1
##     treated       age          education         black       
##  Min.   :1   Min.   :17.00   Min.   : 4.00   Min.   :0.0000  
##  1st Qu.:1   1st Qu.:20.00   1st Qu.: 9.00   1st Qu.:1.0000  
##  Median :1   Median :23.00   Median :11.00   Median :1.0000  
##  Mean   :1   Mean   :24.63   Mean   :10.38   Mean   :0.8013  
##  3rd Qu.:1   3rd Qu.:27.00   3rd Qu.:12.00   3rd Qu.:1.0000  
##  Max.   :1   Max.   :49.00   Max.   :16.00   Max.   :1.0000  
##     hispanic          married          nodegree           re75      
##  Min.   :0.00000   Min.   :0.0000   Min.   :0.0000   Min.   :    0  
##  1st Qu.:0.00000   1st Qu.:0.0000   1st Qu.:0.0000   1st Qu.:    0  
##  Median :0.00000   Median :0.0000   Median :1.0000   Median : 1117  
##  Mean   :0.09428   Mean   :0.1684   Mean   :0.7306   Mean   : 3066  
##  3rd Qu.:0.00000   3rd Qu.:0.0000   3rd Qu.:1.0000   3rd Qu.: 4310  
##  Max.   :1.00000   Max.   :1.0000   Max.   :1.0000   Max.   :37432  
##       re78        
##  Min.   :    0.0  
##  1st Qu.:  549.3  
##  Median : 4232.3  
##  Mean   : 5976.4  
##  3rd Qu.: 9381.3  
##  Max.   :60307.9
```

It is evident that our initial control group is unbalanced since the distribution of the characteristics of individuals is very different. The change in median earnings for treated individuals between 1975 and 1978 is 3114.87. For others it is 1864.865. When adopting a "naive" approach we would assume that treatment increased medium earnings by the difference between the two values, i.e. 1250.005. As treated individuals might have had a higher increase even without treatment, we would thus overestimate the effect of treatment by considering all of the individuals. It is thus necessary to create a balanced pseudo control group in order to simulate the counterfactual situation.

# Calculating propensity scores

Here we would like to assess the effect of treatment on earnings in 1978. We assume that age, years in education, race, marital status, academic degree and earnings in 1975 have an effect on both. So these need to be considered as confounding variabes and will be used to calulate the propensity score.

# Building a propensity score model

Since treatment status is indicated as a binary (dummy) variable, we will fit a logistic regression model on the data. Then we perform a stepwise regression that seeks to minimize the value of Akaike Information Criterion (AIC).


```r
prop.model <- glm(treated ~ age + education + black + hispanic + married + nodegree + re75, 
                  data = lalonde, family = binomial(link = "logit"))
step(prop.model)
```

```
## Start:  AIC=1546.88
## treated ~ age + education + black + hispanic + married + nodegree + 
##     re75
## 
##             Df Deviance    AIC
## <none>           1530.9 1546.9
## - education  1   1533.6 1547.6
## - age        1   1538.5 1552.5
## - nodegree   1   1568.4 1582.4
## - married    1   1577.0 1591.0
## - hispanic   1   1585.7 1599.7
## - re75       1   1617.7 1631.7
## - black      1   2271.7 2285.7
```

```
## 
## Call:  glm(formula = treated ~ age + education + black + hispanic + 
##     married + nodegree + re75, family = binomial(link = "logit"), 
##     data = lalonde)
## 
## Coefficients:
## (Intercept)          age    education        black     hispanic  
##  -5.3562180   -0.0227897    0.0641759    4.1588862    2.1743388  
##     married     nodegree         re75  
##  -1.2394148    1.2704833   -0.0001162  
## 
## Degrees of Freedom: 16288 Total (i.e. Null);  16281 Residual
## Null Deviance:	    2967 
## Residual Deviance: 1531 	AIC: 1547
```

According to AIC values, all of the variables improve the quality of the model. 

Next, we examine coefficients.


```r
summary(prop.model)
```

```
## 
## Call:
## glm(formula = treated ~ age + education + black + hispanic + 
##     married + nodegree + re75, family = binomial(link = "logit"), 
##     data = lalonde)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -1.3476  -0.0850  -0.0359  -0.0172   3.8175  
## 
## Coefficients:
##               Estimate Std. Error z value Pr(>|z|)    
## (Intercept) -5.356e+00  6.403e-01  -8.366  < 2e-16 ***
## age         -2.279e-02  8.470e-03  -2.691  0.00713 ** 
## education    6.418e-02  3.926e-02   1.635  0.10214    
## black        4.159e+00  2.009e-01  20.704  < 2e-16 ***
## hispanic     2.174e+00  2.704e-01   8.041 8.92e-16 ***
## married     -1.239e+00  1.904e-01  -6.511 7.45e-11 ***
## nodegree     1.270e+00  2.123e-01   5.984 2.18e-09 ***
## re75        -1.162e-04  1.404e-05  -8.278  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 2967.2  on 16288  degrees of freedom
## Residual deviance: 1530.9  on 16281  degrees of freedom
## AIC: 1546.9
## 
## Number of Fisher Scoring iterations: 9
```

```r
prop.model <- glm(treated ~ age + black + hispanic + married + nodegree + re75, 
                  data = lalonde, family = binomial(link = "logit"))
```

The coefficient of education is not significantly different from zero, so we updated our model not to include it. 

The dependent variable in logistic regression is binary and we can adjust the predicted values to describe binary outcome. too. Thus, we can draw a classificaion table that illustrates how well the model classifies the observations.


```r
table(prop.model$fitted.values > .5, lalonde$treated, dnn = c("Predicted", "True"))
```

```
##          True
## Predicted     0     1
##     FALSE 15908   221
##     TRUE     84    76
```

The classification table indicates that the proportion of correctly classified treated observations is 0.9812757. This is a rather high rate.

We also calculate a few other statistics that help us evaluate a logistic regression model.


```r
# McFadden's pseudo R-squared value of the model
1 - (prop.model$deviance/prop.model$null.deviance)

# Test the model against a null model
pchisq(prop.model$null.deviance - prop.model$deviance, 
       prop.model$df.null - prop.model$df.residual, lower.tail = FALSE)
```

According to @McFadden1978, the value of McFadden's pseudo-R between 0.2 and 0.4 indicates an exellent model fit. The value we obtained is even higher. We can also reject the null hypothesis that all the coefficients in the model equal zero.

This model performs well enough on our data to use the fitted values of the dependent variable as propensity score values for each individual.

## Creating pseudo control group

Next we create a new variable and assign it propensity scores from the model. We can again use *by* to examine summary statistics of propensity scores separately for treated and other individuals. The comparison of two groups can also be plotted and adding some jitter gives a better overview.


```r
lalonde$propensity <- c(prop.model$fitted.values, use.names = F)
by(lalonde$propensity, lalonde$treated, summary)
```

```
## lalonde$treated: 0
##      Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
## 0.0000441 0.0001544 0.0006743 0.0129976 0.0038139 0.5820945 
## -------------------------------------------------------- 
## lalonde$treated: 1
##      Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
## 0.0007684 0.1232701 0.2850716 0.3001407 0.5037444 0.5756670
```

```r
plot(lalonde$propensity, jitter(lalonde$treated), 
     xlab = "Propensity score", ylab = "Treatment status")
```

![](/assets/img/propensity_score_matching_with_R/unnamed-chunk-7-1.png)

As anticipated, the probability of treated observations to be treated is substantially higher.

There are various matching techniques that can be implemented to select appropriate individuals for control group, e.g. nearest-neighbour, kernel or caliper matching. Here we will use the latter as it allows us to set an acceptable range which functions as quality control [@Bryson2002, 27]. Standard deviation of the propensity score values of treated observations is adopted as the caliper. Every not treated individual whose propensity score is within the caliper of any treated individual's propensity score is placed in the control group. We will follow @Austin2011 who recommends using 0.2 standard deviations as the caliper width.




