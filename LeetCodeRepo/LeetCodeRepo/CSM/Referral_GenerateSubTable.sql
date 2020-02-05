/**
*** History: 
***			02/15/19 - New query 
**/
INSERT INTO Partner_Support.SubscriptionDetails		
	SELECT DISTINCT TPID
			 , OrgName
			 , AreaName
			 , TenantID
			 , CommerceAccountID
			 , OMSSubscriptionID
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
			 , 0 AS PaidUsageUSD
			 , '' AS UsageStartDateKey
			 , '' AS UsageEndDateKey
			 , '' AS InvoiceDateKey
			 , '' AS BillingMonth
			 , SegmentName
			 , SubsidiaryName
			 , GETDATE() AS ProcessedDate
			 , BillableAccountID
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
			 , t.Source
			 , ROW_NUMBER() OVER (PARTITION BY ss.SubscriptionGUID ORDER BY ss.SubscriptionCreatedDate DESC) RNK
		FROM Partner_Support.AdHocSubscription t
		JOIN vwSubscriptionSnapshotV2 ss ON t.SubscriptionGUID = ss.SubscriptionGUID
		--vwSubscriptionSnapshot ss ON t.SubscriptionGUID = ss.SubscriptionGUID
		LEFT JOIN PII.vwAzureContactInfo ci ON t.SubscriptionGUID = ci.SubscriptionGUID
		LEFT JOIN vwServiceBilling sb ON t.SubscriptionGUID = sb.AI_SubscriptionKey -- some subscriptions might not have paid usage for a while or in that billing month
		LEFT JOIN vwOrganizationMaster om ON ss.TPID = om.OrgID  
		WHERE t.CreatedDate IS NULL
		AND t.Source = 'Referral'

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
			 , t.Source
			 , ROW_NUMBER() OVER (PARTITION BY ss.SubscriptionGUID ORDER BY ss.SubscriptionCreatedDate DESC) RNK
		FROM Partner_Support.AdHocSubscription t
		LEFT JOIN vwSubscriptionSnapshotV2 ss ON t.SubscriptionGUID = ss.SubscriptionGUID
		--vwSubscriptionSnapshot ss ON t.SubscriptionGUID = ss.SubscriptionGUID
		LEFT JOIN PII.vwAzureContactInfo_Mooncake ci ON t.SubscriptionGUID = ci.SubscriptionGUID
		JOIN vwServiceBilling sb ON t.SubscriptionGUID = sb.AI_SubscriptionKey  -- some subscriptions might not have paid usage for a while or in that billing month
		JOIN vwOrganizationMaster om ON ss.TPID = om.OrgID   
		WHERE t.CreatedDate IS NULL
		AND t.Source = 'Referral'
		AND sb.BillingType = 'Direct (China)'

	) a
	WHERE RNK = 1



	---------------------------------------------------------------------

	SELECT DISTINCT t.TPID 
			  , t.SubscriptionGUID
			  , sad.TenantID
			  , CASE WHEN CAST(sad.ObjectID AS UNIQUEIDENTIFIER) IS NULL AND ci.ObjectID IS NOT NULL THEN ci.ObjectID
					ELSE CAST(sad.ObjectID AS UNIQUEIDENTIFIER) 
			    END ObjectID
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
LEFT JOIN PII.vwAzureContactInfo ci ON sad.SubscriptionGUID = ci.SubscriptionGUID AND sad.AdminPUID = ci.AccountOwnerPUID
WHERE sad.AdminState = 'Enabled'
AND t.Source = 'Referral'

UNION ALL

SELECT DISTINCT t.TPID 
			  , t.SubscriptionGUID
			  , sra.TenantID
			  , sra.ObjectID
			  , sra.AdminPUID
			  , CASE WHEN sra.PrimaryEmailID IS NULL AND t.AdminPUID = sra.AdminPUID THEN t.AccountOwnerEmail
					 ELSE sra.PrimaryEmailID
				END PrimaryEmailID
			  , CASE WHEN sra.PrimaryFirstName IS NULL AND t.AdminPUID = sra.AdminPUID THEN t.AdminFirstName
					 ELSE sra.PrimaryFirstName
				END PrimaryFirstName
			  , CASE WHEN sra.PrimaryLastName IS NULL AND t.AdminPUID = sra.AdminPUID THEN t.AdminLastName
					 ELSE sra.PrimaryLastName
				END PrimaryLastName
			  , CASE WHEN sra.TelephoneNumber IS NULL AND t.AdminPUID = sra.AdminPUID THEN t.AdminPhoneNumber
					 ELSE sra.TelephoneNumber
				END TelephoneNumber
			  , CASE WHEN sra.PreferredLanguage IS NULL AND t.AdminPUID = sra.AdminPUID THEN t.AdminLocale
					 ELSE sra.PreferredLanguage
				END PreferredLanguage
			  , sra.AdminType
			  , t.CommerceAccountID
			  , GETDATE() AS ProcessedDate
FROM Partner_Support.SubscriptionDetails t
JOIN PII.vwSubscriptionRoleAssignments sra ON t.SubscriptionGUID = sra.SubscriptionGUID 
WHERE sra.AdminType IN ('Owner')
AND t.Source = 'Referral'
ORDER BY 1, 2

------------------------------------------------------------------------

/** check subscription exists in SC **/
SELECT DISTINCT SubscriptionGUID
INTO #tmpInSC
FROM Partner_Support.SubscriptionDetails t
JOIN Partner_Support.CSM_Subscription_TPID s ON t.SubscriptionGUID = s.AI_SubscriptionKey 

SELECT DISTINCT SubscriptionGUID
INTO #tmpNotInSC
FROM Partner_Support.SubscriptionDetails t
LEFT JOIN Partner_Support.CSM_Subscription_TPID s ON t.SubscriptionGUID = s.AI_SubscriptionKey 
WHERE s.AI_SubscriptionKey IS NULL 

UPDATE Partner_Support.AdHocSubscription
SET ExistInSC = 1
FROM #tmpInSC t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

UPDATE Partner_Support.AdHocSubscription
SET ExistInSC = 0
FROM #tmpNotInSC t 
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate IS NULL

/** check subscription exists in AIP **/
SELECT DISTINCT ahs.SubscriptionGUID
INTO #tmpSubInAIP
FROM Partner_Support.AdHocSubscription ahs
JOIN vwSubscriptionSnapshotV2 ss ON ahs.SubscriptionGUID = ss.SubscriptionGUID 
-- vwSubscriptionSnapshot ss ON ahs.SubscriptionGUID = ss.SubscriptionGUID 
WHERE ahs.CreatedDate IS NULL
AND ahs.Source = 'Referral'

SELECT DISTINCT ahs.SubscriptionGUID
INTO #tmpSubNotInAIP
FROM Partner_Support.AdHocSubscription ahs
LEFT JOIN vwSubscriptionSnapshotV2 ss ON ahs.SubscriptionGUID = ss.SubscriptionGUID 
--vwSubscriptionSnapshot ss ON ahs.SubscriptionGUID = ss.SubscriptionGUID 
WHERE ss.SubscriptionGUID IS NULL 
AND ahs.CreatedDate IS NULL
AND ahs.Source = 'Referral'

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

/** find subscription qualify for SC upload **/
SELECT DISTINCT SubscriptionGUID
INTO #tmpUploadToSC
FROM Partner_Support.AdHocSubscription 
WHERE CreatedDate IS NULL
AND Source = 'Referral'
AND ExistInSC = 0
AND NotInAIP = 0

SELECT DISTINCT SubscriptionGUID
INTO #tmpNotUploadToSC
FROM Partner_Support.AdHocSubscription 
WHERE CreatedDate IS NULL
AND Source = 'Referral'
AND ExistInSC = 1
OR NotInAIP =1 

UPDATE Partner_Support.AdHocSubscription 
SET UploadedToSC = 1
  , CreatedDate = GETDATE()
FROM #tmpUploadToSC t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID

UPDATE Partner_Support.AdHocSubscription 
SET UploadedToSC = 0
  , CreatedDate = GETDATE()
FROM #tmpNotUploadToSC t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID