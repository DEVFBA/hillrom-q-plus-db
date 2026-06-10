USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_Quotation_ApprovalRoutes_Get_Pending_Approval]    Script Date: 4/12/2026 10:59:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autor:		Angel Gutierrez
Desc:		Get Pending Approval
Date:		01/02/2021
Example:

	EXEC spGSS_Quotation_ApprovalRoutes_Get_Pending_Approval @pvUser = 'CHDUENAS', @pvIdRole = 'BUSDIREC';
	EXEC spGSS_Quotation_ApprovalRoutes_Get_Pending_Approval @pvUser = 'RIGUTIERRE'
	EXEC spGSS_Quotation_ApprovalRoutes_Get_Pending_Approval @pvUser = 'GIALEMAN', @piFolio = 13, @piVersion = 1
	EXEC spGSS_Quotation_ApprovalRoutes_Get_Pending_Approval @pvUser = 'RIGUTIERRE', @piFolio = 15, @piVersion = 1
	EXEC spGSS_Quotation_ApprovalRoutes_Get_Pending_Approval @pvUser = 'RIGUTIERRE', @piFolio = 13, @piVersion = 1
	EXEC spGSS_Quotation_ApprovalRoutes_Get_Pending_Approval @pvUser = 'LUMUÑOZ', @pvUserSaleExecutive = 'ADVEGA'
	EXEC spGSS_Quotation_ApprovalRoutes_Get_Pending_Approval @pvUser = 'LUMUÑOZ', @piFolio = 2, @pvUserSaleExecutive = 'ADVEGA'
	EXEC spGSS_Quotation_ApprovalRoutes_Get_Pending_Approval @pvUser = 'DICASADO', @piFolio = 568
	EXEC spGSS_Quotation_ApprovalRoutes_Get_Pending_Approval @pvUser = 'DICASADO', @piFolio = 571
	EXEC spGSS_Quotation_ApprovalRoutes_Get_Pending_Approval @pvUser = 'MAQUINTERO', @pvUserSaleExecutiveName = 'Rojas'
*/
CREATE PROCEDURE [dbo].[spGSS_Quotation_ApprovalRoutes_Get_Pending_Approval]
@pvIdLanguageUser			Varchar(10) = 'ANG',
@pvUser						Varchar(50),
@piFolio					Int = 0,
@piVersion					Int = 0,
@pvUserSaleExecutive		Varchar(50) = '' ,
@pvUserSaleExecutiveName	Varchar(150) = '',
@pvIdRole					Varchar(10) = ''
AS

	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	

	--------------------------------------------------------------------
	--Get Pending Approval
	--------------------------------------------------------------------

	/*
	SELECT
		--GSSAW.Id_Approval_Workflow,
		GSSAW.Folio AS [Quote], -- Frontend Column
		GSSAW.[Version], -- Frontend Column
		GSSBillTo.[Name] AS Customer_Bill_To, -- Frontend Column
		GSSEndCust.[Name] AS End_Customer, -- Frontend Column
		SUExecutives.[Name] AS Sales_Executive, -- Frontend Column
		CCurrencies.Short_Desc AS Currency, -- Frontend Column
		CQS.Short_Desc AS Quotation_Status, -- Frontend Column
		GSSQ.Creation_Date AS [Creation_Date], -- Frontend Column
		GSSQ.Id_Country_Bill_To,
		CZC.Id_Zone,
		GSSAW.Id_Role,
		GSSQ.Id_Sales_Type
	FROM GSS_Approval_Workflow AS GSSAW INNER JOIN GSS_Quotation AS GSSQ ON
													GSSAW.Folio = GSSQ.Folio
												AND GSSAW.[Version] = GSSQ.[Version]
												AND GSSQ.Id_Quotation_Status = 'ROUT'
										INNER JOIN GSS_Cat_Customers AS GSSBillTo ON
													GSSQ.Id_Customer_Bill_To = GSSBillTo.Id_Customer
										INNER JOIN GSS_Cat_Customers AS GSSEndCust ON
													GSSQ.Id_Customer_Final = GSSEndCust.Id_Customer
										INNER JOIN Security_Users AS SUExecutives ON
													GSSQ.Sales_Executive = SUExecutives.[User]
										INNER JOIN Cat_Currencies AS CCurrencies ON
													GSSQ.Id_Currency = CCurrencies.Id_Currency
												AND CCurrencies.Id_Language = @pvIdLanguageUser
										INNER JOIN Cat_Quotation_Status AS CQS ON
													GSSQ.Id_Quotation_Status = CQS.Id_Quotation_Status
												AND CQS.Id_Language = @pvIdLanguageUser
										INNER JOIN Cat_Zones_Countries AS CZC ON
													GSSQ.Id_Country_Bill_To = CZC.Id_Country
												AND CZC.[Status] = 1
										INNER JOIN Cat_Zones AS CZ ON
													CZ.Id_Zone = CZC.Id_Zone
												AND CZ.Id_Zone_Type = 'APPR'
										INNER JOIN Security_User_Roles AS SUR ON
													SUR.Id_Zone = CZC.Id_Zone
												AND SUR.Id_Role = GSSAW.Id_Role
										INNER JOIN Users_Sale_Types AS UST ON
													SUR.[User] = UST.[User]
												AND UST.Id_Sales_Type = GSSQ.Id_Sales_Type
	WHERE 
			GSSAW.Id_Approval_Workflow IN (SELECT
												MIN(Id_Approval_Workflow)
										   FROM GSS_Approval_Workflow
										   WHERE Id_Approval_Status = 'PTA'
										   GROUP BY Folio, [Version]) AND
			(@piFolio					= 0		OR GSSAW.Folio					= @piFolio) AND 
			(@piVersion					= 0		OR GSSAW.[Version]				= @piVersion) AND 
			(@pvUser					= ''	OR SUR.[User]					= @pvUser) AND 
			(@pvIdRole					= ''	OR GSSAW.Id_Role				= @pvIdRole);*/

	WITH QuoteMinAppSeq AS (SELECT
								Folio,
								[Version],
								MIN(Approval_Flow_Sequence) AS MinAppSeq
							FROM GSS_Approval_Workflow
							WHERE  
									Id_Approval_Status = 'PTA'
							GROUP BY Folio, [Version]),
		 QuoteNextApproval AS (SELECT
									GSSAWF.Folio,
									GSSAWF.[Version],
									GSSAWF.Id_Detail,
									GSSAWF.Id_Approval_Workflow,
									GSSAWF.Id_Approval_Flow,
									GSSAWF.Id_Role,
									GSSAWF.Id_Approval_Status,
									GSSAWF.Approval_Flow_Sequence,
									GSSAWF.Comments
							   FROM GSS_Approval_Workflow AS GSSAWF INNER JOIN QuoteMinAppSeq ON
																		GSSAWF.Folio = QuoteMinAppSeq.Folio
																	AND GSSAWF.[Version] = QuoteMinAppSeq.[Version]
																	AND GSSAWF.Approval_Flow_Sequence = QuoteMinAppSeq.MinAppSeq)
	SELECT 
		DISTINCT QNA.Folio AS [Quote], -- Frontend Column
		QNA.[Version], -- Frontend Column
		GSSCCBillTo.[Name] AS Customer_Bill_To, -- Frontend Column
		GSSCCFinal.[Name] AS End_Customer, -- Frontend Column
		SUExecutive.[Name] AS Sales_Executive_Name, -- Frontend Column
		GSSQ.Id_Currency, -- Frontend Column
		QNA.Id_Role,
		GSSQ.Id_Customer_Bill_To,
		GSSQ.Id_Customer_Final,
		GSSQ.Sales_Executive,
		GSSQ.Id_Quotation_Status,
		GSSQ.Creation_Date -- Frontend Column
	FROM QuoteNextApproval AS QNA INNER JOIN GSS_Quotation AS GSSQ ON
												GSSQ.Folio = QNA.Folio
											AND GSSQ.[Version] = QNA.[Version]
											AND GSSQ.Id_Quotation_Status = 'ROUT'
								  INNER JOIN GSS_Cat_Customers AS GSSCCBillTo ON
												GSSCCBillTo.Id_Customer = GSSQ.Id_Customer_Bill_To
											AND GSSCCBillTo.Id_Customer_Type = 'BILL'
								  INNER JOIN GSS_Cat_Customers AS GSSCCFinal ON
												GSSCCFinal.Id_Customer = GSSQ.Id_Customer_Final
											AND GSSCCFinal.Id_Customer_Type = 'FINA'
								  INNER JOIN Security_Users AS SUExecutive ON
												GSSQ.Sales_Executive = SUExecutive.[User]
	WHERE
			QNA.Id_Role = @pvIdRole
		AND GSSQ.Id_Sales_Type IN (SELECT
										Id_Sales_Type
								   FROM Users_Sale_Types
								   WHERE 
											[User] = @pvUser);
