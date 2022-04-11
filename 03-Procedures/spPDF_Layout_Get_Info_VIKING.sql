USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_VIKING
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_VIKING'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_VIKING]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_VIKING
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_VIKING
Date:		12/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_VIKING @pvIdZone = 'LIKMEX'


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_VIKING
@pvIdZone	Varchar(10)
AS

/*****************************************************************************/
-- QUERY 1 - Productos
/*****************************************************************************/
SELECT
	KitName = 'VIKINGINT',
	Id_Line = Id_Line,
	Id_Item = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_SubClass = 'PROD'
	AND Id_Line IN ('MOBLIFT')
	AND Item_Model LIKE 'Viking%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 2 -  Option
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'VIKINGINT',
	Id_Line = Id_Line,
	Id_Item = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'COMP'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'BATTERY'
	AND Item_Template LIKE 'VIKING%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC;

/*****************************************************************************/
-- QUERY 3 -  Accessories ‘Armrest’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'VIKINACCES'
	AND Item_Template LIKE 'VIKING%'
	AND Id_Item IN ('2047011')
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 4 - Accessories ‘Leg Protector’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'VIKINACCES'
	AND Item_Template LIKE 'VIKING%'
	AND Id_Item NOT IN ('2047011')
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 5 - Accessories ‘Quick Reference Guide’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'QUICKREFER'
	AND Item_Template LIKE 'VIKING%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 6 - Accessories ‘Holder for Quick Reference Guide’
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'HOLDERQREF'
	AND Item_Template LIKE 'VIKING%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC