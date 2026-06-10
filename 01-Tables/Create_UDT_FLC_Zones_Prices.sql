USE [DBQS]
GO

/****** Object:  UserDefinedTableType [dbo].[UDT_FLC_Zones_Prices]    Script Date: 6/9/2026 6:40:31 AM ******/
CREATE TYPE [dbo].[UDT_FLC_Zones_Prices] AS TABLE(
	[Id_Item] [varchar](50) NOT NULL,
	[Id_Region] [varchar](10) NOT NULL,
	[Id_Zone] [varchar](10) NOT NULL,
	[Price] Float
)
GO