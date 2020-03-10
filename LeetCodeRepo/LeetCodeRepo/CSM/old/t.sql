SELECT DISTINCT cast(t.TPID  as int) as TPID
			  , cast(t.SubscriptionGUID as UNIQUEIDENTIFIER) as SubscriptionGUID
			  , cast(sra.TenantID as UNIQUEIDENTIFIER) as TenantID
			  , cast(sra.AdminPUID as nvarchar(512)) as AdminPUID
			  , cast(CASE WHEN sra.PrimaryEmailID IS NULL AND t.AdminPUID = sra.AdminPUID THEN t.AccountOwnerEmail
					 ELSE sra.PrimaryEmailID
				END as nvarchar(8000)) as PrimaryEmailID
			  , cast(CASE WHEN sra.PrimaryFirstName IS NULL AND t.AdminPUID = sra.AdminPUID THEN t.AdminFirstName
					 ELSE sra.PrimaryFirstName
				END as nvarchar(512)) as PrimaryFirstName
			  , cast(CASE WHEN sra.PrimaryLastName IS NULL AND t.AdminPUID = sra.AdminPUID THEN t.AdminLastName
					 ELSE sra.PrimaryLastName
				END as nvarchar(512)) as PrimaryLastName
			  , cast(CASE WHEN sra.TelephoneNumber IS NULL AND t.AdminPUID = sra.AdminPUID THEN t.AdminPhoneNumber
					 ELSE sra.TelephoneNumber
				END as nvarchar(400)) as TelephoneNumber
			  , cast(CASE WHEN sra.PreferredLanguage IS NULL AND t.AdminPUID = sra.AdminPUID THEN t.AdminLocale
					 ELSE sra.PreferredLanguage
				END as nvarchar(200)) as PreferredLanguage
			  , cast(sra.AdminType as nvarchar(200)) as AdminType
			  , cast(t.CommerceAccountID as nvarchar(100)) as CommerceAccountID
			  , '2020-02-12 06:43:54.907' AS ProcessedDate
FROM Partner_Support.SubscriptionDetails t
JOIN PII.vwSubscriptionRoleAssignments sra ON t.SubscriptionGUID = sra.SubscriptionGUID 
WHERE sra.AdminType IN ('Owner')
ORDER BY 1, 2