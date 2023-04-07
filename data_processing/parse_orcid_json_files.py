# coding: utf-8

# In[ ]:

import glob
import ujson as json
import gzip
import os

JSON_DATA_DIR = "../../data/raw/"


# In[ ]:

def parse_bio(bio_part):
    first_name, last_name = "None", "None"
    if bio_part["personal-details"]["given-names"]:
        first_name = bio_part["personal-details"]["given-names"]["value"].encode('utf-8').replace("\t", " ")
    if bio_part["personal-details"]["family-name"]:
        last_name = bio_part["personal-details"]["family-name"]["value"].encode('utf-8').replace("\t", " ")
    if bio_part["biography"]:
        bio = bio_part["biography"]['value'].encode('utf-8').replace("\t", " ").replace("\n", " ")
    else: bio = "None"
    if bio_part["researcher-urls"]:
        researcher_urls = [unicode(u['url']['value']).replace("\t", " ") for u in bio_part["researcher-urls"]["researcher-url"]]
    else: researcher_urls = "None"
    if bio_part["contact-details"]:
        if bio_part["contact-details"]["address"]:
            country = bio_part["contact-details"]["address"]["country"]["value"].replace("\t", " ")
        else: country = "None"
    else: country = "None"
    if bio_part['keywords']:
        keywords = [str(k['value'].encode('utf-8')).replace("\t", " ") for k in bio_part['keywords']['keyword']]
    else: keywords = "None"
    return [first_name, last_name, str(bio), str(researcher_urls), str(country), str(keywords)]

def parse(filename):
    with open(filename) as data_file:
        data = json.load(data_file)

        #ID
        id = str(data["orcid-profile"]["orcid-identifier"]['path'])

        #BIO
        if data['orcid-profile']['orcid-bio']:
            bio_values = parse_bio(data['orcid-profile']['orcid-bio'])
        else:
            bio_values = ["None", "None", "None", "None", "None", "None"]
    return bio_values, id

def parse_affiliations(file_name):
    f = json.load(open(file_name))
    f = f['orcid-profile']
    if not 'orcid-activities' in f or not f['orcid-activities']:
        return {}
    aff = f['orcid-activities'].get('affiliations',{})
    if not aff:
        return {}
    return aff
    


# In[ ]:

fils = glob.glob(os.path.join(JSON_DATA_DIR, "*"))
with gzip.open("../../data/output/affiliations.json.gz","w") as of:
    f = open("fail.txt","w")
    for i,fil in enumerate(fils):
        if i % 25000 == 0:
            print i
        try:
            affils = parse_affiliations(fil)
            if len(affils):
                bio = parse(fil)
                affils['bio'] = bio[0]
                affils['id'] = bio[1]
                of.write(json.dumps(affils).strip().encode("utf8") + "\n")
        except:
            f.write(fil+"\n")
    f.close()

