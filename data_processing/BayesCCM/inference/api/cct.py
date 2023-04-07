import pandas as pd
import numpy as np
import json
import copy
import re
import warnings
import string

def EM_CCT(bin_responses,num_responses_per_tool):
    N = bin_responses.shape[0]
    M = bin_responses.shape[1]
    
    competencies = np.ones(N)*.9
    consensus = np.zeros(M)

    def update_consensus():
        c = np.nanprod(bin_responses*competencies.reshape(N,-1) + 
                       (1-bin_responses)*(1-competencies).reshape(N,-1),axis=0)
#         print(c[:10])
        e = np.nanprod(bin_responses*(1-competencies).reshape(N,-1) + 
                       (1-bin_responses)*competencies.reshape(N,-1),axis=0)
#         print(e[:10])
        return(c / (c+e))

    def update_competencies():
        return(np.nansum(bin_responses*consensus.reshape(1,-1) +
                         (1-bin_responses)*(1-consensus).reshape(1,-1),axis=1)/num_responses_per_tool)

    def log_likelihood():
        return(np.nansum(consensus.reshape(1,-1)*np.nansum(bin_responses*np.log(competencies).reshape(N,-1) +
                                         (1-bin_responses)*np.log(1-competencies).reshape(N,-1),axis=0)) + 
               np.nansum((1-consensus).reshape(1,-1)*np.nansum(bin_responses*np.log(1 - competencies).reshape(N,-1) +
                                                 (1-bin_responses)*np.log(competencies).reshape(N,-1),axis=0)) +
               np.nansum(-1*(consensus*np.log(consensus) + (1-consensus)*np.log(1-consensus))))

    likelihoods = []
    for i in range(10):
        consensus = np.clip(update_consensus(),a_min=.0000000001,a_max=.99999999999)
        competencies = np.clip(update_competencies(),a_min=.0001,a_max=.9999)
        likelihoods.append(log_likelihood())

    return(consensus,competencies,likelihoods)

def robust_name2cc(x,name2cc):
    try:
        return name2cc[x]
    except:
        return np.nan

def load_and_clean(PATH_TO_CSV):
    df = pd.read_csv(PATH_TO_CSV).dropna()
    df['First'] = [x.lower() for x in df['First']]
    return df

def evaluate_cct(PATH_TO_CSV,PATH_TO_SAVE):
    # Load Target Data to Evaluate Cultural Consensus
    target = load_and_clean(PATH_TO_CSV)
    target_names = target['First'].value_counts().to_dict()
    all_names = set(target_names.keys())
    all_dict_counts = {}
    for dict_name, name_dict in zip(['targetCounts'],[target_names]):
        all_name_dict = {x:0 for x in all_names}
        for name,counts in name_dict.items():
            all_name_dict[name] += counts
        all_dict_counts[dict_name] = all_name_dict
    # Load Data Sources
    with open('../data/CONSENSUS/aggregated_master.json','r') as f:
        master_dict = json.load(f)
    all_gendered_names = set.union(*[set(x.keys()) for x in master_dict.values()])
    new_cols = {}
    new_cols['YearSensitive'] = {x:False for x in all_names}
    new_cols['CountrySensitive'] = {x:False for x in all_names}
    new_cols['NumTools'] = {x:0 for x in all_names}
    new_cols['CountToolSum'] = {x:0 for x in all_names}
    for tool,tool_dict in master_dict.items():
        tool_cap = tool.capitalize()
        new_cols[tool_cap] = {x:np.nan for x in all_names}
        for name in all_names.intersection(set(tool_dict.keys())):
            name_dict = tool_dict[name]
            new_cols['NumTools'][name] += 1
            new_cols[tool_cap][name] = name_dict['ratio']
            if 'total' in name_dict.keys():
                new_cols['CountToolSum'][name] += name_dict['total']
            if 'YEAR_SENSITIVE' in name_dict.keys():
                if (name_dict['YEAR_SENSITIVE'] is True) & (new_cols['YearSensitive'][name] is False):
                    new_cols['YearSensitive'][name] = True
            if 'COUNTRY_SENSITIVE' in name_dict.keys():
                if (name_dict['COUNTRY_SENSITIVE'] is True) & (new_cols['CountrySensitive'][name] is False):
                    new_cols['CountrySensitive'][name] = True
    # Combine target names with all data sources
    all_dict_counts.update(new_cols)
    name_df = pd.DataFrame.from_dict(all_dict_counts)
    bad_names = [x for x in string.ascii_lowercase] + ['NaN',' ','',np.nan]
    name_df = copy.deepcopy(name_df.loc[~name_df.index.isin(bad_names)])
    all_tools = [x.capitalize() for x in master_dict.keys()]
    obs_df = copy.deepcopy(name_df.loc[name_df['NumTools'] != 0])
    obs_df['ToolMean'] = np.nanmean(obs_df[all_tools],axis=1)
    # CCT
    min_respondents = 3
    response_df = obs_df.loc[(~np.isnan(obs_df[all_tools])).sum(axis=1) >= min_respondents]
    bin_responses = []
    for tool in response_df[all_tools].values.T:
        for name in tool:
            if np.isnan(name):
                bin_responses.append(np.nan)
            else:
                bin_responses.append(float(name >= .5))
    bin_responses = np.array(bin_responses).reshape(len(all_tools),-1)
    num_responses_per_tool = (~np.isnan(bin_responses)).sum(axis=1)
    used_tools = np.array(all_tools)[num_responses_per_tool>0]
    consensus, competencies,likelihoods = EM_CCT(bin_responses[num_responses_per_tool>0],
                                 num_responses_per_tool[num_responses_per_tool>0])
    name2cc = dict(zip(list(response_df.index),consensus))
    target['CulturalConsensus'] = target['First'].apply(lambda x: robust_name2cc(x,name2cc))
    target.to_csv(PATH_TO_SAVE,index=False)
    return target

