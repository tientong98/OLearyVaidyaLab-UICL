
# coding: utf-8

# In[1]:


import pandas as pd
import os
import numpy as np
from glob import glob


# In[2]:


bids_dir = '/Shared/oleary/functional/UICL/BIDS/'
txt_dir = '/raid0/homes/crcshare/people/Dan_Oleary/UI_College_Life/fMRI_behav_data'


sessions = list()
handle = open("/oleary/functional/UICL/BIDS/subject_list/session1.txt")
for line in handle:
    line = line.rstrip()
    sessions.append(line)

sublist = list()
handle1 = open("/oleary/functional/UICL/BIDS/subject_list/subjects.txt")
for line1 in handle1:
    line1 = line1.rstrip()
    sublist.append(line1)
runs = ['1', '2']


# In[3]:


for i in range(len(sublist)):
    for run in runs:
        # outputs are saved to BIDS directory
        out_file = os.path.join(bids_dir, 'sub-' + sublist[i], 'ses-' + sessions[i], 'func', 'sub-{subl}_ses-{sesl}_task-stopsignal_run-{runl}_events.tsv'.format(subl=sublist[i], sesl=sessions[i], runl=run))
        stop_signal_file = os.path.join(txt_dir, sublist[i], sublist[i] + '_ST_' + run + '.txt')
        # read txt file, ignoring all lines that didn't start with Event Type
        str_collector = []
        collect = False
        with open(stop_signal_file, 'r') as txt:
            for line in txt:
                if line.startswith('Event Type'):
                    collect=True
                if collect:
                    str_collector.append(line)
        # manipulate txt file in python, making the first line the header
        datalist = [strg.strip('\n').split('\t') for strg in str_collector]
        headers = datalist.pop(0)
            
        # Import dataframe to pandas table
        df = pd.DataFrame(datalist, columns=headers)
            
        # MANIPULATE THINGS IN PANDAS TABLE
        # exclude the first row, which is Nan
        df = df.drop([0])
        # identify go and stop trials
        df['Go'] = np.where(df.Code == 'go:rt', 'go',np.where(df.Code == 'go:lt','go', ''))
        df['Stop'] = np.where(df.Code == 'inhib_go:rt', 'stop',np.where(df.Code == 'inhib_go:lt','stop', ''))
        # Create an 'onset' colume for 'go' and 'stop' rows, each value = df.Time
        df['onset'] = np.where(df.Go == 'go', df.Time, np.where(df.Stop == 'stop', df.Time, ''))
        # making all values in this 'onset' column integers
        df['onset'] = pd.to_numeric(df['onset'])                    
        # assigning a value to the onset of the 1st event
        a = (df.iloc[0]['Time'])
        # deleting any row with NaN, i.e., any rows that are not Go and Stop trials
        df = df.dropna(axis=0, how='any')
        # calculate onset (onset of a given event - onset of the 1st event)
        # then, convert 'onset' time to second
        df['onset'] = (df['onset'] - int(a)) / 10000
        # Calculate the Duration from raw data
        df.rename(columns={'Duration':'DurationRaw'}, inplace=True)  
        df['DurationRaw'] = pd.to_numeric(df['DurationRaw'])
        df['duration'] = (df['DurationRaw'] / 10000)            
        # Go trials categories: 
            # correct go (press correct button when there was no buzzer) 
            # incorrect go (press wrong button when there was no buzzer)
            # missed go (did not press button when there was no buzzer)    
            # Stop trials categories: 
            # correct stop (suppress pressing button when there was buzzer) 
            # incorrect stop (press correct button when there was buzzer)
            # failed stop (press wrong button when there was buzzer)
        df['trial_type'] = np.where((df.Go == 'go') & (df.Type == 'hit'), 'CorGo',
                                    np.where((df.Go == 'go') & (df.Type == 'incorrect'), 'IncGo',
                                    np.where((df.Go == 'go') & (df.Type == 'miss'), 'MissGo',
                                    np.where((df.Stop == 'stop') & (df.Type == 'miss'), 'CorStop',
                                    np.where((df.Stop == 'stop') & (df.Type == 'hit'), 'IncStop',
                                    np.where((df.Stop == 'stop') & (df.Type == 'incorrect'), 'FailStop',''
                                    ))))))           
        # calculate the RT from raw data
        df['RT'] = pd.to_numeric(df['RT'])
        df['response_time'] = (df['RT'] / 10000)
        # drop all columns we don't need
        df = df.drop(['Event Type', 'Code', 'Type', 'Response', 'RT', 'RT Uncertainty', 
                          'Time', 'DurationRaw', 'Uncertainty', 'ReqTime', 'ReqDur', 'Go', 'Stop'], axis = 1)
        # calculate the duration of the excluded first TRs
        TR = 2.8
        N_TR_exclude = 5
        truncate = TR * N_TR_exclude
        # substract all onset timing by the truncated duration
        df['onset'] = (df['onset'] - truncate)
        # writing pandas table to BIDS tsv
        df.to_csv(out_file, na_rep = 'n/a', index=False, sep='\t')
    


# In[23]:


stop_signal_dict = {}
runs = [['1', '2'], ['3', '4']]
for sub in sublist:
    sessions = glob(os.path.join(bids_dir, 'sub-' + sub, 'ses-*'))
    sessions = [int(label.split('-')[2]) for label in sessions]
    sessions.sort()
    sessions = [str(ses) for ses in sessions]
    for ses, run_nums in zip(sessions, runs):
        stop_signal_dict['_'.join([sub, ses])] = []
        for run in run_nums:
            stop_signal_file = os.path.join(txt_dir, sub, sub + '_ST_' + run + '.txt')
            stop_signal_dict['_'.join([sub, ses])].append(stop_signal_file)
            # name of the tsv
            # outputs are saved to BIDS directory
            out_file = os.path.join(bids_dir, 'sub-' + sub, 'ses-' + ses, 'func', 'sub-{subl}_ses-{sesl}_task-stopsignal_run-{runl}_events.tsv'.format(subl=sub, sesl=ses, runl=run))

            # read txt file, ignoring all lines that didn't start with Event Type
            str_collector = []
            collect = False
            with open(stop_signal_file, 'r') as txt:
                for line in txt:
                    if line.startswith('Event Type'):
                        collect=True
                    if collect:
                        str_collector.append(line)
            # manipulate txt file in python, making the first line the header
            datalist = [strg.strip('\n').split('\t') for strg in str_collector]
            headers = datalist.pop(0)
            
            # Import dataframe to pandas table
            df = pd.DataFrame(datalist, columns=headers)
            
            # MANIPULATE THINGS IN PANDAS TABLE
            # exclude the first row, which is Nan
            df = df.drop([0])
            # identify go and stop trials
            df['Go'] = np.where(df.Code == 'go:rt', 'go',np.where(df.Code == 'go:lt','go', ''))
            df['Stop'] = np.where(df.Code == 'inhib_go:rt', 'stop',np.where(df.Code == 'inhib_go:lt','stop', ''))
            # Create an 'onset' colume for 'go' and 'stop' rows, each value = df.Time
            df['onset'] = np.where(df.Go == 'go', df.Time, np.where(df.Stop == 'stop', df.Time, ''))
            # making all values in this 'onset' column integers
            df['onset'] = pd.to_numeric(df['onset'])                    
            # assigning a value to the onset of the 1st event
            a = (df.iloc[0]['Time'])
            # deleting any row with NaN, i.e., any rows that are not Go and Stop trials
            df = df.dropna(axis=0, how='any')
            # calculate onset (onset of a given event - onset of the 1st event)
            # then, convert 'onset' time to second
            df['onset'] = (df['onset'] - int(a)) / 10000
            # Calculate the Duration from raw data
            df.rename(columns={'Duration':'DurationRaw'}, inplace=True)  
            df['DurationRaw'] = pd.to_numeric(df['DurationRaw'])
            df['duration'] = (df['DurationRaw'] / 10000)            
            # Go trials categories: 
                # correct go (press correct button when there was no buzzer) 
                # incorrect go (press wrong button when there was no buzzer)
                # missed go (did not press button when there was no buzzer)    
            # Stop trials categories: 
                # correct stop (suppress pressing button when there was buzzer) 
                # incorrect stop (press correct button when there was buzzer)
                # failed stop (press wrong button when there was buzzer)
            df['trial_type'] = np.where((df.Go == 'go') & (df.Type == 'hit'), 'CorGo',
                                        np.where((df.Go == 'go') & (df.Type == 'incorrect'), 'IncGo',
                                        np.where((df.Go == 'go') & (df.Type == 'miss'), 'MissGo',
                                        np.where((df.Stop == 'stop') & (df.Type == 'miss'), 'CorStop',
                                        np.where((df.Stop == 'stop') & (df.Type == 'hit'), 'IncStop',
                                        np.where((df.Stop == 'stop') & (df.Type == 'incorrect'), 'FailStop',''
                                       ))))))           
            # calculate the RT from raw data
            df['RT'] = pd.to_numeric(df['RT'])
            df['response_time'] = (df['RT'] / 10000)
            # drop all columns we don't need
            df = df.drop(['Event Type', 'Code', 'Type', 'Response', 'RT', 'RT Uncertainty', 
                          'Time', 'DurationRaw', 'Uncertainty', 'ReqTime', 'ReqDur', 'Go', 'Stop'], axis = 1)
            # calculate the duration of the excluded first TRs
            TR = 2.8
            N_TR_exclude = 5
            truncate = TR * N_TR_exclude
            # substract all onset timing by the truncated duration
            df['onset'] = (df['onset'] - truncate)
            # writing pandas table to BIDS tsv
            df.to_csv(out_file, na_rep = 'n/a', index=False, sep='\t')    


# In[6]:





# In[7]:


sessions


# In[71]:


lst1 = ['20180504', '20180510']
lst2 = [['1', '2'], ['3', '4']]

for num, let in zip(lst1, lst2):
    print(num)
    print(let)


# In[76]:


test_dict = {'3003': {'dummy': ['txt1', 'txt2']}}


# In[79]:


test_dict['3003']['dummy']

