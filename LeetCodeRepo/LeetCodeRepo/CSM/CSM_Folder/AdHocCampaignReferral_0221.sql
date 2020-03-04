
-- load data from SubmitCampaignReferral.xls to Partner_Support.AdHocSubscription

--------------------- Truncate tables --------------------------------
TRUNCATE TABLE Partner_Support.TPIDRevenue;
TRUNCATE TABLE Partner_Support.MasterTPIDRevenue;
TRUNCATE TABLE Partner_Support.SubscriptionDetails;


--------------------- Generate Subscription table ---------------------------------
/**
*** History: 
***			02/15/19 - New query 
**/
-- DECLARE @LatestDate INT

-- SELECT @LatestDate = (select max(createddate) from [Partner_Support].[AdHocSubscription] );




with cte as (
select   ss.TPID , ss.CommerceAccountID
			 , ss.OMSSubscriptionID
			 , ss.BillableAccountID
			 , ss.SubscriptionGUID
			 , ss.OfferName
			 , ss.OfferID
			 , ss.CurrentSubscriptionStatus
			 , ss.SubscriptionStartDate,
			 ss.SubscriptionCreatedDate,
			 om.orgname,
			 om.areaname,
			 om.segmentname,
			 om.subsidiaryname
			 from vwSubscriptionSnapshotV2 as ss
			 left join vwOrganizationMaster om on ss.TPID = om.orgid
			 where ss.ai_offertype in ('Benefit Programs', 'Consumption' , 'Unit Commitment', 'Monetary Commitment' , 'Modern', 'CustomerLed')
			 and not ss.offername in ('Free Trial', 'BizSpark', 'BizSpark Plus', 'Microsoft Azure BizSpark 1111', 'Enterprise: BizSpark', 'Visual Studio Enterprise: BizSpark')

union

select   ss.TPID , ss.CommerceAccountID
			 , ss.OMSSubscriptionID
			 , ss.BillableAccountID
			 , ss.SubscriptionGUID
			 , ss.OfferName
			 , ss.OfferID
			 , ss.CurrentSubscriptionStatus
			 , ss.SubscriptionStartDate,
			 ss.SubscriptionCreatedDate,
			 om.orgname,
			 om.areaname,
			 om.segmentname,
			 om.subsidiaryname
			 from vwSubscriptionSnapshotV2 as ss
			 left join vwOrganizationMaster om on ss.TPID = om.orgid
			 where ss.ai_offertype = 'FieldLed'
			 and not ss.offername in ('Free Trial', 'BizSpark', 'BizSpark Plus', 'Microsoft Azure BizSpark 1111', 'Enterprise: BizSpark', 'Visual Studio Enterprise: BizSpark')
			 AND (
			(om.segmentname = 'Small, Medium & Corporate Commercial' and om.subsegmentname = 'SM&C Commercial - SMB Default') or
			(om.segmentname = 'Small, Medium & Corporate Commercial' and om.subsegmentname = 'SM&C Commercial - SMB') or
			(om.segmentname = 'Small, Medium & Corporate Education' and om.subsegmentname = 'SM&C Education - SMB') or
			(om.segmentname = 'Small, Medium & Corporate Government' and om.subsegmentname = 'SM&C Government - SMB') 
			)
) select top 100 * 
into #vwSubscriptionSnapshotV2_OrgMaster
from cte;







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
			 , @parmProcessDate AS ProcessedDate
			 , BillableAccountID
			 , cast(Source as varchar(100)) AS Source
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
		LEFT JOIN PII.vwAzureContactInfo ci ON t.SubscriptionGUID = ci.SubscriptionGUID
		LEFT JOIN vwServiceBilling sb ON t.SubscriptionGUID = sb.AI_SubscriptionKey -- some subscriptions might not have paid usage for a while or in that billing month
		LEFT JOIN vwOrganizationMaster om ON ss.TPID = om.OrgID  
		WHERE t.CreatedDate =  @parmProcessDate
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
		WHERE t.CreatedDate = @parmProcessDate
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
		WHERE t.CreatedDate = @parmProcessDate
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
    WHERE t.CreatedDate = @parmProcessDate
    AND t.SubscriptionGUID  IS NOT NULL
    AND sra.[AdminType] ='Contributor'

) a
WHERE RNK = 1


-------------------- copy subscription data to SC_Subscription_Referral -------------------
-- copy whole table



-------------------- copy subscription data to SC_Admin_Referral -------------------
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
			  , t.ProcessedDate AS ProcessedDate
FROM Partner_Support.SubscriptionDetails t
LEFT JOIN PII.vwSubscriptionAdminDetails sad ON t.SubscriptionGUID = sad.SubscriptionGUID 
LEFT JOIN PII.vwAzureContactInfo ci ON sad.SubscriptionGUID = ci.SubscriptionGUID AND sad.AdminPUID = ci.AccountOwnerPUID 
WHERE sad.AdminState = 'Enabled'

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
			  , t.ProcessedDate AS ProcessedDate
FROM Partner_Support.SubscriptionDetails t
JOIN PII.vwSubscriptionRoleAssignments sra ON t.SubscriptionGUID = sra.SubscriptionGUID 
WHERE sra.AdminType IN ('Contributor', 'admin')
ORDER BY 1, 2

-------------------- copy subscription data to SC_TPID_Referral -------------------

SELECT DISTINCT t.TPID
			  , t.SubscriptionGUID
			  , ahs.CSM
			  , ahs.CSMManager
			  , 99 AS DeltaScore
                                                  , t.ProcessedDate AS ProcessedDate
FROM Partner_Support.SubscriptionDetails t
JOIN Partner_Support.AdHocSubscription ahs ON t.SubscriptionGUID = ahs.SubscriptionGUID

ORDER BY 1, 2





-------------------- UPDATE ADHOC -----------------------------------------------

DECLARE @parmProcessDate DATE
SELECT @parmProcessDate = (select max(createddate) from Partner_Support.AdHocSubscription)

/** check subscription exists in SC **/
-- SELECT DISTINCT SubscriptionGUID
-- INTO #tmpInSC
-- FROM Partner_Support.SubscriptionDetails t
-- JOIN Partner_Support.CSM_Subscription_TPID s ON t.SubscriptionGUID = s.AI_SubscriptionKey 

-- SELECT DISTINCT SubscriptionGUID
-- INTO #tmpNotInSC
-- FROM Partner_Support.SubscriptionDetails t
-- LEFT JOIN Partner_Support.CSM_Subscription_TPID s ON t.SubscriptionGUID = s.AI_SubscriptionKey 
-- WHERE s.AI_SubscriptionKey IS NULL 

-- UPDATE Partner_Support.AdHocSubscription
-- SET ExistInSC = 1
-- FROM #tmpInSC t
-- WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
-- AND Partner_Support.AdHocSubscription.CreatedDate = @parmProcessDate

-- UPDATE Partner_Support.AdHocSubscription
-- SET ExistInSC = 0
-- FROM #tmpNotInSC t 
-- WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
-- AND Partner_Support.AdHocSubscription.CreatedDate = @parmProcessDate

/** check subscription exists in AIP **/
SELECT DISTINCT ahs.SubscriptionGUID
INTO #tmpSubInAIP
FROM Partner_Support.AdHocSubscription ahs
JOIN vwSubscriptionSnapshotV2 ss ON ahs.SubscriptionGUID = ss.SubscriptionGUID 
-- vwSubscriptionSnapshot ss ON ahs.SubscriptionGUID = ss.SubscriptionGUID 
WHERE ahs.CreatedDate = @parmProcessDate

SELECT DISTINCT ahs.SubscriptionGUID
INTO #tmpSubNotInAIP
FROM Partner_Support.AdHocSubscription ahs
LEFT JOIN vwSubscriptionSnapshotV2 ss ON ahs.SubscriptionGUID = ss.SubscriptionGUID 
--vwSubscriptionSnapshot ss ON ahs.SubscriptionGUID = ss.SubscriptionGUID 
WHERE ss.SubscriptionGUID IS NULL 
AND ahs.CreatedDate = @parmProcessDate

UPDATE Partner_Support.AdHocSubscription
SET NotInAIP = 0
FROM #tmpSubInAIP t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID
AND Partner_Support.AdHocSubscription.CreatedDate =@parmProcessDate

UPDATE Partner_Support.AdHocSubscription
SET NotInAIP = 1
FROM #tmpSubNotInAIP t 
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID 
AND Partner_Support.AdHocSubscription.CreatedDate = @parmProcessDate

/** find subscription qualify for SC upload **/
SELECT DISTINCT SubscriptionGUID
INTO #tmpUploadToSC
FROM Partner_Support.AdHocSubscription 
WHERE CreatedDate = @parmProcessDate
-- AND ExistInSC = 0
AND NotInAIP = 0

SELECT DISTINCT SubscriptionGUID
INTO #tmpNotUploadToSC
FROM Partner_Support.AdHocSubscription 
WHERE CreatedDate = @parmProcessDate
-- AND ExistInSC = 1
OR NotInAIP =1 

UPDATE Partner_Support.AdHocSubscription 
SET UploadedToSC = 1
FROM #tmpUploadToSC t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID

UPDATE Partner_Support.AdHocSubscription 
SET UploadedToSC = 0
FROM #tmpNotUploadToSC t
WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID



----------------------- insert into CSM_Subscription_TPID ----------------------
IF EXISTS (SELECT COUNT(ahs.SubscriptionGUID) 
			FROM Partner_Support.AdHocSubscription ahs
			JOIN Partner_Support.SubscriptionDetails sd ON ahs.SubscriptionGUID = sd.SubscriptionGUID
			WHERE ahs.UploadedToSC = 1
		  )
BEGIN 
	INSERT INTO Partner_Support.CSM_Subscription_TPID
	SELECT ahs.TPID, ahs.SubscriptionGUID, ahs.CreatedDate, NULL, NULL
	FROM Partner_Support.AdHocSubscription ahs
	JOIN Partner_Support.SubscriptionDetails sd ON ahs.SubscriptionGUID = sd.SubscriptionGUID
	WHERE ahs.UploadedToSC = 1
END



-------------------- File management --------------------




------------------- export AdHocSubscription to Excel ----------------------

declare @date date
select @date = (select max(createddate) from Partner_Support.AdHocSubscription)
select distinct *  from Partner_Support.AdHocSubscription 
where Source != 'AdHoc' and not (source = 'Referral' and createddate = @date)
order by createddate desc;

------------------ Truncate tables ---------------------
TRUNCATE TABLE Partner_Support.TPIDRevenue;
TRUNCATE TABLE Partner_Support.MasterTPIDRevenue;
TRUNCATE TABLE Partner_Support.SubscriptionDetails;

