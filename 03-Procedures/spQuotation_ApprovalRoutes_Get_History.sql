USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_ApprovalRoutes_Get_History
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_ApprovalRoutes_Get_History'
IF OBJECT_ID('[dbo].[spQuotation_ApprovalRoutes_Get_History]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_ApprovalRoutes_Get_History
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get Approval History
Date:		13/03/2021
Example:

	EXEC spQuotation_ApprovalRoutes_Get_History @pvIdLanguageUser = 'ANG', @pvUser = 'MAQUINTERO'
	EXEC spQuotation_ApprovalRoutes_Get_History @pvIdLanguageUser = 'ANG', @pvUser = 'LUMUNOZ', @piFolio = 10
	EXEC spQuotation_ApprovalRoutes_Get_History @pvIdLanguageUser = 'ANG', @pvUser = 'LUMUNOZ', @pvUserSaleExecitive = 'ANGUTIERRE'
	EXEC spQuotation_ApprovalRoutes_Get_History @pvIdLanguageUser = 'ANG', @pvUser = 'LUMUÑOZ', @piFolio = 2, @pvUserSaleExecitive = 'ADVEGA'

	EXEC spQuotation_ApprovalRoutes_Get_History @pvIdLanguageUser = 'ANG', @pvUser = 'JOMONTANER', @piFolio = 681;

	EXEC spQuotation_ApprovalRoutes_Get_History @pvIdLanguageUser = 'ANG', @pvUser = 'MAQUINTERO', @piFolio = 681;

*/
CREATE PROCEDURE [dbo].spQuotation_ApprovalRoutes_Get_History
@pvIdLanguageUser		Varchar(10) = 'ANG',
@pvUser					Varchar(50),
@piFolio				Int = 0,
@pvUserSaleExecutive	Varchar(50) = '' ,
@pvUserSaleExecutiveName	Varchar(150) = ''
AS

	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @tblWF_CurrentFolios	TABLE(Folio Int, [Version] Int, Id_Approval_Section INT, Id_Approval_Type INT, Approval_Flow_Sequence Int)
	DECLARE @vIdApprovalStatus		Varchar(20) = 'APP' --Appproved

	--Insert current folios
	INSERT INTO @tblWF_CurrentFolios
	SELECT DISTINCT Folio,  [Version], Id_Approval_Section, Id_Approval_Type, Approval_Flow_Sequence
	FROM vwWorkflows
	WHERE Id_Approval_Status = @vIdApprovalStatus 
	


	--------------------------------------------------------------------
	--Get Pending Approval
	--------------------------------------------------------------------
	SELECT	DISTINCT
			Q.Folio,
			Q.[Version], 
			Q.Id_Customer_Bill_To,
			Customer_Bill_To		= CUB.[Name],
			Q.Id_Customer_Final,
			Customer_Final			= CUF.[Name],
			User_Sales_Executive	= Q.Sales_Executive,
			Sales_Executive	= SE.[Name],
			Q.Id_Sales_Type,
			Sales_Type				= CST.Short_Desc,
			Q.Id_Currency,
			Q.Id_Quotation_Status,
			Quotation_Status		= CQS.Short_Desc,
			Q.Creation_Date,

			Next_Approver =ISNULL((	SELECT DISTINCT Role_Desc 
									FROM vwWorkflows  AWF
									WHERE AWF.Folio = Q.Folio  AND AWF.[Version] = Q.[Version] AND Id_Approval_Status = 'PTA' 
									AND AWF.Approval_Flow_Sequence = (	SELECT MIN(Approval_Flow_Sequence)	
																		FROM vwWorkflows 
																		WHERE  Folio = Q.Folio AND [Version] = Q.[Version]  AND Id_Approval_Status = 'PTA' 
																	 )
							     ), '')


	FROM [fnQuotation](@pvIdLanguageUser) Q

	INNER JOIN Approval_Workflow AW ON 
	Q.Folio = AW.Folio AND
	Q.[Version] = AW.[Version]  

-- se Omite el Join con la tabla ya que solo estaba tomando el ultimo flujo

	INNER JOIN @tblWF_CurrentFolios CF ON 
	AW.Folio = CF.Folio AND
	AW.[Version] = CF.[Version] AND 
	AW.Id_Approval_Section = CF.Id_Approval_Section AND
	AW.Id_Approval_Type = CF.Id_Approval_Type AND
	AW.Approval_Flow_Sequence = CF.Approval_Flow_Sequence

	INNER JOIN Security_Users USR ON
	AW.Id_Role = USR.Id_Role

	INNER JOIN Cat_Zones_Countries ZC ON 
	USR.Id_Zone = ZC.Id_Zone AND 
	Q.Id_Country_Bill_To = ZC.Id_Country

	INNER JOIN Cat_Customers CUB ON 
	Q.Id_Customer_Bill_To = CUB.Id_Customer AND
	Q.Id_Country_Bill_To = CUB.Id_Country AND
	Q.Id_Customer_Type_Bill_To = CUB.Id_Customer_Type

	INNER JOIN Cat_Customers CUF ON 
	Q.Id_Customer_Bill_To= CUF.Id_Customer AND
	Q.Id_Country_Bill_To = CUF.Id_Country AND
	Q.Id_Customer_Type_Bill_To = CUF.Id_Customer_Type

	INNER JOIN Security_Users SE ON 
	Q.Id_Sales_Executive = SE.[User]

	INNER JOIN Cat_Sales_Types CST ON
	Q.Id_Sales_Type = CST.Id_Sales_Type AND
	CST.Id_Language = @pvIdLanguageUser

	INNER JOIN Cat_Quotation_Status CQS ON 
	Q.Id_Quotation_Status = CQS.Id_Quotation_Status AND
	CQS.Id_Language = @pvIdLanguageUser

	INNER JOIN Approvers_Sales_Executive ASE ON 
	Q.Id_Sales_Executive = ASE.Sales_Executive 
	AND ASE.[Status] = 1
	AND ASE.[User] = @pvUser

	WHERE 
	Q.Id_Quotation_Status = 'ROUT' AND 
	USR.[User] = @pvUser AND
	(@pvUserSaleExecutive = '' OR Q.Id_Sales_Executive = @pvUserSaleExecutive) AND
	(@pvUserSaleExecutiveName = '' OR Q.Sales_Executive LIKE '%' + @pvUserSaleExecutiveName + '%') AND
	(@piFolio = 0 OR Q.Folio = @piFolio)
	 
	ORDER BY Q.Folio, Q.[Version]