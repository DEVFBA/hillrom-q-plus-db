USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_ACCELLA
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_ACCELLA'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_ACCELLA]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_ACCELLA
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_ACCELLA
Date:		21/12/2021
Example:

	EXEC spPDF_Layout_Get_Info_ACCELLA 


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_ACCELLA
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
	Id_Line in ('ACCELLA')
ORDER BY Id_Item DESC


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = PATSIDECOM - Patient Siderail Com
/*****************************************************************************/
SELECT DISTINCT
	--Id_Item_SubClass,
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character = NULL
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('ACCELLA') AND
	Id_Item_SubClass IN ('BEDCONTROL','HILOPEDAL','BRAKE','BEDEXITALE','WIREDCONNE','NURSECALL','POWSURFA','OPTIUPGRAD') AND 
	Id_Item NOT IN ('AD242A','P005987A','P006052A','P006172A') AND
	[Default] = 0
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 3 -  SUBCLASS = CASTORS - Castors
/*****************************************************************************/
SELECT DISTINCT
--	Id_Item_SubClass,
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
	Id_Line in ('ACCELLA') AND
	ID_Item_SubClass = 'CASTORS' AND 
	Id_Item_Class = 'COMP'
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 4 -  SUBCLASS = GRAPHINTER	- Graphical Interface
/*****************************************************************************/
SELECT DISTINCT
--	Id_Item_SubClass,
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character = NULL
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('ACCELLA') AND
	Id_Item_SubClass = 'GRAPHINTER' AND 
	Id_Item_Class = 'COMP'
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 5 -  SUBCLASS = TRANSSHELF - Permanent IV Pole
/*****************************************************************************/
SELECT DISTINCT
	Id_Item_SubClass,
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character = NULL,[DEFAULT]
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('ACCELLA') AND
	Id_Item_SubClass = 'STEERING' AND
	[Default] = 0 AND 
	Id_Item_Class = 'COMP'
ORDER BY Id_Item



/*****************************************************************************/
-- QUERY 6 -  SUBCLASS = TRANSSHELF - Permanent IV Pole
/*****************************************************************************/
SELECT DISTINCT
	Id_Item_SubClass,
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character = (CASE WHEN Required = 1 AND [Default] = 1 THEN '*'
						    WHEN Id_Item IN ('EU', '230V') THEN '*'
					   ELSE NULL
					   END),
	[DEFAULT]
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('ACCELLA') AND
	Id_Item_SubClass IN ('PLUG', 'VOLTAGE') AND
	[Default] = 0 AND 
	Id_Item_Class = 'COMP' AND
	Id_Item NOT IN  ('110V', '115V', '127V', '220V', '240V', 'CA', 'NZ') 
ORDER BY Id_Item




