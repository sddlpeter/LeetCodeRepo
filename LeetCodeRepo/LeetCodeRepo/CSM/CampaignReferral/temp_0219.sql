------------------------- Step 1: #SubscriptionLIst -------------------------

IF OBJECT_ID('tempdb..#SubscriptionList') IS NOT NULL
  DROP TABLE #SubscriptionList;


WITH CTE AS (
SELECT
  AnalysisTPID = SS.TPID,
  ss.TPID,
  ss.AI_SubscriptionKey,
  ss.CommerceAccountID,
  ss.OMSSubscriptionID,
  ss.SubscriptionGUID,
  ss.OfferName,
  ss.OfferID,
  ss.CurrentSubscriptionStatus,
  ss.SubscriptionStartDate,
  ss.BillableAccountID 
FROM vwSubscriptionSnapshotV2 ss
WHERE 1 = 1
AND BusinessGroupName = 'Azure'
AND AI_IsFraud = 0
AND BisIsTestData = 0
AND AI_IsTest = 0
AND AI_OfferType IN ('Benefit Programs', 'Consumption' , 'Unit Commitment', 'Monetary Commitment' , 'Modern', 'CustomerLed')
AND NOT OfferName IN ('Free Trial', 'BizSpark', 'BizSpark Plus', 'Microsoft Azure BizSpark 1111', 'Enterprise: BizSpark', 'Visual Studio Enterprise: BizSpark')

UNION

SELECT
  AnalysisTPID = SS.TPID,
  ss.TPID,
  ss.AI_SubscriptionKey,
  ss.CommerceAccountID,
  ss.OMSSubscriptionID,
  ss.SubscriptionGUID,
  ss.OfferName,
  ss.OfferID,
  ss.CurrentSubscriptionStatus,
  ss.SubscriptionStartDate,
  ss.BillableAccountID
FROM vwSubscriptionSnapshotV2 ss LEFT JOIN vwOrganizationMaster AS om ON ss.TPID = om.TPID
WHERE 1 = 1
AND ss.BusinessGroupName = 'Azure'
AND ss.AI_IsFraud = 0
AND ss.BisIsTestData = 0
AND ss.AI_IsTest = 0
AND ss.AI_OfferType = 'FieldLed'
AND NOT ss.OfferName IN ('Free Trial', 'BizSpark', 'BizSpark Plus', 'Microsoft Azure BizSpark 1111', 'Enterprise: BizSpark', 'Visual Studio Enterprise: BizSpark')
AND (
(om.segmentname = 'Small, Medium & Corporate Commercial' and om.subsegmentname = 'SM&C Commercial - SMB Default') or
(om.segmentname = 'Small, Medium & Corporate Commercial' and om.subsegmentname = 'SM&C Commercial - SMB') or
(om.segmentname = 'Small, Medium & Corporate Education' and om.subsegmentname = 'SM&C Education - SMB') or
(om.segmentname = 'Small, Medium & Corporate Government' and om.subsegmentname = 'SM&C Government - SMB') 
)
) SELECT * INTO #SubscriptionList
FROM CTE;

--3,613,752


------------------------- Step 1: #BillingResourceGUID2Service -------------------------

IF OBJECT_ID('tempdb..#BillingResourceGUID2Service_II') IS NOT NULL
  DROP TABLE #BillingResourceGUID2Service_II;


WITH CTE
AS (SELECT
  ServiceName,
  WorkloadName,
  BillingResourceGUID = CONVERT(uniqueidentifier, BillingResourceGUID)
FROM Bigcat.vwServiceHierarchy_V2
WHERE LEN(BillingResourceGUID) = 36
)
SELECT
  BillingResourceGUID,
  ServiceName = MAX(ServiceName),
  WorkloadName = MAX(WorkloadName)
  INTO #BillingResourceGUID2Service_II
FROM CTE
GROUP BY BillingResourceGUID;

--92,947

------------------------- Step 2: #MonthlyUsage_ExcludedMonth -------------------------

IF OBJECT_ID('tempdb..#MonthlyUsage_ExcludedMonth_II') IS NOT NULL
  DROP TABLE #MonthlyUsage_ExcludedMonth_II;



DECLARE @CrrtMonth int

-- Use month before current month
SELECT
  @CrrtMonth = CAST(CONVERT(varchar(20), DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0), 112) AS int)

-- if date is before the 8th go back two months prior
IF DATEPART(DAY, GETDATE()) <= 8
  SELECT
    @CrrtMonth = CAST(CONVERT(varchar(20), DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 2, 0), 112) AS int)

-- set Earliest month to current month
DECLARE @EarliestMonth int = @CrrtMonth;

WITH CTE
AS (SELECT DISTINCT
  SL.SubscriptionGUID,
  sh.ServiceName,
  sh.WorkloadName,
  Datekey,
    sl.SubscriptionCreatedDate,
  sl.SubscriptionStartDate,
  sl.SubscriptionEndDate
FROM vwUsageMonthly um
INNER JOIN #SubscriptionList_II SL
  ON UM.AI_SubscriptionKey = SL.AI_SubscriptionKey
LEFT JOIN #BillingResourceGUID2Service_II sh
  ON um.ResourceGUID = sh.BillingResourceGUID
WHERE 1 = 1
AND AI_IsBillable = 1
AND @EarliestMonth <= DateKey
AND DateKey <= @CrrtMonth
)
SELECT * INTO #MonthlyUsage_ExcludedMonth_II
FROM CTE;


INSERT INTO Partner_Support.SubscriptionWorkload
SELECT SubscriptionGUID AS SubGUID,
		ServiceName,
		WorkloadName,
		'Monthly' AS Source,
		GETDATE() AS ProcessedDate
FROM #MonthlyUsage_ExcludedMonth_II;