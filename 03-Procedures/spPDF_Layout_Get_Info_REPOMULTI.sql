USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_REPOMULTI
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_REPOMULTI'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_REPOMULTI]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_REPOMULTI
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_REPOMULTI
Date:		12/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_REPOMULTI @pvIdZone = 'LIKMEX'


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_REPOMULTI
@pvIdZone	Varchar(10)
AS

/*****************************************************************************/
-- QUERY 1 - Accesorios ‘RepoSheet Original’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass IN ('REPOSHEETA')
	AND Item_Long_Desc LIKE 'RepoSheet Original%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 2 - Accesorios ‘SOLO REPOSHEET™ ORIGINAL’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass IN ('REPOSHEETA')
	AND Item_Long_Desc LIKE 'Solo RepoSheet%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 3 - Accesorios ‘MULTISTRAP™’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass IN ('MULTISTRAP')
	AND Item_Long_Desc LIKE 'MultiStrap%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 4 - Accesorios ‘SOLO MULTISTRAP™ - Solo MultiStrap’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass IN ('MULTISTRAP')
	AND Item_Long_Desc LIKE 'Solo MultiStrap%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 5 - Accesorios ‘SOLO MULTISTRAP™ - FixStrap’.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass IN ('MULTISTRAP')
	AND Item_Long_Desc LIKE 'FixStrap%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC