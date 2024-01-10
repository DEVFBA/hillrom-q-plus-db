USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_TH2SYNT
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_TH2SYNT'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_TH2SYNT]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_TH2SYNT
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_TH2SYNT
Date:		13/03/2021
Example:

	EXEC spPDF_Layout_Get_Info_TH2SYNT 
	


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_TH2SYNT
AS

/*****************************************************************************/
-- QUERY 1 -  LISTAS DE PRECIOS - THERAPY2
/*****************************************************************************/
SELECT
	Id_Line,
	Id_Item,
	Item_Long_Desc,
	Price
FROM vwItems_Templates
WHERE	
	Id_Item_SubClass = 'PROD' AND 
	Id_Line in ('THERA2')
ORDER BY Id_Item ASC


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = THERAPY2
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
	AND Id_Line in ('THERA2')
	AND Id_Item_Class = 'COMP'
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 3 -  LISTAS DE PRECIOS - SYNTHETO
/*****************************************************************************/
SELECT
	Id_Line,
	Id_Item,
	Item_Long_Desc,
	Price
FROM vwItems_Templates
WHERE	
	Id_Item_SubClass = 'PROD' AND 
	Id_Line in ('SUNTHE')
ORDER BY Id_Item ASC


/*****************************************************************************/
-- QUERY 4 -  SUBCLASS = Options 'SYNTHETO'.
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
	Id_Line IN ('SUNTHE') AND
	Id_Item_Class = 'COMP' 
ORDER BY Id_Item
