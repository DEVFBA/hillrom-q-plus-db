USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_THSUR
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_THSUR'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_THSUR]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_THSUR
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_THSUR
Date:		12/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_THSUR


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_THSUR
AS

/*****************************************************************************/
-- QUERY 1 - Foam Surface’ (Country of Origin: China)
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'ENTER AS END ITEM',
	Model = Item_Model,
	Item_Long_Desc = Item_Long_Desc,
	Size_Code = '16',
	Size = Measurements,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('ACCE')
	AND Id_Item_Class = 'ACCE'
	AND Id_Family IN ('HOB', 'STR')
	AND Id_Item_SubClass IN ('CHINASURFA')
ORDER BY Id_Item


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = Foam Surfaces - Monodensity
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'FOAMATTRESS',
	Model = Item_Model,
	Item_Long_Desc = Item_Long_Desc,
	Size_Code = (CASE Id_Item 
					WHEN 'ASS027' THEN '15'
					WHEN 'ASS028' THEN '16'
					ELSE '17'
				END),
	Size = Measurements,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('ACCE')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass IN ('FOAMSURFA', 'FRANSURFA')
	AND Item_Long_Desc LIKE 'Monodensity%'
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 3 -  SUBCLASS = Foam Surfaces - Bidensity
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'FOAMATTRESS',
	Model = Item_Model,
	Item_Long_Desc = Item_Long_Desc,
	Size_Code = (CASE Id_Item 
						WHEN 'ASS038' THEN '17'
						WHEN 'ASS032' THEN '16'
						WHEN 'ASS031' THEN '16'
						ELSE '15'
				END),
	Size = Measurements,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('ACCE')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass IN ('FOAMSURFA', 'FRANSURFA')
	AND Item_Long_Desc LIKE 'Bidensity%'
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 4 -  SUBCLASS = Foam Surfaces - Viscoelastic
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'FOAMATTRESS',
	Model = Item_Model,
	Item_Long_Desc = Item_Long_Desc,
	Size_Code = (CASE Id_Item 
						WHEN 'ASS048' THEN '17'
						WHEN 'ASS034' THEN '16'
						WHEN 'ASS099' THEN '16'
						ELSE '15'
				END),
	Size = Measurements,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('ACCE')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass IN ('FOAMSURFA', 'FRANSURFA')
	AND Item_Long_Desc LIKE 'Viscoelastic%'
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 5 -  SUBCLASS = Surfaces Extensions
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'MATTRESSEXT',
	Model = Item_Model,
	Item_Long_Desc = Item_Long_Desc,
	Size_Code = (CASE Id_Item 
						WHEN 'ASS043' THEN '04'
						WHEN 'ASS044' THEN '05'
						WHEN 'ASS077' THEN '06'
						ELSE '07'
				END),
	Size = Measurements,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('ACCE')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass IN ('EXTENSIONS')
ORDER BY Id_Item;

/*****************************************************************************/
-- QUERY 6 -  SUBCLASS = Surfaces Surface Covers - Monodensity
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'MATTRESSCOV',
	Model = Item_Model,
	Item_Long_Desc = Item_Long_Desc,
	Size_Code = (CASE Id_Item 
					WHEN 'TEX027' THEN '15'
					WHEN 'TEX028' THEN '16'
					ELSE '17'
				END),
	Size = Measurements,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('ACCE')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass IN ('SURFACOVER')
	AND Item_Long_Desc LIKE 'Monodensity%'
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 7 -  SUBCLASS = IV Pole
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'MATTRESSCOV',
	Model = Item_Model,
	Item_Long_Desc = Item_Long_Desc,
	Size_Code = (CASE Id_Item 
						WHEN 'TEX038' THEN '17'
						WHEN 'TEX029' THEN '15'
						WHEN 'TEX030' THEN '15'
						ELSE '16'
				END),
	Size = Measurements,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('ACCE')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass IN ('SURFACOVER')
	AND Item_Long_Desc LIKE 'Bidensity%'
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 8 -  SUBCLASS = Surfaces Surface Covers - Viscoelastic
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'MATTRESSCOV',
	Model = Item_Model,
	Item_Long_Desc = Item_Long_Desc,
	Size_Code = (CASE Id_Item WHEN 'TEX048' THEN '17'
	WHEN 'TEX033' THEN '15'
	WHEN 'TEX095' THEN '15'
	ELSE '16'
	END),
	Size = Measurements,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('ACCE')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass IN ('SURFACOVER')
	AND Item_Long_Desc LIKE 'Viscoelastic%'
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 9 -  SUBCLASS = Surfaces US Surfaces – NP50MAT
/*****************************************************************************/
SELECT DISTINCT
	 KitName = 'NP50MAT',
	 Item_Long_Desc = Item_Long_Desc,
	 Part = Id_Item,
	 Price = Price
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('ACCE')
	 AND Id_Item_Class = 'ACCE'
	 AND Id_Item_SubClass IN ('USSURFACES', 'NP50SUR')
	 AND Item_Long_Desc LIKE 'NP50%'
 ORDER BY Id_Item

 /*****************************************************************************/
-- QUERY 10 -  SUBCLASS = Surfaces US Surfaces – NP100MAT
/*****************************************************************************/
SELECT DISTINCT
	 KitName = 'NP100MAT',
	 Item_Long_Desc = Item_Long_Desc,
	 Part = Id_Item,
	 Price = Price
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('ACCE')
	 AND Id_Item_Class = 'ACCE'
	 AND Id_Item_SubClass IN ('USSURFACES', 'NP100SUR')
	 AND Item_Long_Desc LIKE 'NP100%'
 ORDER BY Id_Item
