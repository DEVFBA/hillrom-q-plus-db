USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_SEAFURN
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_SEAFURN'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_SEAFURN]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_SEAFURN
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_SEAFURN
Date:		09/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_SEAFURN 


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_SEAFURN
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
	 AND Id_Line IN ('RECP9180A', 'RECP9190A')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('UPHOLSTERY')
 ORDER BY Id_Item


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = Accessories
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
	 AND Id_Line IN ('RECP9180A', 'RECP9190A')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass NOT IN ('UPHOLSTERY')
 ORDER BY Id_Item;