* Applications of Econometrics
* Lab 2 - Week 3
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

* Install required packages from SSC (Statistical Software Components) Archive
//ssc install estout, replace

* Set working directory
//cd "I:\OneDrive\OneDrive - University of Edinburgh\Uni\Year 3\Applications of Econometrics\Labs"

* Import data from DTA file
//use "Data Sets - Wooldridge\HSEINV.DTA"
 * Data is housing inventory against time.

* Set log file
log using "aofe_lab_02.log", replace

* Set time series var
tsset year

/// PREAMBLE END ///

*** Question 1.i ***

  * Find the first order autocorrelation in log (invpc). Now, find the 
  * autocorrelation after linearly detrending log (invpc). Do the same for 
  * log (price). Which of the two series may have a unit root?


corrgram linvpc, lag(1) noplot
  * Create autocorrelation tabulation with one (1) lag

correlate linvpc linvpc_1
  * Check correlation manually - oddly the numbers aren't the same???

regress linvpc year
predict linvpc_detrended, residuals
  * Generate detrended log(invpc) data 

corrgram linvpc_detrended, lag(1) noplot
  * Create autocorrelation tabulation with one (1) lag for detrended data
  * How on earth do you shift data by one observation in Stata? Seems like a 
  * fairly common operation but cannot find it anywhere..!

  * We observe the first order autocorrelation AR(1) for log(invpc) is ~0.639.
  * After detrending, the first order autocorrelation is ~0.483. Both show 
  * little evidence of a unit root.

corrgram lprice, lag(1) noplot
  * Create autocorrelation tabulation with one (1) lag

correlate lprice lprice_1
  * Check correlation manually - oddly the numbers aren't the same???

regress lprice year
predict lprice_detrended, residuals
  * Generate detrended log(price) data

corrgram lprice_detrended, lag(1) noplot
  * Create autocorrelation tabulation with one (1) lag for detrended data
  * How on earth do you shift data by one observation in Stata? Seems like a 
  * fairly common operation but cannot find it anywhere..!

  * We observe the first order autocorrelation AR(1) for log(price) is ~0.949.
  * After detrending, the first order autocorrelation is ~0.820. Both are fairly 
  * high, and we cannot rule out a unit root.


*** Question 1.ii ***

  * Now find the first order autocorrelation for these variables using AR(1) 
  * models with and without trends. Why are the answers slightly different to 
  * part (i)?

regress linvpc linvpc_1       // B=0.634
regress linvpc linvpc_1 year  // B=0.482
  * Regress with and without the yearly time trend 

regress lprice lprice_1       // B=0.934
regress lprice lprice_1 year  // B=0.821
  * Regress with and without the yearly time trend

  * The numbers are fairly close. The two underlying eqations are:
  * Corr Co-eff: Cov(y_t, y_{t-1})/ \sigma_y_t * \sigma_y_{t-1}
  * Regr Co-eff: Cov(y_t, y_{t-1})/ \sigma^2_y_{t-1}
  * There is a difference of \sigma_y_{t-1} vs \sigma_y_t - these will get very
  * close for a large n, but here we have only 41 observations

*** Question 1.iii ***

  * Based on your findings in parts (i) and (ii), estimate the equation
  * log(invpc_t) = \Beta_0 + \Beta_1 \Delta log(price_t) + \Beta_2t + u_t
  * and report the results in standard form. Interpret the coefficient \Beta_1 
  * and determine whether it is statistically significant.

regress linvpc gprice year 
  * gprice is a given variable for the price growth
  * year serves as our time trend

  * Co-efficient on growth in price is 3.879, that a 1pp increase in price 
  * growth leads to a 3.88 percent increase in investment per capita.
  * p<0.0005, significant at all standard levels

*** Question 1.iv ***

  * Linearly detrend log (invpct) and use the detrended version as the dependent 
  * variable in the regression from part (iii) (see Section 10-5). What happens 
  * to R^2?

regress linvpc_detrended gprice year
  * Use detrended log(invpc) from 1.i
  * R^2 goes from  0.510 to 0.303, indicating that around 30% of the underlying 
  * variation in invpc is explained by \Delta log(price).

*** Question 1.v ***

  * Now use \Delta log(invpct) as the dependent variable. How do your results 
  * change from part (iii)? Is the time trend still significant? Why or why not?

regress ginvpc gprice year
  * The co-effcient of \Delta log(price) has more than halved. p=0.177, which is
  * no longer significant at any standard level. R^2 is also really small. As 
  * using growth eliminates trends, it makes sense the time trend co-effcient is
  * also very small.


/// QUESTION 2 ///

/// PREAMBLE START ///
clear  // don't clear all as that removes graphs
//use "Data Sets - Wooldridge\MINWAGE.DTA"
tsset t
/// PREAMBLE END ///

*** Question 2.i ***

  * Find the first order autocorrelation in gwage232. Does this series appear to 
  * be weakly dependent?

corrgram gwage232, lag(1) noplot
  * The first order autocorrelation AR(1) is -0.035, which is very small. This 
  * suggests gwage232 is weakly dependent.

*** Question 2.ii ***

  * Estimate the dynamic model
  * gwage232_t = \Beta_0 + \Beta_1 gwage232_{t-1} + \Beta_2 gmwage_t + \Beta_3 gcpi_t + u_t
  * by OLS. Holding fixed last months growth in wage and the growth in the CPI, 
  * does an increase in the federal minimum wage result in a contemporaneous 
  * increase in gwage232_t? Explain.

regress gwage232 l.gwage232 gmwage gcpi
  * A 1pp increase in the minimum wage is estimated to imcrease wage growth in
  * sector 232 by 0.152pp. The t-stat is massive, so the relationship is pretty
  * strong. Significant at all standard levels etc

*** Question 2.iii ***

  * Now add the lagged growth in employment, gemp232_{t-1}, to the equation in 
  * part (ii). Is it statistically significant?

regress gwage232 l.gwage232 gmwage gcpi l.gemp232
  * Yes (t-stat: 3.9, p<0.0005)

*** Question 2.iv ***

  * Compared with the model without gwage232_{t-1} and gemp232_{t-1}, does 
  * adding the two lagged variables have much of an effect on the gmwage232 
  * co-efficient?

regress gwage232 gmwage gcpi
  * Co-efficient on wage growth gmwage is 0.151, which is near-identical to 2.ii
  * Both gmwage and gcpi are significant at all levels, with a stonking and big 
  * t-statistic respectivley. Maybe something about correlation is the effect in 
  * that there is no real differnce with no lags?

*** Question 2.v ***

  * Run the regression of gmwage_t on gwage232_{t-1} and gemp232_{t-1}, and 
  * report the R-squared. Comment on how the value of R-squared helps explain 
  * your answer to part (iv).

regress gmwage l.gwage232 l.gemp232
  * R^2 = 0.0039 ~= 0.004, which is miniscule. This kinda explains my comment in 
  * part iv that there may not be a strong relationship in the lagged values.
