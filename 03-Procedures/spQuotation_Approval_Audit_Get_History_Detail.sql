
USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_Approval_Audit_Get_History_Detail
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_Approval_Audit_Get_History_Detail'
IF OBJECT_ID('[dbo].[spQuotation_Approval_Audit_Get_History_Detail]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_Approval_Audit_Get_History_Detail
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spQuotation_Approval_Audit_Get_History_Detail
Date:		04/07/2021
Example:

	EXEC spQuotation_Approval_Audit_Get_History_Detail @pvIdLanguageUser= 'ANG', @piFolio = 567, @piVersion = 1  

*/
CREATE PROCEDURE [dbo].spQuotation_Approval_Audit_Get_History_Detail
@pvIdLanguageUser		Varchar(10) = 'ANG',
@piFolio				Int,
@piVersion				Int
AS


	/******************************************************************/
	-- Workflow Header
	/******************************************************************/
	SELECT DISTINCT 
		AW.Id_Approval_Workflow,
		AW.Folio,
		AW.[Version],
		AW.Id_Header,
		AW.Id_Approval_Flow,
		Approval_Flow_Desc		= AF.Short_Desc,
		Id_Item					= AW.Item_Template,
		Item_Desc				= Item.Short_Desc,
		QH.Discount,
		AW.Id_Role,
		Role_Desc				= SR.Short_Desc,
		AW.Id_Approval_Type,
		Approval_Type_Desc		= T.Short_Desc, 
		AW.Id_Approval_Status,
		Approval_Status_Desc	= AST.Short_Desc,		
		Id_Approver				= AW.Modify_By,
		Approver				= U.[Name],
		[Date]					= AW.Modify_Date,
		AW.Comments,
		AW.Approval_Flow_Sequence,	
		QH.Id_Year_Warranty,
		Year_Warranty_Desc = (SELECT Short_Desc FROM Cat_Years_Warranty WHERE Id_Year_Warranty = QH.Id_Year_Warranty AND Id_Language = @pvIdLanguageUser),
		AW.Modify_IP


	FROM Approval_Workflow AW

	INNER JOIN Quotation_Header QH ON 
	AW.Folio = QH.Folio AND 
	AW.[Version] = QH.[Version] AND
	AW.Item_Template = QH.Item_Template

	INNER JOIN Cat_Item Item ON
	AW.Item_Template = Item.Id_Item

	INNER JOIN Cat_Approvals_Flows AF ON 
	AW.Id_Approval_Flow = AF.Id_Approval_Flow

	INNER JOIN Cat_Approval_Status AST ON
	AW.Id_Approval_Status = AST.Id_Approval_Status

	INNER JOIN Security_Roles SR ON 
	AW.Id_Role = SR.Id_Role

	INNER JOIN Security_Users U ON
	AW.Modify_By = U.[User]

	INNER JOIN Cat_Approval_Types T ON 
	AW.Id_Approval_Section = T.Id_Approval_Section AND 
	AW.Id_Approval_Type = T.Id_Approval_Type


	WHERE AW.Folio = @piFolio AND AW.[Version] = @piVersion

	/******************************************************************/
	-- Workflow Quotation
	/******************************************************************/

	SELECT 
		Id_Approval_Workflow = AW.Id_Approval_WF_Quotation,
		AW.Folio,
		AW.[Version],
		AW.Id_Approval_Flow,
		Approval_Flow_Desc		= AF.Short_Desc,
		AW.Approval_Flow_Sequence,
		AW.Id_Role,
		Role_Desc				= SR.Short_Desc,
		AW.Id_Approval_Type,
		Approval_Type_Desc		= T.Short_Desc, 
		AW.Approval_Information, 
		AW.Id_Approval_Status,
		Approval_Status_Desc	= AST.Short_Desc,
		Id_Approver				= AW.Modify_By,
		Approver				= U.[Name],
		[Date]					= AW.Modify_Date,
		Comments

	FROM Approval_Workflow_Quotation AW

	INNER JOIN Cat_Approvals_Flows AF ON 
	AW.Id_Approval_Flow = AF.Id_Approval_Flow

	INNER JOIN Cat_Approval_Status AST ON
	AW.Id_Approval_Status = AST.Id_Approval_Status

	INNER JOIN Security_Roles SR ON 
	AW.Id_Role = SR.Id_Role

	INNER JOIN Security_Users U ON
	AW.Modify_By = U.[User]

	INNER JOIN Cat_Approval_Types T ON 
	AW.Id_Approval_Section = T.Id_Approval_Section AND 
	AW.Id_Approval_Type = T.Id_Approval_Type

	WHERE AW.Folio = @piFolio AND AW.[Version] = @piVersion



