USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_OBTAOC
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_OBTAOC'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_OBTAOC]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_OBTAOC
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_OBTAOC
Date:		09/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_OBTAOC 


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_OBTAOC
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
 WHERE Id_Item_SubClass = 'PROD'
 AND Id_Line IN ('ARTP634', 'ARTP635', 'ARTP636')
 ORDER BY Id_Item DESC;


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = Top Style
/*****************************************************************************/
SELECT DISTINCT
	 Item_SubClass,
	 Id_Item,
	 Item_Long_Desc,
	 Id_Item_Template,
	 Price,
	 Print_Character = NULL
 FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	AND Id_Line IN ('ARTP634', 'ARTP635', 'ARTP636')
	AND Id_Item_Class = 'COMP'
	AND Id_Item_SubClass IN ('TOPSTYLE')
 ORDER BY Id_Item ASC, Id_Item_Template DESC;

/*****************************************************************************/
-- QUERY 3 -  SUBCLASS = Mirror / Storage
/*****************************************************************************/
 SELECT DISTINCT
	 Item_SubClass,
	 Id_Item,
	 Item_Long_Desc,
	 Id_Item_Template,
	 Price,
	 Print_Character = NULL
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	 AND Id_Line IN ('ARTP634', 'ARTP635', 'ARTP636')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('MIRRORSTOR')
 ORDER BY Id_Item ASC, Id_Item_Template DESC;

/*****************************************************************************/
-- QUERY 4 -  SUBCLASS = Accesorios
/*****************************************************************************/
 SELECT DISTINCT
	 Item_SubClass,
	 Id_Item,
	 Item_Long_Desc,
	 Id_Item_Template,
	 Price,
	 Print_Character = NULL
 FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	AND Id_Line IN ('ARTP634', 'ARTP635', 'ARTP636')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass IN ('FURNACCESS')
 ORDER BY Id_Item ASC, Id_Item_Template DESC;