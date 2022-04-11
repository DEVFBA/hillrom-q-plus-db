USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_OBTP0094##
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_OBTP0094##'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_OBTP0094##]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_OBTP0094##
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_OBTP0094##
Date:		21/12/2021
Example:

	EXEC spPDF_Layout_Get_Info_OBTP0094## 


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_OBTP0094##
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
	Id_Line IN ('P009497', 'P009498')
ORDER BY Id_Item DESC


/*****************************************************************************/
-- QUERY 2 -  Accessories
/*****************************************************************************/
SELECT DISTINCT
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character = NULL
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD')
	AND Id_Line IN ('P009497', 'P009498')
	AND Id_Item_Class = 'ACCE'
ORDER BY Id_Item
