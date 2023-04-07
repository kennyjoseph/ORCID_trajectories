#!/usr/bin/env python
# -*- coding: utf-8 -*-
from fuzzysearch import find_near_matches
import re
from functools import cmp_to_key
from stringdist import rdlevenshtein
from inspect import getsourcefile
from os.path import abspath, join

survey_terms_map = {
'anthropology' : ['anthropology'],
'archaeology' : ['archaeology'],
'art history' : ['art history','history of art'],
'astronomy' : ['astronomy'],
'biochemistry' : ['biochemistry'],
'chemistry' : ['chemistry'],
'classics' : ['classics', 'classical literature','classical humanities'],
'communications' : ['communications', 'communication sciences','communication studies','communication'],
'comparative literature' : ['comparative literature'],
'computer science' : ['computer science','algorithms','computing','informatics'],
'earth sciences' : ['earth sciences','earth science','physical geography',
                    'oceanography','atmospheric sciences','volcano'],
'economics' : ['economics', 'economic','econometrics','finance','economy'],
'education' : ['education','pedagogy'],
'engineering' : ['engineering', 'ingegneria','e.e.','e.c.e.',u'ingenierã a',
                 'cybernetics','telecommunication','telecommunications','telecommunication studies',
                'electrical engineering','chemical engineering','electrical and computer engineering',
                'biochemical engineering', 'biological engineering','neuroengineering',
                'musical engineering','statistical engineering','physical engineering'],
'english literature' : ['english literature','english'],
'evolutionary biology' : ['evolutionary biology'],
'history' : ['history'],
'linguistics' : ['linguistics', 'linguistic'],
'mathematics' : ['mathematics','math','geometry','algebra','number'],
'middle eastern studies' : ['middle eastern studies', 'middle east'],
'molecular biology' : ['molecular biology'],
'music' : ['music theory','musical composition', 'musicology','composition'],
'neuroscience' : ['neuroscience'],
'philosophy' : ['philosophy'],
'physics' : ['physics'],
'political science' : ['political science','political sciences', 'politics','science politique','politology'],
'psychology' : ['psychology','psychological','psicologia', u'psicología'],
'sociology' : ['sociology','sociological','sociologie'],
'spanish literature' : ['spanish literature','spanish'],
'statistics' : ['statistics', 'statistical sciences'],
# these came up a lot but we want to make sure not to match them
'blacklist' : ['biology','health science','higher education','medicine','medical','physical','research science','media',
          'information']
}



fil_path = abspath(getsourcefile(lambda:0)).replace("field_matching.py","")
blacklist = {x.strip().lower() for x in open(join(fil_path, "blacklist.txt"))}
survey_terms_map['blacklist'] += list(blacklist)



term_to_field_map = {}
for k, v in survey_terms_map.items():
    for x in v:
        term_to_field_map[x] = k

survey_terms = set(term_to_field_map.keys())


def my_cmp(x, y):
    return x[1] - y[1] if x[1] - y[1] != 0 else len(y[0]) - len(x[0])


def determine_subword(matched_term_in_exp, matched_term_in_termset, exp, fuzz_str_add=""):
    # decide if its a full string; i.e. not part of another word
    if re.search("(\W|^)+{}(\W|$)+".format(matched_term_in_exp), exp):
        return (matched_term_in_exp, matched_term_in_termset, fuzz_str_add+"full_substring")

    # otherwise, if it is a subword, remove the whole relevant string
    full_matched_term_in_exp = re.search("\w*({})\w*".format(matched_term_in_exp), exp).groups()[0]
    return (full_matched_term_in_exp, matched_term_in_termset, fuzz_str_add+"subword")


def passes_edit_dist_ratio(distance, str1,str2):
    if not len(str1) or not len(str2):
        return False
    return distance / float(len(str1)) <= .2 and distance / float(len(str2)) <= .2


def label(exp, termset):
    if not exp:
        return None

    # If there's an exact match, we're done
    if exp in termset:
        return (exp, exp, "exact_full")

    #### OK, so, no exact matches, we're going to look for misspellings, subwords, exact within the larger string

    # First, cut down potential matches to those that are shorter or almost shorter than exp (within edit distance range)
    exp_len = len(exp)
    terms = [t for t in termset if len(t) <= exp_len+2 ]

    #### First look for almost exact matches based on edit distance
    #Compute edit distance for every term and Take all terms that have an edit distance of 2 or less
    term_to_edit_dist = [ (t, rdlevenshtein(t,exp)) for t in terms]
    term_to_edit_dist = [x for x in term_to_edit_dist if x[1] < 3]
    # sort by edit distance, then length
    term_to_edit_dist = sorted(term_to_edit_dist, key=cmp_to_key(my_cmp))
    if len(term_to_edit_dist):
        for t,dist in term_to_edit_dist:
            if passes_edit_dist_ratio(dist,t,exp):
                # Take the best match -> longest and lowest edit
                best_match = term_to_edit_dist[0]
                return (exp, best_match[0], "editdist")


    # OK, nothing obvious, so we need to search through the string

    #### First, look for exact matches, these can be either subwords or full matches
    exact_matches = [t for t in terms if t in exp]

    # if there's any exact matches, return them
    if len(exact_matches):
        # order by length
        exact_matches = sorted(exact_matches, key=lambda x: -len(x))
        # take the longest
        matched_term = exact_matches[0]

        return determine_subword(matched_term, matched_term, exp)

    ### OK, otherwise we're in a situation where we have a fuzzy match to a subset of the string

    # We find all strings that have an edit distance of <3 somewhere within the string
    fuzzy_matches = []
    for t in terms:
        # bigger edit dist, but then use RDleveinstein
        fuzzy_match = find_near_matches(t, exp, max_l_dist=2)
        if fuzzy_match:
            matched_text = exp[fuzzy_match[0].start:fuzzy_match[0].end]
            if passes_edit_dist_ratio(fuzzy_match[0].dist, matched_text, t):
                fuzzy_matches.append((matched_text,t))

    if len(fuzzy_matches):
        # sort the fuzzy matches by length of matched substring and return
        fuzzy_matches = sorted(fuzzy_matches, key=lambda x: -len(x[0]))
        return determine_subword(fuzzy_matches[0][0], fuzzy_matches[0][1], exp,"fuzzy_")

    # OK, otherwise, no matches!
    return None

def update(exp, matched_exp):
    return exp.replace(matched_exp, "").strip()


def clean_fieldnames(name):
    if not name:
        return None
    name = name.lower()
    name = name.replace("department of","")
    name = name.replace("dept of", "")
    name = name.replace("faculty of", "")
    name = name.replace("school of", "")
    name = name.replace("college of", "")
    name = name.replace("institute for", "")
    name = name.replace("institute of", "")
    name = name.replace("the ", "")
    name = name.replace("  "," ")
    name = name.replace("\t", " ").replace("\n"," ")
    name = name.replace("(","").replace(")","")
    return(name.strip())


def perform_labeling(input_str):
    labels = []
    expression_split = [x.strip() for x in re.split(r"-| and |,|&|/|\+|;", input_str.lower().strip())]

    remaining_content = ""
    for exp in expression_split:
        exp = update(exp, "")
        while True:
            match = label(exp, set(survey_terms))
            if match:
                labels.append(match)
                exp = update(exp, match[0])
                if not len(exp):
                    break
            else:
                remaining_content += " " + exp
                break

    output = []
    for label_res in labels:
        field = term_to_field_map[label_res[1]]
        # hack to deal with communications in engineering
        if field == 'communications' and ('compute' in input_str or
                                          'engineer' in input_str or
                                          'machine' in input_str or
                                          'electr' in input_str):
            continue
        output.append((field, label_res[0], label_res[1], label_res[2]))
    return output, remaining_content


if __name__ == "__main__":


    # FOR SIMPLE TESTING PURPOSES
    td = []
    td.append(({}, 'immunochemistry and math and the field of telecommunications and physic and field of communicatio'))
    #td.append(({}, "electric and information engineering"))
    #td.append(({}, "comparative literature and poetics, shirley and leslie porter cultural studies "))
    #td.append(({},"e.e."))
    #td.append(({}, "hisotry and english literature"))
    #td.append(({}, "electronics & communication egnieering"))
    td.append(({},"biomedical engineering"))
    # OUR FULL TEST
    import pandas as pd
    test_data =pd.read_csv("../../data/processed/field_match_test_sheet.csv",names=['to','from'])
    td = []
    for i, row in test_data.iterrows():
        to = [x.strip() for x in row['to'].lower().strip().split(",")]
        to_res =[]
        for x in to:
            if x == 'none' or x == 'regex' or x == 'other':
                continue
            if x in survey_terms_map.keys():
                to_res.append(x)
        #td.append((set(to_res), row['from']))


    miss = 0
    for result, input_str in td:
        output = perform_labeling(input_str)
        fields = {m[0] for m in output if m[0] != "NONE"}

        if fields != result:
            print(input_str, "\t\n", result, "\t\n", output, "\n")
            miss += 1

    print(miss, len(td))
