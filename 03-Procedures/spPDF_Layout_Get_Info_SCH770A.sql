USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_SCH770A
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_SCH770A'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_SCH770A]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_SCH770A
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_SCH770A
Date:		09/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_SCH770A 


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_SCH770A
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
 AND Id_Line in ('SCH770A')
 ORDER BY Id_Item ASC;


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = Overbed table
/*****************************************************************************/
SELECT DISTINCT
	 Item_SubClass,
	 Id_Item,
	 Item_Long_Desc,
	 Id_Item_Template,
	 Price,
	 Print_Character = (CASE WHEN Required = 1 AND [Default] = 1 THEN '*'
						 ELSE NULL
						END)
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	 AND Id_Line in ('SCH770A')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('OVERBEDTAB')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 3 -  SUBCLASS = Plastic drawer insert
/*****************************************************************************/
SELECT DISTINCT
	 Item_SubClass,
	 Id_Item,
	 Item_Long_Desc,
	 Id_Item_Template,
	 Price,
	 Print_Character = (CASE WHEN Required = 1 AND [Default] = 1 THEN '*'
							 ELSE NULL
						END)
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	 AND Id_Line in ('SCH770A')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('PLADRAWINS')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 4 -  SUBCLASS = Towel Holder
/*****************************************************************************/
SELECT DISTINCT
	 Item_SubClass,
	 Id_Item,
	 Item_Long_Desc = 'yes - available upon request',
	 Id_Item_Template,
	 Price,
	 Print_Character = (CASE WHEN Required = 1 AND [Default] = 1 THEN '*'
							 ELSE NULL
						END)
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	 AND Id_Line in ('SCH770A')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('TOWELHOLD')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 5 -  SUBCLASS = 2 x single bottle hold
/*****************************************************************************/
SELECT DISTINCT
	 Item_SubClass,
	 Id_Item,
	 Item_Long_Desc		= 'yes - available upon request',
	 Id_Item_Template,
	 Price,
	 Print_Character	= (CASE WHEN Required = 1 AND [Default] = 1 THEN '*'
								 ELSE NULL
						   END)
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	 AND Id_Line in ('SCH770A')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('BOTTHOLDER')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 6 -  SUBCLASS = COLORS
/*****************************************************************************/
SELECT DISTINCT
	Item_SubClass,
	Id_Item = 'see colour table',
	Item_Long_Desc = 'body / top plate and/or overbed table',
	Id_Item_Template,
	Price,
	Print_Character = NULL
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	AND Id_Line in ('SCH770A')
	AND Id_Item_Class = 'COMP'
	AND Id_Item_SubClass IN ('COLORS')

 UNION ALL

SELECT DISTINCT
	Item_SubClass,
	Id_Item = 'see colour table.',
	Item_Long_Desc = 'front (drawers and doors) and/or overbed table',
	Id_Item_Template,
	Price,
	Print_Character = NULL
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	AND Id_Line in ('SCH770A')
	AND Id_Item_Class = 'COMP'
	AND Id_Item_SubClass IN ('COLORS')

UNION ALL 

SELECT DISTINCT
	Item_SubClass,
	Id_Item = '.see colour table.',
	Item_Long_Desc = 'overbed table',
	Id_Item_Template,
	Price,
	Print_Character = NULL
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	AND Id_Line in ('SCH770A')
	AND Id_Item_Class = 'COMP'
	AND Id_Item_SubClass IN ('COLORS')
ORDER BY Id_Item
/*****************************************************************************/
-- QUERY 7 -  SUBCLASS = Handles
/*****************************************************************************/
SELECT DISTINCT
	 Item_SubClass,
	 Id_Item,
	 Item_Long_Desc,
	 Id_Item_Template,
	 Price,
	 Print_Character = (CASE WHEN Required = 1 AND [Default] = 1 THEN '*'
							 ELSE NULL
						END)
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	 AND Id_Line in ('SCH770A')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('HANDLES')
 ORDER BY Id_Item