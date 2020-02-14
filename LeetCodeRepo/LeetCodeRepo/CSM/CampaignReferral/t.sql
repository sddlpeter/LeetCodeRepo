
DECLARE @CrrtMonth int

-- Use month before current month
SELECT
  @CrrtMonth = CAST(CONVERT(varchar(20), DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0), 112) AS int)

-- if date is before the 8th go back two months prior
IF DATEPART(DAY, GETDATE()) <= 8
  SELECT
    @CrrtMonth = CAST(CONVERT(varchar(20), DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 2, 0), 112) AS int)

-- set Earliest month to current month
DECLARE @EarliestMonth int = @CrrtMonth






with SubscriptionList as (
SELECT
  AnalysisTPID = SS.TPID
  ,
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
AND AI_OfferType IN (
'Benefit Programs'                          -- unclear reason for inclusion
, 'Consumption'                                -- this is Direct / Pay as you Go
, 'Unit Commitment'                       --unclear reason for inclusion
, 'Monetary Commitment'            --unclear reason for inclusion
, 'Modern'
, 'Modern Customer Led'
)
AND NOT OfferName IN ('Free Trial', 'BizSpark', 'BizSpark Plus', 'Microsoft Azure BizSpark 1111', 'Enterprise: BizSpark', 'Visual Studio Enterprise: BizSpark')
) 


, BillingResourceGUID2Service
AS (SELECT
  ServiceName,
  BillingResourceGUID = CONVERT(uniqueidentifier, BillingResourceGUID),
  IsXamarin = (CASE
    WHEN ISNULL(ServiceName, '') LIKE '%Xamarin%' THEN 1
    ELSE 0
  END),
  IsAzureDevOps = (CASE
    WHEN ISNULL(ServiceName, '') LIKE '%Azure%DevOps%' THEN 1
    ELSE 0
  END),
  IsVisualStudio = (CASE
    WHEN ISNULL(ServiceName, '') LIKE '%Visual Studio Subscription%' THEN 1
    ELSE 0
  END),
  IsAppCenter = (CASE
    WHEN ISNULL(ServiceName, '') LIKE '%App Center%' THEN 1
    ELSE 0
  END)
FROM Bigcat.vwServiceHierarchy_V2
WHERE LEN(BillingResourceGUID) = 36)


, BillingResourceGUID2Service_2 
as (
SELECT top 100
  BillingResourceGUID,
  ServiceName = MAX(ServiceName),
  IsXamarin = MAX(IsXamarin),
  IsAzureDevOps = MAX(IsAzureDevOps),
  IsExcluded = MAX(CASE
    WHEN IsXamarin = 1 OR
      IsAzureDevOps = 1
    THEN 1
    ELSE 0
  END)
FROM BillingResourceGUID2Service
GROUP BY BillingResourceGUID
)

,MonthlyUsage_ExcludedMonth
AS (SELECT
  [DateKey] = Um.[DateKey],
  AI_SubscriptionKey = um.AI_SubscriptionKey,
  HasAzureDevOps = MAX(CASE
    WHEN [Totalunits] > 0. THEN IsAzureDevOps
    ELSE NULL
  END),
  HasXamarin = MAX(CASE
    WHEN [Totalunits] > 0. THEN IsXamarin
    ELSE NULL
  END),
  IsAzureDevOpsOnly = MIN(CASE
    WHEN [Totalunits] > 0. THEN IsAzureDevOps
    ELSE NULL
  END),
  IsXamarinOnly = MIN(CASE
    WHEN [Totalunits] > 0. THEN IsXamarin
    ELSE NULL
  END),
  CSMProgram_IsExcludedMonth = MIN(CASE
    WHEN [Totalunits] > 0. THEN IsExcluded
    ELSE NULL
  END)

FROM vwUsageMonthly um

INNER JOIN SubscriptionList SL
  ON UM.AI_SubscriptionKey = SL.AI_SubscriptionKey

LEFT JOIN BillingResourceGUID2Service_2 sh
  ON um.ResourceGUID = sh.BillingResourceGUID

WHERE 1 = 1
AND AI_IsBillable = 1
AND @EarliestMonth <= DateKey
AND DateKey <= @CrrtMonth

GROUP BY Um.[DateKey],
         um.AI_SubscriptionKey)
SELECT *
FROM MonthlyUsage_ExcludedMonth
WHERE CSMProgram_IsExcludedMonth = 1