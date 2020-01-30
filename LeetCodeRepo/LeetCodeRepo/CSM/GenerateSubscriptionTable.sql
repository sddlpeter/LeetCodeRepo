DECLARE @Date INT
DECLARE @BillingMonth INT

SELECT @Date = DATEPART(DAY, GETDATE())
IF @Date <= 8
	SELECT @BillingMonth = CAST(CONVERT(VARCHAR(20),DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) -2, 0),112) AS INT)
ELSE
	SELECT @BillingMonth = CAST(CONVERT(VARCHAR(20),DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) -1, 0),112) AS INT)


IF OBJECT_ID('tempdb..#FinalSubscriptionDetails')IS NOT NULL
BEGIN
	DROP TABLE #FinalSubscriptionDetails
END

CREATE TABLE #FinalSubscriptionDetails
WITH
(
       DISTRIBUTION = HASH(SubscriptionGUID)
	   ,HEAP
)
AS
		
	SELECT DISTINCT TPID
		 , OrgName
		 , AreaName
		 , TenantID
		 , CommerceAccountID
		 , OMSSubscriptionID
		 , BillableAccountID
		 , SubscriptionGUID
		 , OfferName
		 , OfferID
		 , CurrentSubscriptionStatus
		 , SubscriptionStartDate
		 , Address1
		 , Address2
		 , Address3
		 , City
		 , State
		 , PostalCode
		 , CountryCode
		 , AdminPUID
		 , AdminFirstName
		 , AdminLastName
		 , AdminPhoneNumber
		 , AccountOwnerEmail
		 , AdminCommunicationEmail
		 , AdminLocale
		 , AdminPhonePreference
		 , AdminEmailPreference
		 , '' AS PaidUsageUSD
		 , '' AS UsageStartDateKey
		 , '' AS UsageEndDateKey
		 , '' AS InvoiceDateKey
		 , '' AS BillingMonth
		 , SegmentName
		 , SubsidiaryName
		 , BillingType
		 , AI_OfferType
		 , BusinessGroupName
		 , AI_IsFraud
		 , BisIsTestData
		 , AI_IsTest	
		 , Source
FROM 
	(		
		SELECT ss.TPID
			 , om.OrgName
			 , om.AreaName
			 , ci.TenantID
			 , ss.CommerceAccountID
			 , ss.OMSSubscriptionID
			 , ss.BillableAccountID
			 , ss.SubscriptionGUID
			 , ss.OfferName
			 , ss.OfferID
			 , ss.CurrentSubscriptionStatus
			 , ss.SubscriptionStartDate
			 , ci.Address1
			 , ci.Address2
			 , ci.Address3
			 , ci.City
			 , ci.State
			 , ci.PostalCode
			 , ci.CountryCode
			 , ci.AccountOwnerPUID AS AdminPUID
			 , ci.FirstName AS AdminFirstName
			 , ci.LastName AS AdminLastName
			 , ci.PhoneNumber AS AdminPhoneNumber
			 , ci.AccountOwnerEmail
			 , CASE WHEN ci.MarketingProfileEmailID IS NULL THEN ci.CommunicationEmail 
					ELSE ci.MarketingProfileEmailID
			   END AS AdminCommunicationEmail
			 , CASE WHEN ci.MarketingProfileLocale IS NULL THEN ci.Locale
					ELSE ci.MarketingProfileLocale
			   END AS AdminLocale
			 , ci.AllowPhoneCommunications AS AdminPhonePreference
			 , ci.AllowEmailCommunications AS AdminEmailPreference
			 , om.SegmentName
			 , om.SubsidiaryName
			 , ci.SubscriptionCreatedDate
			 , sb.BillingType
			 , ss.AI_OfferType
			 , ss.BusinessGroupName
			 , ss.AI_IsFraud
			 , ss.BisIsTestData
			 , ss.AI_IsTest 
			 , t.Source
			 , ROW_NUMBER() OVER (PARTITION BY ss.SubscriptionGUID ORDER BY ss.SubscriptionCreatedDate DESC) RNK
		FROM Partner_Support.AdHocSubscription t
		JOIN vwSubscriptionsnapshotV2 ss ON t.SubscriptionGUID = ss.SubscriptionGUID
		--vwSubscriptionSnapshot ss ON t.SubscriptionGUID = ss.SubscriptionGUID
		LEFT JOIN PII.vwAzureContactInfo ci ON t.SubscriptionGUID = ci.SubscriptionGUID
		LEFT JOIN vwServiceBilling sb ON t.SubscriptionGUID = sb.AI_SubscriptionKey AND sb.BillingMonth = @BillingMonth -- some subscriptions might not have paid usage for a while or in that billing month
		LEFT JOIN vwOrganizationMaster om ON ss.TPID = om.OrgID  
		WHERE t.CreatedDate IS NULL
		AND t.Source = 'AdHoc'

		UNION ALL

		SELECT ss.TPID
			 , om.OrgName
			 , om.AreaName
			 , ci.TenantID
			 , ss.CommerceAccountID
			 , ss.OMSSubscriptionID
			 , ss.BillableAccountID
			 , ss.SubscriptionGUID
			 , ss.OfferName
			 , ss.OfferID
			 , ss.CurrentSubscriptionStatus
			 , ss.SubscriptionStartDate
			 , ci.Address1
			 , ci.Address2
			 , ci.Address3
			 , ci.City
			 , ci.State
			 , ci.PostalCode
			 , ci.CountryCode
			 , ci.AccountOwnerPUID AS AdminPUID
			 , ci.FirstName AS AdminFirstName
			 , ci.LastName AS AdminLastName
			 , ci.PhoneNumber AS AdminPhoneNumber
			 , ci.AccountOwnerEmail
			 , CASE WHEN ci.MarketingProfileEmailID IS NULL THEN ci.CommunicationEmail 
					ELSE ci.MarketingProfileEmailID
			   END AS AdminCommunicationEmail
			 , CASE WHEN ci.MarketingProfileLocale IS NULL THEN ci.Locale
					ELSE ci.MarketingProfileLocale
			   END AS AdminLocale
			 , ci.AllowPhoneCommunications AS AdminPhonePreference
			 , ci.AllowEmailCommunications AS AdminEmailPreference
			 , om.SegmentName
			 , om.SubsidiaryName
			 , ci.SubscriptionCreatedDate
			 , sb.BillingType
			 , ss.AI_OfferType
			 , ss.BusinessGroupName
			 , ss.AI_IsFraud
			 , ss.BisIsTestData
			 , ss.AI_IsTest  
			 , t.Source
			 , ROW_NUMBER() OVER (PARTITION BY ss.SubscriptionGUID ORDER BY ss.SubscriptionCreatedDate DESC) RNK
		FROM Partner_Support.AdHocSubscription t
		JOIN vwSubscriptionSnapshotV2 ss ON t.SubscriptionGUID = ss.SubscriptionGUID
		--vwSubscriptionSnapshot ss ON t.SubscriptionGUID = ss.SubscriptionGUID
		LEFT JOIN PII.vwAzureContactInfo_Mooncake ci ON t.SubscriptionGUID = ci.SubscriptionGUID
		LEFT JOIN vwServiceBilling sb ON t.SubscriptionGUID = sb.AI_SubscriptionKey AND sb.BillingMonth = @BillingMonth -- some subscriptions might not have paid usage for a while or in that billing month
		LEFT JOIN vwOrganizationMaster om ON ss.TPID = om.OrgID   
		WHERE t.CreatedDate IS NULL
		AND t.Source = 'AdHoc'
		AND ci.TenantID IS NOT NULL

	) a
	WHERE RNK = 1

-- select * from Partner_Support.AdHocSubscription where createddate is null
-- select * from #FinalSubscriptionDetails

/** check subscription exists in SC **/
SELECT DISTINCT SubscriptionGUID
INTO #tmpInSC
FROM #FinalSubscriptionDetails t
JOIN Partner_Support.CSM_Subscription_TPID s ON t.SubscriptionGUID = s.AI_SubscriptionKey 

SELECT DISTINCT SubscriptionGUID
INTO #tmpNotInSC
FROM #FinalSubscriptionDetails t
LEFT JOIN Partner_Support.CSM_Subscription_TPID s ON t.SubscriptionGUID = s.AI_SubscriptionKey 
WHERE s.AI_SubscriptionKey IS NULL 

UPDATE Partner_Support.AdHocSubscription
SET ExistInSC = 1
FROM #tmpInSC t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID -- 1366
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

UPDATE Partner_Support.AdHocSubscription
SET ExistInSC = 0
FROM #tmpNotInSC t 
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID -- 164
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

/** check subscription exists in AIP **/
SELECT DISTINCT ahs.SubscriptionGUID
INTO #tmpSubInAIP
FROM Partner_Support.AdHocSubscription ahs
JOIN vwSubscriptionSnapshotV2 ss ON ahs.SubscriptionGUID = ss.SubscriptionGUID 
--vwSubscriptionSnapshot ss ON ahs.SubscriptionGUID = ss.SubscriptionGUID 
WHERE ahs.CreatedDate IS NULL
AND ahs.Source = 'AdHoc'

SELECT DISTINCT ahs.SubscriptionGUID
INTO #tmpSubNotInAIP
FROM Partner_Support.AdHocSubscription ahs
LEFT JOIN vwSubscriptionSnapshotV2 ss ON ahs.SubscriptionGUID = ss.SubscriptionGUID 
--vwSubscriptionSnapshot ss ON ahs.SubscriptionGUID = ss.SubscriptionGUID 
WHERE ss.SubscriptionGUID IS NULL 
AND ahs.CreatedDate IS NULL
AND ahs.Source = 'AdHoc'

UPDATE Partner_Support.AdHocSubscription
SET NotInAIP = 0
FROM #tmpSubInAIP t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

UPDATE Partner_Support.AdHocSubscription
SET NotInAIP = 1
FROM #tmpSubNotInAIP t 
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

/** check subscription BillingType is not Direct **/
SELECT DISTINCT SubscriptionGUID
INTO #tmpCorrectBillingType
FROM #FinalSubscriptionDetails 
WHERE BillingType LIKE 'Direct%' 

SELECT DISTINCT SubscriptionGUID
INTO #tmpIncorrectBillingType
FROM #FinalSubscriptionDetails 
WHERE BillingType NOT LIKE 'Direct%' OR BillingType IS NULL   

UPDATE Partner_Support.AdHocSubscription
SET IncorrectBillingType = 0
FROM #tmpCorrectBillingType t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

UPDATE Partner_Support.AdHocSubscription
SET IncorrectBillingType = 1
FROM #tmpIncorrectBillingType t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

/** check subscription OfferType **/
SELECT DISTINCT SubscriptionGUID
INTO #tmpCorrectOfferType
FROM #FinalSubscriptionDetails 
WHERE AI_OfferType IN ('Benefit Programs', 'Consumption', 'Unit Commitment', 'Monetary Commitment','Modern','Modern Customer Led','Modern Field Led','Modern Partner Led')

SELECT DISTINCT SubscriptionGUID
INTO #tmpIncorrectOfferType
FROM #FinalSubscriptionDetails 
WHERE AI_OfferType NOT IN ('Benefit Programs', 'Consumption', 'Unit Commitment', 'Monetary Commitment','Modern','Modern Customer Led','Modern Field Led','Modern Partner Led') 

UPDATE Partner_Support.AdHocSubscription
SET IncorrectAI_OfferType = 0
FROM #tmpCorrectOfferType t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID -- 1366
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

UPDATE Partner_Support.AdHocSubscription
SET IncorrectAI_OfferType = 1
FROM #tmpIncorrectOfferType t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID -- 1366
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

/** check subscription OfferName **/
SELECT DISTINCT SubscriptionGUID
INTO #tmpCorrectOfferName
FROM #FinalSubscriptionDetails 
WHERE OfferName NOT IN ('Free Trial', 'BizSpark', 'BizSpark Plus', 'Microsoft Azure BizSpark 1111', 'Enterprise: BizSpark', 'Visual Studio Enterprise: BizSpark')

SELECT DISTINCT SubscriptionGUID
INTO #tmpIncorrectOfferName
FROM #FinalSubscriptionDetails 
WHERE OfferName IN ('Free Trial', 'BizSpark', 'BizSpark Plus', 'Microsoft Azure BizSpark 1111', 'Enterprise: BizSpark', 'Visual Studio Enterprise: BizSpark')

UPDATE Partner_Support.AdHocSubscription
SET IncorrectOfferName = 0
FROM #tmpCorrectOfferName t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

UPDATE Partner_Support.AdHocSubscription
SET IncorrectOfferName = 1
FROM #tmpIncorrectOfferName t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

/** check subscription BusinessGroupName **/
SELECT DISTINCT SubscriptionGUID
INTO #tmpCorrectBusinessGroupName
FROM #FinalSubscriptionDetails 
WHERE BusinessGroupName = 'Azure'

SELECT DISTINCT SubscriptionGUID
INTO #tmpIncorrectBusinessGroupName
FROM #FinalSubscriptionDetails t
WHERE BusinessGroupName <> 'Azure'

UPDATE Partner_Support.AdHocSubscription
SET IncorrectBusinessGroupName = 0
FROM #tmpCorrectBusinessGroupName t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

UPDATE Partner_Support.AdHocSubscription
SET IncorrectBusinessGroupName = 1
FROM #tmpIncorrectBusinessGroupName t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

/** check subscription is AI_IsFraud **/
SELECT DISTINCT SubscriptionGUID
INTO #tmpAI_IsNotFraud
FROM #FinalSubscriptionDetails 
WHERE AI_IsFraud = 0

SELECT DISTINCT SubscriptionGUID
INTO #tmpAI_IsFraud
FROM #FinalSubscriptionDetails t
WHERE AI_IsFraud = 1

UPDATE Partner_Support.AdHocSubscription
SET AI_IsFraud = 0
FROM #tmpAI_IsNotFraud t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

UPDATE Partner_Support.AdHocSubscription
SET AI_IsFraud = 1
FROM #tmpAI_IsFraud t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

/** check subscription is BisIsTestData **/
SELECT DISTINCT SubscriptionGUID
INTO #tmpBisIsNotTestData
FROM #FinalSubscriptionDetails 
WHERE BisIsTestData = 0

SELECT DISTINCT SubscriptionGUID
INTO #tmpBisIsTestData
FROM #FinalSubscriptionDetails t
WHERE BisIsTestData = 1 

UPDATE Partner_Support.AdHocSubscription
SET BisIsTestData = 0
FROM #tmpBisIsNotTestData t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

UPDATE Partner_Support.AdHocSubscription
SET BisIsTestData = 1
FROM #tmpBisIsTestData t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

/** check subscription is AI_IsTest **/
SELECT DISTINCT SubscriptionGUID
INTO #tmpAI_IsNotTest
FROM #FinalSubscriptionDetails 
WHERE AI_IsTest = 0

SELECT DISTINCT SubscriptionGUID
INTO #tmpAI_IsTest
FROM #FinalSubscriptionDetails t
WHERE AI_IsTest = 1 

UPDATE Partner_Support.AdHocSubscription
SET AI_IsTest = 0
FROM #tmpAI_IsNotTest t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

UPDATE Partner_Support.AdHocSubscription
SET AI_IsTest = 1
FROM #tmpAI_IsTest t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

/** check SubscriptionGUID is null **/
SELECT DISTINCT SubscriptionGUID
INTO #tmpSubscriptionGUIDIsNotNull
FROM #FinalSubscriptionDetails 
WHERE SubscriptionGUID IS NOT NULL

SELECT DISTINCT SubscriptionGUID
INTO #tmpSubscriptionGUIDIsNull
FROM #FinalSubscriptionDetails t
WHERE SubscriptionGUID IS NULL

UPDATE Partner_Support.AdHocSubscription
SET SubscriptionGUIDNull = 0
FROM #tmpSubscriptionGUIDIsNotNull t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

UPDATE Partner_Support.AdHocSubscription
SET SubscriptionGUIDNull = 1
FROM #tmpSubscriptionGUIDIsNull t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

/** check CurrentSubscriptionStatus **/
SELECT DISTINCT SubscriptionGUID
INTO #tmpCorrectSubscriptionStatus
FROM #FinalSubscriptionDetails 
WHERE CurrentSubscriptionStatus NOT IN ('Deprovisioned', 'Disabled')

SELECT DISTINCT SubscriptionGUID
INTO #tmpIncorrectSubscriptionStatus
FROM #FinalSubscriptionDetails t
WHERE CurrentSubscriptionStatus IN ('Deprovisioned', 'Disabled')

UPDATE Partner_Support.AdHocSubscription
SET IncorrectSubscriptionStatus = 0
FROM #tmpCorrectSubscriptionStatus t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

UPDATE Partner_Support.AdHocSubscription
SET IncorrectSubscriptionStatus = 1
FROM #tmpIncorrectSubscriptionStatus t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

/** check TPID is null **/
SELECT DISTINCT SubscriptionGUID
INTO #tmpTPIDIsNotNull
FROM #FinalSubscriptionDetails 
WHERE TPID IS NOT NULL

SELECT DISTINCT SubscriptionGUID
INTO #tmpTPIDIsNull
FROM #FinalSubscriptionDetails t
WHERE TPID IS NULL

UPDATE Partner_Support.AdHocSubscription
SET TPIDNull = 0
FROM #tmpTPIDIsNotNull t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

UPDATE Partner_Support.AdHocSubscription
SET TPIDNull = 1
FROM #tmpTPIDIsNull t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

/** check CommerceAccountID is null **/
SELECT DISTINCT SubscriptionGUID
INTO #tmpCommerceAccountIDIsNotNull
FROM #FinalSubscriptionDetails 
WHERE CommerceAccountID IS NOT NULL

SELECT DISTINCT SubscriptionGUID
INTO #tmpCommerceAccountIDIsNull
FROM #FinalSubscriptionDetails t
WHERE CommerceAccountID IS NULL

UPDATE Partner_Support.AdHocSubscription
SET CommerceAccountIDNull = 0
FROM #tmpCommerceAccountIDIsNotNull t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

UPDATE Partner_Support.AdHocSubscription
SET CommerceAccountIDNull = 1
FROM #tmpCommerceAccountIDIsNull t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

/** check OMSSubscriptionID is null **/
SELECT DISTINCT SubscriptionGUID
INTO #tmpOMSSubscriptionIDIsNotNull
FROM #FinalSubscriptionDetails 
WHERE OMSSubscriptionID IS NOT NULL

SELECT DISTINCT SubscriptionGUID
INTO #tmpOMSSubscriptionIDIsNull
FROM #FinalSubscriptionDetails t
WHERE OMSSubscriptionID IS NULL

UPDATE Partner_Support.AdHocSubscription
SET OMSSubscriptionIDNull = 0
FROM #tmpOMSSubscriptionIDIsNotNull t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

UPDATE Partner_Support.AdHocSubscription
SET OMSSubscriptionIDNull = 1
FROM #tmpCommerceAccountIDIsNull t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

/** check AreaName is null **/
SELECT DISTINCT SubscriptionGUID
INTO #tmpAreaNameIsNotNull
FROM #FinalSubscriptionDetails 
WHERE AreaName IS NOT NULL

SELECT DISTINCT SubscriptionGUID
INTO #tmpAreaNameIsNull
FROM #FinalSubscriptionDetails t
WHERE AreaName IS NULL

UPDATE Partner_Support.AdHocSubscription
SET AreaNameNull = 0
FROM #tmpAreaNameIsNotNull t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

UPDATE Partner_Support.AdHocSubscription
SET AreaNameNull = 1
FROM #tmpAreaNameIsNull t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

/** Final query **/
INSERT INTO Partner_Support.SubscriptionDetails
		SELECT DISTINCT s.TPID
			 , s.OrgName
			 , s.AreaName
			 , s.TenantID
			 , s.CommerceAccountID
			 , s.OMSSubscriptionID
			 , s.SubscriptionGUID
			 , s.OfferName
			 , s.OfferID
			 , s.CurrentSubscriptionStatus
			 , s.SubscriptionStartDate
			 , s.Address1
			 , s.Address2
			 , s.Address3
			 , s.City
			 , s.State
			 , s.PostalCode
			 , s.CountryCode
			 , s.AdminPUID
			 , s.AdminFirstName
			 , s.AdminLastName
			 , s.AdminPhoneNumber
			 , s.AccountOwnerEmail
			 , s.AdminCommunicationEmail
			 , s.AdminLocale
			 , s.AdminPhonePreference
			 , s.AdminEmailPreference
			 , 0 AS PaidUsageUSD
			 , '' AS UsageStartDateKey
			 , '' AS UsageEndDateKey
			 , '' AS InvoiceDateKey
			 , '' AS BillingMonth
			 , s.SegmentName
			 , s.SubsidiaryName
			 , GETDATE() AS ProcessedDate
			 , s.BillableAccountID
			 , s.Source
		FROM #FinalSubscriptionDetails s 
		JOIN Partner_Support.AdHocSubscription t ON s.SubscriptionGUID = t.SubscriptionGUID
		WHERE t.ExistInSC = 0
		AND t.NotInAIP = 0
		AND t.IncorrectBillingType = 0
		AND t.IncorrectAI_OfferType = 0
		AND t.IncorrectOfferName = 0
		AND t.IncorrectBusinessGroupName = 0
		AND t.AI_IsFraud = 0
		AND t.BisIsTestData = 0
		AND t.AI_IsTest = 0
		AND t.SubscriptionGUIDNull = 0
		AND t.IncorrectSubscriptionStatus = 0
		AND t.TPIDNull = 0
		AND t.CommerceAccountIDNull = 0
		AND t.OMSSubscriptionIDNull = 0
		AND t.AreaNameNull = 0
		AND t.CreatedDate IS NULL