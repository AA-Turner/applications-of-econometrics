* Applications of Econometrics
* Lab 1 - Week 2
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
// cd "M:\Stata\AofE Labs"

* Import data from DTA file
// use "Data Sets - Wooldridge\EZANDERS.DTA"
 * Data is unemployment claims against time, with dummies for years and months.
 * There is also a dummy for the existence of the enterprise zone.

* Set log file
log using "aofe_lab_01.log", replace

* Create SIF date variable
* xref: 
  * help egen
  * help datetime_translation
  * https://www.statalist.org/forums/forum/general-stata-discussion/general/1395273-changing-daily-data-into-monthly-data
egen year_month_str = concat(year month), punct(", ")
gen date = mofd(date(year_month_str, "YM"))
format date %tm
drop year_month_str

/// PREAMBLE END ///

*** Question 1.i ***

tsset date
tsline luclms, name("Q1_i") tlabel(1980m1(12)1989m1, grid) xmtick(##4)
  * Creates a timeseries graph of ln(uclms) against date.
  * tlabel sets labels every 12 months from 1980 to 1989, with major gridlines
  * xmtick sets minor x-axis tickmarks every quarter (4 months)
  * name sets the graph's name so that multiple graphs can remain open at once
  
  * We observe large spikes around the start of each new year, which may 
  * indicate that the area has a large amount of seasonal employment 
  * (e.g. harvesting crops), which would cause a large number of workers to 
  * loose their jobs around Q4 of each year.
  * Indiana's population density in 1985 was 154 residents/sq mi (Statista), 
  * which is on the edge of 'rural' by the OECD's definition. Rural areas often 
  * have a high correlation with agricultural work, perhaps supporting the 
  * hypothesis that the consistency of work year-round is not very high.

*** Question 1.ii ***

regress luclms date feb mar apr may jun jul aug sep oct nov dec, robust
  * Regress with robust standard errors
  * Here we exlcude January and use Feb-Dec as dummy variables
  * Underlying unemployment was declining by around 1.4% per month, significant 
  * at all standard confidence levels.
  * There is strong evidence of seasonality, with may-jul and sep-nov recording
  * t-statistics greater than (-)2 and significant at abs(p)<0.05 , although not 
  * all have significance at 1%.

*** Question 1.iii ***

/// Q 1.iii SETUP ///
gen date2 = _n^2 // as muliplying, use row # not date as it is messy
gen date3 = _n^3
/// Q 1.iii SETUP ///

regress luclms date date2 feb mar apr may jun jul aug sep oct nov dec, robust
  * Both date & date2 are significant but the overall R^2 doesn't change much, 
  * suggesting that the Adj-R^2 would change even less

regress luclms date date2 date3 feb mar apr may jun jul aug sep oct nov dec, robust
  * Suddenly, all 3 date vars (date, date^2, date^3) become insignificant even 
  * at p<0.10 - this suggests what we did is wrong!!

/// Q 1.iii CLEANUP ///
drop date2 date3
/// Q 1.iii CLEANUP ///

*** Question 1.iv ***

regress luclms date feb mar apr may jun jul aug sep oct nov dec ez, robust
  * Adding a dummy for enterprise zones gives a co-efficient of -50.8%, 
  * significant at all standard levels. This increases the R^2 value and 
  * decreases the co-effiecient of the error term. However, to check the value 
  * as it is so large we use the formula suggested in the question:
  * 100 * (e^-0.508 - 1) = -39.83
  * This suggests the addition of an enterprise zone reduces unemployment claims
  * by 39.8% per month, again a large result.
  * As a final sense-check, we can refer to the graph from Q1(i). The enterprise
  * zone came into effect from January 1984, at which point we notice a 
  * reduction in peak (log) unemployment claims going forwards.

*** Question 1.v ***

* We assume all the change at the time of the EZ's introduction is due to the EZ
* - that is that there are no other major changes e.g. national policy around 
* the same time. We controlled for certain factors but not everything.

*** Question 1.vi ***

/// Q 1.iii SETUP ///
gen date2 = _n^2 // as muliplying, use row # not date as it is messy
gen date3 = _n^3
/// Q 1.iii SETUP ///

eststo clear
  * esttab - remove models from memory
eststo: quietly regress luclms date feb mar apr may jun jul aug sep ///
	oct nov dec, robust
  * Store Q1.ii regression in esttab
eststo: quietly regress luclms date date2 feb mar apr may jun jul aug sep ///
	oct nov dec, robust
  * Store Q1.iii regression in esttab
eststo: quietly regress luclms date date2 date3 feb mar apr may jun jul aug sep ///
	oct nov dec, robust
  * Store Q1.iii regression in esttab
eststo: quietly regress luclms date feb mar apr may jun jul aug sep ///
	oct nov dec ez, robust
  * Store Q1.iv regression in esttab
esttab, b(3) se(3) ar2 star(+ 0.10 * 0.05 # 0.01) /// 
	order(date date2 date3 ez) label ///
// using aofe_lab_01_q1.csv
  * Set esttab options (http://repec.sowi.unibe.ch/stata/estout/help-esttab.html#stlog-1-opt)
  * b(3) - set point estimates to 3 d.p.
  * se(3) - use standard error to 3 d.p.
  * r2 - use Adj-R^2
  * star(...) - set significance stars
  * label - use variable labels
  * order - as it says on the tin!
  * scalar - include p-value 
  * using ... - Optionally, save results (uncomment the line)

/// Q 1.iii CLEANUP ///
drop date2 date3
/// Q 1.iii CLEANUP ///



/// QUESTION 2 ///

/// PREAMBLE START ///
clear  // don't clear all as that removes graphs
// use "Data Sets - Wooldridge\TRAFFIC2.DTA"

* Create SIF date variable
* xref: 
  * help egen
  * help datetime_translation
  * https://www.statalist.org/forums/forum/general-stata-discussion/general/1395273-changing-daily-data-into-monthly-data
egen month_number = seq(), from(1) to (12)
  * Here, we *guess* that the data is ordered by month chrono, and generate a 
  * cycle repeating the numbers 1 to 12 for the dataset. That we have to do this
  * is awful, I am quite shocked that the input data is so poor so as not to 
  * include a proper datetime -- especially as it is a STATA data file, not 
  * something more interoperable...
  * Standardisation and ISO 8601 exist for a reason!!!
gen date = ym(year, month_number)  // As we have month num we can shortcut here
format date %tm
drop month_number
/// PREAMBLE END ///

*** Question 2.i ***

tsset date
tsline ltotacc, name("Q2_i") tlabel(1980m1(24)1990m1, grid) xmtick(##8)
  * There seems to be an underlying linear upward trend over time, with 
  * volatility (spikes) that look seasonal.

*** Question 2.ii ***

  * We look for the first `1` value and read accross to the date field.
  * Seatbelt law: 1986m1 (Jan 1986)
  * Speed law: 1987m5 (May 1987)

*** Question 2.iii ***

regress ltotacc date feb mar apr may jun jul aug sep oct nov dec, robust
  * Regression with robust standard errors
  * We exclude January as directed
  * The co-efficient on the time variable is 0.0027, or 0.27%, significant at 
  * all standard confidence levels.
  * This value (0.27%) represents the underlying monthly log total accidents as 
  * a percent of ???, excluding seasonal factors.
  * There is quite strong evidence of seasonality, with p-values below 1% in
  * mar, oct, nov & dec. In December there are 9.6% more accidents than January 
  * in the average year, perhaps due to alcohol + winter.

*** Question 2.iv ***
regress ltotacc date feb mar apr may jun jul aug sep oct nov dec wkends unem ///
	spdlaw beltlaw, robust
  * Holding all other variables constant, unemployment has a negative 2.1% 
  * effect on total accidents. This makes sense (I think), as greater 
  * unemployment means fewer journeys in a car, so less potential for accidents 
  * to occur.
  
  * Speed law has a -5.4% co-effcient, indicating that accidents dropped by a 
  * reasonable amount after the speed limit was increased by 10 miles per hour
  * (55mph => 65mph). Potentially, as drivers were more cautious with a greater 
  * speed limit, accidents may have fallen in the short term. Also, this 
  * variable may be masking some other change around May 1987 that we are not 
  * taking into account.

  * Seatbelt law has a co-efficient of 9.5%, that is that accidents increased by
  * nearly a tenth after the seatbelt law came into effect. This doesn't seem to 
  * make sense, but perhaps the opposite effect to the speed law was acting, and 
  * drivers became less cautious.

*** Question 2.v ***

summ prcfat

  * prfcat has a mean of ~0.886, meaning that roughly 4 in every 900 accidents
  * lead to a(t least one) fatality. I am not sure how to judge the magnitude, 
  * though most accidents friends (and I) have been in have been very minor. It
  * also depends what is counted as an accident, or what is reported!

*** Question 2.vi ***

reg prcfat date feb mar apr may jun jul aug sep oct nov dec wkends unem ///
	spdlaw beltlaw, robust
  * Regression with robust standard errors
  * We exclude January as directed
  * This regression measures the impact of dependent variables on the rate of 
  * fatalities.
  * Speed law has a co-efficient of 0.067, indicating that higher speed limits 
  * increase the liklihood of fatal accidents. This is significant at all 
  * standard confidence levels.
  * Belt law has a co-efficient of -0.030, indicating that seat belts reduce the 
  * rate of fatal injuries, although this is not significant at any standard 
  * level (p-value ~= 0.21)

*** Question 2.vii ***

eststo clear
  * esttab - remove models from memory
eststo: quietly regress ltotacc date feb mar apr may jun jul aug sep oct nov ///
	dec, robust
  * Store Q2.iii regression in esttab
eststo: quietly regress ltotacc date feb mar apr may jun jul aug sep oct nov ///
	dec wkends unem spdlaw beltlaw, robust
  * Store Q2.iv regression in esttab
eststo: quietly regress prcfat date feb mar apr may jun jul aug sep oct nov ///
	dec wkends unem spdlaw beltlaw, robust
  * Store Q2.vi regression in esttab

esttab, b(3) se(3) ar2 star(+ 0.10 * 0.05 # 0.01) /// 
	order(date wkends unem spdlaw beltlaw) label ///
// using aofe_lab_01_q2.csv
  * Set esttab options (http://repec.sowi.unibe.ch/stata/estout/help-esttab.html#stlog-1-opt)
  * b(3) - set point estimates to 3 d.p.
  * se(3) - use standard error to 3 d.p.
  * r2 - use Adj-R^2
  * star(...) - set significance stars
  * label - use variable labels
  * order - as it says on the tin!
  * scalar - include p-value 
  * using ... - Optionally, save results (uncomment the line)
