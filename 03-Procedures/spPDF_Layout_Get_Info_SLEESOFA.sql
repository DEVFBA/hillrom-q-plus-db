USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_SLEESOFA
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_SLEESOFA'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_SLEESOFA]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_SLEESOFA
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_SLEESOFA
Date:		09/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_SLEESOFA 


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_SLEESOFA
AS

/*****************************************************************************/
-- QUERY 1 -  LISTAS DE PRECIOS
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
	 AND Id_Line IN ('SLSOP9176A', 'SLSOP9186A')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('UPHOLSTERY')
 ORDER BY Id_Item


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = Components
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
	 AND Id_Line IN ('SLSOP9176A', 'SLSOP9186A')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass NOT IN ('UPHOLSTERY')
 ORDER BY Id_Item;