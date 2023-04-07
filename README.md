# Explaining Gender Differences in Career Trajectories Across 30 Academic Fields
This repository contains the code and data needed to replicate the analyses presented in the paper *Field-specific Ability Beliefs as an Explanation for Gender Differences in Academics' Career Trajectories: Evidence from Public Profiles on ORCID.org* by Hannak, Joseph, Larremore, and Cimpian, forthcoming at JPSP.  If you use this code base or ideas from the paper, please consider citing us!

```
CITATION COMING SOON!
```

The one thing that is not provided is the raw data from ORCID.  For this, you'll need to head over to the [public ORCID dumps](https://support.orcid.org/hc/en-us/articles/360006897394-How-do-I-get-the-public-data-file-).  See the section in this document labeled `raw` for how to access it! Then, run the scripts in ```data_processing``` to generate the files we use for our analyses. These analyses are carried out using code provided in other folders in this repository.  Details on all files in the repository are below.  

Please open an issue if you have questions! Also, please note that in most cases, python code has been tested primarily in `python 3.6`.

Finally, please note that all `data` directories are tarred and gzipped, please make sure to uncompress before attempting to replicate!

# Main Results

The folder `main_results`  contains code and data to replicate the main results of the paper, specifically, the main statistical results reported, the generation of Figure 2 and Figure 3, and the first two robustness checks. Data files used (`01_entry.csv`, `02_exit.csv`, `03_robustness_check_1.csv`) are described in files with the same name, except replacing `.csv` with `_variable_labels.txt`.  Stata code to replicate statistical analysis can be found in `analysis_code.do`. R code to replicate figure construction can be found in `Fig2_code.R` and `Fig3_code.R`.  Finally, outputs of the statistical analysis can be found in `results.txt`.


# Robustness Check 3

This directory provides code to replicate Figure 5, labeled as Robustness Check 3 in the paper.  Stata code to generate estimates for the Entry models for Robustness Check 3 can be found in `Fig5_code_enter.do`, and uses `data_for_Fig_5` to do so. These estimates are written out to the files in `data/entry_data`. Code to generate the estimates for the Exit models and to create the plot is in `run_check.R`. The data used for the Exit models is in `data/exit_data`. 


# Robustness Check 4

 The file ```make_synthetic_biased_data.ipynb``` contains code to generate simulated data for robustness analysis, and to compare those results against our modeling strategy. Code to generate results for the modeling strategy can be found in `robustness_results.R` in this directory.  The directory ```synthetic``` contains the actual simulation data used in the paper

# Figure 4

The file ```make_redblue_network_flow_figures.ipynb```  provides code for the construction of Figure 4 in the paper. The outputted figure was edited slightly (to avoid overlapping labels) in Illustrator before publication!


# Processing the Raw ORCID Data
Code in the ```data_processing``` directory takes the raw ORCID data and runs the preprocessing steps described in the Supplement of the paper.  The primary outputs of this code are two CSV files (both gzipped!), ```cleaned_singlematchtofield_affiliations.csv.gz``` and ```all_switches_w_samefield.csv.gz```, which describe the affiliations and field switches, respectively, on which our primary analyses are carried out.  

These files are large and (relatively) unwieldly. For  simplicity, our analyses use cleaned versions of these files for specific analyses; these are described in more detail below.

## Primary Code Files
- ```extract_affiliations.ipynb``` - Takes as input data from an [AWS sync](https://github.com/ORCID/public-data-sync/blob/master/sync.py) of the ORCID data. Outputs a gender-tagged, cleaned listing of each affiliation to a set of potential fields. Note that the AWS version of the data is very difficult to work with. We encourage others to use the [public ORCID dumps](https://support.orcid.org/hc/en-us/articles/360006897394-How-do-I-get-the-public-data-file-), and provide code in ```parse_orcid_json_files.py``` to process the JSON version of these dumps. See the section of this document entitled `Raw` for how to get started on this.
- ```identify_single_affiliations_and_switches.ipynb``` - Takes as input the affiliations outputted by ```extract_affiliations.ipynb``` and identifies only those affiliations that match a single field in our survey data. Then, computes field switches using our field switch algorithm described in the paper.

## Supplementary Code and Data Files
- ```black-list-roots.txt``` - A list of regular expressions used for the blacklist
- ```field_matching.py``` - Utility code for implementing our algorithm to match strings of text to academic fields
- ```blacklist.txt``` - Terms (not regular expressions) used to identify fields in the blacklist
- ```parse_orcid_json_files.py``` - Code to help clean and extract information from JSON-converted ORCID dumps

## Cultural consensus estimates of associations between name and gender
- `data_processing/BayesCCM` contains functions in `cct.py` which can be called in a demonstration notebook in `CulturalConsensusDemo.ipynb`. Due to the large file size of the training data, *training data file has been zipped* so after cloning the repository, one **must** unzip `aggregated_master.json.zip` into the same folder as the .zip file. 

## Raw
ORCID provides raw data directly. Here, we provide basic information on how to access the public dump. Note, however, that our `parse_orcid_json_files.py` works on a different version of the ORCID schema than the current (2022) dump, so you will have to modify it accordingly.

First, download the summaries file from ORCID (**note, the 2022 file is 21+GB, so make sure you have space!):
```
wget -O summaries.tar.gz PATH_TO_SUMMARIES_FILE
```

Then, you'll need (to use our code) to convert the XML files ORCID uses to JSON:
```
 wget https://github.com/ORCID/orcid-conversion-lib/raw/master/target/orcid-conversion-lib-3.0.7-full.jar
 java -jar orcid-conversion-lib-3.0.7-full.jar --tarball -i summaries.tar.gz  -o summ_json.tgz
 ```

 Finally, you can extract out the json directories. **The 2022 dump appears to be approximately 500GB, so make sure you have space!

 ```
 tar -xzvf summ_json.tgz
 ```

 You can then, finally, point our `parse_orcid_json_files.py` script to the resulting data directory (making appropriate modifications for the new ORCID schema) and get to work!