CREATE TABLE [dbo].[HostedPageManagedSectionProfile] (
    [Id]                                   BIGINT         IDENTITY (1, 1) NOT NULL,
    [HostedPageManagedSelfServicePortalId] BIGINT         NOT NULL,
    [CustomerInformationFieldId]           BIGINT         NOT NULL,
    [Label]                                NVARCHAR (100) NOT NULL,
    [Visible]                              BIT            NOT NULL,
    [Required]                             BIT            NOT NULL,
    [DefaultValue]                         NVARCHAR (255) NULL,
    CONSTRAINT [PK_HostedPageManagedSectionProfile] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_HostedPageManagedSectionProfile_CustomerInformationField] FOREIGN KEY ([CustomerInformationFieldId]) REFERENCES [Lookup].[CustomerInformationField] ([Id]),
    CONSTRAINT [FK_HostedPageManagedSectionProfile_HostedPageManagedSelfServicePortal] FOREIGN KEY ([HostedPageManagedSelfServicePortalId]) REFERENCES [dbo].[HostedPageManagedSelfServicePortal] ([Id])
);


GO

