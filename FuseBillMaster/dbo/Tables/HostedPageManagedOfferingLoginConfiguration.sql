CREATE TABLE [dbo].[HostedPageManagedOfferingLoginConfiguration] (
    [Id]                 BIGINT         NOT NULL,
    [LoginButtonVisible] BIT            CONSTRAINT [DF_LoginButtonVisible] DEFAULT ((0)) NOT NULL,
    [LoginButtonLabel]   NVARCHAR (100) NOT NULL,
    [LoginLinkLabel]     NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_HostedPageManagedOfferingLoginConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedOfferingLoginConfiguration_HostedPageManagedOffering] FOREIGN KEY ([Id]) REFERENCES [dbo].[HostedPageManagedOffering] ([Id]) ON DELETE CASCADE
);


GO

