
USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spRptQuotation_Get_Header
/* ==================================================================================*/	
PRINT 'Crea Procedure: spRptQuotation_Get_Header'
IF OBJECT_ID('[dbo].[spRptQuotation_Get_Header]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spRptQuotation_Get_Header
GO
/*
Autor:		Alejandro Zepeda
Desc:		Report Quotation Header
Date:		12/02/2021
Example:

	EXEC spRptQuotation_Get_Header @pvIdLanguageUser = 'ANG', @piFolio = 514, @piVersion = 1 

*/
CREATE PROCEDURE [dbo].spRptQuotation_Get_Header
@pvIdLanguageUser	Varchar(10) = 'ANG',
@piFolio			Int,
@piVersion			Int
AS

	SELECT 
			Folio,
			[Version],
			Customer_Bill_To,
			Customer_Type_Bill_To,
			Country_Bill_To,
			Sales_Executive,
			Creation_Date,
			SPR_Number,
			Id_Validity_Price,
			Validity_Price_Desc,
			Id_Language_Translation,
			Id_Currency,
			Currency_Desc,
			Sales_Executive_Email
		
	FROM [fnQuotation](@pvIdLanguageUser) 
	WHERE Folio = @piFolio AND [Version] = @piVersion
