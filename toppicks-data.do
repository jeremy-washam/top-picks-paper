set more off
capture log close
clear
cap clear matrix

cd "/Users/loaneruser/Desktop/School/21W/Econ 66/Paper/Stata"
log using "data.log", replace


/******************************************* PREPARE THE FULL RETURNS DATA *******************************************/


// create yearmonth var for returns
use all_returns.dta, clear
gen yearmonth=ym(year(date), month(date))

// create a unique name for TICKER-ym, used to drop duplicates and to merge
egen stock_ym = concat(TICKER yearmonth), punct(-)
duplicates drop stock_ym, force

save all_returns_prepped.dta, replace


/**************************************** PREPARE THE TOP PICKS RETURNS DATA *****************************************/
// Note, this is so that I can evaluate whether the timing of top picks matter:
// If you look at top picks that were selected at any time, how do they do for the whole decade?


// create yearmonth var for returns
use full_returns.dta, clear
gen yearmonth=ym(year(date), month(date))

// create a unique name for TICKER-ym, used to drop duplicates and to merge
egen stock_ym = concat(TICKER yearmonth), punct(-)
duplicates drop stock_ym, force

save top_returns_prepped.dta, replace


/******************************************* PREPARE THE FAMA FRENCH DATA ********************************************/


// create yearmonth for fama-french 
use fff_monthly.dta, clear
gen yearmonth=ym(year(date), month(date))
save fff_prepped.dta, replace


/********************************************* PREPARE THE IBES REC DATA *********************************************/


// rename ticker for ibes data
use ibes_recs.dta, clear
drop TICKER
rename OFTIC TICKER

// create yearmonth var for ibes data
gen yearmonth=ym(year(STATPERS), month(STATPERS))
drop STATPERS

// gen stock_ym to drop duplicates and to merge
egen stock_ym = concat(TICKER yearmonth), punct(-)
duplicates drop stock_ym, force

save recs_prepped.dta, replace


/******************************************** PREPARE THE TOP PICKS DATA ********************************************/


// import top picks
import excel "/Users/loaneruser/Desktop/School/21W/Econ 66/Paper/Stata/Top Picks.xlsx", sheet("Sheet1") firstrow clear

// event time = 1 for the annoucements
gen evttime = 1

// create yearmonth var for top picks
gen date1=date(FormalDate,"MDY")
gen yearmonth=ym(year(date1), month(date1))
drop date1

drop if (year==.)

// mark the stock as a top pick for the next 12 months
// used this glorious guide to figure this out: https://www.statalist.org/forums/forum/general-stata-discussion/general/1369203-expand-observations-while-changing-value-of-one-variable
expand 12, gen(new)
sort TICKER yearmonth new
replace yearmonth = yearmonth[_n-1]+1 if new==1
replace evttime = evttime[_n-1]+1 if new==1
list, noobs sepby(TICKER)
drop new

// create a TICKER-yearmonth var, used to drop duplicates and to merge
egen stock_ym = concat(TICKER yearmonth), punct(-)
duplicates drop stock_ym, force

// top pick dummy
gen toppick = 1


/******************************************** MERGE ALL OF THE DATASETS ********************************************/

// merge in top picks returns
merge 1:1 stock_ym using top_returns_prepped.dta
drop _m

// make a var to designate whether a stock was a top pick at any point
gen topstock = 1

// merge in all returns (every stock in the CRSP dataset)
merge 1:1 stock_ym using all_returns_prepped.dta
drop _m

// merge in fama french factors
merge m:1 yearmonth using fff_prepped.dta
drop _m

// merge in recommendation data */
merge 1:1 stock_ym using recs_prepped.dta
drop _m

/**************************************** CLEAN DATA AND CREATE SOME DUMMIES ****************************************/

// clean data
drop if (RET==.)
drop if (RET==.b)
drop if (RET==.c)
replace toppick=0 if toppick==.
replace evttime=0 if evttime==.
replace topstock=0 if topstock==.

// create a buy rec dummy
gen buy=1 if MEANREC<=2
replace buy=0 if MEANREC>2

// create a dummy for top picks that aren't FAANG, TSLA, or MSFT
gen top_no_faang = 1 if toppick==1
replace top_no_faang = 0 if toppick==0
replace top_no_faang = 0 if TICKER=="FB"
replace top_no_faang = 0 if TICKER=="AAPL"
replace top_no_faang = 0 if TICKER=="AMZN"
replace top_no_faang = 0 if TICKER=="NFLX"
replace top_no_faang = 0 if TICKER=="GOOG"
replace top_no_faang = 0 if TICKER=="MSFT"
replace top_no_faang = 0 if TICKER=="TSLA"

// create firm dummies
gen barclays=1 if (firm=="Barclays")
replace barclays=0 if (firm!="Barclays")

gen citigroup=1 if (firm=="Citigroup")
replace citigroup=0 if (firm!="Citigroup")

gen credit_suisse=1 if (firm=="Credit Suisse")
replace credit_suisse=0 if (firm!="Credit Suisse")

gen deutsche_bank=1 if (firm=="Deutsche Bank")
replace deutsche_bank=0 if (firm!="Deutsche Bank")

gen evercore=1 if (firm=="Evercore ISI")
replace evercore=0 if (firm!="Evercore ISI")

gen jp_morgan=1 if (firm=="JP Morgan")
replace jp_morgan=0 if (firm!="JP Morgan")

gen jefferies=1 if (firm=="Jefferies Group")
replace jefferies=0 if (firm!="Jefferies Group")

gen morgan_stanley=1 if (firm=="Morgan Stanley")
replace morgan_stanley=0 if (firm!="Morgan Stanley")

gen oppenheimer=1 if (firm=="Oppenheimer")
replace oppenheimer=0 if (firm!="Oppenheimer")

gen piper_jaffray=1 if (firm=="Piper Jaffray Companies")
replace piper_jaffray=0 if (firm!="Piper Jaffray Companies")

gen raymond_james=1 if (firm=="Raymond James")
replace raymond_james=0 if (firm!="Raymond James")


// finally, save the data set
save toppicks_dataset_prepped.dta, replace

capture log close
