
USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_Approval_Audit_Get_History_Header
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_Approval_Audit_Get_History_Header'
IF OBJECT_ID('[dbo].[spQuotation_Approval_Audit_Get_History_Header]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_Approval_Audit_Get_History_Header
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spQuotation_Approval_Audit_Get_History_Header
Date:		04/07/2021
Example:

	EXEC spQuotation_Approval_Audit_Get_History_Header  @pvIdLanguageUser = 'ANG', 
														@piFolio = 132, 
														@piVersion = 1

	EXEC spQuotation_Approval_Audit_Get_History_Header  @pvIdLanguageUser = 'ANG',  @pvIdQuotationStatus = 'DIRE'													
	EXEC spQuotation_Approval_Audit_Get_History_Header  @pvIdLanguageUser = 'ANG',  @pvSalesExecutive = 'Ángel'
	EXEC spQuotation_Approval_Audit_Get_History_Header  @pvIdLanguageUser = 'ANG', @pvCustomer = 'MEDITEK'
	EXEC spQuotation_Approval_Audit_Get_History_Header  @pvIdLanguageUser = 'ANG', @pvSPRNumber = 'LATAM-580'
	EXEC spQuotation_Approval_Audit_Get_History_Header  @pvIdLanguageUser = 'ANG', @pvInitialDate = '20210520', @pvFinalDate = '20210526'

*/
CREATE PROCEDURE [dbo].spQuotation_Approval_Audit_Get_History_Header
@pvIdLanguageUser		Varchar(10) = 'ANG',
@piFolio				Int = 0,
@piVersion				Int = 0,
@pvIdQuotationStatus	Varchar(10) = '', 
@pvSalesExecutive		Varchar(255)= '',
@pvCustomer				Varchar(255)= '',
@pvSPRNumber			Varchar(50) = '', 	
@pvInitialDate			Varchar(8)	= '', --YYYYMMDD 
@pvFinalDate			Varchar(8)	= '' --YYYYMMDD 
AS

	SELECT DISTINCT
		AW.Folio,
		AW.[Version],
		Q.Id_Quotation_Status,
		Q.Quotation_Status_Desc,
		Q.Customer_Bill_To,
		Q.Sales_Executive,
		Q.SPR_Number,
		Q.Creation_Date


	FROM [fnQuotation](@pvIdLanguageUser) Q
	
	INNER JOIN vwWorkflows AW ON
	Q.Folio = AW.Folio AND 
	Q.[Version] = AW.[Version]

WHERE (@piFolio = 0 OR AW.Folio = @piFolio) AND 
	  (@piVersion = 0 OR AW.[Version] = @piVersion) AND
	  (@pvIdQuotationStatus = '' OR Q.Id_Quotation_Status = @pvIdQuotationStatus)AND 
	  (@pvSalesExecutive = '' OR Q.Sales_Executive LIKE  '%' + @pvSalesExecutive + '%') AND 
	  (@pvCustomer = '' OR Q.Customer_Bill_To LIKE  '%' + @pvCustomer + '%') AND 
	  (@pvSPRNumber = '' OR Q.SPR_Number LIKE  '%' + @pvSPRNumber + '%') AND 
	  (@pvInitialDate = '' OR CONVERT(VARCHAR(8),Q.Creation_Date,112) BETWEEN @pvInitialDate AND @pvFinalDate) AND 

	  Q.Id_Quotation_Status  IN ('SENT', 'DIRE')

ORDER BY AW.Folio, AW.[Version]

