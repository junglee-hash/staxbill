CREATE TYPE [dbo].[NetsuiteErrorLogList] AS TABLE (
    [EntityTypeId]          INT            NOT NULL,
    [EntityId]              BIGINT         NOT NULL,
    [NetsuiteErrorReasonId] TINYINT        NOT NULL,
    [LastErrorReason]       NVARCHAR (255) NOT NULL,
    [CreatedTimestamp]      DATETIME       NOT NULL,
    [ModifiedTimestamp]     DATETIME       NOT NULL,
    [AccountId]             BIGINT         NOT NULL);


GO

