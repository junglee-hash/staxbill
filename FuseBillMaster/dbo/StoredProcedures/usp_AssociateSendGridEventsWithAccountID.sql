CREATE   PROCEDURE [dbo].[usp_AssociateSendGridEventsWithAccountID]
	@BatchSize BIGINT
	,@DaysBack INT = 10000
AS

BEGIN TRY

BEGIN TRANSACTION

	--STEP 1: find the send grid events that need to be linked to the account
	SELECT TOP (@BatchSize) 
		sge.Id, 
		c.AccountId, 
		cel.Id AS CustomerEmailLogId, 
		sge.[Event], 
		sge.SendgridTimestamp,
		sge.Attempt,
		sge.Reason,
		--sometimes send grid events (which we get via webhook) don't have anything in the email field. Unclear as to why
		COALESCE(sge.Email, cel.ToEmail) AS Email
	INTO #BatchOfNewSendGridEvents
	FROM SendgridEvents sge
	INNER JOIN CustomerEmailLog cel ON cel.SendgridEmailId = sge.SendgridEmailId
	INNER JOIN Customer c ON c.Id = cel.customerId	
	WHERE 
	--Using SendgridTimestamp for filter as it is supported by an index in production
	sge.SendgridTimestamp >= DATEADD(DAY,-@DaysBack,GETUTCDATE()) AND
	(sge.AccountId IS NULL
	OR sge.CustomerEmailLogId IS NULL)
	ORDER BY sge.CreatedTimestamp ASC

	--STEP 2: Update the events account IDs and Customer Email Log IDs
	UPDATE SendgridEvents
	SET 
		AccountId = #BatchOfNewSendGridEvents.AccountId,
		CustomerEmailLogId = #BatchOfNewSendGridEvents.CustomerEmailLogId
	FROM SendgridEvents 
	INNER JOIN #BatchOfNewSendGridEvents ON #BatchOfNewSendGridEvents.Id = SendGridEvents.Id

	--STEP 3: Now we need to get information to populate the customer email event summary table,
	--which means we need to find the first timestamp from the batch for each email's open, delivered, and processed events

	SELECT 
		MIN(SendGridTimestamp) AS MostRecentTimestamp,  
		customerEmailLogId,
		Email,
		[Event]
	INTO #FirstTimestamps 
	FROM #BatchOfNewSendGridEvents 
	WHERE 
	[Event] IN ('delivered','open','processed') 
	AND Email IS NOT NULL
	GROUP BY CustomerEmailLogId, Email, [Event]

	--STEP 4: for the customer email event summary table we also care about the most recent event, regardless
	--of whether the event is delivered/open/processed:

	SELECT
		q.*,
		bonsge.AccountId,
		bonsge.[Event] AS DeliveryResult,
		bonsge.Attempt,
		bonsge.Reason,
		bonsge.Id AS SendGridId
	INTO #LatestEventData
	FROM #BatchOfNewSendGridEvents bonsge
	INNER JOIN
		(
		SELECT 
			CustomerEmailLogId,
			Email,
			MAX(SendgridTimestamp) AS LatestTimestamp 
		FROM #BatchOfNewSendGridEvents
		GROUP BY customerEmailLogId, Email
		) q ON q.CustomerEmailLogId = bonsge.CustomerEmailLogId
	AND q.Email = bonsge.Email
	AND q.LatestTimestamp = bonsge.SendgridTimestamp

	--STEP 5: we need to flatten the data for the merge in step 6.
	--FlattenedEmailData should have one row per customerEmailLogId/Email pairing from the batch
	--we need to do a union between a pivot on opened/delivered/processed and the set of data
	--we have for the other types of events

	SELECT 
		q.customerEmailLogId,
		q.Email,
		[open],
		[delivered],
		[processed],
		bonsge.AccountId,
		bonsge.Attempt,
		bonsge.Reason,
		bonsge.[Event] AS DeliveryResult,	
		q.SendGridId, 
		LatestTimestamp INTO #FlattenedEmailData FROM
		( SELECT 
			CustomerEmailLogId,
			Email,
			[open],
			[delivered],
			[processed],
			--in the unlikely event that two send grid events for the same customer email log and address share a timestamp, 
			--pick one arbitrarily to avoid duplicates which will error out the merge:
			MAX(SendGridId) AS SendGridId, 
			LatestTimestamp
			FROM
			(
				--first half of the union: data for opened/processed/deliverd
				SELECT 
					pvt.customerEmailLogId,
					pvt.Email,
					[open],
					[delivered],
					[processed],
					SendGridId,
					LatestTimestamp
				FROM #FirstTimestamps
				PIVOT (
					MIN(MostRecentTimestamp)
					FOR [Event] IN ([delivered],[open],[processed]) 
				) AS pvt
				INNER JOIN #LatestEventData lee ON lee.CustomerEmailLogId = pvt.CustomerEmailLogId and lee.Email = pvt.Email

				UNION

				--second half of the union: data for the other event types
				SELECT
					otherEvents.CustomerEmailLogId,
					otherEvents.Email,
					NULL AS [open],
					NULL AS [delivered],
					NULL AS [processed],
					SendGridId, 
					LatestTimestamp
				FROM #LatestEventData otherEvents
				LEFT JOIN #FirstTimestamps ft on ft.CustomerEmailLogId = otherEvents.CustomerEmailLogId and ft.Email = otherEvents.Email
				WHERE ft.[Event] IS NULL --this gets us the data for other events like 'bounce' and 'dropped', because there won't be a match on lee
			) AS u 
			GROUP BY
			CustomerEmailLogId,
			Email,
			[open],
			[delivered],
			[processed],
			[LatestTimestamp] 
		) AS q
		INNER JOIN #BatchOfNewSendGridEvents bonsge on bonsge.Id = q.SendGridId

		SELECT 
		bonsge.SendgridTimestamp,
		bonsge.Email,
		bonsge.CustomerEmailLogId,
		count(1) as duplication 
		INTO #doubledUpEvents from #BatchOfNewSendGridEvents bonsge
		GROUP BY bonsge.SendgridTimestamp, bonsge.Email, bonsge.CustomerEmailLogId
		HAVING count(1) > 1

		SELECT
		bonsge.SendgridTimestamp,
		bonsge.Email,
		bonsge.CustomerEmailLogId,
		MAX(bonsge.Id) as SendGridId
		INTO #nonProcessedEventsForDoubledUpEvents
		FROM #doubledUpEvents due 
		INNER JOIN #BatchOfNewSendGridEvents bonsge
		on bonsge.SendGridTimestamp = due.SendgridTimestamp
		AND bonsge.Email = due.Email
		AND bonsge.CustomerEmailLogId = due.CustomerEmailLogId
		WHERE [Event] = 'processed'
		GROUP BY bonsge.SendgridTimestamp, bonsge.Email, bonsge.CustomerEmailLogId

		UPDATE #FlattenedEmailData 
		SET DeliveryResult = bofnsge.[Event],
		[SendGridId] = npefdue.SendGridId
		FROM #FlattenedEmailData fed
		INNER JOIN #nonProcessedEventsForDoubledUpEvents npefdue on npefdue.SendgridTimestamp = fed.LatestTimestamp
		AND npefdue.Email = fed.Email
		AND npefdue.CustomerEmailLogId = fed.CustomerEmailLogId
		INNER JOIN #BatchOfNewSendGridEvents bofnsge on npefdue.SendGridId = fed.SendGridId
		--#BatchOfNewSendGridEvents includes the processed event so filter it out so that we do not set it again
		WHERE bofnsge.[Event] <> 'processed'

	--STEP 6: now that we have the flattened table, we need to upsert the info to the customer email event summary table
	--Inserts are simple, but for updates we need to ensure that the timestamps are always the lower timestamp
	--for opening, processing, and delivery while making sure the last update timestamp and latest event are the most recent


	MERGE dbo.CustomerEmailEventSummary AS [Target]
	USING #FlattenedEmailData AS [Source]
	ON [Source].Email = [Target].ToEmail
		AND [Source].CustomerEmailLogId = [Target].CustomerEmailLogId

		WHEN NOT MATCHED BY TARGET THEN
			INSERT(
				CustomerEmailLogId, 
				ToEmail, 
				ProcessedTimestamp, 
				DeliveredTimestamp, 
				OpenedTimestamp, 
				LatestSendGridEventId, 
				LastUpdatedTimestamp,
				DeliveryResult,
				Attempt,
				Reason,
				AccountId)
			VALUES(
				[Source].CustomerEmailLogId, 
				[Source].Email, 
				[Source].[processed], 
				[Source].[delivered], 
				[Source].[open], 
				[Source].[SendGridId], 
				[Source].[LatestTimestamp],
				[Source].DeliveryResult,
				[Source].Attempt,
				[Source].Reason,
				[Source].AccountId)
		WHEN MATCHED THEN UPDATE SET
			[Target].ProcessedTimestamp = CASE WHEN ( [Target].ProcessedTimestamp < [Source].[processed] OR [Source].[processed] IS NULL)
												THEN [Target].ProcessedTimestamp
												ELSE [Source].[processed]
												END,
			[Target].DeliveredTimestamp = CASE WHEN ( [Target].DeliveredTimestamp < [Source].[delivered] OR [Source].[delivered] IS NULL)
												THEN [Target].DeliveredTimestamp
												ELSE [Source].[delivered]
												END,
			[Target].OpenedTimestamp = CASE WHEN ( [Target].OpenedTimestamp < [Source].[open] OR [Source].[open] IS NULL)
												THEN [Target].OpenedTimestamp
												ELSE [Source].[open]
												END,
			[Target].LatestSendGridEventId = CASE 
													WHEN ([Target].LastUpdatedTimestamp > [Source].[LatestTimestamp]) 
													THEN [Target].LatestSendGridEventId 
													ELSE [Source].[SendGridId]
											 END,
			[Target].LastUpdatedTimestamp =  CASE 
													WHEN ([Target].LastUpdatedTimestamp > [Source].[LatestTimestamp]) 
													THEN [Target].LastUpdatedTimestamp
													ELSE [Source].[LatestTimestamp]
											 END,
			[Target].DeliveryResult =		 CASE 
													WHEN ([Target].LastUpdatedTimestamp > [Source].[LatestTimestamp]) 
													THEN [Target].DeliveryResult
													ELSE [Source].DeliveryResult
											 END,
			[Target].Attempt =				 CASE 
													WHEN ([Target].LastUpdatedTimestamp > [Source].[LatestTimestamp]) 
													THEN [Target].Attempt
													ELSE [Source].Attempt
											 END,
			[Target].Reason =				 CASE 
													WHEN ([Target].LastUpdatedTimestamp > [Source].[LatestTimestamp]) 
													THEN [Target].Reason
													ELSE [Source].Reason
											 END,
			[Target].AccountId = [Source].AccountId;

	DROP TABLE #doubledUpEvents
	DROP TABLE #nonProcessedEventsForDoubledUpEvents
	DROP TABLE #FirstTimestamps
	DROP TABLE #BatchOfNewSendGridEvents
	DROP TABLE #FlattenedEmailData
	DROP TABLE #LatestEventData

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF (@@TRANCOUNT > 0)
		ROLLBACK TRAN;
	THROW;
END CATCH

GO

