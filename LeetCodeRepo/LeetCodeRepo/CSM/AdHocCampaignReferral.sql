/**
*** History: 
***			02/15/19 - New query 
**/
-- DECLARE @LatestDate INT

-- SELECT @LatestDate = (select max(createddate) from [Partner_Support].[AdHocSubscription] );

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
		AND t.SubscriptionGUID IS NOT NULL

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
		AND t.SubscriptionGUID  IS NOT NULL
		AND sb.BillingType = 'Direct (China)'

        UNION ALL


	    SELECT  ss.TPID
			 , om.OrgName
			 , om.AreaName
			 , sa.TenantID
			 , ss.CommerceAccountID
			 , ss.OMSSubscriptionID
			 , ss.BillableAccountID
			 , ss.SubscriptionGUID
			 , ss.OfferName
			 , ss.OfferID
			 , ss.CurrentSubscriptionStatus
			 , ss.SubscriptionStartDate
			 , '' AS Address1
			 , '' AS Address2
			 , '' AS Address3
			 , sa.City
			 , sa.State
			 , sa.PostalCode
			 , '' AS CountryCode
			 , sa.AdminPUID
			 , sa.PrimaryFirstName AS AdminFirstName
			 , sa.PrimaryLastName AS AdminLastName
			 , sa.Mobile AS AdminPhoneNumber
			 , sa.PrimaryEmailID AS AccountOwnerEmail
			 , CASE WHEN sa.MarketingProfileEmailID IS NULL THEN sa.PrimaryEmailID 
					ELSE sa.PrimaryEmailID
			   END AS AdminCommunicationEmail
			 , CASE WHEN sa.MarketingProfileLocale IS NULL THEN sa.PreferredLanguage
					ELSE sa.MarketingProfileLocale
			   END AS AdminLocale
			 , '' AS AdminPhonePreference
			 , '' AS AdminEmailPreference
			 , om.SegmentName
			 , om.SubsidiaryName
			 , t.Source
			 , ROW_NUMBER() OVER (PARTITION BY ss.SubscriptionGUID ORDER BY ss.SubscriptionCreatedDate DESC) RNK
				FROM Partner_Support.AdHocSubscription t
		INNER JOIN vwSubscriptionSnapshotV2 ss ON t.SubscriptionGUID = ss.SubscriptionGUID
		LEFT JOIN [PII].[vwSubscriptionAdminDetails] sa ON t.SubscriptionGUID = sa.SubscriptionGUID
		LEFT JOIN vwServiceBilling sb ON t.SubscriptionGUID = sb.AI_SubscriptionKey -- some subscriptions might not have paid usage for a while or in that billing month
		LEFT JOIN vwOrganizationMaster om ON ss.TPID = om.OrgID  
		WHERE t.CreatedDate IS NULL
		AND t.SubscriptionGUID  IS NOT NULL
		AND sa.[AdminType] = 'Owner'


        UNION ALL

        SELECT     ss.TPID
            , om.OrgName
            , om.AreaName
            , sra.TenantID
            , ss.CommerceAccountID
            , ss.OMSSubscriptionID
            , ss.BillableAccountID
            , ss.SubscriptionGUID
            , ss.OfferName
            , ss.OfferID
            , ss.CurrentSubscriptionStatus
            , ss.SubscriptionStartDate
            , '' AS Address1
            , '' AS Address2
            , '' AS Address3
            , sra.City
            , sra.State
            , sra.PostalCode
            , '' AS CountryCode
            , sra.AdminPUID
            , sra.PrimaryFirstName AS AdminFirstName
            , sra.PrimaryLastName AS AdminLastName
            , sra.Mobile AS AdminPhoneNumber
            , sra.PrimaryEmailID AS AccountOwnerEmail
            , CASE WHEN sra.MarketingProfileEmailID IS NULL THEN sra.PrimaryEmailID 
                ELSE sra.PrimaryEmailID
            END AS AdminCommunicationEmail
            , CASE WHEN sra.MarketingProfileLocale IS NULL THEN sra.PreferredLanguage
                ELSE sra.MarketingProfileLocale
            END AS AdminLocale
            , '' AS AdminPhonePreference
            , '' AS AdminEmailPreference
            , om.SegmentName
            , om.SubsidiaryName
            , t.Source
            , ROW_NUMBER() OVER (PARTITION BY ss.SubscriptionGUID ORDER BY ss.SubscriptionCreatedDate DESC) RNK
            FROM Partner_Support.AdHocSubscription t
    INNER JOIN vwSubscriptionSnapshotV2 ss ON t.SubscriptionGUID = ss.SubscriptionGUID
    LEFT JOIN [PII].[vwSubscriptionRoleAssignments] sra ON t.SubscriptionGUID = sra.SubscriptionGUID
    LEFT JOIN vwServiceBilling sb ON t.SubscriptionGUID = sb.AI_SubscriptionKey -- some subscriptions might not have paid usrage for a while or in that billing month
    LEFT JOIN vwOrganizationMaster om ON ss.TPID = om.OrgID  
    WHERE t.CreatedDate IS NULL
    AND t.SubscriptionGUID  IS NOT NULL
    AND sra.[AdminType] ='Contributor'

) a
WHERE RNK = 1