USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Prices_List_Get_Layouts
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Prices_List_Get_Layouts'
IF OBJECT_ID('[dbo].[spPDF_Prices_List_Get_Layouts]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Prices_List_Get_Layouts
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get Layouts 
Date:		20/01/2022
Example:

	EXEC spPDF_Prices_List_Get_Layouts @pvIdLayoutType = 'IPL', @pvIdZoneType = 'PDFIPL', @pvIdZone = 'IPLCHI'
	EXEC spPDF_Prices_List_Get_Layouts @pvIdLayoutType = 'LIKO', @pvIdZoneType = 'PDFLIK', @pvIdZone = 'IPLCHI'


	SELECT * FROM Cat_PDF_Layout_Types WHERE Id_Zone_Type =  'MLS-MLS-SABINA'

	MLS-MLS-SABINA





*/
CREATE PROCEDURE [dbo].spPDF_Prices_List_Get_Layouts
@pvIdLayoutType		Varchar(10) ,
@pvIdZoneType		Varchar(10),
@pvIdZone			Varchar(10) 
AS



SELECT DISTINCT I.Id_Layout,LA.Layout_Ref, LA.[Order]
	
	FROM Cat_Item I

	INNER JOIN Cat_PDF_Layouts LA ON
	I.Id_Layout = LA.Id_Layout AND
	LA.[Status] = 1

	INNER JOIN Cat_PDF_Layout_Types TL ON 
	LA.Id_Layout_Type = TL.Id_Layout_Type AND 
	TL.[Status] = 1

	INNER JOIN Cat_Zone_Types ZT ON 
	TL.Id_Zone_Type = ZT.Id_Zone_Type AND 
	ZT.[Status] = 1
	
	INNER JOIN Cat_Zones Z ON 
	ZT.Id_Zone_Type =  Z.Id_Zone_Type AND
	Z.Status = 1

	INNER JOIN Cat_Zones_Countries ZC ON 
	Z.Id_Zone = ZC.Id_Zone AND
	ZC.[Status] = 1

	INNER JOIN Commercial_Release C ON 
	I.Id_Item = C.Id_Item AND 
	ZC.Id_Country = C.Id_Country AND
	C.Id_Status_Commercial_Release <> 0

	WHERE  I.Status = 1 AND 
	TL.Id_Layout_Type = @pvIdLayoutType AND 
	Z.Id_Zone_Type = @pvIdZoneType AND
	Z.Id_Zone = @pvIdZone

	ORDER BY LA.[Order]
	
