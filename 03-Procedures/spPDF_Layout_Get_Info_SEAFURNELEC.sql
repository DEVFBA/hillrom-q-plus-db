USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spPDF_Layout_Get_Info_SEAFURNELEC]    Script Date: 8/13/2024 2:25:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autor:		Angel Gutierrez
Desc:		Get spPDF_Layout_Get_Info_SEAFURNELEC
Date:		13/08/2024
Example:

	EXEC spPDF_Layout_Get_Info_SEAFURNELEC 


*/
ALTER PROCEDURE [dbo].[spPDF_Layout_Get_Info_SEAFURNELEC]
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
	 AND Id_Line IN ('RECP9181', 'RECP9191')
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
	 AND Id_Line IN ('RECP9181', 'RECP9191')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass NOT IN ('UPHOLSTERY')
 ORDER BY Id_Item;