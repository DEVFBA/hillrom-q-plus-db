USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_CP7800A
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_CP7800A'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_CP7800A]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_CP7800A
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_CP7800A
Date:		13/03/2021
Example:

	EXEC spPDF_Layout_Get_Info_CP7800A 


*/

CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_CP7800A
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
	Id_Line in ('CP7800A')
ORDER BY Id_Item DESC


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = MOBILITY - Mobility
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
	Id_Line in ('CP7800A') AND
	ID_Item_SubClass = 'MOBILITY' AND
	Id_Item_Class = 'COMP'
ORDER BY Print_Character DESC, Id_Item

/*****************************************************************************/
-- QUERY 3 -  SUBCLASS = PATSIDECOM - Patient Siderail Com
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
	Id_Line in ('CP7800A') AND
	Id_Item_SubClass = 'PATSIDECOM' AND 
	[Default] = 0 AND
	Id_Item_Class = 'COMP'
ORDER BY Id_Item



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
	Id_Line in ('CP7800A') AND
	Id_Item_SubClass = 'IVPOLE.' AND
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
	--,[Default]
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('CP7800A') AND
	Id_Item_SubClass IN('PATIEHELPE','LINEMANAG','BEDEXITALE','PENDANT' ) AND
	Id_Item_Class = 'COMP' AND Id_Item NOT IN ('SINGLE')
ORDER BY Id_Item


/*****************************************************************************/
-- QUERY 6 -  SUBCLASS = SURFACES
/*****************************************************************************/
--COMPESURFA - Compella Surfaces
SELECT DISTINCT
	KitName			= 'COMPELLAMAT',
	Item_Long_Desc	= Item_Long_Desc,
	Part			= Id_Item,
	Price			= Price
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('CP7800A') AND
	Id_Item_SubClass = 'COMPESURFA' AND
	Id_Item_Class = 'ACCE'
ORDER BY Id_Item




/*****************************************************************************/
-- QUERY 7 -  SUBCLASS = ACCESSORIES
/*****************************************************************************/
SELECT DISTINCT
	KitName			= (CASE WHEN Id_Item_SubClass = 'MISCACCESO' THEN 'MISCACCESSORIES'
							ELSE 'COMPELLAACC'
					   END),
Id_Item_SubClass,
	Item_Long_Desc	= Item_Long_Desc,
	Part			= Id_Item,
	Price			= Price		
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('CP7800A') AND
	Id_Item_SubClass IN ('COMPEACCE','MISCACCESO') AND
	Id_Item_Class = 'ACCE'
ORDER BY Id_Item



/*****************************************************************************/
-- QUERY 8 -  SUBCLASS = SAME ACCESSORIES
/*****************************************************************************/
SELECT DISTINCT
	KitName			= Item_SubClass,
	Item_Long_Desc	= Item_Long_Desc,
	Part			= Id_Item,
	Price			= Price		
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('CP7800A') AND
	Id_Item_SubClass IN ('TANKHOLDER', 'BOTTHOLDER', 'IVPOLE','TRAYS') AND
	Id_Item_Class = 'ACCE'
ORDER BY KitName, Id_Item


/*****************************************************************************/
-- QUERY 9 -  SUBCLASS = SOURFACES OPTION
/*****************************************************************************/
SELECT DISTINCT
	KitName			= 'SURFACE OPTION',
	Id_Item_Template,
	Item_Long_Desc	= Item_Long_Desc,
	Part			= Id_Item,
	Price			= Price		
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('CP7800A') AND
	Id_Item_SubClass IN ('SURFACEKIT') AND
	Id_Item_Class = 'COMP'
ORDER BY KitName, Id_Item


/*****************************************************************************/
-- QUERY 10 -  SUBCLASS = SOURFACES ADD-ONS
/*****************************************************************************/
SELECT DISTINCT
	KitName			= 'SURFACE ADD-ONS',
	Id_Item_Template,
	Item_Long_Desc	= Item_Long_Desc,
	Part			= Id_Item,
	Price			= Price		
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('CP7800A') AND
	Id_Item_SubClass IN ('LAROTTHER') AND
	Id_Item_Class = 'COMP'
ORDER BY KitName, Id_Item