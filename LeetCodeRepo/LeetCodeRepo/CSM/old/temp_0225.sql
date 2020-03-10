

WITH tpid_history AS 
(
SELECT datekey, [AI_SubscriptionKey],[TPID]
FROM 
(
SELECT   [DateKey]
        ,[AI_SubscriptionKey]
        ,[TPID]
        ,ROW_NUMBER() OVER(PARTITION BY [AI_SubscriptionKey] ORDER BY [DateKey] DESC)  AS rn
     
  FROM [dbo].[vwSubscription_CustomerV2_History] 
  WHERE tpid IS NOT NULL
  ) AS inn
  WHERE inn.rn = 1
),

tpid_history1 AS 

(
SELECT TPID,AI_SubscriptionKey
FROM 
(
SELECT   TPID
        ,AI_SubscriptionKey
        ,ROW_NUMBER() OVER(PARTITION BY [AI_SubscriptionKey] ORDER BY CreateDate DESC)  AS rn
     
  FROM Partner_Support.[CSM_Subscription_TPID] 
  WHERE tpid IS NOT NULL
  ) AS inn
  WHERE inn.rn = 1
)

SELECT  sb.ResourceGUID,sh.WorkloadName,sh.ServiceName,'Top Customer' as Source    ---- COALESCE(sub.TPID,hist.TPID,hist1.TPID) AS TPID, sub.SubscriptionGUID INTO #tmpTPID 
FROM [Partner_Support].[Customer_Subscription2load] AS cust 
LEFT OUTER JOIN vwSubscriptionSnapshotv2 AS sub ON cust.SubscriptionGUID = sub.[SubscriptionGuid]
LEFT OUTER JOIN tpid_history AS hist ON cust.SubscriptionGUID = hist.[AI_SubscriptionKey]
LEFT OUTER JOIN tpid_history1 AS hist1 ON cust.SubscriptionGUID = hist1.[AI_SubscriptionKey]
LEFT OUTER JOIN vwServiceBilling sb on sb.AI_SubscriptionKey = sub.SubscriptionGUID
LEFT OUTER JOIN [Bigcat].[vwServiceHierarchy_V2] sh ON sb.ResourceGUID = sh.ConsumptionResourceGUID

--20
-- Monthly Occurency specific date should be confirmed

--top cust --monthly 10th

-- sc_workload 


