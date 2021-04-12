set more off
capture log close
clear
cap clear matrix

cd "/Users/loaneruser/Desktop/School/21W/Econ 66/Paper/Stata"
log using "results.log", replace

// load the merged dataset
use toppicks_dataset_prepped.dta, clear

// average monthly returns for top picks, buy recs, S&P500, and all stocks
summ RET if toppick==1
summ RET if buy==1
summ sprtrn
summ RET 

// investment value of top picks! 
reg RET toppick
outreg2 using table3, excel ctitle(Returns on top pick dummy, Monthly returns) replace

reg RET toppick mktrf smb hml rf umd
outreg2 using table3, excel ctitle(Returns on top pick dummy and FF factors, Monthly returns) append

// top pick returns excluding FAANG, MSFT, and TSLA
reg RET top_no_faang
outreg2 using table12, excel ctitle(Returns on top picks without FAANG/Microsoft/Tesla, Monthly returns) replace

reg RET top_no_faang mktrf smb hml rf umd
outreg2 using table12, excel ctitle(Returns on top picks without FAANG/Microsoft/Tesla and FF factors, Monthly returns) append


// what about rec levels - maybe they just do better because they're better recommended
// first, rec characteristics of top picks and top stocks
reg MEANREC toppick
outreg2 using table6, excel ctitle(Mean recommendation level) replace

reg NUMREC toppick
outreg2 using table6, excel ctitle(Number of recommendations) append

reg BUYPCT toppick
outreg2 using table6, excel ctitle(Buy percentage) append

reg SELLPCT toppick
outreg2 using table6, excel ctitle(Sell percentage) append


// fama-French regressions including the dummy for buy recs
reg RET toppick buy
outreg2 using table7, excel ctitle(Returns on top pick and buy rec dummies, Monthly returns) replace

reg RET toppick buy mktrf smb hml rf umd
outreg2 using table7, excel ctitle(Returns on top pick and buy rec dummies and FF factors, Monthly returns) append

// what about top picks that are also buy recs on average vs. ones that aren't? 
summ RET if (toppick==1 & buy==1)
summ RET if (toppick==1 & buy==0)

// average returns for each firm
summ RET if (barclays == 1)
summ RET if (citigroup == 1)
summ RET if (credit_suisse == 1)
summ RET if (deutsche_bank == 1)
summ RET if (evercore == 1)
summ RET if (jp_morgan == 1)
summ RET if (jefferies == 1)
summ RET if (morgan_stanley == 1)
summ RET if (oppenheimer == 1)
summ RET if (piper_jaffray == 1)
summ RET if (raymond_james == 1)


// regress returns on firm dummies
reg RET barclays citigroup credit_suisse deutsche_bank evercore jp_morgan jefferies morgan_stanley oppenheimer piper_jaffray raymond_james
outreg2 using table9, excel ctitle(Returns on firm dummies, Monthly returns) replace

reg RET barclays citigroup credit_suisse deutsche_bank evercore jp_morgan jefferies morgan_stanley oppenheimer piper_jaffray raymond_james mktrf smb hml rf umd
outreg2 using table9, excel ctitle(Returns on firm dummies and FF factors, Monthly returns) append

// does the timing of top picks matter?
// essentially, the topstock var marks a stock that was selected as a top pick at any point
// so we can compare how those stocks did for the whole decade vs. the duration of the top pick designation
summ RET if toppick==1
summ RET if topstock==1

// now regress on both variables (toppick and topstock) to see which one matters more
reg RET toppick topstock
outreg2 using table10, excel ctitle(Returns on top pick and top stock dummies, Monthly returns) replace

reg RET toppick topstock mktrf smb hml rf umd
outreg2 using table10, excel ctitle(Returns on top pick and top stock dummies and FF factors, Monthly returns) append

// performance by year 
summ RET if (toppick==1 & year==2011)
summ RET if (toppick==1 & year==2012)
summ RET if (toppick==1 & year==2013)
summ RET if (toppick==1 & year==2014)
summ RET if (toppick==1 & year==2015)
summ RET if (toppick==1 & year==2016)
summ RET if (toppick==1 & year==2017)
summ RET if (toppick==1 & year==2018)
summ RET if (toppick==1 & year==2019)
summ RET if (toppick==1 & year==2020)

summ RET if (buy==1 & year==2011)
summ RET if (buy==1 & year==2012)
summ RET if (buy==1 & year==2013)
summ RET if (buy==1 & year==2014)
summ RET if (buy==1 & year==2015)
summ RET if (buy==1 & year==2016)
summ RET if (buy==1 & year==2017)
summ RET if (buy==1 & year==2018)
summ RET if (buy==1 & year==2019)
summ RET if (buy==1 & year==2020)

summ RET if year==2011
summ RET if year==2012
summ RET if year==2013
summ RET if year==2014
summ RET if year==2015
summ RET if year==2016
summ RET if year==2017
summ RET if year==2018
summ RET if year==2019
summ RET if year==2020



capture log close
