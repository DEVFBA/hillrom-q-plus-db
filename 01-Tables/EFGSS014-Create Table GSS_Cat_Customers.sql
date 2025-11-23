USE [DBQS]
GO

/****** Object:  Table [dbo].[GSS_Cat_Customers]    Script Date: 9/18/2025 9:48:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GSS_Cat_Customers](
	[Id_Customer] [int] NOT NULL,
	[Id_Country] [varchar](10) NOT NULL,
	[Id_Customer_Type] [varchar](10) NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[Number_JDE] [numeric](18, 0) NULL,
	[Address_Street] [varchar](100) NULL,
	[Address_Int] [varchar](30) NULL,
	[Address_Ext] [varchar](30) NULL,
	[Address_State] [varchar](50) NULL,
	[Address_ZipCode] [varchar](12) NULL,
	[Address_City] [varchar](50) NULL,
	[Address_County] [varchar](50) NULL,
	[Email] [varchar](50) NOT NULL,
	[Contact] [varchar](100) NOT NULL,
	[Status] [bit] NOT NULL,
	[Modify_By] [varchar](50) NOT NULL,
	[Modify_Date] [datetime] NOT NULL,
	[Modify_IP] [varchar](20) NOT NULL,
	[Phone_Number] [varchar](30) NULL,
 CONSTRAINT [PK_GSS_CAT_CUSTOMERS] PRIMARY KEY NONCLUSTERED 
(
	[Id_Customer_Type] ASC,
	[Id_Country] ASC,
	[Id_Customer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[GSS_Cat_Customers]  WITH CHECK ADD  CONSTRAINT [FK_GSS_CAT_CUST_FK_COUNTR_CAT_COUN] FOREIGN KEY([Id_Country])
REFERENCES [dbo].[Cat_Countries] ([Id_Country])
GO

ALTER TABLE [dbo].[GSS_Cat_Customers] CHECK CONSTRAINT [FK_GSS_CAT_CUST_FK_COUNTR_CAT_COUN]
GO


