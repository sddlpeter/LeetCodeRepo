

----------------- Step 1: Truncate table ---------------------

TRUNCATE TABLE Partner_Support.SubscriptionDetails;


---------------- Step 2: Generate Subscription Table ------------------


DECLARE @CurrMonth int

-- Use month before current month
SELECT
  @CurrMonth = CAST(CONVERT(varchar(20), DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0), 112) AS int)

-- if date is before the 8th go back two months prior
IF DATEPART(DAY, GETDATE()) <= 8
  SELECT
    @CurrMonth = CAST(CONVERT(varchar(20), DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 2, 0), 112) AS int)

-- set Earliest month to current month
DECLARE @EarliestMonth int = @CurrMonth


IF OBJECT_ID('tempdb..#SubscriptionList') IS NOT NULL
  DROP TABLE #SubscriptionList

SELECT
  AnalysisTPID = SS.TPID
  --AnalysisTPID                                                 =isnull(convert(Varchar(255),SS.TPID),SS.[CommerceAccountId])
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
  ss.BillableAccountID INTO #SubscriptionList

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
-- Modern Offer Types
, 'Modern'
, 'Modern Customer Led'
--,'Modern Field Led'                      -- not currently include
--,'Modern Partner Led'                -- do not include
)
-- Not one of these Offers 
AND NOT OfferName IN ('Free Trial', 'BizSpark', 'BizSpark Plus', 'Microsoft Azure BizSpark 1111', 'Enterprise: BizSpark', 'Visual Studio Enterprise: BizSpark')



IF OBJECT_ID('tempdb..#BillingResourceGUID2Service') IS NOT NULL
  DROP TABLE #BillingResourceGUID2Service

  ;
WITH CTE
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
--left join [vwWorkload] W
--            on SH.WorkloadID=W.WorkloadID
WHERE LEN(BillingResourceGUID) = 36)
SELECT
  BillingResourceGUID,
  ServiceName = MAX(ServiceName),
  IsXamarin = MAX(IsXamarin),
  IsAzureDevOps = MAX(IsAzureDevOps),
  IsExcluded = MAX(CASE
    WHEN IsXamarin = 1 OR
      IsAzureDevOps = 1
    --or IsVisualStudio=1 
    THEN 1
    ELSE 0
  END) INTO #BillingResourceGUID2Service

FROM CTE

GROUP BY BillingResourceGUID



IF OBJECT_ID('tempdb..#MonthlyUsage_ExcludedMonth') IS NOT NULL
  DROP TABLE #MonthlyUsage_ExcludedMonth

  ;
WITH CTE
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

INNER JOIN #SubscriptionList SL
  ON UM.AI_SubscriptionKey = SL.AI_SubscriptionKey

LEFT JOIN #BillingResourceGUID2Service sh
  ON um.ResourceGUID = sh.BillingResourceGUID

WHERE 1 = 1
AND AI_IsBillable = 1
AND @EarliestMonth <= DateKey
AND DateKey <= @CurrMonth

GROUP BY Um.[DateKey],
         um.AI_SubscriptionKey)
SELECT
  * INTO #MonthlyUsage_ExcludedMonth
FROM CTE
WHERE CSMProgram_IsExcludedMonth = 1





IF OBJECT_ID('tempdb..#ServiceBillingSubscription') IS NOT NULL
  DROP TABLE #ServiceBillingSubscription

SELECT
  AI_SubscriptionKey = SB.AI_SubscriptionKey,
  BillingMonth = SB.BillingMonth,
  AnalysisTPID = SL.AnalysisTPID,
  HasExcludedUsage = MAX(CASE
    WHEN MU.[DateKey] IS NULL THEN 0
    ELSE 1
  END),
  PaidUsageUSD = SUM(SB.PaidUsageUSD),
  PaidUsageUSD_CSMProgram = SUM(CASE
    WHEN SB.BillingType IN (
      -- ** Direct
      'Direct (Global)', 'Direct (China)', 'Direct RI'
      -- ** Modern
      , 'Modern Customer-Led', 'Modern Customer-LedRI'
      --,'Modern Field-Led'
      --,'Modern Field-LedRI'
      ) AND
      MU.[DateKey] IS NULL THEN PaidUsageUSD
    ELSE NULL
  END) INTO #ServiceBillingSubscription

FROM vwServiceBilling SB

INNER JOIN #SubscriptionList SL
  ON SB.AI_SubscriptionKey = SL.AI_SubscriptionKey

LEFT JOIN #MonthlyUsage_ExcludedMonth MU
  ON SB.BillingMonth = MU.[DateKey]
  AND SB.AI_SubscriptionKey = MU.AI_SubscriptionKey

WHERE 1 = 1
AND @EarliestMonth <= BillingMonth
AND BillingMonth <= @CurrMonth


GROUP BY SB.AI_SubscriptionKey,
         SB.BillingMonth,
         SL.AnalysisTPID


-- Final TPID PaidUsageUSD Total Calculation

IF OBJECT_ID('tempdb..#ServiceBilling_TPIDTotal') IS NOT NULL
  DROP TABLE #ServiceBilling_TPIDTotal

  ;
WITH CTE
AS (SELECT
  AnalysisTPID,
  BillingMonth,
  PaidUsageUSD_CSMProgram = SUM(PaidUsageUSD_CSMProgram)
FROM #ServiceBillingSubscription SB

GROUP BY AnalysisTPID,
         BillingMonth)
SELECT
  AnalysisTPID,
  CSMProgram_AddMonth = MIN(BillingMonth),
  PaidUsageUSD_CSMProgram,
  BillingMonth,
  CSMProgram_MostRecentMonth = MAX(BillingMonth),
  PaidUsageUSD_MostRecentMonth = SUM(CASE
    WHEN BillingMonth = @CurrMonth THEN PaidUsageUSD_CSMProgram
    ELSE 0
  END) INTO #ServiceBilling_TPIDTotal

FROM CTE
GROUP BY AnalysisTPID,PaidUsageUSD_CSMProgram,BillingMonth


IF OBJECT_ID('tempdb..#ServiceBilling_TPIDTotal_Rest_Of_The_World') IS NOT NULL
  DROP TABLE #ServiceBilling_TPIDTotal_Rest_Of_The_World

select AnalysisTPID,
 CSMProgram_AddMonth = MIN(BillingMonth),
 CSMProgram_MostRecentMonth = MAX(BillingMonth),
 PaidUsageUSD_MostRecentMonth = SUM(CASE
    WHEN (BillingMonth = @CurrMonth ) then
 PaidUsageUSD_CSMProgram  
 ELSE 0
  END) INTO #ServiceBilling_TPIDTotal_Rest_Of_The_World from #ServiceBilling_TPIDTotal ss
 LEFT JOIN vwOrganizationMaster om
    ON ss.AnalysisTPID = om.OrgID where PaidUsageUSD_CSMProgram >=1000 and  om.SubsidiaryName!='United States' group by AnalysisTPID

 IF OBJECT_ID('tempdb..#ServiceBilling_TPIDTotal_US') IS NOT NULL
  DROP TABLE #ServiceBilling_TPIDTotal_US

select AnalysisTPID,
 CSMProgram_AddMonth = MIN(BillingMonth),
 CSMProgram_MostRecentMonth = MAX(BillingMonth),
 PaidUsageUSD_MostRecentMonth = SUM(CASE
    WHEN (BillingMonth = @CurrMonth ) then
 PaidUsageUSD_CSMProgram
 ELSE 0
  END) INTO #ServiceBilling_TPIDTotal_US from #ServiceBilling_TPIDTotal ss
 LEFT JOIN vwOrganizationMaster om
    ON ss.AnalysisTPID = om.OrgID where PaidUsageUSD_CSMProgram >=500 and om.SubsidiaryName='United States' group by AnalysisTPID


Select * into #ServiceBilling_TPIDTotal_US_All from (Select * from #ServiceBilling_TPIDTotal_Rest_Of_The_World union select * from #ServiceBilling_TPIDTotal_US) as tmp


--select * from #ServiceBilling_TPIDTotal_US_All

SELECT
  CSMProgram_AddMonth,
  COUNT(*)
FROM #ServiceBilling_TPIDTotal
GROUP BY CSMProgram_AddMonth
ORDER BY CSMProgram_AddMonth




IF OBJECT_ID('tempdb..#AzureContactInfo') IS NOT NULL
  DROP TABLE #AzureContactInfo

  ;
WITH CTE
AS (SELECT
  SubscriptionGUID,
  TenantID,
  Address1,
  Address2,
  Address3,
  City,
  [State],
  PostalCode,
  CountryCode,
  AccountOwnerPUID,
  FirstName,
  LastName,
  PhoneNumber,
  AccountOwnerEmail,
  MarketingProfileEmailID,
  CommunicationEmail,
  Locale,
  AllowPhoneCommunications,
  AllowEmailCommunications
FROM PII.vwAzureContactInfo
WHERE SubscriptionGUID IN (SELECT
  SubscriptionGUID
FROM #SubscriptionList)

UNION

SELECT
  SubscriptionGUID,
  TenantID,
  Address1,
  Address2,
  Address3,
  City,
  [State],
  PostalCode,
  CountryCode,
  AccountOwnerPUID,
  FirstName,
  LastName,
  PhoneNumber,
  AccountOwnerEmail,
  MarketingProfileEmailID,
  CommunicationEmail,
  Locale,
  AllowPhoneCommunications,
  AllowEmailCommunications
FROM PII.vwAzureContactInfo_Mooncake
WHERE SubscriptionGUID IN (SELECT
  SubscriptionGUID
FROM #SubscriptionList)
AND NOT SubscriptionGUID IN (SELECT
  SubscriptionGUID
FROM PII.vwAzureContactInfo))
SELECT
  * INTO #AzureContactInfo
FROM CTE



INSERT INTO Partner_Support.SubscriptionDetails

  SELECT
    TPID = ss.TPID,
    OrgName = om.OrgName,
    AreaName = om.AreaName,
    TenantID = ci.TenantId,
    CommerceAccountID = ss.CommerceAccountID,
    OMSSubscriptionID = ss.OMSSubscriptionID,
    SubscriptionGUID = ss.AI_SubscriptionKey,
    OfferName = ss.OfferName,
    OfferID = ss.OfferID,
    CurrentSubscriptionStatus = ss.CurrentSubscriptionStatus,
    SubscriptionStartDate = ss.SubscriptionStartDate,
    CASE
      WHEN ci.Address1 IS NULL THEN ca.AddressLine1
      ELSE ci.Address1
    END AS Address1,
    CASE
      WHEN ci.Address2 IS NULL THEN ca.AddressLine2
      ELSE ci.Address2
    END AS Address2,
    CASE
      WHEN ci.Address3 IS NULL THEN ca.AddressLine3
      ELSE ci.Address3
    END AS Address3,
    ci.City,
    ci.State,
    ci.PostalCode,
    CASE
      WHEN ci.CountryCode IS NULL THEN ca.CountryCode
      ELSE ci.CountryCode
    END AS CountryCode,
    ci.AccountOwnerPUID AS AdminPUID,
    CASE
      WHEN ci.FirstName IS NULL THEN ca.FirstName
      ELSE ci.FirstName
    END AS AdminFirstName,
    CASE
      WHEN ci.LastName IS NULL THEN ca.LastName
      ELSE ci.LastName
    END AS AdminLastName,
    CASE
      WHEN ci.PhoneNumber IS NULL THEN ca.PhoneNumber
      ELSE ci.PhoneNumber
    END AS AdminPhoneNumber,
    ci.AccountOwnerEmail,
    CASE
      WHEN ci.MarketingProfileEmailID IS NULL THEN ci.CommunicationEmail
      ELSE ci.MarketingProfileEmailID
    END AS AdminCommunicationEmail,
    CASE
      WHEN ci.Locale IS NULL THEN ca.CommunicationCulture
      ELSE ci.Locale
    END AS AdminLocale,
    ci.AllowPhoneCommunications AS AdminPhonePreference,
    ci.AllowEmailCommunications AS AdminEmailPreference,
    PaidUsageUSD = BTotal.PaidUsageUSD_MostRecentMonth,
   
    UsageStartDateKey = CONVERT(int, CSMProgram_AddMonth),
    UsageEndDateKey = CONVERT(int, CSMProgram_MostRecentMonth),
    InvoiceDateKey = CONVERT(int, NULL),
    BillingMonth = CONVERT(int, NULL),
    SegmentName = om.SegmentName,
    SubsidiaryName = om.SubsidiaryName,
    ProcessedDate = GETDATE(),
    BillableAccountID = ss.BillableAccountID,
    NULL AS source
  FROM #SubscriptionList SS

  INNER JOIN #ServiceBilling_TPIDTotal_US_All BTotal
    ON SS.AnalysisTPID = BTotal.AnalysisTPID

  LEFT JOIN #AzureContactInfo ci
    ON ss.AI_SubscriptionKey = ci.SubscriptionGUID

  LEFT JOIN PII.vwCommerceAccount ca
    ON ss.CommerceAccountID = ca.CAId

  LEFT JOIN vwOrganizationMaster om
    ON ss.TPID = om.OrgID


  WHERE 1 = 1 


  AND ss.CurrentSubscriptionStatus NOT IN ('Deprovisioned', 'Disabled')









----------------- Step 3: Copy Subscription data to SC ----------------------

-- copy Partner_Support.SubscriptionDetails to SC_Subscription_LogicV2


---------------- Step 4: Copy Admin data to SC ----------------------

SELECT DISTINCT t.TPID 
			  , t.SubscriptionGUID
			  , sad.TenantID
			  , sad.AdminPUID
			  , CASE WHEN sad.MarketingProfileEmailID IS NULL AND sad.PrimaryEmailID IS NULL AND t.AdminPUID = sad.AdminPUID THEN t.AccountOwnerEmail
					 WHEN sad.MarketingProfileEmailID IS NULL THEN sad.PrimaryEmailID
					 ELSE sad.MarketingProfileEmailID
			    END AS PrimaryEmailID
			  , CASE WHEN sad.PrimaryFirstName IS NULL AND t.AdminPUID = sad.AdminPUID THEN t.AdminFirstName
					 ELSE sad.PrimaryFirstName
				END PrimaryFirstName
			  , CASE WHEN sad.PrimaryLastName IS NULL AND t.AdminPUID = sad.AdminPUID THEN t.AdminLastName
					 ELSE sad.PrimaryLastName
				END PrimaryLastName
			  , CASE WHEN sad.TelephoneNumber IS NULL AND t.AdminPUID = sad.AdminPUID THEN t.AdminPhoneNumber
					 ELSE sad.TelephoneNumber
				END TelephoneNumber
			  , CASE WHEN sad.PreferredLanguage IS NULL AND t.AdminPUID = sad.AdminPUID THEN t.AdminLocale
					 ELSE sad.PreferredLanguage
				END PreferredLanguage
			  , sad.AdminType
			  , t.CommerceAccountID
                                                  , GETDATE() AS ProcessedDate
FROM Partner_Support.SubscriptionDetails t
LEFT JOIN PII.vwSubscriptionAdminDetails sad ON t.SubscriptionGUID = sad.SubscriptionGUID 
WHERE sad.AdminState = 'Enabled'
AND sad.AdminType IS NOT NULL

UNION ALL

SELECT DISTINCT t.TPID 
			  , t.SubscriptionGUID
			  , sra.TenantID
			  , sra.AdminPUID
			  , CASE WHEN sra.MarketingProfileEmailID IS NULL THEN sra.PrimaryEmailID 
					 ELSE sra.MarketingProfileEmailID
			    END AS PrimaryEmailID
			  , sra.PrimaryFirstName
			  , sra.PrimaryLastName
			  , sra.TelephoneNumber
			  , sra.PreferredLanguage
			  , sra.AdminType
			  , t.CommerceAccountID
                                                  , GETDATE() AS ProcessedDate
FROM Partner_Support.SubscriptionDetails t
JOIN PII.vwSubscriptionRoleAssignments sra ON t.SubscriptionGUID = sra.SubscriptionGUID 
WHERE sra.AdminType IN ('Owner') 
ORDER BY 1, 2



---------------- Step 5: Copy TPID data to SC ----------------------


SELECT DISTINCT TPID, SubscriptionGUID, GETDATE() AS ProcessedDate
FROM Partner_Support.SubscriptionDetails
ORDER BY 1, 2




-------------- Step 6: Copy to CSM_Subscription_TPID ----------------
IF EXISTS (SELECT COUNT(*) FROM Partner_Support.SubscriptionDetails)
BEGIN 
	INSERT INTO Partner_Support.CSM_Subscription_TPID
	SELECT DISTINCT TPID, SubscriptionGUID, GETDATE() AS CreateDate, NULL, NULL
	FROM Partner_Support.SubscriptionDetails
END

------------- Step 7: Truncate Table -----------------
TRUNCATE TABLE Partner_Support.TPIDRevenue;
TRUNCATE TABLE Partner_Support.MasterTPIDRevenue;
TRUNCATE TABLE Partner_Support.SubscriptionDetails;
TRUNCATE TABLE Partner_Support.TPIDSubscriptionRevenue;

