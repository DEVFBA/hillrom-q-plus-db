USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_PRP7500
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_PRP7500'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_PRP7500]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_PRP7500
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_PRP7500
Date:		13/03/2021
Example:

	EXEC spPDF_Layout_Get_Info_PRP7500 


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_PRP7500
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
	Id_Line in ('PRP7500')
ORDER BY Id_Item DESC


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = PATSIDECOM - Patient Siderail Com
/*****************************************************************************/
SELECT DISTINCT
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character = NULL
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('PRP7500') AND
	Id_Item_SubClass = 'PATSIDECOM' AND 
	Id_Item_Class = 'COMP' AND 
	[Default] = 0
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 3 -  SUBCLASS = MOBILITY - Mobility
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
	Id_Line in ('PRP7500') AND
	ID_Item_SubClass = 'MOBILITY' AND 
	Id_Item_Class = 'COMP' 
ORDER BY Print_Character DESC, Id_Item

/*****************************************************************************/
-- QUERY 4 -  SUBCLASS = PERIVPOLE - Permanent IV Pole
/*****************************************************************************/
SELECT DISTINCT
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character = NULL
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('PRP7500') AND
	Id_Item_SubClass = 'PERIVPOLE' AND 
	Id_Item_Class = 'COMP'  
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 5 -  SUBCLASS = TRANSSHELF - Permanent IV Pole
/*****************************************************************************/
SELECT DISTINCT
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character = NULL
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('PRP7500') AND
	Id_Item_SubClass = 'TRANSSHELF' AND 
	Id_Item_Class = 'COMP' 
ORDER BY Id_Item


/*****************************************************************************/
-- QUERY 6 -  SUBCLASS = SURFACES
/*****************************************************************************/
--ACCUMSURFA - Accumax Surfaces
SELECT DISTINCT
	KitName			= 'PROGRESSAMAT',
	Item_Long_Desc	= Item_Long_Desc,
	Part			= Id_Item,
	Price			= Price
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('PRP7500') AND
	Id_Item_SubClass =  'ACCUMSURFA' AND 
	Id_Item_Class = 'ACCE'
ORDER BY Id_Item

--THERASURFA - Therapy Integrated Surfaces (Royal Blue)
SELECT DISTINCT
	KitName			= 'PROGRESSAMAT',
	Item_Long_Desc	= Item_Long_Desc,
	Part			= Id_Item,
	Price			= Price
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('PRP7500') AND
	Id_Item_SubClass =  'THERASURFA' AND 
	Id_Item_Class = 'ACCE'
ORDER BY Id_Item


--PULMOSURFA - Pulmonary Integrated Surfaces (Raspberry)
SELECT DISTINCT
	KitName			= 'PROGRESSAMAT',
	Item_Long_Desc	= Item_Long_Desc,
	Part			= Id_Item,
	Price			= Price
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('PRP7500') AND
	Id_Item_SubClass =  'PULMOSURFA' AND 
	Id_Item_Class = 'ACCE'
ORDER BY Id_Item


/*****************************************************************************/
-- QUERY 7 -  SUBCLASS = ACCESORIES
/*****************************************************************************/
SELECT DISTINCT
	KitName			= (CASE WHEN Id_Item_SubClass = 'MISCACCESO' THEN 'MISCACCESSORIES'
							ELSE 'PROGRESSAACC'
					   END),
	Item_Long_Desc	= Item_Long_Desc,
	Part			= Id_Item,
	Price			= Price		
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('PRP7500') AND
	Id_Item_SubClass IN ('PROGRACCES', 'MISCACCESO', 'BEDACCESOR') AND 
	Id_Item_Class = 'ACCE'
ORDER BY Id_Item
