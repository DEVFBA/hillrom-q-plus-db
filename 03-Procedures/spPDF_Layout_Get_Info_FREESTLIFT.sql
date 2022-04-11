USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_FREESTLIFT
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_FREESTLIFT'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_FREESTLIFT]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_FREESTLIFT
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_FREESTLIFT
Date:		12/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_FREESTLIFT @pvIdZone = 'LIKMEX'


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_FREESTLIFT
@pvIdZone	Varchar(10)
AS

/*****************************************************************************/
-- QUERY 1 - Accesorios ‘‘FreeSpan Straight Rail – Freespan Rail LR’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('FREELIS')
	AND Id_Item_SubClass = 'ASSEMPARTS'
	AND Item_Long_Desc LIKE 'FreeSpan Rail%'
	AND Item_Long_Desc LIKE '%LR%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 2 - ‘FreeSpan Straight Rail – Freespan Rail MR’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('FREELIS')
	AND Id_Item_SubClass = 'ASSEMPARTS'
	AND Item_Long_Desc LIKE 'FreeSpan Rail%'
	AND Item_Long_Desc LIKE '%MR%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 3 - Accesorios FreeSpan Straight Rail – Freespan Side Support
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('FREELIS')
	AND Id_Item_SubClass = 'ASSEMPARTS'
	AND Item_Long_Desc LIKE 'FreeSpan Side Support%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 4 - Accesorios ‘FreeSpan Traverse – FreeSpan Upright Support
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('FREELIS')
	AND Id_Item_SubClass = 'ASSEMPARTS'
	AND Item_Long_Desc LIKE 'FreeSpan Upright Support%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 5 - Accesorios ‘FreeSpan Traverse – FreeSpan Cross-beam
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('FREELIS')
	AND Id_Item_SubClass = 'ASSEMPARTS'
	AND Item_Long_Desc LIKE 'FreeSpan Cross-beam%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 6 - Accesorios FreeSpan Traverse – Parking Bracket
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('FREELIS')
	AND Id_Item_SubClass = 'ASSEMPARTS'
	AND Item_Long_Desc LIKE 'Parking Bracket%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 7 - Accesorios ‘FreeSpan Traverse – Ultra Traverse Damper’
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('FREELIS')
	AND Id_Item_SubClass = 'ASSEMPARTS'
	AND Item_Long_Desc LIKE 'Ultra Traverse Damper%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 8 -Accesorios ‘FreeSpan UltraTwin – UltraTwin FreeSpan Upright Support’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('FREELIS')
	AND Id_Item_SubClass = 'ASSEMPARTS'
	AND Item_Long_Desc LIKE 'UltraTwin FreeSpan Upright Support%'
	AND Id_Item IN ('3103520')
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 9 - Accesorios ‘FreeSpan UltraTwin – Ultra Control Unit’
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('FREELIS')
	AND Id_Item_SubClass = 'ASSEMPARTS'
	AND Item_Long_Desc LIKE 'Ultra Control Unit%'
	AND Id_Zone = @pvIdZone
 ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 10 - Accesorios ‘FreeSpan UltraTwin – UltraTwin FreeSpan Upright Support Wide.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('FREELIS')
	AND Id_Item_SubClass = 'ASSEMPARTS'
	AND Item_Long_Desc LIKE 'UltraTwin FreeSpan Upright Support%'
	AND Id_Item IN ('3103521')
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 11 - Accesorios ‘‘FreeSpan UltraTwin – UltraTwist’
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('FREELIS')
	AND Id_Item_SubClass = 'ASSEMPARTS'
	AND Item_Long_Desc LIKE 'UltraTwist%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 12 - . Accesorios ‘FreeStand – FreeStand Upright Support’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('FREELIS')
	AND Id_Item_SubClass = 'ASSEMPARTS'
	AND Item_Long_Desc LIKE 'FreeStand Upright Support%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 13 - Accesorios ‘FreeStand – FreeStand Parking Set’
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('FREELIS')
	AND Id_Item_SubClass = 'ASSEMPARTS'
	AND Item_Long_Desc LIKE 'FreeStand PArking Set%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC