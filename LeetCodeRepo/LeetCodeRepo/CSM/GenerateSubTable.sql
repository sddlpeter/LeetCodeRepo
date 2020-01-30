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