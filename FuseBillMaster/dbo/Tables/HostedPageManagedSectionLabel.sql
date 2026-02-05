CREATE TABLE [dbo].[HostedPageManagedSectionLabel] (
    [Id]                          BIGINT        NOT NULL,
    [ProfileEditButton]           NVARCHAR (50) NOT NULL,
    [ProfileChangePasswordButton] NVARCHAR (50) NULL,
    [ProfileSaveButton]           NVARCHAR (25) NOT NULL,
    [ProfileCancelButton]         NVARCHAR (25) NOT NULL,
    [ProfileBackButton]           NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_HostedPageManagedSectionLabel] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_HostedPageManagedSectionLabel_HostedPageManagedSelfServicePortal] FOREIGN KEY ([Id]) REFERENCES [dbo].[HostedPageManagedSelfServicePortal] ([Id])
);


GO

