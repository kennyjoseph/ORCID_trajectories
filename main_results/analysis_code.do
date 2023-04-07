version 16.1
set linesize 200

/////////////////////////////
// Analyses on FIELD ENTRY //
/////////////////////////////

// set working directory first -- USER MUST EDIT

cd ""

// output results to log file

log using results.txt, replace text

// import data

import delimited using "01_entry.csv", clear 

// preparing the data for analysis

replace case="1" if case=="TRUE"
replace case="0" if case=="FALSE"
destring case, replace

rename case selected

rename choice_op switch_no

encode is_fem_factor, gen(is_fem)
replace is_fem = 2 - is_fem
label define is_fem_label 0 "male" 1 "female"
label values is_fem is_fem_label

egen long oid_num = group(oid)

summarize stem
generate stem_c = stem - r(mean)
summarize stem_c

cmset oid_num switch_no to_matched_field

// main model

clogit selected ib0.is_fem##(c.fab c.stem_c), group(_caseid)  vce(cluster oid_num) 

clogit selected fab stem_c if is_fem==0, group(_caseid)  vce(cluster oid_num) // simple slope of FAB for men
margins, dydx(fab) atmeans
margins, dydx(stem_c) atmeans

margins, at(fab==(-0.5(0.1)0.5)) atmeans  // for plotting Figure 2

clogit selected fab stem_c if is_fem==1, group(_caseid)  vce(cluster oid_num) // simple slope of FAB for women
margins, dydx(fab) atmeans
margins, dydx(stem_c) atmeans

margins, at(fab==(-0.5(0.1)0.5)) atmeans  // for plotting Figure 2


clogit selected ib0.is_fem##(c.fab c.sexism c.stem_c), group(_caseid)  vce(cluster oid_num) // adding sexism

clogit selected fab sexism stem_c if is_fem==0, group(_caseid)  vce(cluster oid_num) // simple slope for men
margins, dydx(fab) atmeans
margins, dydx(stem_c) atmeans

clogit selected fab sexism stem_c if is_fem==1, group(_caseid)  vce(cluster oid_num) // simple slope for women
margins, dydx(fab) atmeans
margins, dydx(stem_c) atmeans


// calculating the % reduction in gender x FAB coefficient due to sexism

/* 

// FAB slope difference pre-adjustment for sexism
. display .02633 - (-.221917)
.248247

// FAB slope difference post-adjustment for sexism
. display -.0811566 - (-.2440339)
.1628773

// FAB reduction in gender difference in slopes
. display (.248247 - .1628773) / .248247
.34389016

*/


// calculating the % reduction in gender x STEM coefficient due to sexism

/* 
// STEM slope difference pre-adjustment for sexism
. display .2518963 - .0449617
.2069346

// STEM slope difference post-adjustment for sexism
. display .2321852 - .0362546
.1959306

// STEM reduction in gender difference in slopes
. display (.2069346 - .1959306) / .2069346
.05317622

*/


/////////////////////////////
// Analyses on FIELD EXITS //
/////////////////////////////

// import data

import delimited using "02_exit.csv", clear

// preparing the data for analysis

encode stem, gen(stem_num)
label drop stem_num

replace stem_num = stem_num - 1

encode left_field, gen(left_field_num)

replace left_field_num = left_field_num - 1
label drop left_field_num

tab left_field left_field_num

encode is_fem, gen(is_fem_num)

replace is_fem_num = 2 - is_fem_num

label define stemnonstem 0 "non-STEM" 1 "STEM"

label define MF 0 "man" 1 "woman"

label values stem_num stemnonstem

label values is_fem_num MF

summarize stem_num
generate stem_c = stem_num - r(mean)
summarize stem_c

// main model

logit left_field_num ib0.is_fem_num##(c.fab c.stem_c), vce(cluster oid) 

logit left_field_num ib1.is_fem_num##(c.fab c.stem_c), vce(cluster oid)  // switch omitted gender category -> FAB slope for women

margins, dydx(fab) at(is_fem_num==(0 1)) atmeans // average marginal effects

margins, dydx(fab) at(is_fem_num==(0 1)) pwcompare(effects) atmeans // compare average marginal effects

margins, at(is_fem_num==(0 1) fab==(-0.5(0.1)0.5)) atmeans // for plotting Figure 3

logit left_field_num ib0.is_fem_num##c.stem_c, vce(cluster oid)  // just STEM


logit left_field_num ib0.is_fem_num##(c.fab c.sexism c.stem_c), vce(cluster oid)  // adding sexism

logit left_field_num ib1.is_fem_num##(c.fab c.sexism c.stem_c), vce(cluster oid)  // switch omitted gender category -> FAB slope for women

margins, dydx(fab) at(is_fem_num==(0 1)) atmeans // average marginal effects

margins, dydx(fab) at(is_fem_num==(0 1)) pwcompare(effects) atmeans // compare average marginal effects

// calculating the % reduction in gender x FAB coefficient due to sexism
/*
. display (.0443732 - .0265736)/ .0443732
.40113402
*/


//////////////////////////
// Robustness check #1 //
/////////////////////////

// import data

import delimited using "03_robustness_check_1.csv", clear

// preparing the data for analysis

encode from_matched_field, gen(from_matched_field_num)

summarize stem
generate stem_c = stem - r(mean)
summarize stem_c

// main model

logit is_fem fab stem_c i.from_matched_field_num, vce(cluster oid)

margins, dydx(fab) atmeans // average marginal effects


//////////////////////////
// Robustness check #2 //
/////////////////////////

// import data -- ENTRY

import delimited using "01_entry.csv", clear 

// preparing the data for analysis

replace case="1" if case=="TRUE"
replace case="0" if case=="FALSE"
destring case, replace

ren case selected

ren choice_op switch_no

encode is_fem_factor, gen(is_fem)
replace is_fem = 2 - is_fem
label define is_fem_label 0 "male" 1 "female"
label values is_fem is_fem_label

egen long oid_num = group(oid)

cmset oid_num switch_no to_matched_field

// main model

clogit selected ib0.is_fem##(c.fab c.hw c.sme c.sel stem), group(_caseid)  vce(cluster oid_num)


// import data -- EXIT

import delimited using "02_exit.csv", clear

// preparing the data for analysis

encode stem, gen(stem_num)
label drop stem_num

replace stem_num = stem_num - 1

encode left_field, gen(left_field_num)

replace left_field_num = left_field_num - 1
label drop left_field_num

tab left_field left_field_num

encode is_fem, gen(is_fem_num)

replace is_fem_num = 2 - is_fem_num

label define stemnonstem 0 "non-STEM" 1 "STEM"

label define MF 0 "man" 1 "woman"

label values stem_num stemnonstem

label values is_fem_num MF

// main model

logit left_field_num ib0.is_fem_num##(c.fab c.hw c.sme c.sel stem_num), vce(cluster oid) 


//////////////////////////////////////////////////////////
// Robustness checks #3 and #4 -- see GitHub repository //
//////////////////////////////////////////////////////////

log close