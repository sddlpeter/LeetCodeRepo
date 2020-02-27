
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

-- UPDATE Partner_Support.AdHocSubscription 
-- SET UploadedToSC = 0
-- FROM #tmpNotUploadToSC t
-- WHERE t.SubscriptionGUID = Partner_Support.AdHocSubscription.SubscriptionGUID