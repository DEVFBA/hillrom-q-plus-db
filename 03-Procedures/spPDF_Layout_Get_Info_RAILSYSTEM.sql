USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_RAILSYSTEM
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_RAILSYSTEM'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_RAILSYSTEM]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_RAILSYSTEM
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_RAILSYSTEM
Date:		12/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_RAILSYSTEM @pvIdZone = 'LIKMEX'


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_RAILSYSTEM
@pvIdZone	Varchar(10)
AS

/*****************************************************************************/
-- QUERY 1 - Accesorios ‘Rail System H70 – Straight Rail (natural)’.
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
	AND Id_Item_SubClass = 'RAILSYSH70'
	AND Item_Long_Desc LIKE '%Straight Rail H70%'
	AND Id_Item LIKE '%N'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 2 - Accesorios ‘Rail System H70 – Straight Rail (white)’.
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
	AND Id_Item_SubClass = 'RAILSYSH70'
	AND Item_Long_Desc LIKE '%Straight Rail H70%'
	AND Id_Item LIKE '%V'
	AND Item_Long_Desc NOT LIKE 'Embedded%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC;

/*****************************************************************************/
-- QUERY 3 - Accesorios ‘Rail System H70 – 90° Rail Curve’
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
	AND Id_Item_SubClass = 'RAILSYSH70'
	AND Item_Long_Desc LIKE '90° RailCurve H70%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 4 - Accesorios ‘Rail System H70 – 45° Rail Curve’
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
	AND Id_Item_SubClass = 'RAILSYSH70'
	AND Item_Long_Desc LIKE '45° RailCurve H70%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 5 - Accesorios ‘Rail System H70 – Embedded Straight Rail’.
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
	AND Id_Item_SubClass = 'RAILSYSH70'
	AND Item_Long_Desc LIKE 'Embedded Straight Rail H70%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 6 - Accesorios ‘Rail System H70 – 90° Embedded Rail Curve’.
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
	AND Id_Item_SubClass = 'RAILSYSH70'
	AND Item_Long_Desc LIKE '90° Embedded Rail Curve H70%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 7 - Accesorios ‘Rail System H70 – 45° Embedded Rail Curve’.
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
	AND Id_Item_SubClass = 'RAILSYSH70'
	AND Item_Long_Desc LIKE '45° Embedded Rail Curve H70%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 8 -Accesorios ‘Rail System H100 – Straight Rail (natural)’.
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
	AND Id_Item_SubClass = 'RAISYSH100'
	AND Item_Long_Desc LIKE '%Straight Rail%'
	AND Id_Item LIKE '%N'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 9 - Accesorios ‘Rail System H100 – Straight Rail (white)’.
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
	AND Id_Item_SubClass = 'RAISYSH100'
	AND Item_Long_Desc LIKE '%Straight Rail%'
	AND Id_Item LIKE '%V'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 10 - Accesorios ‘Rail System H140 – Straight Rail (natural)’.
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
	AND Id_Item_SubClass = 'RAISYSH140'
	AND Item_Long_Desc LIKE '%Straight Rail%'
	AND Id_Item LIKE '%N'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 11 - Accesorios ‘Rail System H140 – Straight Rail (white)’
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
	AND Id_Item_SubClass = 'RAISYSH140'
	AND Item_Long_Desc LIKE '%Straight Rail%'
	AND Id_Item LIKE '%V'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 12 - . Accesorios ‘Rail System H160 – Straight Rail (natural)’.
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
	AND Id_Item_SubClass = 'RSYH160180'
	AND Item_Long_Desc LIKE '%Straight Rail%'
	AND Id_Item LIKE '%N'
	AND Item_Long_Desc LIKE '%H160%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 13 - Accesorios ‘Rail System H160 – Straight Rail (white)’.
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
	AND Id_Item_SubClass = 'RSYH160180'
	AND Item_Long_Desc LIKE '%Straight Rail%'
	AND Id_Item LIKE '%V'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 14 - Accesorios ‘Rail System H180 – Straight Rail (natural)’.
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
	AND Id_Item_SubClass = 'RSYH160180'
	AND Item_Long_Desc LIKE '%Straight Rail%'
	AND Id_Item LIKE '%N'
	AND Item_Long_Desc LIKE '%H180%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 15 - Accesorios ‘Rail System H160 – End Stop’.
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
	AND Id_Item_SubClass = 'RSYH160180'
	AND Item_Long_Desc LIKE 'End Stop Set%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 16 - Accesorios ‘End Covers – End Cover H70’.
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
	AND Id_Item_SubClass = 'ENDCOVERS'
	AND Item_Long_Desc LIKE 'End Cover H70%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 17 - Accesorios ‘End Covers – Embedded End Cover H70’
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
	AND Id_Item_SubClass = 'ENDCOVERS'
	AND Item_Long_Desc LIKE 'Embedded End Cover H70%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 18 - Accesorios ‘End Covers – End Cover H1##’.
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
	AND Id_Item_SubClass = 'ENDCOVERS'
	AND Item_Long_Desc LIKE 'End Cover H1%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 19 - Accesorios ‘End Covers – End Cover for current profile’.}
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
	AND Id_Item_SubClass = 'ENDCOVERS'
	AND Item_Long_Desc LIKE 'End Cover for%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 20 - Accesorios ‘End Covers – Rail Cover’.
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
	AND Id_Item_SubClass = 'ENDCOVERS'
	AND Item_Long_Desc LIKE 'Rail Cover%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 21 - Accesorios ‘Assembly Parts – Ceiling Mount Rail System – Ceiling Bracket 61’.
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
	AND Id_Item_SubClass = 'CEIMORASYS'
	AND Item_Long_Desc LIKE 'Ceiling bracket 61%'
	AND Item_Long_Desc NOT LIKE '%Joint%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 22 - Accesorios ‘Assembly Parts – Ceiling Mount Rail System – Ceiling Bracket 61 Joint’.
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
	AND Id_Item_SubClass = 'CEIMORASYS'
	AND Item_Long_Desc LIKE 'Ceiling bracket 61 Joint%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 23 - Accesorios ‘Assembly Parts – Ceiling Mount Rail System – Ceiling Bracket 71 Arch’.
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
	AND Id_Item_SubClass = 'CEIMORASYS'
	AND Item_Long_Desc LIKE 'Ceiling bracket 71 Arch%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 24 - Accesorios ‘Assembly Parts – Ceiling Mount Rail System – Joint Piece’.
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
	AND Id_Item_SubClass = 'CEIMORASYS'
	AND Item_Long_Desc LIKE 'Joint Piece%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 25 - Accesorios ‘Assembly Parts – Ceiling Mount Rail System – Joint Section’.
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
	 AND Id_Item_SubClass = 'CEIMORASYS'
	 AND Item_Long_Desc LIKE 'Joint Section%'
	 AND Id_Zone = @pvIdZone
 ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 26 -. Accesorios ‘Assembly Parts – Ceiling Mount Rail System – Pendant adjustable 4 - 12 in’.
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
	AND Id_Item_SubClass = 'CEIMORASYS'
	AND Item_Long_Desc LIKE 'Pendant adjustable%'
	AND Id_Item IN ('3102011', '3102012', '3102013', '3102014')
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 27 - Accesorios ‘Assembly Parts – Ceiling Mount Rail System – Pendant adjustable 12 - 83 in’
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
	AND Id_Item_SubClass = 'CEIMORASYS'
	AND Item_Long_Desc LIKE 'Pendant adjustable%'
	AND Id_Item IN ('3102031', '3102032', '3102033', '3102034', '3102043')
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC


/*****************************************************************************/
-- QUERY 28 - Accesorios ‘Assembly Parts – Ceiling Mount Rail System – Pendant Angled’
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
	AND Id_Item_SubClass = 'CEIMORASYS'
	AND Item_Long_Desc LIKE 'PendantAngled%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 29 - Accesorios ‘Assembly Parts – Ceiling Mount Rail System – Side Support’
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
	AND Id_Item_SubClass = 'CEIMORASYS'
	AND Item_Long_Desc LIKE 'Side Support%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 30 - Accesorios ‘Assembly Parts – Ceiling Mount Rail System – Damp Ceiling Bracket’.
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
	AND Id_Item_SubClass = 'CEIMORASYS'
	AND Item_Long_Desc LIKE 'Damp Ceiling Bracket%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 31 - Accesorios ‘Assembly Parts – Ceiling Mount Rail System – Threaded Steel Rods’.
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
	AND Id_Item_SubClass = 'CEIMORASYS'
	AND Item_Long_Desc LIKE 'Threaded Steel Rods%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 32 - Accesorios ‘Extension Cable’.
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
	AND Id_Item_SubClass = 'CEIMORASYS'
	AND Item_Long_Desc LIKE 'Distance Block%'
	AND Id_Zone = @pvIdZone
 ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 33 - Accesorios ‘Assembly Parts – Ceiling Mount Rail System – Pendant Cover’.
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
	AND Id_Item_SubClass = 'CEIMORASYS'
	AND Item_Long_Desc LIKE 'Pendant Cover%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 34 - Accesorios ‘Assembly Parts – Ceiling Mount Rail System – Pendant Washer’.
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
	AND Id_Item_SubClass = 'CEIMORASYS'
	AND Item_Long_Desc LIKE 'Pendant Washer%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 35 - Accesorios ‘Assembly Parts – Suspended Rail System – Slimline Upright Support’.
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
	AND Id_Item_SubClass = 'SUSRAILSYS'
	AND Item_Long_Desc LIKE 'Slimline Upright Support%'
	AND Id_Zone = @pvIdZone
 ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 36 - Accesorios ‘Assembly Parts – Suspended Rail System – Assembly Parts for Slimline Upright Support’
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
	AND Id_Item_SubClass = 'SUSRAILSYS'
	AND Item_Long_Desc LIKE 'Assembly Parts for Slimline Upright Support%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 37 - Accesorios ‘Assembly Parts – Suspended Rail System – Slimline Foot’.
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
	 AND Id_Item_SubClass = 'SUSRAILSYS'
	 AND Item_Long_Desc LIKE 'Slimline Foot%'
	 AND Id_Zone = @pvIdZone
 ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 38 - Accesorios ‘Assembly Parts – Suspended Rail System – Upright Support’.
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
	AND Id_Item_SubClass = 'SUSRAILSYS'
	AND Item_Long_Desc LIKE 'Upright Support%'
	AND Id_Item LIKE '%V'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 39 - Accesorios ‘Assembly Parts – Suspended Rail System – Assembly Parts for One Upright Support’
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
	AND Id_Item_SubClass = 'SUSRAILSYS'
	AND Item_Long_Desc LIKE 'Assembly Parts for One Upright Support%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 40 - Accesorios ‘Assembly Parts – Suspended Rail System – Upright Support Distance Aluspacer’
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
	AND Id_Item_SubClass = 'SUSRAILSYS'
	AND Item_Long_Desc LIKE 'Upright Support Distance Aluspacer%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 41 - Accesorios ‘Assembly Parts – Suspended Rail System – Turnable Bracket for Upright Support’
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
	AND Id_Item_SubClass = 'SUSRAILSYS'
	AND Item_Long_Desc LIKE 'Turnable Bracket for Upright Support%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 42 - Accesorios ‘Assembly Parts – Suspended Rail System – Upright Support Steel’.
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
	AND Id_Item_SubClass = 'SUSRAILSYS'
	AND Item_Long_Desc LIKE 'Upright Support Steel%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 43 - Accesorios ‘Assembly Parts – Suspended Rail System – Superstructure’.
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
	AND Id_Item_SubClass = 'SUSRAILSYS'
	AND Item_Long_Desc LIKE 'Superstructure%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 44 - Accesorios ‘Assembly Parts – Suspended Rail System – Wall Bracket Turnable’.
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
	AND Id_Item_SubClass = 'SUSRAILSYS'
	AND Item_Long_Desc LIKE 'Wall Bracket, turnable%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 45 - Accesorios ‘Assembly Parts – Suspended Rail System – Wall Bracket Parallel’.
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
	AND Id_Item_SubClass = 'SUSRAILSYS'
	AND Item_Long_Desc LIKE 'Wall Bracket, parallel%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 46 - . Accesorios ‘Assembly Parts – Suspended Rail System – Assembly Partd for Suspended Rail System (natural)’.
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
	AND Id_Item_SubClass = 'SUSRAILSYS'
	AND Item_Long_Desc LIKE 'Assembly Parts for Suspended Rail System%'
	AND Id_Item LIKE '%N'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 47 - Accesorios ‘Assembly Parts – Suspended Rail System – Assembly Partd for Suspended Rail System (white)’.
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
	AND Id_Item_SubClass = 'SUSRAILSYS'
	AND Item_Long_Desc LIKE 'Assembly Parts for Suspended Rail System%'
	AND Id_Item LIKE '%V'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 48 - Accesorios ‘HandControl LR ES-4MS’.
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
	AND Id_Item_SubClass = 'SUSRAILSYS'
	AND Item_Long_Desc LIKE 'Assembly Set reinforcement%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 49 - Accesorios ‘Assembly Parts – Suspended Rail System – Reinforcement Rail (natural)’
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
	AND Id_Item_SubClass = 'SUSRAILSYS'
	AND Item_Long_Desc LIKE 'Reinforcement Rail%'
	AND Id_Item LIKE '%N'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 50 - Accesorios ‘Assembly Parts – Suspended Rail System – Reinforcement Rail (white)’
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
	AND Id_Item_SubClass = 'SUSRAILSYS'
	AND Item_Long_Desc LIKE 'Reinforcement Rail%'
	AND Id_Item LIKE '%V'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 51 - Accesorios ‘Assembly Parts – Suspended Rail System – Rail Joint’.
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
	AND Id_Item_SubClass = 'SUSRAILSYS'
	AND Item_Long_Desc LIKE 'Rail Joint%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 52 - Accesorios ‘Rail Switch System – Traverse Switch’
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
	AND Id_Item_SubClass = 'RAISWSYH70'
	AND Item_Long_Desc LIKE 'Traverse Switch%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 53 - Accesorios ‘Rail Switch System – Side Rail Switch Manua
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
	AND Id_Item_SubClass = 'RAISWSYH70'
	AND Item_Long_Desc LIKE 'Side Rail Switch, manual%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 54 - Accesorios ‘Rail Switch System – Side Rail Switch Electrical’.
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
	AND Id_Item_SubClass = 'RAISWSYH70'
	AND Item_Long_Desc LIKE 'Side Rail Switch, electrical%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 55 - Accesorios ‘Rail Switch System – Turntable Mechanical’.
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
	AND Id_Item_SubClass = 'RAISWSYH70'
	AND Item_Long_Desc LIKE 'Turntable, mechanical%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 56 - Accesorios ‘Rail Switch System – Turntable Electrical’
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
	AND Id_Item_SubClass = 'RAISWSYH70'
	AND Item_Long_Desc LIKE 'Turntable, electrical%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 57 - Accesorios ‘Rail Switch System – Stabilization Bar for Traverse Switch’
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
	AND Id_Item_SubClass = 'RAISWSYH70'
	AND Item_Long_Desc LIKE 'Stabilization Bar for Traverse Switch%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 58 - Accesorios ‘Quick Release Carriage’
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
	AND Id_Item_SubClass = 'RAISWSYH70'
	AND Item_Long_Desc LIKE 'Control Box%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 59 - Accesorios ‘Rail Switch System – Traverse Rail Carrier - Likorall, Multirall – Traverse Rail Carrier 1’.
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
	AND Id_Item_SubClass = 'TRARACAH70'
	AND Item_Long_Desc LIKE 'Traverse Rail Carrier%'
	AND Id_Item IN ('3102513', '3102511', '3102512', '3102518', '3102561')
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 60 - Accesorios ‘Rail Switch System – Traverse Rail Carrier - Likorall, Multirall – Traverse Rail Carrier 2’.
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
	AND Id_Item_SubClass = 'TRARACAH70'
	AND Item_Long_Desc LIKE 'Traverse Rail Carrier%'
	AND Id_Item IN ('3102514', '3102515', '3102556', '3102506')
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 61 - Accesorios ‘Rail Switch System – Traverse Rail Carrier - Likorall, Multirall – Traverse Rail Carrier 3’.
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
	AND Id_Item_SubClass = 'TRARACAH70'
	AND Item_Long_Desc LIKE 'Traverse Rail Carrier%'
	AND Id_Item IN ('3102516', '3102517', '3102509')
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 62 - Accesorios ‘Rail Switch System – Traverse Rail Carrier - Likorall, Multirall – Traverse Rail Carrier 4’.
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
	AND Id_Item_SubClass = 'TRARACAH70'
	AND Item_Long_Desc LIKE 'Traverse Rail Carrier%'
	AND Id_Item IN ('3102531', '3102532')
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC


/*****************************************************************************/
-- QUERY 63 - Accesorios ‘Rail Switch System – Traverse Carrier Multi - Likorall – Traverse Carrier Multi Standard’.
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
	AND Id_Item_SubClass = 'TRCAMULH70'
	AND Item_Long_Desc LIKE 'Traverse Carrier Multi, standard%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 64 - Accesorios ‘Rail Switch System – Traverse Carrier Multi - Likorall – Traverse Carrier Multi Wide’.
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
	AND Id_Item_SubClass = 'TRCAMULH70'
	AND Item_Long_Desc LIKE 'Traverse Carrier Multi, wide%'
	AND Item_Long_Desc NOT LIKE '%raised%'
	AND Item_Long_Desc NOT LIKE '%lowered%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 65 - Accesorios ‘Rail Switch System – Traverse Carrier Multi - Likorall – Traverse Carrier Multi Wide Raised’.
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
	AND Id_Item_SubClass = 'TRCAMULH70'
	AND Item_Long_Desc LIKE 'Traverse Carrier Multi, wide%'
	AND Item_Long_Desc LIKE '%raised%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 66 - Accesorios ‘Rail Switch System – Traverse Carrier Multi - Likorall – Traverse Carrier Multi Wide Lowered’.
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
	AND Id_Item_SubClass = 'TRCAMULH70'
	AND Item_Long_Desc LIKE 'Traverse Carrier Multi, wide%'
	AND Item_Long_Desc LIKE '%lowered%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 67 - Accesorios ‘Rail Switch System – Traverse Carrier Multi - Likorall – Transfer Motor Traverse’.
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
	AND Id_Item_SubClass = 'TRCAMULH70'
	AND Item_Long_Desc LIKE 'Transfer Motor Traverse%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 68 - Accesorios ‘Rail Switch System – Hand Control’.
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
	AND Id_Item_SubClass = 'RAISWSYH70'
	AND Item_Long_Desc LIKE 'Hand Control%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC/*****************************************************************************/
-- QUERY 69 - Accesorios ‘Rail Switch System – Extension Cable’.
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
	AND Id_Item_SubClass = 'RAISWSYH70'
	AND Item_Long_Desc LIKE 'Extension Cable%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 70 - Accesorios ‘Rail Switch System – Traverse Rail Carrier - Likorall, Multirall – Traverse Rail Carrier 5’.
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
	AND Id_Item_SubClass = 'TRARACAH70'
	AND Item_Long_Desc LIKE 'Traverse Rail Carrier%'
	AND Id_Item IN ('3102519')
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC