// VARIABLE LABELS
// fab = field-specific ability beliefs (Brilliance Orientation)
// is_fem = gender of the ORCID user (0 = man, 1 = woman)


// set Stata version to 16.1
version 16.1


// change directory to working folder ***PLEASE EDIT TO LOCAL DIRECTORY***
cd ""


//////////////////////////////////////////////////////
///////////////  MODEL ON FULL DATASET ///////////////
//////////////////////////////////////////////////////

clear
import delimited using 01_entry.csv

cd "data_for_Fig_5"

// PREPARE THE DATA

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

// coefficient for MEN
clogit selected fab stem if is_fem==0, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store _full_model_MEN
estout using _full_model_MEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")

// coefficient for WOMEN
clogit selected fab stem if is_fem==1, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store _full_model_WOMEN
estout using _full_model_WOMEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")



/////////////////////////////////////////////////////////////////
///////////////  FROM BACHELORS TO PHD //////////////////////////
/////////////////////////////////////////////////////////////////

clear
import delimited using Fig5_enter_from_bach.csv

// PREPARE THE DATA

replace stem="1" if stem=="TRUE"
replace stem="0" if stem=="FALSE"
destring stem, replace

replace case="1" if case=="TRUE"
replace case="0" if case=="FALSE"
destring case, replace

ren case selected

ren choice_op switch_no

egen long oid_num = group(oid)

encode is_fem_factor, gen(is_fem)
replace is_fem = 2 - is_fem
label define is_fem_label 0 "male" 1 "female"
label values is_fem is_fem_label

// creates the strata/grouping variable _caseid
cmset oid_num switch_no to_matched_field


// coefficient for MEN
clogit selected fab stem if is_fem==0, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store from_bachelors_MEN
estout using from_bachelors_MEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")

// coefficient for WOMEN
clogit selected fab stem if is_fem==1, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store from_bachelors_WOMEN
estout using from_bachelors_WOMEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")




/////////////////////////////////////////////////////////////////
///////////////  FROM PHD TO POSTDOC/PROFESSOR///////////////////
/////////////////////////////////////////////////////////////////

clear
import delimited using Fig5_enter_from_phd.csv

// PREPARE THE DATA

replace stem="1" if stem=="TRUE"
replace stem="0" if stem=="FALSE"
destring stem, replace

replace case="1" if case=="TRUE"
replace case="0" if case=="FALSE"
destring case, replace

ren case selected

ren choice_op switch_no

egen long oid_num = group(oid)

encode is_fem_factor, gen(is_fem)
replace is_fem = 2 - is_fem
label define is_fem_label 0 "male" 1 "female"
label values is_fem is_fem_label

// creates the strata/grouping variable _caseid
cmset oid_num switch_no to_matched_field


// coefficient for MEN
clogit selected fab stem if is_fem==0, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store from_PhD_MEN
estout using from_PhD_MEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")

// coefficient for WOMEN
clogit selected fab stem if is_fem==1, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store from_PhD_WOMEN
estout using from_PhD_WOMEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")


/////////////////////////////////////////////////////////////////
///////////////  PRE 2000                     ///////////////////
/////////////////////////////////////////////////////////////////

clear
import delimited using Fig5_enter_pre2000.csv

// PREPARE THE DATA

replace stem="1" if stem=="TRUE"
replace stem="0" if stem=="FALSE"
destring stem, replace

replace case="1" if case=="TRUE"
replace case="0" if case=="FALSE"
destring case, replace

ren case selected

ren choice_op switch_no

egen long oid_num = group(oid)

encode is_fem_factor, gen(is_fem)
replace is_fem = 2 - is_fem
label define is_fem_label 0 "male" 1 "female"
label values is_fem is_fem_label

// creates the strata/grouping variable _caseid
cmset oid_num switch_no to_matched_field


// coefficient for MEN
clogit selected fab stem if is_fem==0, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store pre2000_MEN
estout using pre2000_MEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")

// coefficient for WOMEN
clogit selected fab stem if is_fem==1, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store pre2000_WOMEN
estout using pre2000_WOMEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")



/////////////////////////////////////////////////////////////////
///////////////  POST 2000                     //////////////////
/////////////////////////////////////////////////////////////////

clear
import delimited using Fig5_enter_post2000.csv

// PREPARE THE DATA

replace stem="1" if stem=="TRUE"
replace stem="0" if stem=="FALSE"
destring stem, replace

replace case="1" if case=="TRUE"
replace case="0" if case=="FALSE"
destring case, replace

ren case selected

ren choice_op switch_no

egen long oid_num = group(oid)

encode is_fem_factor, gen(is_fem)
replace is_fem = 2 - is_fem
label define is_fem_label 0 "male" 1 "female"
label values is_fem is_fem_label

// creates the strata/grouping variable _caseid
cmset oid_num switch_no to_matched_field



// coefficient for MEN
clogit selected fab stem if is_fem==0, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store post2000_MEN
estout using post2000_MEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")

// coefficient for WOMEN
clogit selected fab stem if is_fem==1, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store post2000_WOMEN
estout using post2000_WOMEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")




/////////////////////////////////////////////////////////////////
///////////////  TO ASIAN INSTITUTIONS                    ///////
/////////////////////////////////////////////////////////////////

clear
import delimited using Fig5_enter_asia.csv

// PREPARE THE DATA

replace stem="1" if stem=="TRUE"
replace stem="0" if stem=="FALSE"
destring stem, replace

replace case="1" if case=="TRUE"
replace case="0" if case=="FALSE"
destring case, replace

ren case selected

ren choice_op switch_no

egen long oid_num = group(oid)

encode is_fem_factor, gen(is_fem)
replace is_fem = 2 - is_fem
label define is_fem_label 0 "male" 1 "female"
label values is_fem is_fem_label

// creates the strata/grouping variable _caseid
cmset oid_num switch_no to_matched_field


// coefficient for MEN
clogit selected fab stem if is_fem==0, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store to_Asia_MEN
estout using to_Asia_MEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")

// coefficient for WOMEN
clogit selected fab stem if is_fem==1, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store to_Asia_WOMEN
estout using to_Asia_WOMEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")



/////////////////////////////////////////////////////////////////
///////////////  TO EUROPEAN INSTITUTIONS                 ///////
/////////////////////////////////////////////////////////////////

clear
import delimited using Fig5_enter_europe.csv

// PREPARE THE DATA

replace stem="1" if stem=="TRUE"
replace stem="0" if stem=="FALSE"
destring stem, replace

replace case="1" if case=="TRUE"
replace case="0" if case=="FALSE"
destring case, replace

ren case selected

ren choice_op switch_no

egen long oid_num = group(oid)

encode is_fem_factor, gen(is_fem)
replace is_fem = 2 - is_fem
label define is_fem_label 0 "male" 1 "female"
label values is_fem is_fem_label

// creates the strata/grouping variable _caseid
cmset oid_num switch_no to_matched_field



// coefficient for MEN
clogit selected fab stem if is_fem==0, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store to_Europe_MEN
estout using to_Europe_MEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")

// coefficient for WOMEN
clogit selected fab stem if is_fem==1, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store to_Europe_WOMEN
estout using to_Europe_WOMEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")





/////////////////////////////////////////////////////////////////
///////////////  TO LATIN AMERICAN INSTITUTIONS           ///////
/////////////////////////////////////////////////////////////////

clear
import delimited using Fig5_enter_lac.csv

// PREPARE THE DATA

replace stem="1" if stem=="TRUE"
replace stem="0" if stem=="FALSE"
destring stem, replace

replace case="1" if case=="TRUE"
replace case="0" if case=="FALSE"
destring case, replace

ren case selected

ren choice_op switch_no

egen long oid_num = group(oid)

encode is_fem_factor, gen(is_fem)
replace is_fem = 2 - is_fem
label define is_fem_label 0 "male" 1 "female"
label values is_fem is_fem_label

// creates the strata/grouping variable _caseid
cmset oid_num switch_no to_matched_field



// coefficient for MEN
clogit selected fab stem if is_fem==0, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store to_LatinAm_MEN
estout using to_LatinAm_MEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")

// coefficient for WOMEN
clogit selected fab stem if is_fem==1, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store to_LatinAm_WOMEN
estout using to_LatinAm_WOMEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")





/////////////////////////////////////////////////////////////////
///////////////  TO NORTH AMERICAN INSTITUTIONS           ///////
/////////////////////////////////////////////////////////////////

clear
import delimited using Fig5_enter_north_america.csv

// PREPARE THE DATA

replace stem="1" if stem=="TRUE"
replace stem="0" if stem=="FALSE"
destring stem, replace

replace case="1" if case=="TRUE"
replace case="0" if case=="FALSE"
destring case, replace

ren case selected

ren choice_op switch_no

egen long oid_num = group(oid)

encode is_fem_factor, gen(is_fem)
replace is_fem = 2 - is_fem
label define is_fem_label 0 "male" 1 "female"
label values is_fem is_fem_label

// creates the strata/grouping variable _caseid
cmset oid_num switch_no to_matched_field


// coefficient for MEN
clogit selected fab stem if is_fem==0, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store to_NorthAm_MEN
estout using to_NorthAm_MEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")

// coefficient for WOMEN
clogit selected fab stem if is_fem==1, group(_caseid) vce(cluster oid_num)

// output coefficients to csv
estimates store to_NorthAm_WOMEN
estout using to_NorthAm_WOMEN.csv, replace cells("b se ci_l ci_u") delimiter(",") mlabels("")


