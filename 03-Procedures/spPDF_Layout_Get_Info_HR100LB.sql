USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_HR100LB
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_HR100LB'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_HR100LB]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_HR100LB
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_HR100LB
Date:		13/03/2021
Example:

	EXEC spPDF_Layout_Get_Info_HR100LB 


*/

CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_HR100LB
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
	Id_Line in ('HR100LB')
ORDER BY Id_Item DESC

