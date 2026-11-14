USE DBQS
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- vwWorkflows
/* ==================================================================================*/	
PRINT 'Crea View: vwApprovalsFlows'

IF OBJECT_ID('vwApprovalsFlows','V') IS NOT NULL
       DROP VIEW [dbo].vwApprovalsFlows
GO



/*
Autor:		Angel Gutierrez
Desc:		Approvals Flows by Country with Approvers
Date:		10/10/2026
Example:
		SELECT * FROM vwApprovalsFlows WHERE Id_Country = 'MX' AND Id_Sales_Type = 'DIRSA';
*/

CREATE VIEW dbo.vwApprovalsFlows
AS

SELECT
	AD.Id_Sales_Type,
	CST.Short_Desc AS Sales_Type_Desc,
	AD.Id_Zone AS Discount_Id_Zone,
	CZ.Short_Desc AS Discount_Zone_Desc,
	AD.Id_Discount_Category,
	CDC.Short_Desc As Discount_Category_Desc,
	AD.Bottom_Limit,
	AD.Upper_Limit,
	AD.Id_Approval_Flow,
	CAF.Short_Desc AS Approval_Flow_Desc,
	[AT].Id_Role,
	SR.Short_Desc AS Role_Desc,
	SR.Approval_Flow_Sequence,
	CZC.Id_Country,
	CC.Short_Desc AS Country,
	ACZC.Id_Zone AS Approval_Zone_Id,
	ACZ.Short_Desc AS Approval_Zone_Desc,
	SUR.[User],
	SU.[Name] AS [User_Name],
	SUR.Id_Role AS SUR_Id_Role,
	SUR.Id_Zone AS SUR_Id_Zone
FROM Approved_Discounts AS AD INNER JOIN Cat_Zones AS CZ ON
									AD.Id_Zone = CZ.Id_Zone
							  INNER JOIN Cat_Discount_Categories AS CDC ON
									AD.Id_Discount_Category = CDC.Id_Discount_Category
								AND CDC.Id_Business_Line = 'PSSLIKO'
							  INNER JOIN Cat_Approvals_Flows AS CAF ON
									AD.Id_Approval_Flow = CAF.Id_Approval_Flow
							  INNER JOIN Cat_Sales_Types AS CST ON
									AD.Id_Sales_Type = CST.Id_Sales_Type
								AND CST.Id_Language = 'ANG'
							  INNER JOIN Approval_Tracker AS [AT] ON
									AD.Id_Approval_Flow = [AT].Id_Approval_Flow
							  INNER JOIN Security_Roles AS SR ON
									[AT].Id_Role = SR.Id_Role 
							  INNER JOIN Cat_Zones_Countries AS CZC ON
									AD.Id_Zone = CZC.Id_Zone
								AND CZC.[Status] = 1 -- HA027 - Excel Venezuela Incorrecto
							  INNER JOIN Cat_Zones_Countries AS ACZC ON
									CZC.Id_Country = ACZC.Id_Country
								AND ACZC.[Status] = 1 -- HA027 - Excel Venezuela Incorrecto
							  INNER JOIN Cat_Zones AS ACZ ON
									ACZC.Id_Zone = ACZ.Id_Zone
								AND ACZ.Id_Zone_Type = 'APPR'
								AND ACZ.[Status] = 1
							  INNER JOIN Security_User_Roles AS SUR ON
									[AT].Id_Role = SUR.Id_Role
								AND ACZC.Id_Zone = SUR.Id_Zone
							  INNER JOIN Security_Users AS SU ON
									SUR.[User] = SU.[User]
								AND SU.[Status] = 1
							  INNER JOIN Cat_Countries AS CC ON
									CZC.Id_Country = CC.Id_Country
							  INNER JOIN Users_Sale_Types AS USR ON
									AD.Id_Sales_Type = USR.Id_Sales_Type
								AND SUR.[User] = USR.[User];
