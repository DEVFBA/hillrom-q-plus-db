USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_SLEECHA
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_SLEECHA'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_SLEECHA]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_SLEECHA
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_SLEECHA
Date:		09/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_SLEECHA 


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_SLEECHA
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
	 AND Id_Line IN ('SLCHP9135A', 'SLCHP9145A')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('UPHOLSTERY')
 ORDER BY Id_Item;


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
	 AND Id_Line IN ('SLCHP9135A', 'SLCHP9145A')
	 AND Id_Item_Class = 'COMP'
	 --AND Id_Item_SubClass NOT IN ('UPHOLSTERY')
	 AND Id_Item_SubClass IN ('TRAYTABLE')-- 20220921 A solicitud de Alexis
 ORDER BY Id_Item