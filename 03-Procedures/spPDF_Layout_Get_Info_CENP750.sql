USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_CENP750
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_CENP750'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_CENP750]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_CENP750
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_CENP750
Date:		21/12/2021
Example:

	EXEC spPDF_Layout_Get_Info_CENP750 


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_CENP750
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
	Id_Line in ('CENP750')
ORDER BY Id_Item DESC


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = BRAKE - Brake
/*****************************************************************************/
SELECT DISTINCT
--	Id_Item_SubClass,
	Item_SubClass,
	Id_Item,
	Item_Long_Desc,
	Id_Item_Template,
	Price,
	Print_Character = NULL
	
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('CENP750') AND
	Id_Item_SubClass IN ('BRAKE') 
ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 3 -  SUBCLASS = Country of origin
/*****************************************************************************/
SELECT
	Item_SubClass	= 'Country of Origin',
	Id_Item			= 'C',
	Item_Long_Desc	= 'China',
	Id_Item_Template= 'CENTURIS C',
	Price			= 0 ,
	Print_Character = NULL


/*****************************************************************************/
-- QUERY 4 -  SUBCLASS = VOLTAGE
/*****************************************************************************/
SELECT
	Item_SubClass	= 'Voltage' ,
	Id_Item			= '1',
	Item_Long_Desc	= '110-130 V',
	Id_Item_Template= 'CENTURIS C',
	Price			= 0 ,
	Print_Character = NULL
UNION
SELECT
	Item_SubClass	= 'Voltage' ,
	Id_Item			= '2',
	Item_Long_Desc	= '210-240 V',
	Id_Item_Template= 'CENTURIS C',
	Price			= 0 ,
	Print_Character = NULL


/*****************************************************************************/
-- QUERY 5 -  SUBCLASS = SURFACES - FRANSURFA
/*****************************************************************************/
--Country of Origin: France
SELECT DISTINCT
	KitName			= 'MATTRESS',Id_Item_SubClass,
	Model			= Item_Model,
	Size_Code		= '16',
	Item_Long_Desc	= Item_Long_Desc,
	Item_Short_Desc = Item,
	Part			= Id_Item,
	Price			= Price
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('CENP750') AND
	Id_Item_SubClass =  'FRANSURFA' AND 
	Id_Item_Class = 'ACCE'
ORDER BY Id_Item

--Country of Origin: USA
SELECT DISTINCT
	KitName			= Id_Item_SubClass,
	Item_Long_Desc	= Item_Long_Desc,
	Part			= Id_Item,
	Price			= Price
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('CENP750') AND
	Id_Item_SubClass IN('NP50SUR','NP100SUR','ACCUMSURFA') AND 
	Id_Item_Class = 'ACCE'
ORDER BY Id_Item


--Country of Origin: China
SELECT DISTINCT
	KitName			= Id_Item_SubClass,
	Item_Long_Desc	= Item_Long_Desc,
	Part			= Id_Item,
	Price			= Price
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('CENP750') AND
	Id_Item_SubClass =  'CHINASURFA' AND 
	Id_Item_Class = 'ACCE'
ORDER BY Id_Item


/*****************************************************************************/
-- QUERY 6 -  SUBCLASS = ACCESORIES
/*****************************************************************************/
SELECT DISTINCT
	KitName			= 'ENTER AS END ITEM',
	Item_Long_Desc	= Item_Long_Desc,
	Part			= Id_Item,
	Price			= Price		
FROM vwItems_Templates
WHERE 
	Id_ItemTemplate_Class IN ('PROD', 'ACCE') AND
	Id_Line in ('CENP750') AND
	Id_Item_SubClass IN ('TANKHOLDER', 'IVPOLE', 'MISCACCESO','LINEMANAG') AND 
	Id_Item_Class = 'ACCE'
ORDER BY Id_Item




