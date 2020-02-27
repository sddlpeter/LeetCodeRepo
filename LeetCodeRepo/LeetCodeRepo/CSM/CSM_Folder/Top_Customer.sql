

/* Top Customer (Updated) -- Added RBAC logic */

/* From the subscriptions provided by top customer list, 
*** find the TPID then find the subscriptions under those TPID
*** don't apply any filters
*** don't need to pull revenue data
*** don't remove subscription already exist in SC
** NOTE: WHEN EXPORTING RECORDSET to EXCEL, WE NEED TO SAVE RESULTSET IN LOCAL SERVER FOLDER AS CSV, THEN COPYTO LOCAL MACHINE/LAPTOP AND THEN UPLOAD TO SHAREPOINT FOLDER.
ENSURE TO SHIFT-DELETE ALL EXPORTED RESULTSET FILES FROM SERVER, LOCAL MACHINE/LAPTOP IMMEDIATELY AFTER UPLOADING TO SHAREPOINT FOLDER. PII/SENSITIVE DATA CANNOT RESIDE IN LOCAL FOLDERS.
*/

WITH tpid_history AS 
(
SELECT datekey, [AI_SubscriptionKey],[TPID]
FROM 
(
SELECT   [DateKey]
        ,[AI_SubscriptionKey]
        ,[TPID]
        ,ROW_NUMBER() OVER(PARTITION BY [AI_SubscriptionKey] ORDER BY [DateKey] DESC)  AS rn
     
  FROM [dbo].[vwSubscription_CustomerV2_History] 
  WHERE tpid IS NOT NULL
  ) AS inn
  WHERE inn.rn = 1
),

tpid_history1 AS 
(
SELECT TPID,AI_SubscriptionKey
FROM 
(
SELECT   TPID
        ,AI_SubscriptionKey
        ,ROW_NUMBER() OVER(PARTITION BY [AI_SubscriptionKey] ORDER BY CreateDate DESC)  AS rn
     
  FROM Partner_Support.[CSM_Subscription_TPID] 
  WHERE tpid IS NOT NULL
  ) AS inn
  WHERE inn.rn = 1
)


SELECT COALESCE(sub.TPID,hist.TPID,hist1.TPID) AS TPID, sub.SubscriptionGUID INTO #tmpTPID 
FROM [Partner_Support].[Customer_Subscription2load] AS cust 
LEFT OUTER JOIN vwSubscriptionSnapshotv2 AS sub ON cust.SubscriptionGUID = sub.[SubscriptionGuid]
LEFT OUTER JOIN tpid_history AS hist ON cust.SubscriptionGUID = hist.[AI_SubscriptionKey]
LEFT OUTER JOIN tpid_history1 AS hist1 ON cust.SubscriptionGUID = hist1.[AI_SubscriptionKey]


-- 'Top Customer' as Source





/** Subscription Details **/
IF OBJECT_ID('tempdb..#SubscriptionDetails')IS NOT NULL
BEGIN
       DROP TABLE #SubscriptionDetails
END

CREATE TABLE #SubscriptionDetails
WITH
(
       DISTRIBUTION = HASH(SubscriptionGUID)
          ,HEAP
)
AS
       SELECT DISTINCT t.TPID 
              , om.OrgName
             , om.AreaName
             , ss.CommerceAccountID
             , ss.OMSSubscriptionID
             , ss.BillableAccountID
             , ss.SubscriptionGUID
             , ss.OfferName
             , ss.OfferID
             , ss.CurrentSubscriptionStatus
             , ss.SubscriptionStartDate
             , om.SegmentName
             , om.SubsidiaryName
             , ss.SubscriptionCreatedDate
             --select count(distinct t.SubscriptionGUID) --s.SubscriptionGUID
       FROM #tmpTPID t --2602
       LEFT JOIN vwSubscriptionSnapshotv2 ss ON  t.SubscriptionGUID = ss.[AI_SubscriptionKey] --AND t.TPID = ss.TPID 
       LEFT JOIN vwOrganizationMaster om ON t.TPID = om.OrgID 

       -- exclude 'FieldLed' segment != '' subsegment != ''
       
--select * from #SubscriptionDetails

--IF OBJECT_ID('tempdb..#FinalSubscriptionDetails')IS NOT NULL
--BEGIN
--       DROP TABLE #FinalSubscriptionDetails
--END

--CREATE TABLE #FinalSubscriptionDetails
--WITH
--(
--       DISTRIBUTION = HASH(SubscriptionGUID)
--        ,HEAP
--)
--AS
INSERT INTO [Partner_Support].[SubscriptionDetails] 
       SELECT DISTINCT TPID
             , OrgName
             , AreaName
             , TenantID
             , CommerceAccountID
             , OMSSubscriptionID
             -- , BillableAccountID
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
             , PaidUsageUSD
             , UsageStartDateKey
             , UsageEndDateKey
             , InvoiceDateKey
             , BillingMonth
             , SegmentName
             , SubsidiaryName
             ,GETDAte()
             ,BillableAccountID
             ,'TopCustomer'
           
       FROM 
       (            
             SELECT t.TPID
                    , t.OrgName
                    , t.AreaName
                    , ci.TenantID
                    , t.CommerceAccountID
                    , t.OMSSubscriptionID
                    , t.BillableAccountID
                    , t.SubscriptionGUID
                    , t.OfferName
                    , t.OfferID
                    , t.CurrentSubscriptionStatus
                    , t.SubscriptionStartDate
                    , CASE WHEN ci.Address1 IS NULL THEN ca.AddressLine1
                                 ELSE ci.Address1
                       END AS Address1
                    , CASE WHEN ci.Address2 IS NULL THEN ca.AddressLine2
                                 ELSE ci.Address2
                       END AS Address2
                    , CASE WHEN ci.Address3 IS NULL THEN ca.AddressLine3
                                 ELSE ci.Address3
                       END AS Address3
                    , ci.City
                    , ci.State
                    , ci.PostalCode
                    , CASE WHEN ci.CountryCode IS NULL THEN ca.CountryCode
                                 ELSE ci.CountryCode
                       END AS CountryCode
                    , ci.AccountOwnerPUID AS AdminPUID
                    , CASE WHEN ci.FirstName IS NULL THEN ca.FirstName
                                 ELSE ci.FirstName
                       END AS AdminFirstName
                    , CASE WHEN ci.LastName IS NULL THEN ca.LastName
                                 ELSE ci.LastName
                       END AS AdminLastName
                    , CASE WHEN ci.PhoneNumber IS NULL THEN ca.PhoneNumber
                                 ELSE ci.PhoneNumber
                       END AS AdminPhoneNumber
                    , ci.FirstName AS AdminFirstName2
                    , ci.LastName AS AdminLastName2
                    , ci.PhoneNumber AS AdminPhoneNumber2
                    , ci.AccountOwnerEmail 
                     , CASE WHEN ci.MarketingProfileEmailID IS NULL THEN ci.CommunicationEmail 
                                 ELSE ci.MarketingProfileEmailID
                       END AS AdminCommunicationEmail
                    , CASE WHEN ci.Locale IS NULL THEN ca.CommunicationCulture
                                 ELSE ci.Locale
                       END AS AdminLocale
                   , ci.Locale AS AdminLocale2
                    , ci.AllowPhoneCommunications AS AdminPhonePreference
                    , ci.AllowEmailCommunications AS AdminEmailPreference
                    , 0 AS PaidUsageUSD
                    , 0 AS UsageStartDateKey
                    , 0 AS UsageEndDateKey
                    , 0 AS InvoiceDateKey
                    , 0 AS BillingMonth
                    , t.SegmentName
                    , t.SubsidiaryName
                    , CASE WHEN ci.TenantID IS NOT NULL THEN ROW_NUMBER() OVER (PARTITION BY ci.SubscriptionGUID ORDER BY ci.SubscriptionCreatedDate DESC)
                                 ELSE ROW_NUMBER() OVER (PARTITION BY t.SubscriptionGUID ORDER BY t.SubscriptionCreatedDate DESC)
                       END RNK
             FROM #SubscriptionDetails t
             LEFT JOIN PII.vwAzureContactInfo ci ON t.SubscriptionGUID = ci.SubscriptionGUID
             LEFT JOIN PII.vwCommerceAccount ca ON t.CommerceAccountID = ca.CAID
 UNION ALL

             SELECT t.TPID
                    , t.OrgName
                    , t.AreaName
                    , ci.TenantID
                    , t.CommerceAccountID
                    , t.OMSSubscriptionID
                    , t.BillableAccountID
                    , t.SubscriptionGUID
                    , t.OfferName
                    , t.OfferID
                    , t.CurrentSubscriptionStatus
                    , t.SubscriptionStartDate
                    , CASE WHEN ci.Address1 IS NULL THEN ca.AddressLine1
                                 ELSE ci.Address1
                       END AS Address1
                    , CASE WHEN ci.Address2 IS NULL THEN ca.AddressLine2
                                 ELSE ci.Address2
                       END AS Address2
                    , CASE WHEN ci.Address3 IS NULL THEN ca.AddressLine3
                                 ELSE ci.Address3
                       END AS Address3
                    , ci.City
                    , ci.State
                    , ci.PostalCode
                    , CASE WHEN ci.CountryCode IS NULL THEN ca.CountryCode
                                 ELSE ci.CountryCode
                       END AS CountryCode
                    , ci.AccountOwnerPUID AS AdminPUID
                    , CASE WHEN ci.FirstName IS NULL THEN ca.FirstName
                                 ELSE ci.FirstName
                       END AS AdminFirstName
                    , CASE WHEN ci.LastName IS NULL THEN ca.LastName
                                 ELSE ci.LastName
                       END AS AdminLastName
                    , CASE WHEN ci.PhoneNumber IS NULL THEN ca.PhoneNumber
                                 ELSE ci.PhoneNumber
                       END AS AdminPhoneNumber
                    , ci.FirstName AS AdminFirstName2
                    , ci.LastName AS AdminLastName2
                    , ci.PhoneNumber AS AdminPhoneNumber2
                    , ci.AccountOwnerEmail 
                     , CASE WHEN ci.MarketingProfileEmailID IS NULL THEN ci.CommunicationEmail 
                                 ELSE ci.MarketingProfileEmailID
                       END AS AdminCommunicationEmail
                    , CASE WHEN ci.Locale IS NULL THEN ca.CommunicationCulture
                                 ELSE ci.Locale
                       END AS AdminLocale
                    , ci.Locale AS AdminLocale2
                    , ci.AllowPhoneCommunications AS AdminPhonePreference
                    , ci.AllowEmailCommunications AS AdminEmailPreference
                    , 0 AS PaidUsageUSD
                    , 0 AS UsageStartDateKey
                    , 0 AS UsageEndDateKey
                    , 0 AS InvoiceDateKey
                    , 0 AS BillingMonth
                    , t.SegmentName
                    , t.SubsidiaryName
                    ,CASE WHEN ci.TenantID IS NOT NULL THEN ROW_NUMBER() OVER (PARTITION BY ci.SubscriptionGUID ORDER BY ci.SubscriptionCreatedDate DESC)
                                 ELSE ROW_NUMBER() OVER (PARTITION BY t.SubscriptionGUID ORDER BY t.SubscriptionCreatedDate DESC)
                       END RNK                 
             FROM #SubscriptionDetails t
             LEFT JOIN PII.vwAzureContactInfo_mooncake ci ON t.SubscriptionGUID = ci.SubscriptionGUID
             LEFT JOIN PII.vwCommerceAccount ca ON t.CommerceAccountID = ca.CAID
UNION ALL
			       
             SELECT t.TPID
                    , t.OrgName
                    , t.AreaName
                    , sa.TenantID
                    , t.CommerceAccountID
                    , t.OMSSubscriptionID
                    , t.BillableAccountID
                    , t.SubscriptionGUID
                    , t.OfferName
                    , t.OfferID
                    , t.CurrentSubscriptionStatus
                    , t.SubscriptionStartDate
                    , '' AS Address1
                    , '' AS Address2
                    , '' AS Address3
                    , sa.City
                    , sa.State
                    , sa.PostalCode
                    , CASE WHEN sa.Country IS NULL THEN ca.CountryCode
                                 ELSE sa.Country
                       END AS CountryCode
                    , sa.AdminPUID AS AdminPUID
                    , CASE WHEN sa.PrimaryFirstName IS NULL THEN ca.FirstName
                                 ELSE sa.PrimaryFirstName
                       END AS AdminFirstName
                    , CASE WHEN sa.PrimaryLastName IS NULL THEN ca.LastName
                                 ELSE sa.PrimaryLastName
                       END AS AdminLastName
                    , CASE WHEN sa.Mobile IS NULL THEN ca.PhoneNumber
                                 ELSE sa.Mobile
                       END AS AdminPhoneNumber
                    , sa.PrimaryFirstName AS AdminFirstName2
                    , sa.PrimaryLastName AS AdminLastName2
                    , sa.Mobile AS AdminPhoneNumber2
                    , sa.PrimaryEmailID AS AccountOwnerEmail 
					, CASE WHEN sa.MarketingProfileEmailID IS NULL THEN sa.UserPrincipalName
						ELSE sa.PrimaryEmailID
						END AS AdminCommunicationEmail
                    ,CASE WHEN sa.MarketingProfileLocale IS NULL THEN sa.PreferredLanguage
                                 ELSE sa.MarketingProfileLocale
                       END AS AdminLocale
                    , sa.MarketingProfileLocale AS AdminLocale2
                    ,'' AS AdminPhonePreference
                    ,'' AS AdminEmailPreference
                    , 0 AS PaidUsageUSD
                    , 0 AS UsageStartDateKey
                    , 0 AS UsageEndDateKey
                    , 0 AS InvoiceDateKey
                    , 0 AS BillingMonth
                    , t.SegmentName
                    , t.SubsidiaryName
                    , CASE WHEN sa.TenantID IS NOT NULL THEN ROW_NUMBER() OVER (PARTITION BY sa.SubscriptionGUID ORDER BY sa.SubscriptionGUID DESC)
                                 ELSE ROW_NUMBER() OVER (PARTITION BY t.SubscriptionGUID ORDER BY t.SubscriptionCreatedDate DESC)
                       END RNK
             FROM #SubscriptionDetails t
             LEFT JOIN [PII].[vwSubscriptionAdminDetails] sa ON t.SubscriptionGUID = sa.SubscriptionGUID
             LEFT JOIN PII.vwCommerceAccount ca ON t.CommerceAccountID = ca.CAID
			 WHERE sa.[AdminType] in ('Owner','Contributor')

UNION ALL

             SELECT t.TPID
                    , t.OrgName
                    , t.AreaName
                    , sra.TenantID
                    , t.CommerceAccountID
                    , t.OMSSubscriptionID
                    , t.BillableAccountID
                    , t.SubscriptionGUID
                    , t.OfferName
                    , t.OfferID
                    , t.CurrentSubscriptionStatus
                    , t.SubscriptionStartDate
                    , '' AS Address1
                    , '' AS Address2
                    , '' AS Address3
                    , sra.City
                    , sra.State
                    , sra.PostalCode
                    , CASE WHEN sra.Country IS NULL THEN ca.CountryCode
                                 ELSE sra.Country
                       END AS CountryCode
                    , sra.AdminPUID AS AdminPUID
                    , CASE WHEN sra.PrimaryFirstName IS NULL THEN ca.FirstName
                                 ELSE sra.PrimaryFirstName
                       END AS AdminFirstName
                    , CASE WHEN sra.PrimaryLastName IS NULL THEN ca.LastName
                                 ELSE sra.PrimaryLastName
                       END AS AdminLastName
                    , CASE WHEN sra.Mobile IS NULL THEN ca.PhoneNumber
                                 ELSE sra.Mobile
                       END AS AdminPhoneNumber
                    , sra.PrimaryFirstName AS AdminFirstName2
                    , sra.PrimaryLastName AS AdminLastName2
                    , sra.Mobile AS AdminPhoneNumber2
                    , sra.PrimaryEmailID AS AccountOwnerEmail 
					, CASE WHEN sra.MarketingProfileEmailID IS NULL THEN sra.UserPrincipalName
						ELSE sra.PrimaryEmailID
						END AS AdminCommunicationEmail
                    ,CASE WHEN sra.MarketingProfileLocale IS NULL THEN sra.PreferredLanguage
                                 ELSE sra.MarketingProfileLocale
                       END AS AdminLocale
                    , sra.MarketingProfileLocale AS AdminLocale2
                    ,'' AS AdminPhonePreference
                    ,'' AS AdminEmailPreference
                    , 0 AS PaidUsageUSD
                    , 0 AS UsageStartDateKey
                    , 0 AS UsageEndDateKey
                    , 0 AS InvoiceDateKey
                    , 0 AS BillingMonth
                    , t.SegmentName
                    , t.SubsidiaryName
                    , CASE WHEN sra.TenantID IS NOT NULL THEN ROW_NUMBER() OVER (PARTITION BY sra.SubscriptionGUID ORDER BY sra.SubscriptionGUID DESC)
                                 ELSE ROW_NUMBER() OVER (PARTITION BY t.SubscriptionGUID ORDER BY t.SubscriptionCreatedDate DESC)
                       END RNK
             FROM #SubscriptionDetails t
             LEFT JOIN [PII].[vwSubscriptionRoleAssignments] sra ON t.SubscriptionGUID = sra.SubscriptionGUID
             LEFT JOIN PII.vwCommerceAccount ca ON t.CommerceAccountID = ca.CAID
			 WHERE sra.[AdminType] in ('Owner','Contributor')
       ) a
             WHERE RNK = 1

			 

SELECT * from (select *,ROW_NUMBER() OVER (PARTITION BY SubscriptionGUID  ORDER BY TenantId DESC) as RNK2                                
FROM [Partner_Support].[SubscriptionDetails] ) a
where a.RNK2 = 1
ORDER BY 1, 8  ;

-- select count(distinct tpid) from #FinalSubscriptionDetails
-- select count(distinct subscriptionguid) from #FinalSubscriptionDetails -- 41651
-- select subscriptionguid from #FinalSubscriptionDetails group by subscriptionguid having count(*) > 1 



/** Admin Details **/

WITH admins as
(
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
                      --, sad.SubscriptionName
FROM [Partner_Support].[SubscriptionDetails] t
LEFT JOIN PII.vwSubscriptionAdminDetails sad ON t.SubscriptionGUID = sad.SubscriptionGUID 
LEFT JOIN PII.vwAzureContactInfo ci ON sad.SubscriptionGUID = ci.SubscriptionGUID AND sad.AdminPUID = ci.AccountOwnerPUID
WHERE sad.AdminState = 'Enabled'
--AND sad.PrimaryEmailID IS NOT NULL
AND sad.AdminType IS NOT NULL
--AND t.TenantID IS NOT NULL

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
FROM [Partner_Support].[SubscriptionDetails] t
JOIN PII.vwSubscriptionRoleAssignments sra ON t.SubscriptionGUID = sra.SubscriptionGUID 
WHERE sra.AdminType = 'Owner' 
--AND sra.PrimaryEmailID IS NOT NULL
)
SELECT * FROM admins WHERE PrimaryEmailID IS NOT NULL ORDER BY 1, 2  

/** TPID Details **/
--SELECT DISTINCT TPID
--     , SubscriptionGUID,*
--     --, '' AS [CSM Manager Alias]
--FROM #FinalSubscriptionDetails s
--ORDER BY 1, 2

SELECT  DISTINCT TPID
       , SubscriptionGUID
                                 
FROM [Partner_Support].[SubscriptionDetails]