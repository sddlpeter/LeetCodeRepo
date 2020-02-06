/****** Object:  Table [Partner_Support].[SubscriptionDetails]    Script Date: 2/5/2020 7:04:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Partner_Support].[SubscriptionDetails]
(
	[TPID] [int] NULL,
	[OrgName] [nvarchar](1000) NULL,
	[AreaName] [varchar](70) NULL,
	[TenantID] [uniqueidentifier] NULL,
	[CommerceAccountID] [varchar](50) NULL,
	[OMSSubscriptionID] [varchar](50) NULL,
	[SubscriptionGUID] [uniqueidentifier] NULL,
	[OfferName] [varchar](500) NULL,
	[OfferID] [varchar](50) NULL,
	[CurrentSubscriptionStatus] [varchar](50) NULL,
	[SubscriptionStartDate] [datetime] NULL,
	[Address1] [nvarchar](512) NULL,
	[Address2] [nvarchar](512) NULL,
	[Address3] [nvarchar](512) NULL,
	[City] [nvarchar](128) NULL,
	[State] [nvarchar](128) NULL,
	[PostalCode] [nvarchar](64) NULL,
	[CountryCode] [nchar](20) NULL,
	[AdminPUID] [nvarchar](200) NULL,
	[AdminFirstName] [nvarchar](64) NULL,
	[AdminLastName] [nvarchar](64) NULL,
	[AdminPhoneNumber] [nvarchar](200) NULL,
	[AccountOwnerEmail] [nvarchar](500) NULL,
	[AdminCommunicationEmail] [nvarchar](129) NULL,
	[AdminLocale] [nvarchar](32) NULL,
	[AdminPhonePreference] [bit] NULL,
	[AdminEmailPreference] [bit] NULL,
	[PaidUsageUSD] [decimal](38, 6) NULL,
	[UsageStartDateKey] [int] NULL,
	[UsageEndDateKey] [int] NULL,
	[InvoiceDateKey] [int] NULL,
	[BillingMonth] [int] NULL,
	[SegmentName] [varchar](80) NULL,
	[SubsidiaryName] [varchar](80) NULL,
	[ProcessedDate] [datetime] NULL,
	[BillableAccountID] [bigint] NULL,
	[Source] [varchar](15) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [SubscriptionGUID] ),
	HEAP
)
GO


