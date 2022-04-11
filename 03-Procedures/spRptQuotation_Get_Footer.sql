
USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spRptQuotation_Get_Footer
/* ==================================================================================*/	
PRINT 'Crea Procedure: spRptQuotation_Get_Footer'
IF OBJECT_ID('[dbo].[spRptQuotation_Get_Footer]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spRptQuotation_Get_Footer
GO
/*
Autor:		Alejandro Zepeda
Desc:		Report Quotation Footer
Date:		12/02/2021
Example:

	EXEC spRptQuotation_Get_Footer @pvIdLanguageUser = 'ANG', @piFolio = 343, @piVersion = 1 


*/SS
CREATE PROCEDURE [dbo].spRptQuotation_Get_Footer
@pvIdLanguageUser	Varchar(10) = 'ANG',
@piFolio			Int,
@piVersion			Int
AS

	SELECT 
			Folio,
			[Version],
			Total					= (SELECT SUM(Grand_Total) FROM Quotation_Header WHERE Folio = @piFolio AND [Version] = @piVersion),
			Id_Incoterm,
			Incoterm_Desc,
			Sales_Executive,
			Sales_Executive_Region	= 'Area Sales Manager | ' + RE.Short_Desc,
			Sales_Executive_Email	= U.Email,
			Symbol
		
	FROM [fnQuotation](@pvIdLanguageUser) Q

	INNER JOIN Security_Users U ON 
	Q.Id_Sales_Executive = U.[User]

	INNER JOIN Cat_Region_Zones RZ ON 
	U.Id_Zone = RZ.Id_Zone 
	
	INNER JOIN Cat_Regions RE ON
	RZ.Id_Region =  RE.Id_Region

	INNER JOIN Cat_Currencies C ON 
	Q.Id_Currency = C.Id_Currency AND
	C.Id_Language = @pvIdLanguageUser

	WHERE Folio = @piFolio AND [Version] = @piVersion
	
	 
