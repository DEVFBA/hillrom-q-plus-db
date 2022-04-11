USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_HRRP870
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_HRRP870'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_HRRP870]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_HRRP870
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_HRRP870
Date:		09/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_HRRP870 


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_HRRP870
AS

/*****************************************************************************/
-- QUERY 1 - Lista de Precios
/*****************************************************************************/
SELECT
	Id_Line,
	Id_Item,
	Item_Long_Desc,
	Price
FROM vwItems_Templates
WHERE Id_Item_SubClass = 'PROD'
	AND Id_Line in ('HRRP870')
ORDER BY Id_Item DESC

/*****************************************************************************/
-- QUERY 2 - Componentes ‘Sin Sección’.
/*****************************************************************************/
SELECT DISTINCT
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character = (CASE WHEN [Default] = 1 THEN '*'
							ELSE NULL
						END)
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	AND Id_Line in ('HRRP870')
	AND Id_Item_Class = 'COMP'
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 3 - Accesorios ‘MISCACCESSORIES
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'MDG',
	Item_Long_Desc = Item_Long_Desc,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	AND Id_Line in ('HRRP870')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass = 'BEDACCESOR'
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 4 - Accesorios ‘RESIDENTACC’
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'RSB',
	Item_Long_Desc = Item_Long_Desc,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	AND Id_Line in ('HRRP870')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass = 'RESIDACCES'
ORDER BY Id_Item
