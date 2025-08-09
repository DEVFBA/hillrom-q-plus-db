USE [DBQS]
GO

/* ==================================================================================*/
-- UDT_Quotation_Header -- EFPSLI011
/* ==================================================================================*/
PRINT 'Crea UDT_Quotation_Header' 
IF type_id('[dbo].[UDT_Quotation_Header]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Quotation_Header]
GO

CREATE TYPE [dbo].[UDT_Quotation_Header] AS TABLE(
	Folio						int NOT NULL,
	[Version]					smallint NOT NULL,
	Id_Header					bigint NOT NULL,
	Item_Template				varchar(50) NOT NULL,
	Discount					float NOT NULL,
	Quantity					smallint NOT NULL,
	Allocation					float NOT NULL,
	Transfer_Price				float NOT NULL,
	Transport_Cost				float NOT NULL,
	Taxes						float NOT NULL,
	Landed_Cost					float NOT NULL,
	Local_Transport				float NOT NULL,
	[Services]					float NOT NULL,
	Warehousing					float NOT NULL,
	Local_Cost					float NOT NULL,
	Final_Price					float NOT NULL,
	Margin						float NOT NULL,
	Total						float NOT NULL,
	Amount_Warranty				float NULL,
	Id_Year_Warranty			smallint NULL,
	Percentage_Warranty			float NULL,
	Cost_Percentage_Warranty	float NULL,
	Cost_Amount_Warranty		float NULL,
	Margin_Warranty				float NULL,
	General_Taxes_Percentage	float NULL,
	General_Taxes_Total			float NULL,
	General_Taxes_Warranty		float NULL,
	Grand_Total					float NULL,
	Item_SPR					varchar(50) NULL,
	Id_Installation_Charge		varchar(10) NULL,
	Installation_Charges_Price	float		NULL,
	Modify_By					varchar(50) NULL,
	Modify_Date					datetime NULL,
	Modify_IP					varchar(20) NULL
)
GO

