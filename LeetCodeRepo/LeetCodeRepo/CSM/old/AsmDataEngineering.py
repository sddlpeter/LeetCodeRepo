'''
This script allows to load, clean and process raw ASIM event level data, and to assign a 
workload status of each event in the dataset. Note that the functions defined here are 
called and used in the main modeling script: AsimModeling.py
'''

###############################################################################
import pandas as pd
import seaborn as sns
import numpy as np
import matplotlib.pyplot as plt
import matplotlib
from datetime import timedelta 
sns.set(style = 'darkgrid')
matplotlib.rcParams['font.sans-serif'] = "Segoe UI"
###############################################################################

###############################################################################
def getTimeFeatures(dt):
    '''
    Extract and return time features from a Timestamp
    :parameter dt: the Timestamp to break down
    :return dt.year, dt.month, dt.day, dt.isoweekday(): the corresponding year, month, day of month, day of week
    '''
    return dt.year, dt.month, dt.day, dt.isoweekday() #Monday maps to 1, Sunday maps to 7
###############################################################################

###############################################################################
def getWorkload(g, workloadType, AssignmentTag, RoutingActionList, workTimeThreshold):
    '''
    Extract and compute workload from the event data. In other words, tag whether or not an event generates workload and keep track of what typ of workload is being generated (if any).
    The idea behind the workload tagging is to make sure that some form of work was performed by an engineer before she/he reroutes the case or task that was routed to her/his queue.
    Hence, the methodology not only checks when a case or task is being (re)routed to a queue, but also makes sure an agent was assigned and that a significant amount of time elapsed
    before a new rerouting event took place (e.g. 15 minutes minimum). If for instance an agent reroutes a case to another queue a few seconds after the case was assigned to her/him,
    no workload will be counted at this step of the incident.
    :parameter g: the dataframe of the incident to compute workload on (pandas group)
    :parameter workloadType: the name of the workload to be computed (e.g. MainWorkloadType or AdditionalWorkloadType) (string) - will become a new column name in the dataframe the function is run against
    :parameter AssignmentTag: the entity action that is considered as case/task assignment (e.g. AgentAssigned or TaskAssignedToAgent) (string)
    :parameter RoutingActionList: the list of entity actions that can be considered as routing events (e.g. ['CaseRouted', 'CaseRerouted', 'CaseManuallyRerouted', 'CaseReopened']) (list)
    :parameter workTimeThreshold: the time threshold (in minute) after which it is assumed that the agent worked on a case/task long enough that some workload is generated 
    :return g: the modified group (with an additional workloadType column) (pandas group)
    '''

    listAction = list(g['EntityAction']) #get ordered sequence of EntityAction (chronologically ascending)
    listActionTime = list(g['EventDateTime']) #get ordered sequence of EventDateTime (chronologically ascending)
    OriginatingSystem = list(g['OriginatingSystem'])[0] #get the name of the system the case orginitated from
    W = ['NoWorkload'] * len(listAction) #instantiate the workload vector W with 'NoWorkload' at each entry

    shift = 0 #amount by which to shift the index after truncating the listAction (will be used at the end of each iteration)
    while True:
        try: #try to identify the index of the next occurence of AssignmentTag
            selectedAgentAssigned = min(idx for idx, val in enumerate(listAction) if val == AssignmentTag)
        except: #if can't find one, end process
            break
        try: #try to find the last routing action index (i.e. candidate row for workload generation) prior to the currently selected AssignmentTag index 
            priorRouting = max(idx for idx, val in enumerate(listAction[ : selectedAgentAssigned]) if val in RoutingActionList)
        except: #if no routing actions is found prior to the currently selected AssignmentTag index, then consider the current AssignmentTag line as the prior routing row (i.e. the candidate row for workload generation)
            priorRouting = selectedAgentAssigned
        try: #try to find the first routing event index or first AssignmentTag (internal transfers) index after the currently selected AssignmentTag index 
            posteriorRouting = selectedAgentAssigned+1 + min(idx for idx, val in enumerate(listAction[selectedAgentAssigned + 1: ]) if val in RoutingActionList + [AssignmentTag])
        except: #if none are found (e.g. the agent solved/closed the case) then assign workload to the current candidate row (i.e. priorRouting, which can either be an AssignmentTag or an action in RoutingActionList)
            W[priorRouting + shift] = 'Workload_' + str(listAction[priorRouting])
            break
        
        workTime = (listActionTime[posteriorRouting] - listActionTime[selectedAgentAssigned]).total_seconds() / 60.0  #compute time delta between current AssignmentTag row and the first posterior routing (posteriorRouting) index
        if workTime > workTimeThreshold: #if workTime > 15min...
            W[priorRouting + shift] = 'Workload_' + str(listAction[priorRouting]) #then assign workload to the current candidate row (i.e. priorRouting, which can either be an AssignmentTag or an action in RoutingActionList)
        
        listAction = listAction[selectedAgentAssigned+1 : ] #truncate listAction and only focus on remaining part of the incident life (from selectedAgentAssigned+1 included and onward)
        shift += selectedAgentAssigned+1 #keep track of the shift to insert workload event at the right workload vector index
    
    #if the function is running to identify main workload events (e.g. case rerouting, routing, etc.)...
    #if any form of workload was found, and if the OriginatingSystem is not rave, then rename the first workload tag to indicate incident creation
    if workloadType == 'MainWorkloadType' and any('Workload_' in w for w in W) and OriginatingSystem not in ['Rave', 'RAVE']:  #if workloadType == 'MainWorkloadType' and any('Workload_' in w for w in W): 
        creationIx = min(idx for idx, val in enumerate(W) if val.find('Workload_') != -1)
        W[creationIx] = 'Workload_IncidentCreation' #note: not necessarily on Workload_CaseRouted (could be a Workload_CaseReRouted, etc.)

    g[workloadType] = W #store MainWorkloadType vector as a new column in the goup
    return g
###############################################################################

###############################################################################
def processAsimData(RawFileName):
    '''
    Load, clean and process raw ASIM event level data, before tagging the workload status of each event in the dataset
    :paramter RawFileName: the name of the raw csv file to read (str)
    :return rawDf: the raw dataframe (before any modification) (pandas)
    :return df: the processed and tagged dataframe - ready for modeling (pandas)
    '''
    
    print('load Service Desk event file: {}...'.format(RawFileName)) #Note: this comprises all events from all incidents that transited through ASIM at some point during their life cycle
    rawDf = pd.read_csv(RawFileName, low_memory = False)
    
    print('Keep only relevant fields')
    C = ['IncidentNumber', 'OriginatingSystem', 'EventDate', 'EventDateTime', 'LOB', 'PlanningCategory', 'Service_Offering', 'QueueName', 'EntityAction', 'State'] 
    df = rawDf[C].copy(deep = True)
    
    print('Convert data types and extract time features')
    df['EventDateTime'] = pd.to_datetime(df['EventDateTime'])
    df['EventDate'] = pd.to_datetime(df['EventDate'])
    df['Year'], df['Month'], df['DayOfMonth'], df['DayOfWeek'] = list(zip(*map(getTimeFeatures, df['EventDate'])))
    
    print('Sort per IncidentNumber and EventDateTime (chronologically)')
    df = df.sort_values(['IncidentNumber', 'EventDateTime'], ascending = [True, True]).reset_index(drop = True)
    
    print('Filter out all incidents whose first event\'s State is \'Closed\'')
    df = df.groupby('IncidentNumber').filter(lambda x: list(x['State'])[0] not in ['Closed', 'ClosedCompleted', 'ClosedCancelled']).sort_values(['IncidentNumber', 'EventDateTime'], ascending = [True, True]).reset_index(drop = True)
    
    print('Computing main workload...')
    df = df.groupby('IncidentNumber').apply(getWorkload,
                                            workloadType = 'MainWorkloadType',
                                            AssignmentTag = 'AgentAssigned',
                                            RoutingActionList = ['CaseRouted', 'CaseRerouted', 'CaseManuallyRerouted', 'CaseReopened'],
                                            workTimeThreshold = 15)
    
    print('Computing all other additional workload...')
    df = df.groupby('IncidentNumber').apply(getWorkload,
                                            workloadType = 'TaskWorkloadType',
                                            AssignmentTag = 'TaskAssignedToAgent',
                                            RoutingActionList = ['CollaborationTaskCreated', 'CollaborationTaskRerouted','CollaborationTaskManuallyRerouted', 'FollowUpTaskCreated', 'FollowUpTaskRerouted', 'FollowUpTaskManuallyRerouted', 'EscalationTaskCreated', 'EscalationTaskRerouted', 'EscalationTaskManuallyRerouted', 'RedemptionCreated'],
                                            workTimeThreshold = 15)
    
    print('Merge the 2 workload vectors (MainWorkloadType and TaskWorkloadType)') #note: if MainWorkloadType != 'NoWorkload' then TaskWorkloadType == 'NoWorkload' by definition - and vice-versa)
    df['AllWorkloadTypeRaw'] = ['NoWorkload' if (e[0] == 'NoWorkload' and e[1] == 'NoWorkload') else (e[0] if e[0] != 'NoWorkload' else e[1]) for e in zip(list(df['MainWorkloadType']), list(df['TaskWorkloadType']))]
    
    print('Clean up and finalize workload taxonomy...')
    taxonomyMap = {'Workload_IncidentCreation': 'IncidentCreation',
                   'Workload_CaseRerouted': 'TransferIntoQueue',
                   'Workload_CaseRouted': 'TransferIntoQueue', #some CaseRouted events are not considered IncidentCreation (e.g. if OriginatingSystem is RAVE)
                   'Workload_CaseManuallyRerouted': 'TransferIntoQueue', 
                   'Workload_AgentAssigned': 'TransferWithinQueue', #i.e. there was no rerouting between 2 distinct agent assignments
                   'Workload_CaseReopened' : 'AdditionalWorkload',
                   'Workload_CollaborationTaskCreated': 'AdditionalWorkload',
                   'Workload_CollaborationTaskRerouted': 'AdditionalWorkload',
                   'Workload_CollaborationTaskManuallyRerouted': 'AdditionalWorkload', 
                   'Workload_FollowUpTaskCreated': 'AdditionalWorkload',
                   'Workload_FollowUpTaskRerouted': 'AdditionalWorkload',
                   'Workload_FollowUpTaskManuallyRerouted': 'AdditionalWorkload',
                   'Workload_EscalationTaskCreated': 'AdditionalWorkload',
                   'Workload_EscalationTaskRerouted': 'AdditionalWorkload',
                   'Workload_EscalationTaskManuallyRerouted': 'AdditionalWorkload',
                   'Workload_TaskAssignedToAgent' : 'AdditionalWorkload',
                   'Workload_RedemptionCreated': 'AdditionalWorkload',
                   'NoWorkload': 'NoWorkload'}
    
    df['AllWorkloadType'] = df['AllWorkloadTypeRaw'].apply(lambda x: taxonomyMap[x])
    
    print('Compute WorkloadGeneration binary based on AllWorkloadType...')
    df['WorkloadGeneration'] = df['AllWorkloadType'].apply(lambda x: 1 if x != 'NoWorkload' else 0)
    
    #Note that the system was not fully adopted prior to spring/summer 2019 so we truncate the time series in the following way:
        #starting date: 2019-07-01 
        #ending date: second to last day available in data set (last day pull might be incomplete)
    #Note: we first compute workload, and then truncate the time series. Indeed, by doing so, we do not exclude fractions of incidents (e.g. get rid of first few events)
    #which could cause the routing or agent assignment to be lost and the workload to be innacurate at the start of the time series.
    print('Keep data in [2019-07-01, {}]'.format((df['EventDate'].max() - timedelta(days = 1)).date()))
    for p in ['AAD - Account Management', 'AAD - Sync', 'AAD - Authentication']:
        tempDf = df.loc[df['PlanningCategory'] == p].reset_index(drop = True)
        tempDf = tempDf.groupby('EventDate').agg({'WorkloadGeneration' : 'sum'}).reset_index().rename(columns = {'WorkloadGeneration' : 'DailyWorkload'})
        plt.plot(tempDf['EventDate'], tempDf['DailyWorkload'], c = np.random.rand(3,))
        plt.xticks(rotation = 70)
        plt.title('Daily workload time series for {}'.format(p))
        plt.axvline(x = pd.Timestamp('2019-07-01'), color='k', linestyle='--')
        plt.axvline(x = df['EventDate'].max() - timedelta(days = 1), color='k', linestyle='--')
        plt.show()
        del tempDf
    tempDf = df.groupby('EventDate').agg({'WorkloadGeneration' : 'sum'}).reset_index().rename(columns = {'WorkloadGeneration' : 'DailyWorkload'})
    plt.plot(tempDf['EventDate'], tempDf['DailyWorkload'])
    plt.xticks(rotation = 70)
    plt.title('Daily workload time series for ASIM (total)')
    plt.axvline(x = pd.Timestamp('2019-07-01'), color='k', linestyle='--')
    plt.axvline(x = df['EventDate'].max() - timedelta(days = 1), color='k', linestyle='--')
    plt.show()
    del tempDf
    #Note that the overall workload is ASIM has an upward trend, but it might just be due to the fact than more and more of the business is being routed to the new system.
    #in fact hte PCY in our PoC are fairly stationary.
    df = df.loc[(df['EventDate'] >= pd.Timestamp('2019-07-01')) & (df['EventDate'] <= df['EventDate'].max() - timedelta(days = 1))].reset_index(drop = True)
    
    #plot workload breakdown into its various components
    tempDf = df.groupby(['EventDate', 'AllWorkloadType']).agg({'WorkloadGeneration' : 'sum'}).reset_index()
    tempDf = pd.pivot_table(tempDf,
                          index = ['EventDate'],
                          columns = 'AllWorkloadType',
                          values = 'WorkloadGeneration').reset_index().replace(np.nan, 0)
    plt.stackplot(tempDf['EventDate'], [tempDf['IncidentCreation'].tolist(), tempDf['TransferIntoQueue'].tolist(), tempDf['AdditionalWorkload'].tolist(), tempDf['TransferWithinQueue']], labels=['Incident creations','Transfers into queue','Additional workload','Transfers within queue'], colors = sns.color_palette("Blues_d"))
    plt.title('Workload Breakdown in ASIM')
    plt.xlabel('Time')
    plt.ylabel('Workload', fontsize = 12)
    plt.legend(bbox_to_anchor=(1.5, 1))
    plt.xticks(rotation = 70)
    plt.show()
    del tempDf
    
    #entire incidents have missing Service_Offering. Hence we randomly assign a service offering for these (about 5% of incidents)
    df['Service_Offering_Original'] = df['Service_Offering'].copy(deep = True)
    def dealWithMissingServiceOffering(g):
        '''
        Since a small fractions of incidents are missing the service offering, we randomly assign either Premier or Broad Commercial
        to all events in a given incident
        :parameter g: the dataframe of a particular incident (pandas group)
        :return g: the modified incident dataframe (pandas group)
        '''
        s = g['Service_Offering_Original'].tolist()[0] #select first entry of Service_Offering_Original. Note that the value is always the same across a specific incident's event list
        if s in ['Premier', 'Broad Commercial']:
            g['Service_Offering'] = s
            return g
        else:
            s = np.random.choice(['Premier', 'Broad Commercial']) 
            g['Service_Offering'] =  s
            return g
    df = df.groupby('IncidentNumber').apply(dealWithMissingServiceOffering)
    print('End of data engineering section.')
    
    return rawDf, df
###############################################################################    





