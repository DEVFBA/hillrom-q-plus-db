USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_MANUALAIDS
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_MANUALAIDS'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_MANUALAIDS]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_MANUALAIDS
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_MANUALAIDS
Date:		12/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_MANUALAIDS @pvIdZone = 'LIKMEX'


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_MANUALAIDS
@pvIdZone	Varchar(10)
AS

/*****************************************************************************/
-- QUERY 1 - Accesorios ‘HandyTube - Short’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'ACCE'
	AND Id_Item_SubClass IN ('MANUALAIDS')
	AND Item_Long_Desc LIKE 'HandyTube Short%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 2 - Accesorios ‘HandyTube - Long’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'ACCE'
	AND Id_Item_SubClass IN ('MANUALAIDS')
	AND Item_Long_Desc LIKE 'HandyTube Long%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 3 - Accesorios ‘HandyTube - Wide’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'ACCE'
	AND Id_Item_SubClass IN ('MANUALAIDS')
	AND Item_Long_Desc LIKE 'HandyTube Wide%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 4 - Accesorios ‘HANDYSHEET™ - HandySheet Short’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'ACCE'
	AND Id_Item_SubClass IN ('MANUALAIDS')
	AND Item_Long_Desc LIKE 'HandySheet%'
	AND Id_Item IN ('3715015-10', '3715017-10', '3716015-10')
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 5 - Accesorios ‘HANDYSHEET™ - HandySheet Long’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'ACCE'
	AND Id_Item_SubClass IN ('MANUALAIDS')
	AND Item_Long_Desc LIKE 'HandySheet%'
	AND Id_Item IN ('3716017-10')
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 6 - Accesorios ‘HANDYSHEET™ - FixStrap’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'ACCE'
	AND Id_Item_SubClass IN ('MANUALAIDS')
	AND Item_Long_Desc LIKE 'FixStrap%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 7 - Accesorios ‘HANDYBELT™’
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'ACCE'
	AND Id_Item_SubClass IN ('MANUALAIDS')
	AND Item_Model = 'HandyBelt'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC