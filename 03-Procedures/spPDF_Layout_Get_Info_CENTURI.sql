USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_CENTURI
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_CENTURI'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_CENTURI]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_CENTURI
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_CENTURI
Date:		21/12/2021
Example:

	EXEC spPDF_Layout_Get_Info_CENTURI 


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_CENTURI
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
	Id_Line in ('CENTURI')
ORDER BY Id_Item DESC


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = STEERING - Steering
/*****************************************************************************/
SELECT DISTINCT
--	Id_Item_SubClass,
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character = (CASE WHEN Required = 1 AND [Default] = 1 THEN '*'
					   ELSE NULL
					   END)
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('CENTURI') AND
	Id_Item_SubClass IN ('STEERING') AND 
	Id_Item_Class = 'COMP'
ORDER BY Print_Character DESC, Id_Item

/*****************************************************************************/
-- QUERY 3 -  SUBCLASS = BEDEXTENDE - Bed Extender
/*****************************************************************************/
SELECT DISTINCT
--	Id_Item_SubClass,
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character = (CASE WHEN Required = 1 AND [Default] = 1 THEN '*'
					   ELSE NULL
					   END)
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('CENTURI') AND
	ID_Item_SubClass = 'BEDEXTENDE' AND 
	Id_Item_Class = 'COMP'
ORDER BY Id_Item


/*****************************************************************************/
-- QUERY 4 -  SUBCLASS = PLUG - VOLTAGE
/*****************************************************************************/
SELECT DISTINCT
	--Id_Item_SubClass,
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character = (CASE WHEN Required = 1 AND [Default] = 1 THEN '*'
							WHEN Id_Item IN ('EU', '220V') THEN '*'
					   ELSE NULL
					   END),
	[DEFAULT]
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('CENTURI') AND
	Id_Item_SubClass IN ('PLUG', 'VOLTAGE') AND
	[Default] = 0 AND 
	Id_Item_Class = 'COMP' AND
	Id_Item NOT IN ('110V', '115V', '127V', '230V', '240V', 'AU', 'BZ', 'CA', 'NZ', 'BIVOLT 120 230V')
ORDER BY Id_Item




