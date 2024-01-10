USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_ApprovalRoutes_Get_Pending_Approval
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_ApprovalRoutes_Get_Pending_Approval'
IF OBJECT_ID('[dbo].[spQuotation_ApprovalRoutes_Get_Pending_Approval]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_ApprovalRoutes_Get_Pending_Approval
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get Pending Approval
Date:		01/02/2021
Example:

	EXEC spQuotation_ApprovalRoutes_Get_Pending_Approval @pvUser = 'BRLIMA'
	EXEC spQuotation_ApprovalRoutes_Get_Pending_Approval @pvUser = 'DICASADO', @piFolio = 437
	EXEC spQuotation_ApprovalRoutes_Get_Pending_Approval @pvUser = 'LUMUÑOZ', @pvUserSaleExecutive = 'ADVEGA'
	EXEC spQuotation_ApprovalRoutes_Get_Pending_Approval @pvUser = 'LUMUÑOZ', @piFolio = 2, @pvUserSaleExecutive = 'ADVEGA'
	EXEC spQuotation_ApprovalRoutes_Get_Pending_Approval @pvUser = 'DICASADO', @piFolio = 568
	EXEC spQuotation_ApprovalRoutes_Get_Pending_Approval @pvUser = 'DICASADO', @piFolio = 571
	EXEC spQuotation_ApprovalRoutes_Get_Pending_Approval @pvUser = 'MAQUINTERO', @pvUserSaleExecutiveName = 'Rojas'
*/
CREATE PROCEDURE [dbo].spQuotation_ApprovalRoutes_Get_Pending_Approval
@pvIdLanguageUser			Varchar(10) = 'ANG',
@pvUser						Varchar(50),
@piFolio					Int = 0,
@pvUserSaleExecutive		Varchar(50) = '' ,
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
	FROM vwWorkflows --Approval_Workflow
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

	SELECT	Folio,
			[Version], 
			Id_Customer_Bill_To,
			Customer_Bill_To,
			Id_Customer_Final,
			Customer_Final,
			User_Sales_Executive,
			Sales_Executive,
			Id_Sales_Type,
			Sales_Type,
			Id_Currency,
			Id_Quotation_Status,
			Quotation_Status,
			Creation_Date,
			Apply_File = MAX(Apply_File)
	FROM
		(SELECT	DISTINCT
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
				Apply_File = (SELECT CAST(Apply_File AS SMALLINT) FROM Approval_Tracker WHERE Id_Approval_Flow = AW.Id_Approval_Flow AND Id_Role = AW.Id_Role)

		FROM [fnQuotation](@pvIdLanguageUser) Q

		INNER JOIN vwWorkflows  AW ON --Approval_Workflow
		Q.Folio = AW.Folio AND
		Q.[Version] = AW.[Version]  

		INNER JOIN @tblWF_CurrentFolios CF ON 
		AW.Folio = CF.Folio AND
		AW.[Version] = CF.[Version] AND 
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

		WHERE USR.[User] IN (SELECT User_Approver FROM @tblApprovers) 	 AND
		(@pvUserSaleExecutive = '' OR Q.Id_Sales_Executive = @pvUserSaleExecutive) AND
		(@pvUserSaleExecutiveName = '' OR Q.Sales_Executive LIKE '%' + @pvUserSaleExecutiveName + '%') AND
		(@piFolio = 0 OR Q.Folio = @piFolio) AND 
		Q.Id_Quotation_Status = 'ROUT'
		) AS TblPending

		GROUP BY 
			Folio,
			[Version], 
			Id_Customer_Bill_To,
			Customer_Bill_To,
			Id_Customer_Final,
			Customer_Final,
			User_Sales_Executive,
			Sales_Executive,
			Id_Sales_Type,
			Sales_Type,
			Id_Currency,
			Id_Quotation_Status,
			Quotation_Status,
			Creation_Date
