USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_TRCHANA
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_TRCHANA'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_TRCHANA]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_TRCHANA
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_TRCHANA
Date:		09/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_TRCHANA 


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_TRCHANA
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
 AND Id_Line in ('TRCHANA')
 ORDER BY Id_Item DESC;


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = CASTORS
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
	 AND Id_Line in ('TRCHANA')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('CASTORS')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 3 -  SUBCLASS = Accessories
/*****************************************************************************/
SELECT DISTINCT
	 KitName = (CASE Id_Item WHEN 'AD297A' THEN 'IVPOLE'
							 ELSE 'FURNACC'
				END),
	 Item_Long_Desc = Item_Long_Desc,
	 Part = Id_Item,
	 Price = Price
	 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
 AND Id_Line in ('TRCHANA')
 AND Id_Item_Class = 'ACCE'
 ORDER BY Id_Item