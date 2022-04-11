USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_CH700B3
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_CH700B3'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_CH700B3]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_CH700B3
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_CH700B3
Date:		09/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_CH700B3 


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_CH700B3
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
 AND Id_Line in ('CH700B3')
 ORDER BY Id_Item ASC;


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = HINGE
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
 AND Id_Line in ('CH700B3')
 AND Id_Item_Class = 'COMP'
 AND Id_Item_SubClass IN ('HINGE')
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
	 AND Id_Line in ('CH700B3')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('PLADRAWINS')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 4 -  SUBCLASS = Fixed strip or sliding tray
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
	 AND Id_Line in ('CH700B3')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('FIXEDSLIDI')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 5 -  SUBCLASS = CASTORS
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
	 AND Id_Line in ('CH700B3')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('CASTORS')
 ORDER BY Id_Item

 /*****************************************************************************/
-- QUERY 6 -  SUBCLASS = Acessory Bar Holder
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
	 AND Id_Line in ('CH700B3')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('ACCEBARHOL')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 7 -  SUBCLASS = Additional Options
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
	 AND Id_Line in ('CH700B3')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass NOT IN ('ACCEBARHOL', 'CASTORS', 'FIXEDSLIDI', 'PLADRAWINS','HINGE', 'FIXSHECOLO', 'HANDLES', 'FIXSLICOLO', 'COLORS')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 8 -  SUBCLASS = COLORS
/*****************************************************************************/
SELECT DISTINCT
	Item_SubClass,
	Id_Item = (CASE Id_Item_SubClass 
						WHEN 'FIXSHECOLO' THEN 'see colour table'
						WHEN 'FIXSLICOLO' THEN 'see colour table.'
					  END),
	Item_Long_Desc = (CASE Id_Item_SubClass 
						WHEN 'FIXSHECOLO' THEN 'for fixed shelf'
						WHEN 'FIXSLICOLO' THEN 'for fixed strip or sliding tray'
					  END),
	Id_Item_Template,
	Price,
	Print_Character = NULL
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	AND Id_Line in ('CH700B3')
	AND Id_Item_Class = 'COMP'
	AND Id_Item_SubClass IN ('FIXSHECOLO', 'FIXSLICOLO')
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 9 -  SUBCLASS = Handles
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
	 AND Id_Line in ('CH700B3')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('HANDLES')
 ORDER BY Id_Item