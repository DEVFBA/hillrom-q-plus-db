USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_MEDSURGACC
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_MEDSURGACC'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_MEDSURGACC]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_MEDSURGACC
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_MEDSURGACC
Date:		12/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_MEDSURGACC


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_MEDSURGACC
AS

/*****************************************************************************/
-- QUERY 1 - Accesorios Bag Holders
/*****************************************************************************/
SELECT DISTINCT
	 KitName = Id_Item_SubClass,
	 Part = Id_Item,
	 Item_Long_Desc = Item_Long_Desc,
	 Item_Template = Id_Item_Template,
	 Price = Price
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD')
	 AND Id_Item_Class = 'ACCE'
	 AND Id_Item_Template IN ('HR900 X3', 'ACCELLA', 'CENTURISX3')
	 AND Id_Item_SubClass = 'BAGHOLDER'
 ORDER BY Id_Item;


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = Bottle Holder
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'BOTTLEHOLDER',
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Item_Template = Id_Item_Template,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_Template IN ('HR900 X3', 'ACCELLA', 'CENTURISX3')
	AND Id_Item_SubClass = 'BOTTHOLDER'
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 3 -  SUBCLASS = Controls
/*****************************************************************************/
SELECT DISTINCT
	KitName = (CASE Id_Item 
					WHEN 'AD280A' THEN 'CONTROLMODULES'
					WHEN 'AD283A' THEN 'CONTROLMODULES'
					ELSE 'CONTROLPENDANT'
			   END),
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Item_Template = Id_Item_Template,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_Template IN ('HR900 X3', 'ACCELLA', 'CENTURISX3')
	AND Id_Item_SubClass IN ('CONTROLS')
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 4 -  SUBCLASS = Support Accessories’
/*****************************************************************************/
SELECT DISTINCT
/*	KitName = (CASE Id_Item WHEN 'AC968A' THEN 'FURNACC'
			ELSE 'SUPPORTACC'
			END),*/ 
	KitName = 'SUPPORTACC',--20220913 Ajuste Alexis
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Item_Template = Id_Item_Template,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_Template IN ('HR900 X3', 'ACCELLA', 'CENTURISX3')
	AND Id_Item_SubClass IN ('FURNISUPPO')
	AND Id_Item NOT IN ('AC968A','AD325A' ) --20220913 Ajuste Alexis

UNION ALL --AZR 20220920 - Ajuste a solicitud de Alexis

SELECT DISTINCT
	KitName = 'SUPPORTACC',
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Item_Template = Id_Item_Template,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_Template IN ('HR900 X3', 'ACCELLA', 'CENTURISX3')
	and Id_Item  IN ('AD286A') --AZR 20220920 - Ajuste a solicitud de Alexis
	AND Id_Item_SubClass IN ('MEDSURACCE')
ORDER BY Id_Item


/*****************************************************************************/
-- QUERY 5 -  SUBCLASS = Tank Holder
/*****************************************************************************/
SELECT DISTINCT
	KitName = Id_Item_SubClass,
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Item_Template = Id_Item_Template,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_Template IN ('HR900 X3', 'ACCELLA', 'CENTURISX3')
	AND Id_Item_SubClass IN ('TANKHOLDER')
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 6 -  SUBCLASS = Lifpole
/*****************************************************************************/
SELECT DISTINCT
	KitName = Id_Item_SubClass,
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Item_Template = Id_Item_Template,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_Template IN ('HR900 X3', 'ACCELLA', 'CENTURISX3')
	AND Id_Item_SubClass IN ('LIFTPOLE')
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 7 -  SUBCLASS = IV Pole
/*****************************************************************************/
SELECT DISTINCT
	KitName = Id_Item_SubClass,
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Item_Template = Id_Item_Template,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_Template IN ('HR900 X3', 'ACCELLA', 'CENTURISX3')
	AND Id_Item_SubClass IN ('IVPOLE')
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 8 -  SUBCLASS = Option Upgrade
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'OPTIONUPGRADE',
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Item_Template = Id_Item_Template,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_Template IN ('HR900 X3', 'ACCELLA', 'CENTURISX3')
	AND Id_Item_SubClass IN ('OPTIUPGRAD')
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 9 -  SUBCLASS = Siderail Accessories
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'SIDERAILACC',
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Item_Template = Id_Item_Template,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_Template IN ('HR900 X3', 'ACCELLA', 'CENTURISX3')
	AND Id_Item_SubClass IN ('SIDRAACCE')
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 10 -  SUBCLASS = 
/*****************************************************************************/
SELECT DISTINCT
	KitName = Id_Item_SubClass,
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Item_Template = Id_Item_Template,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_Template IN ('HR900 X3', 'ACCELLA', 'CENTURISX3')
	AND Id_Item_SubClass IN ('TRAYS')
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 11 -  SUBCLASS = Traction
/*****************************************************************************/
SELECT DISTINCT
	KitName = 'TRACTION',
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Item_Template = Id_Item_Template,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_Template IN ('HR900 X3', 'ACCELLA', 'CENTURISX3')
	and Id_Item NOT IN ('AD286A') --AZR 20220920 - Ajuste a solicitud de Alexis
	AND Id_Item_SubClass IN ('MEDSURACCE')
ORDER BY Id_Item


/*****************************************************************************/
-- QUERY 12 -  SUBCLASS = Furniture & Support Accessories’ -- 20220913 Ajuste Alexis
/*****************************************************************************/
SELECT DISTINCT
	KitName = (CASE Id_Item WHEN 'AC968A' THEN 'FURNACC'
				ELSE 'SUPPORTACC'
				END),
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Item_Template = Id_Item_Template,
	Price = Price
FROM vwItems_Templates
WHERE Id_ItemTemplate_Class IN ('PROD')
	AND Id_Item_Class = 'ACCE'
	AND Id_Item_Template IN ('HR900 X3', 'ACCELLA', 'CENTURISX3')
	AND Id_Item_SubClass IN ('FURNISUPPO')
	AND Id_Item IN ('AC968A','AD325A' )