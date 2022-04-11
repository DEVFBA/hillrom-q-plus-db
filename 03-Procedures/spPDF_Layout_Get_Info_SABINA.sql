USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_SABINA
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_SABINA'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_SABINA]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_SABINA
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_SABINA
Date:		12/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_SABINA @pvIdZone = 'LIKMEX'


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_SABINA
@pvIdZone	Varchar(10)
AS

/*****************************************************************************/
-- QUERY 1 - Productos
/*****************************************************************************/
SELECT
	KitName = 'SABINAII',
	Id_Line = Id_Line,
	Id_Item = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_SubClass = 'PROD'
	AND Id_Line IN ('MOBLIFT')
	AND Item_Model LIKE 'SABINA%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 2 -  Option
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'SABINAII',
	Id_Line = Id_Line,
	Id_Item = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'COMP'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'SLINGBAR'
	AND Item_Template LIKE 'SABINA%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC;

/*****************************************************************************/
-- QUERY 3 -  Accessories ‘Quick Reference Guide’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'QUICKREFER'
	AND Item_Template LIKE 'SABINA%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC;

/*****************************************************************************/
-- QUERY 4 - Accessories ‘Holder for Quick Reference Guide’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'HOLDERQREF'
	AND Item_Template LIKE 'SABINA%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC;

/*****************************************************************************/
-- QUERY 5 - Accesorios ‘Heel Support’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'SABINACCES'
	AND Id_Item IN ('2027011')
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC;

/*****************************************************************************/
-- QUERY 6 - Accesorios ‘SeatStrap SlingBar’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'SABINACCES'
	AND Id_Item IN ('2027006', '2027007')
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 7 - Accesorios ‘Sabina SeatStrap’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'SABINACCES'
	AND Id_Item IN ('3591115')
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 8 - Accesorios ‘Calf Strap’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'SABINACCES'
	AND Id_Item IN ('20290022')
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 9 - Accesorios ‘Support Vest Mod 91 – Support Vest’
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'SUPPVESM91'
	AND Item_Long_Desc LIKE 'SupportVest%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 10 - Accesorios ‘Support Vest Mod 91 - Extension’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'SUPPVESM91'
	AND Item_Long_Desc LIKE 'Extension%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 11 - Accesorios ‘Support Vest Mod 91 - Padding’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'SUPPVESM91'
	AND Item_Long_Desc LIKE 'Padding%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 12 - Accesorios ‘Safety Vest Mod 93’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'SAFEVESM93'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 13 - Accesorios ‘Comfort Vest Mod 95’
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'COMFVESM95'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 14 - Accesorios ‘Solo Support Vest Mod 911’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_Line IN ('MOBLIFT')
	AND Id_Item_SubClass = 'SOSUVEM911'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC
