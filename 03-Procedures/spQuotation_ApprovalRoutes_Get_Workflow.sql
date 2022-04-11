
USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_ApprovalRoutes_Get_Workflow 
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_ApprovalRoutes_Get_Wrorkflow'
IF OBJECT_ID('[dbo].[spQuotation_ApprovalRoutes_Get_Workflow]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_ApprovalRoutes_Get_Workflow
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get Approval Workflow
Date:		10/02/2021
Example:

	EXEC spQuotation_ApprovalRoutes_Get_Workflow @piFolio = 480, @piVersion = 1 

*/
CREATE PROCEDURE [dbo].spQuotation_ApprovalRoutes_Get_Workflow
@piFolio					Int,
@piVersion					Int = 0
AS


	-- Get Header WorkFlow Information
	SELECT 
		AW.Id_Approval_Workflow,
		AW.Folio,
		AW.[Version],
		AW.Id_Approval_Section,
		Approval_Section_Desc = SE.Short_Desc,
		AW.Id_Approval_Type, 
		Approval_Type_Desc = TY.Short_Desc,
		AW.Id_Header,
		AW.Id_Approval_Flow,
		Approval_Flow_Desc		= AF.Short_Desc,
		Id_Item					= AW.Item_Template,
		Item_Desc				= Item.Short_Desc,
		AW.Id_Role,
		Role_Desc				= SR.Short_Desc,
		AW.Id_Approval_Status,
		Approval_Status_Desc	= AST.Short_Desc,
		AW.Approval_Flow_Sequence,
		AW.Comments,
		AW.Modify_By,
		AW.Modify_Date,
		AW.Modify_IP


	FROM Approval_Workflow AW

	INNER JOIN Cat_Item Item ON
	AW.Item_Template = Item.Id_Item

	INNER JOIN Cat_Approvals_Flows AF ON 
	AW.Id_Approval_Flow = AF.Id_Approval_Flow

	INNER JOIN Cat_Approval_Status AST ON
	AW.Id_Approval_Status = AST.Id_Approval_Status

	INNER JOIN Security_Roles SR ON 
	AW.Id_Role = SR.Id_Role

	INNER JOIN Cat_Approval_Sections SE ON
	AW.Id_Approval_Section = SE.Id_Approval_Section

	INNER JOIN Cat_Approval_Types TY ON
	AW.Id_Approval_Section = TY.Id_Approval_Section AND
	AW.Id_Approval_Type	= TY.Id_Approval_Type

	WHERE AW.Folio = @piFolio AND 
	(@piVersion = 0 or AW.[Version] = @piVersion)



	
	-- Get Quotatiom WorkFlow Information
	SELECT 
		Id_Approval_Workflow = AW.Id_Approval_WF_Quotation,
		AW.Folio,
		AW.[Version],
		AW.Id_Approval_Section,
		Approval_Section_Desc = SE.Short_Desc,
		AW.Id_Approval_Type, 
		Approval_Type_Desc = TY.Short_Desc,
		AW.Id_Approval_Flow,
		Approval_Flow_Desc		= AF.Short_Desc,
		AW.Id_Role,
		Role_Desc				= SR.Short_Desc,
		AW.Id_Approval_Status,
		Approval_Status_Desc	= AST.Short_Desc,
		AW.Approval_Flow_Sequence,
		AW.Approval_Information,
		AW.Comments,
		AW.Modify_By,
		AW.Modify_Date,
		AW.Modify_IP


	FROM Approval_Workflow_Quotation AW

	INNER JOIN Cat_Approvals_Flows AF ON 
	AW.Id_Approval_Flow = AF.Id_Approval_Flow

	INNER JOIN Cat_Approval_Status AST ON
	AW.Id_Approval_Status = AST.Id_Approval_Status

	INNER JOIN Security_Roles SR ON 
	AW.Id_Role = SR.Id_Role

	INNER JOIN Cat_Approval_Sections SE ON
	AW.Id_Approval_Section = SE.Id_Approval_Section

	INNER JOIN Cat_Approval_Types TY ON
	AW.Id_Approval_Section = TY.Id_Approval_Section AND
	AW.Id_Approval_Type	= TY.Id_Approval_Type

	WHERE AW.Folio = @piFolio AND 
	(@piVersion = 0 or AW.[Version] = @piVersion)

