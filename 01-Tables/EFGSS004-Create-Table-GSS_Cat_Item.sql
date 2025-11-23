USE [DBQS]
GO

/****** Object:  Table [dbo].[GSS_Cat_Item]    Script Date: 10/31/2025 5:42:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GSS_Cat_Item](
	[Id_Item] [varchar](50) NOT NULL,
	[Id_Country] [varchar](10) NOT NULL,
	[Id_Item_Class] [varchar](10) NOT NULL,
	[Id_Item_SubClass] [varchar](10) NOT NULL,
	[Id_Discount_Category] [varchar](10) NOT NULL,
	[Id_Country_Package] [varchar](10) NULL,
	[Id_Item_Related] [varchar](50) NULL,
	[Short_Desc] [varchar](50) NOT NULL,
	[Long_Desc] [varchar](255) NOT NULL,
	[Model] [varchar](100) NULL,
	[Specifications] [varchar](1000) NULL,
	[Weight] [varchar](50) NULL,
	[Measurements] [varchar](50) NULL,
	[Image_Path] [varchar](255) NULL,
	[Status] [bit] NOT NULL,
	[Item_SPR] [varchar](50) NULL,
	[Modify_By] [varchar](50) NOT NULL,
	[Modify_Date] [datetime] NOT NULL,
	[Modify_IP] [varchar](20) NOT NULL,
 CONSTRAINT [PK_GSS_CAT_ITEM] PRIMARY KEY NONCLUSTERED 
(
	[Id_Item] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Cat_Item]  WITH CHECK ADD  CONSTRAINT [FK_GSS_CAT_ITEM_FK_CATCOU_CAT_COUN] FOREIGN KEY([Id_Country_Package])
REFERENCES [dbo].[Cat_Countries] ([Id_Country])
GO

ALTER TABLE [dbo].[Cat_Item] CHECK CONSTRAINT [FK_GSS_CAT_ITEM_FK_CATCOU_CAT_COUN]
GO

ALTER TABLE [dbo].[Cat_Item]  WITH CHECK ADD  CONSTRAINT [FK_GSS_CAT_ITEM_FK_CATDIS_CAT_DISC] FOREIGN KEY([Id_Discount_Category])
REFERENCES [dbo].[Cat_Discount_Categories] ([Id_Discount_Category])
GO

ALTER TABLE [dbo].[Cat_Item] CHECK CONSTRAINT [FK_GSS_CAT_ITEM_FK_CATDIS_CAT_DISC]
GO

ALTER TABLE [dbo].[Cat_Item]  WITH CHECK ADD  CONSTRAINT [FK_GSS_CAT_ITEM_FK_CATITE_CAT_ITEM] FOREIGN KEY([Id_Item_Class], [Id_Item_SubClass])
REFERENCES [dbo].[Cat_Item_SubClasses] ([Id_Item_Class], [Id_Item_SubClass])
GO

ALTER TABLE [dbo].[Cat_Item] CHECK CONSTRAINT [FK_GSS_CAT_ITEM_FK_CATITE_CAT_ITEM]
GO

ALTER TABLE [dbo].[Cat_Item]  WITH CHECK ADD  CONSTRAINT [FK_GSS_CAT_ITEM_FK_COUNTR_CAT_COUN] FOREIGN KEY([Id_Country])
REFERENCES [dbo].[Cat_Countries] ([Id_Country])
GO

ALTER TABLE [dbo].[Cat_Item] CHECK CONSTRAINT [FK_GSS_CAT_ITEM_FK_COUNTR_CAT_COUN]
GO

