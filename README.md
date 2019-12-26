# Abalone's Age Prediction

In this study, we aim to resolve the traditionally tedious and time consuming task of determining the age of abalone by constructing predictive models of the ages of abalones using other physical measures that are easier to obtain. Based on the dataset with which we are provided, we construct models of various complexities and propose the one with the highest out-of-sample prediction performance. Our model is able to control the mean squared prediction error to an infinitesimal extent, while subject to only a reasonably small model bias. In addition, we also explore the possibilities of conjecturing other interior content (in-shell information), such as shucked weights of abalone, using measurements which can be obtained prior to cracking the shell (out-of-shell information). Our results show that not only is predicting such in-shell measures with out-of-shell information feasible, but one might achieve even better results than making predictions on the ages of the abalones.

## Methods and Results 

### Exploratory Data Analysis and Processing

To begin, we start off by investigating the distribution within each variable, continuous and categorical, respectively. As shown in ​`Figure 1​` below, 

![](/figures/figure1)
*image_caption*

a few variables appear to be right-skewed, and clearly there are outliers to be removed in the variable ​height.​ We devote the next paragraph to the issue of outliers. Here, we examine some candidate transformations in order to fix the skewness in the response variable of interest, ​rings,​ the results of which are shown in ​`Figure 2​`. 

![](/figures/figure2)
*image_caption*

Multiple transformations seem to be appropriate, so we will apply a Box-Cox procedure later to rigorously select the transformation. Then, we study the distribution of outcome variable and overall sample observations across different levels of the categorical variable, ​Sex​. We can see from ​`Figures 3 ​and ​4​` that the data is pretty evenly split across the levels of ​Sex​, and that Males and Females have similar but slightly different distributions than that of the Infants.

![](/figures/figure3)
*image_caption*

![](/figures/figure4)
*image_caption*

Next, we regress the outcome variable on all the predictor variables so we can detect the existence of any potential outliers. In addition to non-linear residuals and heteroscedasticity, `Figure 5​` also shows signs of outliers in both the outcome and the predictor dimensions. So, we apply a Cook’s Distance measure to help remove the outliers, in both outcome and predictor dimensions. 

![](/figures/figure5)
*image_caption*

Our calculation shows that a total of $105$ observations are outlying at the 95% level. Since the sample size exceeds the numbers of outliers massively, these outliers are then removed from the sample. A set of new histograms are plotted and presented in ​`Figure 6​` after the removal. It is safe to conclude that no obvious outliers are present in the continuous variables.

![](/figures/figure6)
*image_caption*

Furthermore, we proceed to decide the transformation to apply on the outcome variable, rings.​ As is implied in ​`Figure 7`, t​ he Box-Cox procedure suggests that the log-transformation is appropriate. 

![](/figures/figure7)
*image_caption*

So the linear model is fitted again with the log-transformed outcome variable, and this time, the non-linearity in the residuals (indicated by ​`Figure 5​`) has reduced, error variance appears to be constant, and other model assumptions also appear to be satisfied (​`Figure 8​`).

![](/figures/figure8)
*image_caption*

`Figure 9` d​epicts that there might be some non-linear relations between the log-outcome and some predictor variables. Therefore, we have left a whole section of discussion below to showcase the second-order models. While some of the weight measures appear to be highly collinear as is seen in ​`Figure 10`,​ for our purpose of prediction, we will leave this issue to the model selection technique with the hope of it excluding the redundant variables.

![](/figures/figure9)
*image_caption*

![](/figures/figure10)
*image_caption*

Lastly, to further simplify the candidate features, we split all variables by the levels of Sex​ and plot relevant graphs presented in ​`Figuers 11​ to ​13`.​ Consequently, we have found strong signal that Males and Females can be combined into one, as one can hardly distinguish them from their mixture. Therefore, we aggregate them to be Adults, and are left with two levels, Adults & Infants, for this categorical variable.

![](/figures/figure11)
*image_caption*

![](/figures/figure12)
*image_caption*

![](/figures/figure13)
*image_caption*

### Model Selection: First-Order Additive Model

Prior to performing the model selection in `R`, we first split the processed sample data into a training set ($80%$ of the observations) and a validation set ($20%$). We then use the validation set to validate our model that is built on training data. This step is then followed by the comparison of variables between the two sets. As is displayed in ​`Figures 14​ and ​15​`, the two sets are highly comparable in all variables.

![](/figures/figure14)
*image_caption*

![](/figures/figure15)
*image_caption*

We implement the Stepwise Model Selection Procedures in `R` in all three ways, i.e. forward selection, backward elimination, and forward stepwise. The full model includes all the variables in their original forms; whereas the null model is ​log(rings)​ regressed on a vector of 1’s. Since our goal is to make prediction, $AIC$ is naturally the choice of model selection criterion. As a result, all 3 directions point to the same model as expressed below:

![](/figures/figure17)


the $AIC$ of which attains the lowest level of $-10670.94$, and an $R_{a}^{2}$  of $0.6193$. In order to show the consistency in the parameter estimation, we use both the training and validation data to fit the “best” model selected by the stepwise procedures. 

As shown in `Table 1`, most of the estimated coefficients as well as their standard errors agree quite closely on the two data sets, which implies the consistency in the parameter estimation. We also examine the $\frac{SSE}{n}$ and $R_{a}^{2}$ using both the training data and validation data. From `Table 2`, we see that the $R_{a}^{2}$  are quite close to each other, so are the $\frac{SSE}{n}$ measures of the training data and the validation data. Moreover, using the validation set, we calculate the mean squared prediction error ($MSPE$) to be $0.03588815$, which is identical to $\frac{SSE}{n}$, $0.03781645$, up until the third decimal place; hence, we believe that there is hardly any overfitting in our model. Finally, the Mallow’s $Cp$ for this model is exactly $9$, equal to the size of the model, indicating that this is a correct model and thus subject to no bias.

![](/tables/table1)
*image_caption*

### Model Selection: Second-Order Polynomial Model with Interaction Terms

In order to attempt to tackle the non-linearity in the residuals as mentioned above, we experiment with models that are on another level of complexity, second-order polynomial models with interactions. Our full model in this case contains all first-order variables, their squared forms, and all the two-way interaction terms, with $8$, $8$, and $28$ terms, respectively. Similar to the above scenario, we apply the stepwise procedure in 3 directions, and pick the model with the lowest $AIC$ to compare with the afore-chosen first-order model.

Different from the above, this time the backward elimination yields a model with an AIC of $-11175$, slightly smaller than the AIC of the other two (same model chosen by the other two), $-11172$. Model specification is omitted here for brevity. This model has an $R_{a}^{2}$ of $0.6701$, alongside $27$ predictor variables in total (plus an intercept; so p is 28), including 8 first-order terms, 5 second-order terms, and $14$ two-way interaction terms. In comparing the $MSPE$, $0.03346289$, and the SSE/n, $0.03183063$, we examine the out-of-sample prediction power of this model. It is clear that the overfitting of this model is very tiny. However, Mallow's $Cp$, $15.78186$, is a bit smaller than $p$, suggesting that the model is subject to some non-negligible bias.

While this model shows some improvement in $R_{a}^{2}$ and Akaike Information Criterion (AIC), it is very likely that this model is not a correct model. Additionally, the model complexity is way higher than the first-order model introduced in Equation (1). Therefore, by the Principle of Parsimony and the model bias suggested by Mallow’s $Cp$, we propose the first-order model to be our predictive model of the ages of abalones.

### Model Selection: Predictive Model for In-Shell Content

To test the feasibility of predicting the in-shell information from out-shell information, we performed model selection on predicting each of the four in-shell variables (shucked weight, viscera weight, shell weight, and rings) with all five variables of physical measures (sex, length, diameter, height, and weight). For consistency in comparison, the training and testing data sets are the same as the previous sections.

Like before, forward selection, backward elimination, and forward stepwise procedures on first-order without interaction variables are employed with $AIC$ criterion in selecting the best model. Consequently, the best models for each prediction task are reported below:

![](/figures/figure18)

When performing model validation, $MSPE$, Mallow’s $Cp$, and $R_{a}^{2}$ are used as criterion for consistency. The results are summarized in ​`Table 3​` . We see that there is no obvious overfitting of the model, as $MSPE$ is very small and reasonably close to $\frac{SSE}{n}$ in all four cases. We also notice that shucked weight and log-transformed rings have higher $MSPE$ than $\frac{SSE}{n}$, suggesting that the model fit the testing data better than the training data. We suspect that the reason for such phenomena might be the random shuffling of the data. Mellow’s $Cp$ values, on the other hand, are also very close to $p$, suggesting small model bias. Therefore, it is safe to conclude that we can predict in-shell content given out-of-shell information. This discovery aligns with our observations upon investigating correlation matrix, where high correlations exist among different weights measures. If the out-of-shell variables can be used to predict the log-transformed rings, it is natural to believe that such relationships also exist between the out-shell variables and the other in-shell variables.

Another interesting observation is that the $R_{a}^{2}$ values of the models with dependent variables shucked weight, visera weight, and shell weight, respectively, are drastically higher than that of the model for log-transformed rings. Such comparison indicates that the datasets are likely to be more suitable in predicting other in-shell content than the rings. This section of the study provides a justification for the possibility of building predicting models on in-shell content from the out-of-shell physical measures. But since we have only examined the first-order models with no interaction, further investigations are appropriate for better prediction results.

## Conclusion and Discussion

Overall, we have developed a model, as described in Equation (1), that best captures the ages of the abalones given this particular data set. While a more complex model seems to outperform the first-order additive model in some ways, the model bias manifesting in the Mallow’s Cp undermines its predictive power from the in-sample perspective. We believe that the proposed model can effectively tackle the real-world technicality in identifying the ages of the abalones only using the physical measures, and hence is expected to improve the efficiency of this task with a reasonably low error.

On the other hand, despite the outstanding performance of our predictive model on ages, our findings also suggest that the available data is more suitable in building a model to infer other interior content, such as shucked weights, than a model of predicting the ages. Both the goodness-of-fit measures and the out-of-sample prediction measures provide strong evidence in support of our claim. Therefore, one would expect the set of models studied here to have other empirical values in addition to predicting the ages of the abalones.

Lastly, in order to holistically characterize and therefore best predict the ages of the abalones, one should also take into account other factors including climate patterns, water salinity, temperatures, etc. Further research is appropriate to determine what other factors would contribute to the success of this task.

## Data Source
[Abalone Data Set](https://archive.ics.uci.edu/ml/datasets/Abalone)


## Authors

Kenneth Lee ([@kenneth-lee-ch](https://github.com/kenneth-lee-ch))

Miao Hu 

Roger Zhou.

## Reference
Warwick J Nash, Tracy L Sellers, Simon R Talbot, Andrew J Cawthorn and Wes B Ford (1994) "The Population Biology of Abalone (Haliotis species) in Tasmania. I. Blacklip Abalone (H. rubra) from the North Coast and Islands of Bass Strait", Sea Fisheries Division, Technical Report No. 48 (ISSN 1034-3288)

## License
[MIT](https://choosealicense.com/licenses/mit/)
If you do find this script useful, a link back to this repository would be appreciated. Thanks!