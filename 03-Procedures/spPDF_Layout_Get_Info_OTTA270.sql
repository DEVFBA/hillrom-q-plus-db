USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_OTTA270
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_OTTA270'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_OTTA270]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_OTTA270
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_OTTA270
Date:		09/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_OTTA270 


*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_OTTA270
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
 AND Id_Line in ('OTTA270')
 ORDER BY Id_Item ASC;

