USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_AFF4P37
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_AFF4P37'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_AFF4P37]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_AFF4P37
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_AFF4P37
Date:		21/12/2021
Example:

	EXEC spPDF_Layout_Get_Info_AFF4P37 


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_AFF4P37
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
	Id_Line in ('AFF4P37')
ORDER BY Id_Item ASC


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = SEATCUT - Seat Cut 
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
	 AND Id_Line in ('AFF4P37')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass = 'SEATCUT'
 ORDER BY Id_Item;

/*****************************************************************************/
-- QUERY 3 -  SUBCLASS = SURFOSESIZ - Surface Foot Section
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
	 AND Id_Line in ('AFF4P37')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass = 'SURFOSESIZ'
	 AND Id_Item NOT IN ('3.5')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 4 -  SUBCLASS = PUSHHANDLE|CALFSUPPOR	- Additional Options
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
	 AND Id_Line in ('AFF4P37')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('PUSHHANDLE', 'CALFSUPPOR')
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 5 -  SUBCLASS = SUR5HESECT - Surfaces Replacement Surfaces, 5" Head Section
/*****************************************************************************/
SELECT DISTINCT
	 KitName = 'AFFINITYMAT',
	 Item_Long_Desc = Item_Long_Desc,
	 Part = Id_Item,
	 Price = Price
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	 AND Id_Line in ('AFF4P37')
	 AND Id_Item_Class = 'ACCE'
	 AND Id_Item_SubClass = 'SUR5HESECT'
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 6 -  SUBCLASS = SU45FOSECT - Surfaces Replacement Surfaces, 4.5" Foot Section.
/*****************************************************************************/
SELECT DISTINCT
	 KitName = 'AFFINITYMAT',
	 Item_Long_Desc = Item_Long_Desc,
	 Part = Id_Item,
	 Price = Price
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
 AND Id_Line in ('AFF4P37')
 AND Id_Item_Class = 'ACCE'
 AND Id_Item_SubClass = 'SU45FOSECT'
 ORDER BY Id_Item

 /*****************************************************************************/
-- QUERY 7 -  SUBCLASS = SU35FOSECT - Surfaces Replacement Surfaces, 3.5" Foot Section
/*****************************************************************************/
SELECT DISTINCT
	 KitName = 'AFFINITYMAT',
	 Item_Long_Desc = Item_Long_Desc,
	 Part = Id_Item,
	 Price = Price
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	 AND Id_Line in ('AFF4P37')
	 AND Id_Item_Class = 'ACCE'
	 AND Id_Item_SubClass = 'SU35FOSECT'
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 8 -  SUBCLASS = Accessories
/*****************************************************************************/
SELECT DISTINCT
	 KitName = (CASE WHEN Id_Item_SubClass = 'MISCACCESO' THEN 'MISCACCESSORIES'
					ELSE 'AFFINITYAACC'
				END),
	 Item_Long_Desc = Item_Long_Desc,
	 Part = Id_Item,
	 Price = Price
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
 AND Id_Line in ('AFF4P37')
 AND Id_Item_Class = 'ACCE'
 AND Id_Item_SubClass IN ('MISCACCESO', 'AFFIACCESO')
 ORDER BY Id_Item