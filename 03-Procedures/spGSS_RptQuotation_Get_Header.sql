USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_RptQuotation_Get_Header]    Script Date: 5/24/2026 9:02:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autor:		Angel Gutierrez
Desc:		GSS Report Quotation Header
Date:		04/19/2026
Example:

	EXEC spGSS_RptQuotation_Get_Header @pvIdLanguageUser = 'ANG', @piFolio = 514, @piVersion = 1 

*/
CREATE PROCEDURE [dbo].[spGSS_RptQuotation_Get_Header]
@pvIdLanguageUser	Varchar(10) = 'ANG',
@piFolio			Int,
@piVersion			Int
AS

	SELECT 
			GSSQ.Folio,
			GSSQ.[Version],
			BillTo.[Name] AS Customer_Bill_To,
			GSSQ.Id_Customer_Type_Bill_To,
			GSSQ.Id_Country_Bill_To,
			GSSQ.Sales_Executive,
			GSSQ.Creation_Date,
			GSSQ.SPR_Number,
			GSSQ.Id_Validity_Price,
			GSSQ.Id_Currency,
			CC.Short_Desc AS Currency,
			SU.Email,
			Customer_Contact = '',
			Customer_Phone = '',
			Customer_Email = '',
			GSSQ.Id_Quotation_Status,
			CQS.Short_Desc AS Quotation_Status,
			EOMONTH(DATEADD(MONTH, 3, GSSQ.Creation_Date)) AS Commitment_Date
	FROM GSS_Quotation AS GSSQ INNER JOIN GSS_Cat_Customers AS BillTo ON
												GSSQ.Id_Customer_Bill_To = BillTo.Id_Customer
							   INNER JOIN Security_Users AS SU ON
												GSSQ.Sales_Executive = SU.[User]
							   INNER JOIN Cat_Currencies AS CC ON
												GSSQ.Id_Currency = CC.Id_Currency
											AND CC.Id_Language = @pvIdLanguageUser
							   INNER JOIN Cat_Quotation_Status AS CQS ON
												GSSQ.Id_Quotation_Status = CQS.Id_Quotation_Status
											AND CQS.Id_Language =  @pvIdLanguageUser
	WHERE Folio = @piFolio AND [Version] = @piVersion
