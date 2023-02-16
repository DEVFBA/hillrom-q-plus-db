USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_HIRO900
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_HIRO900'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_HIRO900]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_HIRO900
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_HIRO900
Date:		09/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_HIRO900


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_HIRO900
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
 AND Id_Line in ('HIRO900')
 ORDER BY Id_Item DESC;


/*****************************************************************************/
-- QUERY 2 -  SUBCLASS = Sin Sección
/*****************************************************************************/
SELECT DISTINCT
	 Item_SubClass,
	 Id_Item,
	 Item_Long_Desc,
	 Price,
	 Print_Character = (CASE WHEN Required = 1 AND [Default] = 1 THEN '*'
							 ELSE NULL
						END)
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	 AND Id_Line in ('HIRO900')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('BEDEXTENDE', 'HEADSECTIO', 'NURSECALL','NIGHTLIGHT','EACHAFLAPO', 'BRAOFFALAR','HILOPEDAL', 'SAFWORKLOA','FOOTBOPEND') -- AZR Se quita el 'ACCEBARHOL' a solicitud de Alexis
 AND Id_Item NOT IN ('220K', 'MHS')
 
 UNION
 
 SELECT
	 Item_SubClass = 'KIT',
	 Id_Item = 'SHO + NL',
	 Item_Long_Desc = 'Shock Position and Night Light with bilateral caregiver control panel (not compatible)',
	 Price = (	SELECT	Price
				FROM Items_Template_Kits
				WHERE Item_Template = 'HR900 X3' AND Id_Template_Kit = 4),
	Print_Character = NULL

 UNION
 
 SELECT
	 Item_SubClass = 'KIT',
	 Id_Item = 'SHO + NL + BOA',
	 Item_Long_Desc = 'Shock Position, Night Light and Brake-off indicator with bilateral caregiver control panel (not compatible with 250K)',
	 Price = (	SELECT Price
				 FROM Items_Template_Kits
				 WHERE Item_Template = 'HR900 X3' AND Id_Template_Kit = 2),
	Print_Character = NULL


/*****************************************************************************/
-- QUERY 3 -  SUBCLASS = Controls
/*****************************************************************************/
SELECT DISTINCT
	 Item_SubClass,
	 Id_Item,
	 Item_Long_Desc,
	 Price,
	 Print_Character = NULL
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	 AND Id_Line in ('HIRO900')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('BEDCONTROL')
 ORDER BY Id_Item
/*****************************************************************************/
-- QUERY 4 -  SUBCLASS = Brake and Steer
/*****************************************************************************/
SELECT DISTINCT
	 Item_SubClass,
	 Id_Item,
	 Item_Long_Desc,
	 Price,
	 Print_Character = NULL
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	 AND Id_Line in ('HIRO900')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('BRAKE')
	 AND [Default] = 0
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 5 -  SUBCLASS = Castors
/*****************************************************************************/
SELECT DISTINCT
	 Item_SubClass,
	 Id_Item,
	 Item_Long_Desc,
	 Price,
	 Print_Character = NULL
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	 AND Id_Line in ('HIRO900')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('CASTORS')
	 AND [Default] = 0
 ORDER BY Id_Item

/*****************************************************************************/
-- QUERY 6 -  SUBCLASS = Steering Wheel
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
	 AND Id_Line in ('HIRO900')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('STEERING')
	 AND [Default] = 0
 ORDER BY Id_Item

 /*****************************************************************************/
-- QUERY 7 -  SUBCLASS = Plug & Voltage
/*****************************************************************************/
SELECT DISTINCT
	 Item_SubClass,
	 Id_Item,
	 Item_Long_Desc,
	 Price,
	 Print_Character = (CASE WHEN Id_Item = 'EU' THEN '*'
							 WHEN Id_Item = '230V' THEN '*'
							 ELSE NULL
						END)
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	 AND Id_Line in ('HIRO900')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('PLUG', 'VOLTAGE')
	 AND Id_Item NOT IN ('110v', '115V', '127V', '220V', '240V','Bi120230V', 'BIVOLT 120 230V', 'CA', 'NZ')
 ORDER BY Id_Item


 /*****************************************************************************/
-- QUERY 8 -  SUBCLASS = BEDEXITALR
/*****************************************************************************/
SELECT DISTINCT
	 Item_SubClass,
	 Id_Item,
	 Item_Long_Desc,
	 Price,
	 Print_Character = NULL
 FROM vwItems_Templates
 WHERE Id_ItemTemplate_Class IN ('PROD', 'ACCE')
	 AND Id_Line in ('HIRO900')
	 AND Id_Item_Class = 'COMP'
	 AND Id_Item_SubClass IN ('BEDEXITALR')


 UNION
 
 SELECT
	 Item_SubClass = 'KIT',
	 Id_Item = 'BEA + WCO + NL + BOA',
	 Item_Long_Desc = '3 Mode Bed Exit Alarm + 37 pin Wired connection + Intelligent night light (requires SHS)',
	 Price = (	SELECT Price
				FROM Items_Template_Kits
				WHERE Item_Template = 'HR900 X3' AND Id_Template_Kit = 3),
	 Print_Character = NULL

 ORDER BY Id_Item