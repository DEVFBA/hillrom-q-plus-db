USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_ACCUMAX
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_ACCUMAX'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_ACCUMAX]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_ACCUMAX
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_ACCUMAX
Date:		12/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_ACCUMAX


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_ACCUMAX
AS

/*****************************************************************************/
-- QUERY 1 - Surfaces AD (Careassist, HR900, AVG1600, Centuris)
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'ACCUMAX',
	Item_Long_Desc = Item_Long_Desc,
	Size = Measurements,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('ACCE')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass IN ('ACCUMSURFA')
	AND Id_Item LIKE 'PAH%'
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = Surfaces IS (Versacare)
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'ACCUMAX',
	Item_Long_Desc = Item_Long_Desc,
	Size = Measurements,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('ACCE')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass IN ('ACCUMSURFA')
	AND Id_Item LIKE 'PAF%'
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 3 -  SUBCLASS = Surfaces TC (Totalcare)
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'ACCUMAX',
	Item_Long_Desc = Item_Long_Desc,
	Size = Measurements,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('ACCE')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass IN ('ACCUMSURFA')
	AND Id_Item LIKE 'PAU%'
ORDER BY Id_Item
