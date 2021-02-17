**************************
*READ IN DATA
**************************

*Read in Data
use "/Users/marinom/Dropbox/missing-data_csp-2021/MarinoSlides/ehr-and-claims_simulated-data_csp-2021.dta"

**************************
*Complete Case example
**************************


*Subset data to those who are eligible for cholesterol screening
tab cholesterol_eligibility
keep if cholesterol_eligibility==1

*Look at descriptives for primary outcome of EHR-derived cholesterol screening
tab cholesterol_ehr

*Run a logistic regression of cholesterol screening on important covariates
xi: logistic cholesterol_ehr age i.sex i.race_eth i.language i.fpl

**************************
*Single Imputation example
**************************

*Preserve the data because we will manipulate. We want to revert back
preserve

*Single Impute Age using its mean
summarize age
replace age=40.05 if age==.

*Single Impute Sex using its mode
tab sex
replace sex="Female" if sex==""

*Single Impute Race/Ethnicity using its mode
tab race_eth
replace race_eth="Non-Hispanic, white" if race_eth==""

*Single Impute Language using its mode (NOTE: Language has no missing data
*in this subsample so there were no changes made)
tab language
replace language="English" if language==""

*Single Impute FPL using its mode
tab fpl
replace fpl="<=138% FPL" if fpl==""

*Run a logistic regression of cholesterol screening on important covariates
xi: logistic cholesterol_ehr age i.sex i.race_eth i.language i.fpl

*restore the data to its original form
restore

**************************
*Missing Indicator example: Note, for this example, we just include age and sex
**************************

*Preserve the data because we will manipulate. We want to revert back
preserve

*Create missing age indicator
generate age_missing=0
replace age_missing=1 if age==.

*Set all missing ages to 0
replace age=0 if age==.

*Create a new sex variable with missing categories
generate sex_missing=sex
replace sex_missing="missing" if sex==""

*Run a logistic regression of cholesterol screening on only age and sex
xi: logistic cholesterol_ehr age i.age_missing i.sex_missing

*restore the data to its original form
restore

**************************
*Multiple Imputation example
**************************

*Need to convert string variables into numeric
encode sex, generate(sex_n)
generate sex_binary=sex_n-1
encode race_eth, generate(race_eth_n)
encode fpl, generate(fpl_n)
generate fpl_binary=fpl_n-1
encode language, generate(language_n)

*Preserve the data because we will manipulate. We want to revert back
preserve

*Declare the storage style
mi set wide

*Register Variables
mi register imputed age sex_binary race_eth_n fpl_binary
mi register regular language_n

*Perform m=10 imputations
mi impute chained (regress) age (logit) sex_binary fpl_binary (mlogit) race_eth_n = language_n, ///
add (10) rseed(2021)

*Perform multiply-imputed logistic regression (m=10 imputations)
mi estimate: logistic cholesterol_ehr age i.sex_binary i.race_eth_n i.language_n i.fpl_binary

*restore the data to its original form
restore

**************************
*R-Squared example
**************************

*install mibeta to extract R-square from MI results (Run code, click on link, and click install)
findit mibeta

*Declare the storage style
mi set wide

*Register Variables
mi register imputed age sex_binary race_eth_n fpl_binary
mi register regular language_n

*Perform m=10 imputations
mi impute chained (regress) age (logit) sex_binary fpl_binary (mlogit) race_eth_n = language_n, ///
add (10) rseed(2021)

*Perform multiply-imputed linear regression (m=10 imputations)
mi estimate: regress cholesterol_total age i.sex_binary i.race_eth_n i.language_n i.fpl_binary

*Estimate multiply-imputed R-square
mibeta cholesterol_total age i.sex_binary i.race_eth_n i.language_n i.fpl_binary, fisherz

**************************
*R-Squared example: BY HAND
**************************

*See the following URL for a good Stata Example: 
*https://stats.idre.ucla.edu/stata/faq/how-can-i-estimate-r-squared-for-a-model-estimated-with-multiply-imputed-data/



























