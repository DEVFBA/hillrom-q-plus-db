USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_Quotation_ApprovalRoutes_Get_Header_Detail]    Script Date: 4/12/2026 8:45:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get Approval Header and Detail
Date:		01/02/2021
Example:

	EXEC spGSS_Quotation_ApprovalRoutes_Get_Header_Detail @piFolio = 17, @piVersion = 1; 
	EXEC spGSS_Quotation_ApprovalRoutes_Get_Header_Detail @piFolio = 457, @piVersion = 1;
	EXEC spGSS_Quotation_ApprovalRoutes_Get_Header_Detail @piFolio = 457, @piVersion = 1;
	EXEC spGSS_Quotation_ApprovalRoutes_Get_Header_Detail @piFolio = 658, @piVersion = 1;
	EXEC spGSS_Quotation_ApprovalRoutes_Get_Header_Detail @piFolio = 672, @piVersion = 1;
	EXEC spGSS_Quotation_ApprovalRoutes_Get_Header_Detail @piFolio = 679, @piVersion = 1;
*/
CREATE PROCEDURE [dbo].[spGSS_Quotation_ApprovalRoutes_Get_Header_Detail]
@pvIdLanguageUser	Varchar(10) = 'ANG',
@piFolio			Int,
@piVersion			Int
--@pvUser				Varchar(50),
--@pvRole				Varchar(10) -- AEGH 05/19/25 Project Multiline Users
AS

	--------------------------------------------------------------------
	--GET Approval Header
	--------------------------------------------------------------------
	SELECT
		DISTINCT GSSQ.Folio AS Quote, -- Frontend Column
		GSSQ.[Version], -- Frontend Column
		GSSQ.Id_Currency, -- Frontend Column
		dbo.fnGSSGetQuotationGrossTotal(@piFolio, @piVersion) AS Price_List_Total, -- Frontend Column
		(SELECT
			SUM(Total_Price)
		 FROM GSS_Quotation_Detail
		 WHERE 
				Folio = @piFolio 
			AND [Version] = @piVersion 
			AND Level_Number = 2) AS Net_Total, -- Frontend Column
		(1-(SELECT
			SUM(Total_Price)
		 FROM GSS_Quotation_Detail
		 WHERE 
				Folio = @piFolio 
			AND [Version] = @piVersion 
			AND Level_Number = 2)/dbo.fnGSSGetQuotationGrossTotal(@piFolio, @piVersion)) AS Overall_Discount, -- Frontend Column
		GSSQ.Id_Customer_Bill_To,
		GSSCCBillTo.[Name] AS Customer_Name, -- Frontend Column
		GSSQ.Sales_Executive,
		SUExecutive.[Name] AS Sales_Executive_Name, -- Frontend Column
		GSSQ.TTQ_Quote_Number -- Frontend Column
	FROM GSS_Quotation AS GSSQ INNER JOIN  GSS_Quotation_Detail AS GSSQD ON
											GSSQ.Folio = GSSQD.Folio
										AND GSSQ.[Version] = GSSQD.[Version]
							   INNER JOIN GSS_Cat_Customers AS GSSCCBillTo ON
											GSSQ.Id_Customer_Bill_To = GSSCCBillTo.Id_Customer
										AND GSSCCBillTo.Id_Customer_Type = 'BILL'
							   INNER JOIN Security_Users AS SUExecutive ON
											GSSQ.Sales_Executive = SUExecutive.[User]
	WHERE
			GSSQD.Folio =  @piFolio 
		AND GSSQD.[Version] = @piVersion; 

	--------------------------------------------------------------------
	--GET Approval Details (Discount)
	--------------------------------------------------------------------
	
	WITH QuoteMinAppSeq AS (SELECT
								MIN(Approval_Flow_Sequence) AS MinAppSeq
							FROM GSS_Approval_Workflow
							WHERE 
									Folio = @piFolio
								AND [Version] = @piVersion
								AND Id_Approval_Status = 'PTA'
							GROUP BY Folio, [Version]),
		 QuoteNextApproval AS (SELECT
									Id_Detail,
									Id_Approval_Workflow,
									Id_Approval_Flow,
									Id_Role,
									Id_Approval_Status,
									Approval_Flow_Sequence,
									Comments
							   FROM GSS_Approval_Workflow
							   WHERE
										Folio = @piFolio 
									AND [Version] = @piVersion
									AND Approval_Flow_Sequence = (SELECT
																		MinAppSeq
																  FROM QuoteMinAppSeq))
	SELECT 
		GSSQD.Id_Detail,
		GSSQD.Level_Number,
		GSSQD.Quantity,
		GSSQD.Id_Item AS [Item_Code],
		REPLICATE('    ', GSSQD.Level_Number - 1) + GSSQD.[Description] AS [Item_Description],
		GSSQD.Discount AS [Offered_Discount],
		GSSQD.Unit_Price,
		GSSQD.Total_Price AS [Total],
		QuoteNextApproval.Id_Approval_Workflow,
		QuoteNextApproval.Id_Approval_Status,
		QuoteNextApproval.Id_Role,
		(CASE
				WHEN QuoteNextApproval.Id_Approval_Flow IS NULL THEN 0
				ELSE 1
		 END) AS To_Approve
	FROM GSS_Quotation_Detail AS GSSQD LEFT OUTER JOIN QuoteNextApproval ON
											GSSQD.Id_Detail = QuoteNextApproval.Id_Detail
	WHERE 
			GSSQD.Folio = @piFolio
		AND GSSQD.[Version] = @piVersion;