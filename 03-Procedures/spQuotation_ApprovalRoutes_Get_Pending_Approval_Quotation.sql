USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_ApprovalRoutes_Get_Pending_Approval_Quotation
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_ApprovalRoutes_Get_Pending_Approval_Quotation'
IF OBJECT_ID('[dbo].[spQuotation_ApprovalRoutes_Get_Pending_Approval_Quotation]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_ApprovalRoutes_Get_Pending_Approval_Quotation
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get Pending Approval by Quotation Seccion
Date:		10/08/2021
Example:

	EXEC spQuotation_ApprovalRoutes_Get_Pending_Approval_Quotation @pvUser = 'VIROJAS',@pvUserSaleExecitive = 'VIROJAS'
	EXEC spQuotation_ApprovalRoutes_Get_Pending_Approval_Quotation @pvUser = 'LUMUÑOZ', @piFolio = 293
	EXEC spQuotation_ApprovalRoutes_Get_Pending_Approval_Quotation @pvUser = 'LUMUÑOZ', @pvUserSaleExecitive = 'ADVEGA'
	EXEC spQuotation_ApprovalRoutes_Get_Pending_Approval_Quotation @pvUser = 'LUMUÑOZ', @piFolio = 2, @pvUserSaleExecitive = 'ADVEGA'

	select * from Approval_Workflow_Quotation order by 1 
*/
CREATE PROCEDURE [dbo].spQuotation_ApprovalRoutes_Get_Pending_Approval_Quotation
@pvIdLanguageUser		Varchar(10) = 'ANG',
@pvUser					Varchar(50),
@piFolio				Int = 0,
@pvUserSaleExecutive	Varchar(50) = '',
@pvUserSaleExecutiveName	Varchar(150) = '' 
AS

	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @tblWF_CurrentFolios	TABLE(Folio Int, [Version] Int, Approval_Flow_Sequence Int)
	DECLARE @tblApprovers			TABLE(User_Approver Varchar(20))
	DECLARE @vIdApprovalStatus		Varchar(20) = 'PTA' --Pending to Appprove

	--Get and Insert Pending to Appprove current folios
	INSERT INTO @tblWF_CurrentFolios
	SELECT Folio,  [Version], MIN(Approval_Flow_Sequence)
	FROM Approval_Workflow_Quotation
	WHERE Id_Approval_Status = @vIdApprovalStatus
	GROUP BY Folio,  [Version]

	--Get and Insert Approvers
	INSERT INTO @tblApprovers
	SELECT Absence_User FROM Approvers_Absence 
	WHERE Backup_User = @pvUser AND 
	CONVERT(VARCHAR(8), GETDATE(), 112) BETWEEN CONVERT(VARCHAR(8), Initial_Effective_Date, 112) AND CONVERT(VARCHAR(8), Final_Effective_Date, 112)
	UNION ALL
	SELECT @pvUser

	--------------------------------------------------------------------
	--Get Pending Approval
	--------------------------------------------------------------------
	SELECT	
		DISTINCT
			Q.Folio,
			Q.[Version], 
			Id_Approval_Workflow = Id_Approval_WF_Quotation,
			Approval_Section = APS.Short_Desc,
			Approval_Types = APT.Short_Desc,
			AW.Approval_Information,
			AW.Comments,
			Q.Id_Quotation_Status,
			Quotation_Status		= CQS.Short_Desc,
			Q.Creation_Date,
			Apply_File = (SELECT Apply_File FROM Approval_Tracker WHERE Id_Approval_Flow = AW.Id_Approval_Flow AND Id_Role = AW.Id_Role)




	FROM [fnQuotation](@pvIdLanguageUser) Q

	INNER JOIN Approval_Workflow_Quotation AW ON 
	Q.Folio = AW.Folio AND
	Q.[Version] = AW.[Version]  

	INNER JOIN Cat_Approval_Sections APS ON
	AW.Id_Approval_Section = APS.Id_Approval_Section 

	INNER JOIN Cat_Approval_Types APT ON
	AW.Id_Approval_Section = APT.Id_Approval_Section AND
	AW.Id_Approval_Type = APT.Id_Approval_Type

	INNER JOIN @tblWF_CurrentFolios CF ON 
	AW.Folio = CF.Folio AND
	AW.[Version] = CF.[Version] AND 
	AW.Approval_Flow_Sequence = CF.Approval_Flow_Sequence

	INNER JOIN Security_Users USR ON
	AW.Id_Role = USR.Id_Role


	INNER JOIN Cat_Quotation_Status CQS ON 
	Q.Id_Quotation_Status = CQS.Id_Quotation_Status AND
	CQS.Id_Language = @pvIdLanguageUser

	WHERE USR.[User] IN (SELECT User_Approver FROM @tblApprovers) 	 AND
	(@pvUserSaleExecutive = '' OR Q.Id_Sales_Executive = @pvUserSaleExecutive) AND
	(@pvUserSaleExecutiveName = '' OR Q.Sales_Executive LIKE '%' + @pvUserSaleExecutiveName + '%') AND
	(@piFolio = 0 OR Q.Folio = @piFolio) AND 
	Q.Id_Quotation_Status = 'ROUT'
