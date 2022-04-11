USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_BEDSPRE
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_BEDSPRE'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_BEDSPRE]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_BEDSPRE
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_BEDSPRE
Date:		09/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_BEDSPRE 


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_BEDSPRE
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
	AND Id_Line IN ('BEDSPRE')
 ORDER BY Id_Item DESC;


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = Componentes
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
	AND Id_Line IN ('BEDSPRE')
	AND Id_Item_Class = 'COMP'
	AND Id_Item_SubClass IN ('LOCK')
 ORDER BY Id_Item;