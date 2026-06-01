USE [DBQS]
GO

/****** Object:  Table [dbo].[GSS_Cat_Quotation_Commercial_Policies]    Script Date: 5/1/2026 9:55:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GSS_Cat_Quotation_Commercial_Policies](
	[Id_Country] [varchar](10) NOT NULL,
	[Id_Sales_Type] [varchar](10) NOT NULL,
	[Id_Incoterm] [varchar](10) NOT NULL,
	[Id_Currency] [varchar](10) NOT NULL,
	[Status] [bit] NOT NULL,
	[Modify_By] [varchar](50) NOT NULL,
	[Modify_Date] [datetime] NOT NULL,
	[Modify_IP] [varchar](20) NOT NULL,
 CONSTRAINT [PK_GSS_CAT_QUOTATION_COMMERCIAL_PO] PRIMARY KEY NONCLUSTERED 
(
	[Id_Currency] ASC,
	[Id_Sales_Type] ASC,
	[Id_Incoterm] ASC,
	[Id_Country] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[GSS_Cat_Quotation_Commercial_Policies]  WITH CHECK ADD  CONSTRAINT [FK_GSS_Countries_ContrIesSalesType] FOREIGN KEY([Id_Country])
REFERENCES [dbo].[Cat_Countries] ([Id_Country])
GO

ALTER TABLE [dbo].[GSS_Cat_Quotation_Commercial_Policies] CHECK CONSTRAINT [FK_GSS_Countries_ContrIesSalesType]
GO


