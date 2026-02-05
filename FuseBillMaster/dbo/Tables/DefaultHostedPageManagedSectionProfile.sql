CREATE TABLE [dbo].[DefaultHostedPageManagedSectionProfile] (
    [Id]         BIGINT         NOT NULL,
    [FieldValue] NVARCHAR (100) NOT NULL,
    [Visible]    BIT            NOT NULL,
    [Required]   BIT            NOT NULL,
    CONSTRAINT [PK_DefaultHostedPageManagedSectionProfile] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_DefaultHostedPageManagedSectionProfile_CustomerInformationField] FOREIGN KEY ([Id]) REFERENCES [Lookup].[CustomerInformationField] ([Id])
);


GO

