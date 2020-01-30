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
ORDER BY 1, 2