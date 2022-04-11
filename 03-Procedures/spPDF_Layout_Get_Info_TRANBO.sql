USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_TRANBO
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_TRANBO'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_TRANBO]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_TRANBO
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_TRANBO
Date:		12/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_TRANBO


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_TRANBO
AS

/*****************************************************************************/
-- QUERY 1 -  LISTAS DE PRECIOS
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'TRANSFERBOARD',
	Item_Long_Desc = Item_Long_Desc,
	Part = Id_Item,
	Size = Measurements,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	AND Id_Line in ('TRANBO')
	AND Id_Item_Class = 'PROD'
ORDER BY Id_Item