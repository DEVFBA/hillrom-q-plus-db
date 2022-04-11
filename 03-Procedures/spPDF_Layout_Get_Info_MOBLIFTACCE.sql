USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_MOBLIFTACCE
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_MOBLIFTACCE'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_MOBLIFTACCE]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_MOBLIFTACCE
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_MOBLIFTACCE
Date:		12/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_MOBLIFTACCE @pvIdZone = 'LIKMEX'


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_MOBLIFTACCE
@pvIdZone	Varchar(10)
AS

/*****************************************************************************/
-- QUERY 1 - Accessories ‘Charger for Extra Battery’
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'MOBLIFTACC'
	AND Item_Long_Desc LIKE 'Charger for Extra Battery%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 2 -  Accessories ‘Wall Mounted Battery’
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'MOBLIFTACC'
	AND Item_Long_Desc LIKE 'Wall Mounted Battery%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 3 -  Accesorios ‘Extra Battery Box’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'MOBLIFTACC'
	AND Item_Long_Desc LIKE 'Extra Battery Box%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 4 - Accesorios ‘Cord for Hand Control’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'MOBLIFTACC'
	AND Item_Long_Desc LIKE 'Cord for HandControl%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 5 - Accesorios ‘Extension Cable
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'MOBLIFTACC'
	AND Item_Long_Desc LIKE 'Extension Cable%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 6 - Accesorios ‘Wheel Set 100/100’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'MOBLIFTACC'
	AND Item_Long_Desc LIKE 'Wheel Set 100/100%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 7 - Accesorios ‘Wheel Set 100/75’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'MOBLIFTACC'
	AND Item_Long_Desc LIKE 'Wheel Set 100/75%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 8 - Accesorios Holder for Charging Cable’
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'MOBLIFTACC'
	AND Item_Long_Desc LIKE 'Holder for Charging Cable%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC
/*****************************************************************************/
-- QUERY 9 - Accesorios ‘Leg Protector’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'MOBLIFTACC'
	AND Item_Long_Desc LIKE 'Leg Protector%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 10 - Accesorios ‘Lever for Base Width Adjustment’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'ACCE'
	AND Id_Item_SubClass = 'MOBLIFTACC'
	AND Item_Long_Desc LIKE 'Lever for Base Width Adjustment%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 11 - Accesorios ‘Battery Lead Acid’.
/*****************************************************************************/

SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'COMP'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'BATTERY'
	AND Item_Long_Desc LIKE 'Battery Lead Acid%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC;