USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_PRP7501
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_PRP7501'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_PRP7501]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_PRP7501
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_PRP7501
Date:		13/03/2021
Example:

	EXEC spPDF_Layout_Get_Info_PRP7501 
	


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_PRP7501
AS

/*****************************************************************************/
-- QUERY 1 -  LISTAS DE PRECIOS
/*****************************************************************************/
SELECT
	Id_Line,
	Id_Item,
	Item_Long_Desc,
	Price
FROM vwItems_Templates
WHERE	
	Id_Item_SubClass = 'PROD' AND 
	Id_Line in ('PRP7501')
ORDER BY Id_Item DESC


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = FRAME & SURFACE OPTIONS
/*****************************************************************************/
SELECT DISTINCT
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character = (CASE WHEN Required = 1 AND [Default] = 1 THEN '*' 
						ELSE NULL 
					   END)
FROM vwItems_Templates
WHERE
	Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	AND Id_Line in ('PRP7501')
	AND Id_Item_Class = 'COMP'
	AND Id_Item_SubClass IN ('CHAFRADESI', 'FRASURMODE', 'FRASURWID', 'FRASURMMS', 'PERCUVIBRA', 'ROTATION')
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 3 -  SUBCLASS = PATIENT SIDERAIL COM
/*****************************************************************************/
SELECT DISTINCT
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character = (CASE WHEN Required = 1 AND [Default] = 1 THEN '*'
					   ELSE NULL
					   END)
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line IN ('PRP7501') AND
	Id_Item_Class = 'COMP' AND
	ID_Item_SubClass IN ('PATSIDECOM')
	
ORDER BY Print_Character DESC, Id_Item

/*****************************************************************************/
-- QUERY 4 -  SUBCLASS = MOBILITY
/*****************************************************************************/
SELECT DISTINCT
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character =  (CASE WHEN Required = 1 AND [Default] = 1 THEN '*'
					   ELSE NULL
					   END)
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line IN ('PRP7501') AND
	Id_Item_Class = 'COMP'  AND 
	Id_Item_SubClass IN ('MOBILITY')
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 5 -  SUBCLASS = IV POLE
/*****************************************************************************/
SELECT DISTINCT
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character = (CASE WHEN Required = 1 AND [Default] = 1 THEN '*'
					   ELSE NULL
					   END)
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('PRP7501') AND
	Id_Item_Class = 'COMP' AND
	Id_Item_SubClass IN ('PERIVPOLE')
	
ORDER BY Id_Item


/*****************************************************************************/
-- QUERY 6 -  SUBCLASS = TRANSPORT SHELF
/*****************************************************************************/
--ACCUMSURFA - Accumax Surfaces
SELECT DISTINCT
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character = (CASE WHEN Required = 1 AND [Default] = 1 THEN '*'
					   ELSE NULL
					   END)
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('PRP7501') AND
	Id_Item_Class = 'COMP' AND
	Id_Item_SubClass IN ('TRANSSHELF')
	
ORDER BY Id_Item


/*****************************************************************************/
-- QUERY 7 -  SUBCLASS = SURFACES
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'PROGRESSAPLUSMAT',
	Item_Long_Desc = Item_Long_Desc,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE
	Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	AND Id_Line IN ('PRP7501')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass = 'PROPLUMATT'
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 8 -  SUBCLASS = ACCESSORIES
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'PROGRESSAPLUSMAT',
	Item_Long_Desc = Item_Long_Desc,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE
	Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	AND Id_Line IN ('PRP7501')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass IN ('PROGRACCES', 'PROPLUACCE') -- Corrección Ángel Gutiérrez 14/12/23
ORDER BY Id_Item