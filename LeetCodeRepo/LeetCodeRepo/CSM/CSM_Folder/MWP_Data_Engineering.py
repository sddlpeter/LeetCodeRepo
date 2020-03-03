import pandas as pd
import numpy as np
import warnings
pd.options.mode.chained_assignment = None
warnings.simplefilter(action='ignore', category=FutureWarning)


###############################################################################
# FUNCTIONS


def fields_mapping(mapping_dict, mapping_file_path, data_source):
    '''
    this function maps fields in raw data based on mapping tables to create clean fields
    :parameter mapping_dict: dictionary of columns needed for mapping purpose
    :parameter mapping_file_path: string to represent mapping file location
    :parameter data_source: raw data in dataframe
    :returns merged: dataframe with the mapped fields added
    '''

    for idx, k in enumerate(mapping_dict.keys()):

        if idx == 0:  # Create the "merged" dataframe
            # Read in the excel document with the mapping
            mapping_doc = pd.read_excel(mapping_file_path, sheet_name=str(k))

            # Pick relevant columns: Key Columns + Flag Columns

            # Make list of Flag Column:
            # Grab the Target FLAG
            relevant_columns = [col for col in mapping_doc.columns if "FL" in col and col not in mapping_dict[k]]

            flag = relevant_columns.copy()  # Copy for later use

            # Check: Should only be one target column
            assert len(relevant_columns) == 1

            # Add key columns to the list of relevant columns
            relevant_columns.extend(mapping_dict[k])

            # Create new df called merged: that merges the relevant columns from the mapping document with the rave request data
            merged = data_source.merge(mapping_doc[relevant_columns], on=mapping_dict[k], how='left').reset_index(drop=True)

        else:  # Add to the "merged" dataframe
            # Read in the excel document with the mapping
            mapping_doc = pd.read_excel(mapping_file_path, sheet_name=str(k))

            # Pick relevant columns: Key Columns + Flag Columns

            # Make list of Flag Column:
            # Add column if it is a flag column and make sure it's not double counted it by checking it's not already a key column
            relevant_columns = [col for col in mapping_doc.columns if "FL" in col and col not in mapping_dict[k]]

            flag = relevant_columns.copy()  # Copy for later use

            # Add key columns to the list of relevant columns
            relevant_columns.extend(mapping_dict[k])

            # Add the new Flags to the merged colum by sequentially merging
            merged = merged.merge(mapping_doc[relevant_columns], on=mapping_dict[k], how='left').reset_index(drop=True)

    # Print mismatch: How many are unmapped?
    flag_columns = [col for col in merged.columns if "FL" in col]
    merged[flag_columns] = merged[flag_columns].fillna('Undefined')

    # Check 1: Make sure number of rows are the same between the flagged data and the Rave Request Data
    assert merged.shape[0] == data_source.shape[0]

    # Check 2: The new columns should only be the flagged columns
    merged.shape[1] - data_source.shape[1] == len(flag_columns)

    return merged


def align_data_dates(data, start_date, end_date):
    '''
    this function aligns start and end dates in raw data set
    :parameter data: data frame of raw data
    :parameter start_date: start date of raw data
    :parameter end_date: end date of raw data
    :returns data_t: dataframe with the raw data in selected date range
    '''
    if 'CreatedDateTime' in data.columns:
        # for RR, date column is named as CreatedDateTime
        data_t = data[(data['CreatedDateTime'] > start_date) &
                      (data['CreatedDateTime'] < end_date)].reset_index(drop=True)
        return data_t

    if 'AR_CreateDateTime' in data.columns:
      # for RR, date column is named as AR_CreatedDateTime
        data_t = data[(data['AR_CreateDateTime'] > start_date) &
                      (data['AR_CreateDateTime'] < end_date)].reset_index(drop=True)

        return data_t

def run_ETL(raw_input_path, sheetname, dt_data_start, dt_data_end, map_dic, mapping_file_path, output_filename):
  '''
  this function executes the steps to load raw data and map desired fields (by calling relevant functions) 
  :parameter raw_input_path: raw input file location
  :parameter sheetname: Excel sheetname of RR data
  :parameter dt_data_start: start date of raw data
  :parameter dt_data_end: end date of raw data
  :parameter map_dic: dictionary of columns needed for mapping purpose
  :parameter mapping_file_path: mapping file location
  :parameter output_filename: cache file location
  :returns merged_df: dataframe with the RR data including mapped fields
  '''
  rr = pd.read_excel(raw_input_path, sheet_name=sheetname) # load raw data 
  df_r_t = align_data_dates(rr, start_date=dt_data_start, end_date=dt_data_end)  # align dates
  merged_df = fields_mapping(mapping_dict=map_dic, mapping_file_path=mapping_file_path, data_source=df_r_t) # map fields
  merged_df.to_pickle(output_filename) # export to cache

  return merged_df

# prepare RR data (create forecast lines)
def data_prep_rr_fc(df, path_raw, path_cache, dict_tz_mapping, col_to_tag):
  '''
  this function defines the forecast line for RR 
  :parameter df: dataframe with RR data (including mapped fields)
  :parameter path_raw: input file location of raw data cache
  :parameter path_cache: output cache file location
  :parameter dict_tz_mapping: dictionary for time zone mapping
  :parameter col_to_tag: field name of the forecast line - i.e. the column used for labeling purpose
  :returns df_RR_team: dataframe with the forecast line added
  '''
  if B_use_cache_mapped:
    df_RR = pd.read_pickle(path_raw)  # load cache file
  else:
    df_RR = df.copy(deep=True)
  df_RR = df_RR.loc[df_RR['IsCSS'] == 'Yes', :]  # keep only CSS related requests
  # define forecast line
  df_RR['Hour'] = df_RR['CreatedDateTime'].apply(lambda x: int(x.time().hour))  # extract hour from timestamp
  df_RR['TZ'] = df_RR['Hour'].map(dict_tz_mapping)  # map time zone using dictionary
  df_RR[col_to_tag] = df_RR['FL_Technology'] + df_RR['FL_Audience'] + df_RR['FL_Language'] \
              + df_RR['FL_Severity'] + df_RR['FL_Cloud'] + df_RR['TZ']  # concatenate 6 fields to define forecast line
  cols_keep = [
         'RaveRequestId', 
         'ServiceRequestNumber', 
         'CreatedDateTime', 
         'CompletedDateTime', 
         'RaveRequestIsSDtoRave',
         'SupportLanguage', 
         col_to_tag
         ]  
  df_RR_team = df_RR.loc[:, cols_keep]  # select relevant columns to keep
  df_RR_team.to_pickle(path_cache)  # export to cache
  
  return df_RR_team

# prepare AR data (create forecast lines)
def data_prep_ar_fc(df, path_raw, path_cache, dict_tz_mapping, col_to_tag):
  '''
  this function defines the forecast line for RR 
  note that this function is different from RR prep function because fields names are different for AR
  :parameter df: dataframe with AR data (including mapped fields)
  :parameter path_raw: input file location of raw data cache
  :parameter path_cache: output cache file location
  :parameter dict_tz_mapping: dictionary for time zone mapping
  :parameter col_to_tag: field name of the forecast line - i.e. the column used for labeling purpose
  :returns df_ar: dataframe with the forecast line added
  '''
  if B_use_cache_mapped:
    df_ar = pd.read_pickle(path_raw) # load cache file
  else:
    df_ar = df.copy(deep=True)
  df_ar['Hour'] = df_ar['AR_CreateDateTime'].apply(lambda x: int(x.time().hour))  # extract hour from timestamp
  df_ar['TZ'] = df_ar['Hour'].map(dict_tz_mapping)  # map time zone using dictionary
  df_ar['FL_AR_SupportAreaName'] = df_ar['FL_AR_SupportAreaName'].fillna('Undefined')  # fill missing values with "undefined"
  df_ar[col_to_tag] = df_ar['FL_AR_SupportAreaName'] + df_ar['AR_FL_Audience'] + df_ar['FL_Language'] \
                 + df_ar['FL_Severity'] + df_ar['FL_Cloud'] + df_ar['TZ']  # concatenate 6 fields to define forecast line
  df_ar.to_pickle(path_cache) # export to cache

  return df_ar

def workload_label(df, col_to_tag, str_tag):
  '''
  this function labels each event's status with respect to a line/team
  :parameter df: dataframe of RR data with forecast line defined
  :parameter col_to_tag: column that the labeling is based on; should be the column name of the forecast line
  :parameter str_tag: name of the target line that the labeling is with respect to
  :returns df_output: dataframe with workload event labeled with respect to str_tag
  '''
  print('Tagging ' + str_tag)

  # select relevant data
  df_RR_team_entry = df.loc[df[col_to_tag] == str_tag, :]  # take all records associated with target line
  list_team_tickets = list(df_RR_team_entry['ServiceRequestNumber'].unique())  # extract all ticket numbers associated with these events
  df = df.loc[df['ServiceRequestNumber'].isin(list_team_tickets), :]  # select the records associated with these ticket numbers
  df[col_to_tag] = df[col_to_tag].fillna('Other')  # replace null values in target column with "other"

  # tag team/line
  df_output = pd.DataFrame()
  for t in list_team_tickets:
    # loop through each ticket
    df_tk = df.loc[df['ServiceRequestNumber'] == t, :]  # select events in this ticket
    list_from_SD = list(df_tk['RaveRequestIsSDtoRave'])  # capture whether the ticket is from Service Desk
    if len(df_tk) == 1:
      # only 1 RR
      df_tk['Is_open'] = [True]  # single event is an open event
      df_tk['Is_Last'] = [True]  # single event is the last event of the ticket
      B_from_SD = list_from_SD[0]
      if B_from_SD == 'Yes':
        # if ticket is from service desk, then it is opened somewhere else, so this single event is a transfer-in
        df_tk['Tag'] = 'TI-inside'
      else:
        # if ticket is not from service desk, then this event is a single event within our target line
        df_tk['Tag'] = 'IN-single'
    elif 'Yes' in list_from_SD:
      # if multiple events in this ticket and the ticket is from SD, then the ticket is a transfer-in
      num_requests = len(df_tk)
      list_to_tag = list(df_tk[col_to_tag])
      df_tk = df_tk.sort_values(by='CreatedDateTime')
      # tag events in target line as TI-inside, otherwise it is TI-outside
      list_tags = ['TI-inside' if x == str_tag else 'TI-outside' for x in list_to_tag]
      df_tk['Tag'] = list_tags
      df_tk['Is_Last'] = [False] * (num_requests-1) + [True]  # label last event of the ticket
      df_tk['Is_open'] = [True] + [False] * (num_requests-1)  # label open event of the ticket
    else:
      # multipe events in this ticket, but not transferred from SD
      df_tk = df_tk.sort_values(by='CreatedDateTime')
      num_requests = len(df_tk)
      list_unique_team = list(df_tk[col_to_tag].unique())
      if len(list_unique_team) == 1:
        # only 1 unique line/team: this is completed within target line but has multiple events (likely internal handovers)
        list_tags = ['IN-multi-open'] + ['IN-multi-inside']*(num_requests-1)  # differentiate open events vs. other internal work
        df_tk['Tag'] = list_tags
      else:
        list_rr_team = list(df_tk[col_to_tag])
        if list_rr_team[0] == str_tag:
          # if the first event is in our target line, it is a transfer OUT
          list_to_tag = list_rr_team[1:]
          # inside request if it is done by our line; outside request if it is done by another line
          list_tags = ['TO-inside' if x == str_tag else 'TO-outside' for x in list_to_tag]
          df_tk['Tag'] = ['TO-open'] + list_tags
        else:
          # otherwise, this ticket is a transfer IN
          list_to_tag = list_rr_team[1:]
          # inside request if it is done by our line; outside request if it is done by another line
          list_tags = ['TI-inside' if x == str_tag else 'TI-outside' for x in list_to_tag]
          df_tk['Tag'] = ['TI-open'] + list_tags
      df_tk['Is_Last'] = [False] * (num_requests-1) + [True]  # label last event of the ticket
      df_tk['Is_open'] = [True] + [False] * (num_requests-1)  # label open event of the ticket
    df_output = pd.concat([df_output, df_tk], sort=False)

  df_output['Duration_in_min'] = df_output['CompletedDateTime'] - df_output['CreatedDateTime']  # calculate RR duration
  df_output['Duration_in_min'] = df_output['Duration_in_min']/np.timedelta64(1,'m')  # measure duration in minutes

  df_output['tag_obj'] = str_tag  # label the target line (for easy selection later when concatenated with other lines)

  return df_output

###############################################################################
# PARAMETERS

mapping_file_path = '../Raw Input/FC_Line_Mapping_vS.xlsx'
raw_input_path = '../Raw Input/RaveData4BCG_20191211.xlsx'
dt_data_start = '2019-01-01'
dt_data_end = '2019-11-01'
rr_sheetname = 'RaveRequest2019'
ar_sheetname = 'CollaborationWorkload'
path_raw_rr = '../Cache/RR_mapped.pkl'
path_raw_ar = '../Cache/AR_mapped.pkl'
path_cache_rr_w_fc = '../Cache/RR_w_fc_lines.pkl'
path_cache_rr_tagged = '../Cache/RR_tagged.pkl' # consistent with model input location
path_cache_ar_w_fc = '../Cache/AR_w_fc_lines.pkl' # consistent with model input location
col_to_tag = 'FC_Line_TZ'

B_use_cache_raw = False # whether to use cache raw data (instead of reloading flat files)
B_use_cache_mapped = False  # whether to use cache data with fields already mapped
B_use_cache_fc = False  # whether to use cahce data with forecast line already defined
B_prep_all_lines = False  # whether to label all lines

rr_map_dic = {'Cloud': ['GeographyLevel2Name', 'IsCloudRaveRequest'],
              'Region': ['GeographyLevel2Name'],
              'Severity': ['WasRaveRequestCritsit'],
              'Service Offering': ['ServiceOffering'],
              'Language': ['SupportLanguage', 'GeographyLevel2Name'],
              'RR_S500': ['SupportAreaName'],
              'RR Customer Audience': ['PlanningCategory', 'ServiceOffering', 'FL_S500'],
              'ThemeMap':['Theme'],
              'Product':['SupportAreaName', 'FL_ThemeProduct']}

ar_map_dic = {'ARProduct': ['AR_SupportAreaName'],
             'AR Severity': ['From_WasRaveRequestCritsit'],
             'AR Cloud': ['From_GeographyLevel2Name', 'From_IsCloudRaveRequest'],
             'AR Language': ['From_SupportLanguage', 'From_GeographyLevel2Name'],
             'AR_S500': ['From_SupportAreaName'], 
             'AR Customer Audience': ['From_PlanningCategory', 'From_ServiceOffering', 'FL_AR_S500']} 

# timezone mapping (for forecast line definition)
dict_americas = {k: 'Americas' for k in range(14, 22)}
dict_apac = {**{k: 'APAC' for k in range(0, 6)}, **{k: 'APAC' for k in range(22, 24)}}
dict_emea = {k: 'EMEA' for k in range(6, 14)}
dict_tz_mapping = {**dict_americas, **dict_apac, **dict_emea}

list_lines = [
        'SharePointNon-S500EnglishCritSitCloudAmericas',
        'SharePointNon-S500EnglishNon-CritSitCloudAmericas',
        'SharePointNon-S500Non-EnglishNon-CritSitCloudAmericas',
        'SharePointNon-S500Non-EnglishCritSitCloudAmericas',  # low volume
        'SharePointNon-S500JapaneseCritSitCloudAPAC',   # low volume
        'SharePointNon-S500JapaneseNon-CritSitCloudAPAC',
        'SharePointNon-S500JapaneseNon-CritSitOn-PremAPAC',  # low volume
        'ExchangeNon-S500EnglishNon-CritSitCloudEMEA',
        'ExchangeNon-S500EnglishCritSitCloudEMEA',
        'ExchangeNon-S500Non-EnglishNon-CritSitCloudEMEA',
        'ExchangeNon-S500Non-EnglishCritSitCloudEMEA',  # low volume 
        'ExchangeNon-S500EnglishNon-CritSitOn-PremAmericas',
        'ExchangeNon-S500EnglishCritSitOn-PremAmericas',  #  low volume
        'ExchangeNon-S500Non-EnglishNon-CritSitOn-PremAmericas',  # low volume
        'ExchangeNon-S500Non-EnglishCritSitOn-PremAmericas',  
        'SharePointNon-S500JapaneseCritSitOn-PremAPAC',   # no volume in Oct 19
        ]

###############################################################################
# EXECUTION


if __name__ == "__main__":
  # raw ETL and map fields
  if not B_use_cache_raw:
    print("Running ETL on RR...")
    df_rr_fc = run_ETL(raw_input_path, rr_sheetname, dt_data_start, dt_data_end, rr_map_dic, mapping_file_path, path_raw_rr)
    print("Running ETL on AR...")
    df_ar_fc = run_ETL(raw_input_path, ar_sheetname, dt_data_start, dt_data_end, ar_map_dic, mapping_file_path, path_raw_ar)
  else:
    df_rr_fc = pd.DataFrame()
    df_ar_fc = pd.DataFrame()

  # define forecast lines
  if not B_use_cache_fc:
    print("Defining FC line for RR...")
    df_rr = data_prep_rr_fc(df_rr_fc, path_raw_rr, path_cache_rr_w_fc, dict_tz_mapping, col_to_tag)
    print("Defining FC line for AR...")
    df_ar = data_prep_ar_fc(df_ar_fc, path_raw_ar, path_cache_ar_w_fc, dict_tz_mapping, col_to_tag)
  else:
    df_rr = pd.read_pickle(path_cache_rr_w_fc)

  # tag workload
  df_all_tagged = pd.DataFrame()
  if B_prep_all_lines:
    list_lines = list(df_rr[col_to_tag].unique())
  for str_line in list_lines:
    df_tagged_line = workload_label(df_rr, col_to_tag, str_line)
    df_all_tagged = pd.concat([df_all_tagged, df_tagged_line])

  df_all_tagged.to_pickle(path_cache_rr_tagged)


  