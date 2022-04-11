USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_SLINGCHILDREN
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_SLINGCHILDREN'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_SLINGCHILDREN]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_SLINGCHILDREN
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_SLINGCHILDREN
Date:		12/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_SLINGCHILDREN @pvIdZone = 'LIKMEX'


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_SLINGCHILDREN
@pvIdZone	Varchar(10)
AS

/*****************************************************************************/
-- QUERY 1 - Accesorios ‘LIKO ORIGINAL HIGHBACK SLING™, MOD 200’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass = 'SLINGCHILD'
	AND Item LIKE 'Liko Original HighBack Sling, Mod. 200%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 2 - Accesorios ‘LIKO SILHOUETTESLING™, MOD 22’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass = 'SLINGCHILD'
	AND Item LIKE 'Liko SilhouetteSling, Mod. 22%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 3 - Accesorios ‘TEDDY HYGIENESLING™/ LIKO HYGIENESLING™, MOD 41’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass = 'SLINGCHILD'
	AND Item LIKE 'Teddy HygieneSling / Liko HygieneSling, Mod. 41%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 4 - Accesorios ‘TEDDY HYGIENEVEST HIGHBACK™/ LIKO HYGIENEVEST HIGHBACK™, MOD 55’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass = 'SLINGCHILD'
	AND Item LIKE 'Teddy HygieneVest HighBack / Liko HygieneVest High%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 5 - Accesorios ‘TEDDYVEST™/ LIKO MASTERVEST™, MOD 60’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass = 'SLINGCHILD'
	AND Item LIKE 'TeddyVest / Liko MasterVest, Mod. 60%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 6 - Accesorios ‘LEG HARNESS MASTERVEST, MOD 66’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass = 'SLINGCHILD'
	AND Item LIKE 'Leg Harness MasterVest, Mod. 66%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC
