

------------------ Step 1: truncate table ---------------------------

TRUNCATE TABLE DailyUsage;



------------------ Step 2: First batch to CSM_DataFeeds_IS ---------------------------
DECLARE @BeginDateKey int
DECLARE @EndDateKey int

SET @BeginDateKey = CAST(CONVERT(VARCHAR(20),DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) -6, 0),112) AS INT)
SET @endDateKey = CAST(CONVERT(VARCHAR(20), DATEADD(DAY, -DAY(GETDATE()), DATEADD(MONTH, -2, GETDATE())) ,112) AS INT)

SELECT t.TPID
	  , t.AI_SubscriptionKey
	  , sh.WorkloadName 
	  , sh.ServiceName AS SoldServiceName
	 -- , sh.SoldServiceName 
	  , SUM(ud.Totalunits) AS Totalunits
	  , SUM(ud.NormalizedUnits_UsageDateRate) AS NormalizedUnits
	  , ud.DateKey
                  , GETDATE() AS ProcessedDate
FROM Partner_Support.CSM_Subscription_TPID t
JOIN vwUsageDaily ud ON t.AI_SubscriptionKey = ud.AI_SubscriptionKey
JOIN Bigcat.vwServiceHierarchy_v2 (nolock) sh on CONVERT(NVARCHAR(100), ud.ResourceGUID) = sh.BillingResourceGUID 
--vwServiceHierarchy sh ON ud.ResourceGUId = sh.ResourceGUId
WHERE ud.DateKey BETWEEN @BeginDateKey AND @EndDateKey
AND t.TPID IS NOT NULL
GROUP BY t.TPID, t.AI_SubscriptionKey, sh.WorkloadName, sh.ServiceName, ud.DateKey
ORDER BY 1, 2, 3, 4, 7



------------------ Step 3: Second batch to CSM_DataFeeds_IS ---------------------------
DECLARE @BeginDateKey int
DECLARE @EndDateKey int

SET @BeginDateKey = CAST(CONVERT(VARCHAR(20),DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) -2, 0),112) AS INT)
SET @endDateKey = CAST(CONVERT(VARCHAR(20),DATEADD(DAY, DATEDIFF(DAY, 0 ,GETDATE()), 0) -1 ,112) AS INT)

SELECT t.TPID
	  , t.AI_SubscriptionKey
	  , sh.WorkloadName 
	  , sh.ServiceName AS SoldServiceName
	  --, sh.SoldServiceName 
	  , SUM(ud.Totalunits) AS Totalunits
	  , SUM(ud.NormalizedUnits_UsageDateRate) AS NormalizedUnits
	  , ud.DateKey
                  , GETDATE() AS ProcessedDate
FROM Partner_Support.CSM_Subscription_TPID t
--PartnerBA_Publish.CSM_Subscription_TPID t
JOIN vwUsageDaily ud ON t.AI_SubscriptionKey = ud.AI_SubscriptionKey
JOIN Bigcat.vwServiceHierarchy_v2 (nolock) sh on CONVERT(NVARCHAR(100), ud.ResourceGUID) = sh.BillingResourceGUID
--vwServiceHierarchy sh ON ud.ResourceGUId = sh.ResourceGUId
WHERE ud.DateKey BETWEEN @BeginDateKey AND @EndDateKey
AND t.TPID IS NOT NULL
GROUP BY t.TPID, t.AI_SubscriptionKey, sh.WorkloadName, sh.ServiceName, ud.DateKey
ORDER BY 1, 2, 3, 4, 7




------------------ Step 4: truncate table MonthlyRevenue ---------------------------

TRUNCATE TABLE MonthlyRevenue;



------------------ Step 5: Load data to MonthlyRevenue on CSM_DataFeeds_IS ---------------------------
DECLARE @MinBillingMonth INT;
	SET @MinBillingMonth = CAST(CONVERT(VARCHAR(20),DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) -6, 0),112) AS INT);
	
	with SubscriptionList as
	(
	select 
			SS.TPID
			,ss.AI_SubscriptionKey
			,ss.CommerceAccountID
			,ss.OMSSubscriptionID
			,ss.SubscriptionGUID
			,ss.OfferName
			,ss.OfferID
			,ss.CurrentSubscriptionStatus
			,ss.SubscriptionStartDate
			,ss.BillableAccountID
	from vwSubscriptionSnapshotV2 ss
	where 1=1 
		AND BusinessGroupName = 'Azure'
		AND AI_IsFraud = 0
		AND BisIsTestData = 0
		AND AI_IsTest = 0
		and AI_OfferType IN (
				'Benefit Programs'		-- unclear reason for inclusion
				, 'Consumption'			-- this is Direct / Pay as you Go
				, 'Unit Commitment'		 --unclear reason for inclusion
				, 'Monetary Commitment'	 --unclear reason for inclusion
				,'Modern'
				,'Modern Customer Led'
				)
	and not OfferName IN ('Free Trial', 'BizSpark', 'BizSpark Plus', 'Microsoft Azure BizSpark 1111', 'Enterprise: BizSpark', 'Visual Studio Enterprise: BizSpark') 
	)
	
	
		SELECT 
			TPID						=SL.TPID
			,SubscriptionGUID			=SL.SubscriptionGUID
			,BillingMonth				=SB.BillingMonth
			,PaidUsageUSD				=SUM(SB.PaidUsageUSD)
			,ProcessedDate				=getdate()
			,PaidUsageUSD_CSMProgram	=SUM(case when SB.BillingType in (
												'Direct (Global)'
												, 'Direct (China)'
												,'Modern Customer-Led'
												,'Modern Customer-LedRI'
												)																								
												then PaidUsageUSD else null end)
				
	
	FROM vwServiceBilling   SB
		inner join SubscriptionList SL 
		on SB.AI_SubscriptionKey=SL.AI_SubscriptionKey
		where 1=1
		and BillingMonth>=@MinBillingMonth
	GROUP BY 
	SL.TPID
	,SL.SubscriptionGUID
	,SB.BillingMonth

