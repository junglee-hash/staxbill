CREATE TABLE [dbo].[DefaultTxtTemplate] (
    [Id]                  BIGINT         NOT NULL,
    [TxtTypeId]           INT            NOT NULL,
    [FriendlyName]        VARCHAR (50)   NOT NULL,
    [TxtBody]             NVARCHAR (500) NOT NULL,
    [EnabledDefault]      BIT            CONSTRAINT [DF_EnabledDefault] DEFAULT ((1)) NOT NULL,
    [FriendlyDescription] VARCHAR (255)  NOT NULL,
    CONSTRAINT [PK_DefaultTxtTemplate] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DefaultTxtTemplate_TxtType] FOREIGN KEY ([TxtTypeId]) REFERENCES [Lookup].[TxtType] ([Id])
);


GO

