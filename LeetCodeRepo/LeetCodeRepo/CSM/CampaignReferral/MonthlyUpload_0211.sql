
/* Monthly Upload --- Added RBAC logic */ 

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





------------------------- Step 1: #SubscriptionLIst -------------------------

IF OBJECT_ID('tempdb..#SubscriptionList') IS NOT NULL
  DROP TABLE #SubscriptionList

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
  INTO #SubscriptionList
FROM vwSubscriptionSnapshotV2 ss
WHERE 1 = 1
AND BusinessGroupName = 'Azure'
AND AI_IsFraud = 0
AND BisIsTestData = 0
AND AI_IsTest = 0
AND AI_OfferType IN ('Benefit Programs', 'Consumption' , 'Unit Commitment', 'Monetary Commitment' , 'Modern', 'CustomerLed','FieldLed'
--,'Modern Field Led'  
)
AND NOT OfferName IN ('Free Trial', 'BizSpark', 'BizSpark Plus', 'Microsoft Azure BizSpark 1111', 'Enterprise: BizSpark', 'Visual Studio Enterprise: BizSpark');




------------------------- Step 1: #BillingResourceGUID2Service -------------------------

IF OBJECT_ID('tempdb..#BillingResourceGUID2Service') IS NOT NULL
  DROP TABLE #BillingResourceGUID2Service;


WITH CTE
AS (SELECT
  ServiceName,
  WorkloadName,
  BillingResourceGUID = CONVERT(uniqueidentifier, BillingResourceGUID),
  IsXamarin = (CASE WHEN ISNULL(ServiceName, '') LIKE '%Xamarin%' THEN 1 ELSE 0 END),
  IsAzureDevOps = (CASE WHEN ISNULL(ServiceName, '') LIKE '%Azure%DevOps%' THEN 1 ELSE 0 END),
  IsVisualStudio = (CASE WHEN ISNULL(ServiceName, '') LIKE '%Visual Studio Subscription%' THEN 1 ELSE 0 END),
  IsAppCenter = (CASE WHEN ISNULL(ServiceName, '') LIKE '%App Center%' THEN 1 ELSE 0 END)
FROM Bigcat.vwServiceHierarchy_V2
WHERE LEN(BillingResourceGUID) = 36
)
SELECT
  BillingResourceGUID,
  ServiceName = MAX(ServiceName),
  IsXamarin = MAX(IsXamarin),
  IsAzureDevOps = MAX(IsAzureDevOps),
  IsExcluded = MAX(CASE WHEN IsXamarin = 1 OR IsAzureDevOps = 1 THEN 1 ELSE 0 END) 
  INTO #BillingResourceGUID2Service
FROM CTE
GROUP BY BillingResourceGUID



------------------------- Step 2: #MonthlyUsage_ExcludedMonth -------------------------

IF OBJECT_ID('tempdb..#MonthlyUsage_ExcludedMonth') IS NOT NULL
  DROP TABLE #MonthlyUsage_ExcludedMonth;

WITH CTE
AS (SELECT
  [DateKey] = Um.[DateKey],
  AI_SubscriptionKey = um.AI_SubscriptionKey,
  HasAzureDevOps = MAX(CASE WHEN [Totalunits] > 0. THEN IsAzureDevOps ELSE NULL END),
  HasXamarin = MAX(CASE WHEN [Totalunits] > 0. THEN IsXamarin ELSE NULL END),
  IsAzureDevOpsOnly = MIN(CASE WHEN [Totalunits] > 0. THEN IsAzureDevOps ELSE NULL END),
  IsXamarinOnly = MIN(CASE WHEN [Totalunits] > 0. THEN IsXamarin ELSE NULL END),
  CSMProgram_IsExcludedMonth = MIN(CASE WHEN [Totalunits] > 0. THEN IsExcluded ELSE NULL END),
  sh.ServiceName,
  sh.WorkloadName
FROM vwUsageMonthly um
INNER JOIN #SubscriptionList SL
  ON UM.AI_SubscriptionKey = SL.AI_SubscriptionKey
LEFT JOIN #BillingResourceGUID2Service sh
  ON um.ResourceGUID = sh.BillingResourceGUID
WHERE 1 = 1
AND AI_IsBillable = 1
AND @EarliestMonth <= DateKey
AND DateKey <= @CrrtMonth
GROUP BY Um.[DateKey],
         um.AI_SubscriptionKey
)
SELECT * INTO #MonthlyUsage_ExcludedMonth
FROM CTE WHERE CSMProgram_IsExcludedMonth = 1;





------------------------- Step 2: #ServiceBillingSubscription -------------------------

IF OBJECT_ID('tempdb..#ServiceBillingSubscription') IS NOT NULL
  DROP TABLE #ServiceBillingSubscription;

SELECT
  AI_SubscriptionKey = SB.AI_SubscriptionKey,
  BillingMonth = SB.BillingMonth,
  AnalysisTPID = SL.AnalysisTPID,
  HasExcludedUsage = MAX(CASE WHEN MU.[DateKey] IS NULL THEN 0 ELSE 1 END),
  PaidUsageUSD = SUM(SB.PaidUsageUSD),
  PaidUsageUSD_CSMProgram = SUM(CASE WHEN SB.BillingType IN ('Direct (Global)', 'Direct (China)', 'Direct RI', 'Modern Customer-Led', 'Modern Customer-LedRI' --,'Modern Field-Led'
																) AND MU.[DateKey] IS NULL THEN PaidUsageUSD ELSE NULL END),
  MU.ServiceName,
  MU.WorkloadName
  INTO #ServiceBillingSubscription
FROM vwServiceBilling SB
INNER JOIN #SubscriptionList SL
  ON SB.AI_SubscriptionKey = SL.AI_SubscriptionKey
LEFT JOIN #MonthlyUsage_ExcludedMonth MU
  ON SB.BillingMonth = MU.[DateKey]
  AND SB.AI_SubscriptionKey = MU.AI_SubscriptionKey
WHERE 1 = 1
AND @EarliestMonth <= BillingMonth
AND BillingMonth <= @CrrtMonth
GROUP BY SB.AI_SubscriptionKey,
         SB.BillingMonth,
         SL.AnalysisTPID;



------------------------- Step 2: #ServiceBilling_TPIDTotal -------------------------

IF OBJECT_ID('tempdb..#ServiceBilling_TPIDTotal') IS NOT NULL
  DROP TABLE #ServiceBilling_TPIDTotal;

WITH CTE
AS (SELECT
	AnalysisTPID,
	BillingMonth,
	PaidUsageUSD_CSMProgram = SUM(PaidUsageUSD_CSMProgram)
FROM #ServiceBillingSubscription SB
GROUP BY AnalysisTPID, BillingMonth
)
SELECT
  AnalysisTPID,
  CSMProgram_AddMonth = MIN(BillingMonth),
  PaidUsageUSD_CSMProgram,
  BillingMonth,
  CSMProgram_MostRecentMonth = MAX(BillingMonth),
  PaidUsageUSD_MostRecentMonth = SUM(CASE WHEN BillingMonth = @CrrtMonth THEN PaidUsageUSD_CSMProgram ELSE 0 END) 
  INTO #ServiceBilling_TPIDTotal
FROM CTE
GROUP BY AnalysisTPID,PaidUsageUSD_CSMProgram,BillingMonth;


------------------------- Step 3:  #ServiceBilling_TPIDTotal_Rest_Of_The_World -------------------------

IF OBJECT_ID('tempdb..#ServiceBilling_TPIDTotal_Rest_Of_The_World') IS NOT NULL
  DROP TABLE #ServiceBilling_TPIDTotal_Rest_Of_The_World

select AnalysisTPID,
 CSMProgram_AddMonth = MIN(BillingMonth),
 CSMProgram_MostRecentMonth = MAX(BillingMonth),
 PaidUsageUSD_MostRecentMonth = SUM(CASE
    WHEN (BillingMonth = @CrrtMonth ) then
 PaidUsageUSD_CSMProgram  
 ELSE 0
  END) INTO #ServiceBilling_TPIDTotal_Rest_Of_The_World from #ServiceBilling_TPIDTotal ss
 LEFT JOIN vwOrganizationMaster om
    ON ss.AnalysisTPID = om.OrgID where PaidUsageUSD_CSMProgram >=1000 and  om.SubsidiaryName!='United States' group by AnalysisTPID


------------------------- Step 3:  #ServiceBilling_TPIDTotal_US -------------------------

 IF OBJECT_ID('tempdb..#ServiceBilling_TPIDTotal_US') IS NOT NULL
  DROP TABLE #ServiceBilling_TPIDTotal_US

select AnalysisTPID,
 CSMProgram_AddMonth = MIN(BillingMonth),
 CSMProgram_MostRecentMonth = MAX(BillingMonth),
 PaidUsageUSD_MostRecentMonth = SUM(CASE
    WHEN (BillingMonth = @CrrtMonth ) then
 PaidUsageUSD_CSMProgram
 ELSE 0
  END) INTO #ServiceBilling_TPIDTotal_US from #ServiceBilling_TPIDTotal ss
 LEFT JOIN vwOrganizationMaster om
    ON ss.AnalysisTPID = om.OrgID where PaidUsageUSD_CSMProgram >=500 and om.SubsidiaryName='United States' group by AnalysisTPID


------------------------- Step 3:  #ServiceBilling_TPIDTotal_US_All -------------------------

Select * into #ServiceBilling_TPIDTotal_US_All from (Select * from #ServiceBilling_TPIDTotal_Rest_Of_The_World union select * from #ServiceBilling_TPIDTotal_US) as tmp;

-- SELECT
--   CSMProgram_AddMonth,
--   COUNT(*)
-- FROM #ServiceBilling_TPIDTotal
-- GROUP BY CSMProgram_AddMonth
-- ORDER BY CSMProgram_AddMonth



------------------------- Step 4:  #AzureContactInfo -------------------------

IF OBJECT_ID('tempdb..#AzureContactInfo') IS NOT NULL
  DROP TABLE #AzureContactInfo;

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
			WHERE SubscriptionGUID IN (SELECT  SubscriptionGUID FROM #SubscriptionList)
			AND NOT SubscriptionGUID IN (SELECT SubscriptionGUID FROM PII.vwAzureContactInfo)

UNION 
			SELECT											---- Added RBAC Logic
			  SubscriptionGUID,
			  TenantID,
			  '' AS Address1,
			  '' AS Address2,
			  '' AS Address3,
			  City,
			  [State],
			  PostalCode,
			  case when b.CountryCode is null then 'NA' else b.CountryCode end AS CountryCode,
			  AdminPUID AS AccountOwnerPUID,
			  PrimaryFirstName AS FirstName,
			  PrimaryLastName AS LastName,
			  Mobile AS PhoneNumber,
			  '' AS AccountOwnerEmail,
			  MarketingProfileEmailID,
			  UserPrincipalName AS CommunicationEmail,
			  MarketingProfileLocale AS Locale,
			  '' AS AllowPhoneCommunications,
			  '' AS AllowEmailCommunications
			FROM [PII].[vwSubscriptionAdminDetails] as a
			LEFT JOIN vwCountries as b on a.Country = b.Name
			WHERE SubscriptionGUID IN (SELECT SubscriptionGUID FROM #SubscriptionList)
			AND [AdminType] = 'Owner'

UNION 

		      SELECT											---- Added RBAC Logic
			  SubscriptionGUID,
			  TenantID,
			  '' AS Address1,
			  '' AS Address2,
			  '' AS Address3,
			  City,
			  [State],
			  PostalCode,
			  case when b.CountryCode is null then 'NA' else b.CountryCode end AS CountryCode,
			  AdminPUID AS AccountOwnerPUID,
			  PrimaryFirstName AS FirstName,
			  PrimaryLastName AS LastName,
			  Mobile AS PhoneNumber,
			  '' AS AccountOwnerEmail,
			  MarketingProfileEmailID,
			  UserPrincipalName AS CommunicationEmail,
			  MarketingProfileLocale AS Locale,
			  '' AS AllowPhoneCommunications,
			  '' AS AllowEmailCommunications
			FROM [PII].[vwSubscriptionRoleAssignments] as a
			LEFT JOIN vwCountries as b on a.Country = b.Name
			WHERE SubscriptionGUID IN (SELECT SubscriptionGUID FROM #SubscriptionList)
			AND [AdminType] ='Contributor'
)
SELECT * 
INTO #AzureContactInfo
FROM CTE




------------------------- Step 5:  Insert into Partner_Support.SubscriptionDetails -------------------------

INSERT INTO Partner_Support.SubscriptionDetails

		  SELECT
			TPID = cast(ss.TPID as int),
			OrgName = cast(om.OrgName as nvarchar(1000)),
			AreaName = cast(om.AreaName as varchar(70)),
			TenantID = cast(ci.TenantId as uniqueidentifier),
			CommerceAccountID = cast(ss.CommerceAccountID as varchar(50)),
			OMSSubscriptionID = cast(ss.OMSSubscriptionID as varchar(50)),
			SubscriptionGUID = cast(ss.AI_SubscriptionKey as uniqueidentifier),
			OfferName = cast(ss.OfferName as varchar(500)),
			OfferID = cast(ss.OfferID as varchar(50)),
			CurrentSubscriptionStatus = cast(ss.CurrentSubscriptionStatus as varchar(50)),
			SubscriptionStartDate = cast(ss.SubscriptionStartDate as datetime),
			cast(CASE
			  WHEN ci.Address1 IS NULL THEN ca.AddressLine1
			  ELSE ci.Address1
			END as nvarchar(512)) AS Address1,
			cast(CASE
			  WHEN ci.Address2 IS NULL THEN ca.AddressLine2
			  ELSE ci.Address2
			END as nvarchar(512)) AS Address2,
			cast(CASE
			  WHEN ci.Address3 IS NULL THEN ca.AddressLine3
			  ELSE ci.Address3
			END as nvarchar(512)) AS Address3,
			cast(ci.City as nvarchar(128)) as City,
			cast(ci.State as nvarchar(128)) as State,
			cast(ci.PostalCode as nvarchar(64)) as PostalCode,
			cast(CASE
			  WHEN ci.CountryCode IS NULL THEN ca.CountryCode
			  ELSE ci.CountryCode
			END as nchar(20)) AS CountryCode,
			cast(ci.AccountOwnerPUID as nvarchar(200)) AS AdminPUID,
			cast(CASE
			  WHEN ci.FirstName IS NULL THEN ca.FirstName
			  ELSE ci.FirstName
			END as nvarchar(64)) AS AdminFirstName,
			cast(CASE
			  WHEN ci.LastName IS NULL THEN ca.LastName
			  ELSE ci.LastName
			END as nvarchar(64)) AS AdminLastName,
			cast(CASE
			  WHEN ci.PhoneNumber IS NULL THEN ca.PhoneNumber
			  ELSE ci.PhoneNumber
			END as nvarchar(200)) AS AdminPhoneNumber,
			cast(ci.AccountOwnerEmail as nvarchar(500)) AS AccountOwnerEmail,
			cast(CASE
			  WHEN ci.MarketingProfileEmailID IS NULL THEN ci.CommunicationEmail
			  ELSE ci.MarketingProfileEmailID
			END as nvarchar(129)) AS AdminCommunicationEmail,
			cast(CASE
			  WHEN ci.Locale IS NULL THEN ca.CommunicationCulture
			  ELSE ci.Locale
			END as nvarchar(32)) AS AdminLocale,
			cast(ci.AllowPhoneCommunications as bit) AS AdminPhonePreference,
			cast(ci.AllowEmailCommunications as bit) AS AdminEmailPreference,
			PaidUsageUSD = cast(BTotal.PaidUsageUSD_MostRecentMonth as decimal(38,6)),
   
			UsageStartDateKey = CONVERT(int, CSMProgram_AddMonth),
			UsageEndDateKey = CONVERT(int, CSMProgram_MostRecentMonth),
			InvoiceDateKey = CONVERT(int, NULL),
			BillingMonth = CONVERT(int, NULL),
			SegmentName = cast(om.SegmentName as varchar(80)),
			SubsidiaryName = cast(om.SubsidiaryName as varchar(80)),
			ProcessedDate = GETDATE(),
			BillableAccountID = cast(ss.BillableAccountID as bigint),
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


