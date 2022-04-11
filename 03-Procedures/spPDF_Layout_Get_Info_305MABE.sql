USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_305MABE
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_305MABE'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_305MABE]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_305MABE
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_305MABE
Date:		13/03/2021
Example:

	EXEC spPDF_Layout_Get_Info_305MABE 


*/

CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_305MABE
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
	Id_Line in ('305MABE')
ORDER BY Id_Item DESC


/*****************************************************************************/
-- QUERY 2 -  Accesorios ‘Country of Origin; USA’.
/*****************************************************************************/
SELECT DISTINCT
	 KitName = (CASE WHEN IT.Id_Item_SubClass = 'NP50SUR' THEN 'NP50MAT'
	 ELSE 'NP100MAT'
	 END),
	 Item_Long_Desc = IT.Item_Long_Desc,
	 Size = I.Measurements,
	 Part = IT.Id_Item,
	 Price = IT.Price
 FROM vwItems_Templates AS IT 
 INNER JOIN Cat_Item AS I
 ON IT.Id_Item = I.Id_Item
 WHERE IT.Id_Line in ('305MABE')
 AND IT.Id_Item_Class = 'ACCE'
 AND IT.Id_Item_SubClass IN ('NP50SUR', 'NP100SUR')
 ORDER BY IT.Id_Item DESC;

/*****************************************************************************/
-- QUERY 3 -  Accesorios ‘Country of Origin CHINA’
/*****************************************************************************/
SELECT DISTINCT
	 KitName = 'SURFACE',
	 Item_Long_Desc = IT.Item_Long_Desc,
	 Size = I.Measurements,
	 Part = IT.Id_Item,
	 Price = IT.Price
 FROM vwItems_Templates AS IT 
 INNER JOIN Cat_Item AS I
 ON IT.Id_Item = I.Id_Item
 WHERE IT.Id_Line in ('305MABE')
 AND IT.Id_Item_Class = 'ACCE'
 AND IT.Id_Item_SubClass = 'CHINASURFA'
 ORDER BY IT.Id_Item DESC;


/*****************************************************************************/
-- QUERY 4 -  Accesorios ‘Accessories – Country of Origin Accessories: USA (unless stated otherwise)’
/*****************************************************************************/
SELECT
	 KitName = 'ENTER AS END ITEM',
	 Item_Long_Desc = Item_Long_Desc,
	 Part = Id_Item,
	 Price = Price
 FROM vwItems_Templates
 WHERE Id_Line in ('305MABE')
 AND Id_Item_Class = 'ACCE'
 AND Id_Item_SubClass = 'IVPOLE'
 ORDER BY Id_Item DESC;
