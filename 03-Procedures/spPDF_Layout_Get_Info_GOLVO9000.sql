USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_GOLVO9000
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_GOLVO9000'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_GOLVO9000]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_GOLVO9000
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_GOLVO9000
Date:		12/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_GOLVO9000 @pvIdZone = 'LIKMEX'


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_GOLVO9000
@pvIdZone	Varchar(10)
AS

/*****************************************************************************/
-- QUERY 1 - P280 Overlay
/*****************************************************************************/
SELECT
	KitName = 'GOLVO9000INT',
	Id_Line = Id_Line,
	Id_Item = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_SubClass = 'PROD'
	AND Id_Line IN ('MOBLIFT')
	AND Item_Model LIKE 'Golvo%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = Option
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'GOLVO9000INT',
	Id_Line = Id_Line,
	Id_Item = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'COMP'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'BATTERY'
	AND Item_Template LIKE 'GOLVO%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC;


/*****************************************************************************/
-- QUERY 3 -  SUBCLASS = Accessories ‘Low Base Kit’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'GOLVOACCES'
	AND Id_Item IN ('20090071')
	AND Item_Template LIKE 'GOLVO%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 4 -  SUBCLASS = Accessories ‘Leg Protector’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'GOLVOACCES'
	AND Id_Item NOT IN ('20090071')
	AND Item_Template LIKE 'GOLVO%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC
/*****************************************************************************/
-- QUERY 5 -  SUBCLASS = Accessories ‘Quick Reference Guide’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'QUICKREFER'
	AND Item_Template LIKE 'GOLVO%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC;

/*****************************************************************************/
-- QUERY 6 -  SUBCLASS = Accessories ‘Holder for Quick Reference Guide’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'HOLDERQREF'
	AND Item_Template LIKE 'GOLVO%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC;

