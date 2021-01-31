* Applications of Econometrics
* Lab 3 - Week 4
* Adam Turner | s1811672

* NOTE ALL use, ssc AND cd COMMANDS HAVE BEEN COMMENTED OUT FOR UPLOAD!

* Note: /// is the line-join or line-continuation marker when ending a line
version 14

/// PREAMBLE START ///

* Drop all existing variables and graphs - this is for when running the do file
*   many times to avoid Stata errors. We also clear the (interactive) screen
capture log close         // Stops logging
set more off, permanently // Disable pagination
graph drop _all           // Clears all graphs
clear all                 // Clears all data
cls                       // Clears the screen

//* Install required packages from SSC (Statistical Software Components) Archive
//ssc install estout, replace

* Set working directory
cd "I:\OneDrive\OneDrive - University of Edinburgh\Uni\Year 3\Applications of Econometrics\Labs"

* Import data from DTA file
use "lab3-fred.dta"
 * Data is inflation & unemployment against time.

* Set log file
log using "aofe_lab_03.log", replace

* Set time series var
tsset year

/// PREAMBLE END ///

*** Question 1.i ***

  * Estimate the static Phillips curve equation 
  * inf_t = \beta_0 + \beta_1 unem_t + u_t 
  * by OLS including all years (1960-2019). Interpret your result.

regress inf unem
  * Regress inflation on unemployment

  * Beta_1 is 0.27, indicating a +ve relationship between unemployment and 
  * inflation. This is not what the phillips curve precicts!

*** Question 1.ii ***

  * Obtain the OLS residuals from part (i), u_t, and obtain \rho from the 
  * regression u_t on u_{t-1}. (It is fine to include an intercept in this 
  * regression.) Is there strong evidence of serial correlation?

predict double errors, residuals 
  * use double float precision
regress errors l.errors

  * Beta = 0.789, t = 9.78, strong evidence of +ve serial correlation.

*** Question 1.iii ***

  * Now estimate the static Phillips curve model by iterative Prais-Winsten for 
  * the periods 1960-2006 and 1960-2019. Interpret your results.

prais inf unem if year <= 2006
  * Better way of modifying time period?
prais inf unem

  * Adding 15 years decreases Beta from -0.50 to 0.54, and increases the 
  * confidence from p=0.076 to p=0.14. Relationship is now negative as expected 
  * - perhaps as we have removed serial correlation through differencing.

*** Question 1.iv ***


  * Rather than using Prais-Winsten, use two-step Cochrane-Orcutt (for 1960-
  * 2019). Compare your estimates of \beta_1 and \rho to the results in (iii).

prais inf unem, corc twostep
  * help prais says that this is stupidly easy! corc says to use CO, twostep 
  * does as it says on the tin

  * We have a larger beta, at -0.46 and p=0.037. R^2 has also decreased.

/// QUESTION 2 ///

/// PREAMBLE START ///
drop errors
clear  // don't clear all as that removes graphs
use "Data Sets - Wooldridge\MINWAGE.DTA"
tsset t
/// PREAMBLE END ///

*** Question 2.i ***

  * Find the first order autocorrelation in gwage232. Does this series appear to 
  * be weakly dependent?

regress gwage232 gmwage gcpi
predict double errors, residuals 

regress errors l.errors
  * Strictly exogeneous
regress errors l.errors gmwage gcpi
  * Included

  * Regression #1: beta = -0.097, t = −2.41, 
  * Regression #2: beta = -0.098, t = −2.42, 
  * Both have evidence of negative serial correlation, doesn't matter which.

*** Question 2.ii ***

  * Obtain the Newey-West standard error for the OLS estimates in part (i), 
  * using a lag of 12. How do the Newey-West standard errors compare to the 
  * usual OLS standard errors?

newey gwage232 gmwage gcpi, lag(12)
  * gmwage: 0.045/0.0097 ~= 4.6x bigger
  * gcpi: 0.064/0.082 ~= 0.78x bigger (1.2x smaller)
  * Co-efficients identical

*** Question 2.iii ***

  * Now obtain the heteroscedasticity-robust standard errors for OLS, and 
  * compare them with the usual standard errors and the Newey-West standard 
  * errors. Does it appear that serial correlation or heteroscedasticity is more 
  * of a problem in this application?

regress gwage232 gmwage gcpi, robust
  * gmwage (dep): heteroscedasticity.
  * gcpi: unsure - SC?

*** Question 2.iv ***

  * Add lags 1 through 12 of gmwage to the equation in part (i). Obtain the 
  * long-run propensity for the effect of gmwage on gwage232t.

generate diff_1 = gmwage_1 - gmwage
generate diff_2 = gmwage_2 - gmwage
generate diff_3 = gmwage_3 - gmwage
generate diff_4 = gmwage_4 - gmwage
generate diff_5 = gmwage_5 - gmwage
generate diff_6 = gmwage_6 - gmwage
generate diff_7 = gmwage_7 - gmwage
generate diff_8 = gmwage_8 - gmwage
generate diff_9 = gmwage_9 - gmwage
generate diff_10 = gmwage_10 - gmwage
generate diff_11 = gmwage_11 - gmwage
generate diff_12 = gmwage_12 - gmwage

newey gwage232 gmwage diff_* gcpi, lag(12)  
  * this is excruciating

*** Question 2.v ***

  * If you leave out the lags of gmwage, is the estimate of the long-run 
  * propensity much different?

newey gwage232 gmwage gcpi, lag(12)
  * w/ lags: beta_1 = 0.198
  * no lags: beta_1 = 0.151
  * lags responsible for 0.047 (~1/3) increase.
