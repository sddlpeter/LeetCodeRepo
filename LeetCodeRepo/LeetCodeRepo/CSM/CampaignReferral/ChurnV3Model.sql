
------------------------------ CustomerChurnMCScore_2019_10_05.ss -----------------------------------
DECLARE @Week DATE 
SET @Week = (SELECT CAST(CONVERT(VARCHAR(8),GETDATE()-4,112) AS DATE))

SELECT [SliceStartDateKey]
      ,[CloudCustomerGUID]
      ,[TimeStamp]
      ,[PredictedChurnScore]
      ,[PredictedChurnLabel]
  FROM [dbo].[vwCustomerChurn_MC_Score] (nolock) 
  WHERE CAST(CONVERT(VARCHAR(8),[SliceStartDateKey]) AS DATE)=@Week







------------------------------ CustomerChurnScore_2019_10_05.ss ------------------------------------
DECLARE @Week DATE 
SET @Week = (SELECT CAST(CONVERT(VARCHAR(8),GETDATE()-4,112) AS DATE))

SELECT [SliceStartDateKey]
      ,[CloudCustomerGUID]
      ,[TimeStamp]
      ,[PredictedChurnScore]
      ,[PredictedChurnLabel]
  FROM [dbo].[vwCustomerChurn_Output_Score] (nolock) 
WHERE CAST(CONVERT(VARCHAR(8),[SliceStartDateKey]) AS DATE)=@Week






------------------------------ SubscriptionCustomerWeekly_2019_10_27.ss ---------------------------------
DECLARE @Week DATE 
DECLARE @Week_1 DATE 
SET @Week = (SELECT CAST(CONVERT(VARCHAR(8),GETDATE()-4,112) AS DATE))
SET @Week_1 = (SELECT CAST(CONVERT(VARCHAR(8),GETDATE()-11,112) AS DATE))

SELECT [DATEKEY]
     
      ,[AI_SubscriptionKey]
      ,[SubscriptionGuid]
      ,[BillableAccountId]
      ,[AgreementNumber]
      ,[EnrollmentNumber]
      ,[MSCustomerGuid]
      ,[CloudCustomerGuid]
      ,[PCN]
      ,[TPID]
      ,[OrgID]
      ,[CommerceAccountId]
      ,[StartsOn]
      ,[EndsOn]
      ,[DataSourceId]
      ,[AI_CreatedAt]
      ,[AI_UpdatedAt]
      ,[AI_ChannelType]
      ,[MSSALES_AgreementID]
      ,[OMSSubscriptionId]
      ,[ProgramCode]
      ,[WAPEP_PCN]
      ,[pccode]
      ,[CloudCurrentAgreementNumber]
      ,[SupportedforCloudCustomerGuid]
  FROM [dbo].[vwSubscription_CustomerV2_History] (nolock) 
WHERE CAST(CONVERT(VARCHAR(8),[DATEKEY]) AS DATE) BETWEEN  @Week_1 AND @Week ;
