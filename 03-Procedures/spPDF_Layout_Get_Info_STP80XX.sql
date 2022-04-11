USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_STP80XX
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_STP80XX'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_STP80XX]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_STP80XX
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_STP80XX
Date:		21/12/2021
Example:

	EXEC spPDF_Layout_Get_Info_STP80XX 


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_STP80XX
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
 AND Id_Family in ('STR')
 ORDER BY Id_Item ASC;


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = Deck Width
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
		AND Id_Family in ('STR')
		AND Id_Item_Class = 'COMP'
		AND Id_Item_SubClass IN ('DECKWIDTH')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 3 -  SUBCLASS = SURFACE
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
	 AND Id_Family in ('STR')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('SURFACE')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 4 -  SUBCLASS = PUSHHANDLE (standard colour: grey/with O2 tank holder colour: blue)
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
	 AND Id_Family in ('STR')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('PUSHHANDLE')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 5 -  SUBCLASS = IV pole type/location
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
	 AND Id_Family in ('STR')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('IVPOLETYLO')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 6 -  SUBCLASS = IV pole transport push handles (not available with handbrake - HB)
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
	 AND Id_Family in ('STR')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('IVPOLETRHA')
 ORDER BY Id_Item

 /*****************************************************************************/
-- QUERY 7 -  SUBCLASS = STEERING
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
	 AND Id_Family in ('STR')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('STEERING')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 8 -  SUBCLASS = Brake Pedals
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
	 AND Id_Family in ('STR')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('BRAKEPEDAL')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 9 -  SUBCLASS = Surface
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
 AND Id_Family in ('STR')
 AND Id_Item_Class = 'COMP'
 AND Id_Item_SubClass IN ('RADIOSURFA')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 10 -  SUBCLASS = 
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
	 AND Id_Family in ('STR')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('HYDRCONPED')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 11 -  SUBCLASS = SIDERAILS
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
	 AND Id_Family in ('STR')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('SIDERAILS')
 ORDER BY Id_Item


/*****************************************************************************/
-- QUERY 12 -  SUBCLASS = 
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
	 AND Id_Family in ('STR')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('BUMPCOLORS')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 13 -  SUBCLASS = Additional Options
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
	 AND Id_Family in ('STR')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('BACKSAFOWL', 'AUTOCONTOU', 'KNEEGATCH','UPRIGCAHOL', 'SCALE', 'O2TANK')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 14 -  SUBCLASS = Surfaces
/*****************************************************************************/
SELECT DISTINCT
	 KitName = 'STRETCHERMAT',
	 Item_Long_Desc = Item_Long_Desc,
	 Id_Item_Template,
	 Part = Id_Item,
	 Price = Price
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD')
	 AND Id_Family in ('STR')
	 AND Id_Item_Class = 'ACCE'
	 AND Id_Item_SubClass = 'STRETSURFA'
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 15 -  SUBCLASS = Sin Subsección
/*****************************************************************************/
SELECT DISTINCT
	 KitName = (CASE WHEN Id_Item_SubClass = 'MISCACCESO' THEN 'MISCACCESSORIES'
					ELSE 'STRETCHERAACC'
				END),
	 Item_Long_Desc = Item_Long_Desc,
	 Part = Id_Item,
	 Price = Price
	 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD')
	 AND Id_Family in ('STR')
	 AND Id_Item_Class = 'ACCE'
	 AND Id_Item_SubClass IN ('MISCACCESO', 'STRETACCES')
	 AND Id_Item NOT IN ('P265', 'P35745AT', 'P262A01', 'P262A02', 'P263', 'P449', 'P261EC')
 ORDER BY KitName, Id_Item

/*****************************************************************************/
-- QUERY 16 -  SUBCLASS = Following for OB/GYN only
/*****************************************************************************/
SELECT DISTINCT
	 KitName = (CASE WHEN Id_Item_SubClass = 'MISCACCESO' THEN 'MISCACCESSORIES'
					 ELSE 'STRETCHERAACC'
				END),
	 Item_Long_Desc = Item_Long_Desc,
	 Part = Id_Item,
	 Price = Price
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD')
	 AND Id_Family in ('STR')
	 AND Id_Item_Class = 'ACCE'
	 AND Id_Item_SubClass IN ('MISCACCESO', 'STRETACCES')
	 AND Id_Item IN ('P265', 'P35745AT')
 ORDER BY KitName, Id_Item

/*****************************************************************************/
-- QUERY 17 -  SUBCLASS = Following for Surgical only
/*****************************************************************************/
SELECT DISTINCT
		KitName = (CASE WHEN Id_Item_SubClass = 'MISCACCESO' THEN 'MISCACCESSORIES'
						ELSE 'STRETCHERAACC'
					END),
		Item_Long_Desc = Item_Long_Desc,
		Part = Id_Item,
		Price = Price
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD')
	 AND Id_Family in ('STR')
	 AND Id_Item_Class = 'ACCE'
	 AND Id_Item_SubClass IN ('MISCACCESO', 'STRETACCES')
	 AND Id_Item IN ('P262A01', 'P262A02', 'P263', 'P449', 'P261EC')
 ORDER BY KitName, Id_Item	