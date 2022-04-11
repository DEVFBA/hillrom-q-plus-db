USE DBQS
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- vwWorkflows
/* ==================================================================================*/	
PRINT 'Crea View: vwWorkflows'

IF OBJECT_ID('vwWorkflows','V') IS NOT NULL
       DROP VIEW [dbo].vwWorkflows
GO



/*
Autor:		Alejandro Zepeda
Desc:		Workflows  View
Date:		24/10/2021
Example:
		SELECT * FROM vwWorkflows
*/

CREATE VIEW dbo.vwWorkflows
AS
SELECT	DISTINCT 
		AWF.Folio, 
		AWF.[Version], 
		AWF.Id_Approval_Section,
		Approval_Section_Desc = CAS.Short_Desc,
		AWF.Id_Approval_Type,
		Approval_Type_Desc = CAT.Short_Desc,
		AWF.Id_Approval_Flow,
		Approval_Flow_Desc = CAF.Short_Desc,
		AWF.Id_Role,
		Role_Desc = SR.Short_Desc, 
		AWF.Id_Approval_Status,
		Approval_Status_Desc = AST.Short_Desc,
		Comments,
		AWF.Approval_Flow_Sequence 

FROM Approval_Workflow AWF

INNER JOIN Cat_Approval_Sections CAS ON
AWF.Id_Approval_Section =  CAS.Id_Approval_Section

INNER JOIN Cat_Approval_Types CAT ON 
AWF.Id_Approval_Section  = CAT.Id_Approval_Section AND
AWF.Id_Approval_Type = CAT.Id_Approval_Type 

INNER JOIN Cat_Approvals_Flows CAF ON 
AWF.Id_Approval_Flow = CAF.Id_Approval_Flow

INNER JOIN Security_Roles SR ON 
AWF.Id_Role = SR.Id_Role

INNER JOIN Cat_Approval_Status AST ON 
AWF.Id_Approval_Status = AST.Id_Approval_Status

UNION ALL

SELECT	DISTINCT 
		AWF.Folio, 
		AWF.[Version], 
		AWF.Id_Approval_Section,
		Approval_Section_Desc = CAS.Short_Desc,
		AWF.Id_Approval_Type,
		Approval_Type_Desc = CAT.Short_Desc,
		AWF.Id_Approval_Flow,
		Approval_Flow_Desc = CAF.Short_Desc,
		AWF.Id_Role,
		Role_Desc = SR.Short_Desc, 
		AWF.Id_Approval_Status,
		Approval_Status_Desc = AST.Short_Desc,
		Comments,
		AWF.Approval_Flow_Sequence 

FROM Approval_Workflow_Quotation AWF

INNER JOIN Cat_Approval_Sections CAS ON
AWF.Id_Approval_Section =  CAS.Id_Approval_Section

INNER JOIN Cat_Approval_Types CAT ON 
AWF.Id_Approval_Section  = CAT.Id_Approval_Section AND
AWF.Id_Approval_Type = CAT.Id_Approval_Type 

INNER JOIN Cat_Approvals_Flows CAF ON 
AWF.Id_Approval_Flow = CAF.Id_Approval_Flow

INNER JOIN Security_Roles SR ON 
AWF.Id_Role = SR.Id_Role

INNER JOIN Cat_Approval_Status AST ON 
AWF.Id_Approval_Status = AST.Id_Approval_Status