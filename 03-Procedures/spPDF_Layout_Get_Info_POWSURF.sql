USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_POWSURF
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_POWSURF'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_POWSURF]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_POWSURF
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_POWSURF
Date:		12/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_POWSURF


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_POWSURF
AS

/*****************************************************************************/
-- QUERY 1 -  SUBCLASS = P290 ‘Overlay’
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'AIRMATTRESS',
	Model = Item_Model,
	Item_Long_Desc = Item_Long_Desc,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('ACCE')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass IN ('POWSURFA')
	AND Item_Model = 'P290'
ORDER BY Id_Item;

/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = P290 ‘Replacement with foam base’.
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'AIRMATTRESS',
	Model = Item_Model,
	Item_Long_Desc = Item_Long_Desc,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('ACCE')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass IN ('POWSURFA')
	AND Item_Model = 'P290MRS'
ORDER BY Id_Item;

/*****************************************************************************/
-- QUERY 3 -  SUBCLASS = P290 ‘Replacement with full air’
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'AIRMATTRESS',
	Model = Item_Model,
	Item_Long_Desc = Item_Long_Desc,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('ACCE')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass IN ('POWSURFA')
	AND Item_Model = 'P290AIR'
ORDER BY Id_Item;


/*****************************************************************************/
-- QUERY 4 -  SUBCLASS = ACCELLA Therapy.
/*****************************************************************************/
SELECT DISTINCT
	 KitName = 'AIRMATTRESS',
	 Model = 'AD307A(*)',
	 Item_Long_Desc = Item_Long_Desc,
	 Part = Id_Item,
	 Price = Price
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('ACCE')
	 AND Id_Item_Class = 'ACCE'
	 AND Id_Item_SubClass IN ('POWSURFA')
	 AND Item_Model IN ('AD307A', 'P006789A')
 ORDER BY Id_Item;


/*****************************************************************************/
-- QUERY 5 -  SUBCLASS = Surfaces Surface Covers - Viscoelastic
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'AIRMATTRESS',
	Model = Item_Model,
	Item_Long_Desc = Item_Long_Desc,
	Part = Id_Item,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('ACCE')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_SubClass IN ('POWSURFA')
	AND Item_Model = 'P260'
ORDER BY Id_Item