USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_ApprovalRoutes_Get_Operation_Expenses
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_ApprovalRoutes_Get_Operation_Expenses'
IF OBJECT_ID('[dbo].[spQuotation_ApprovalRoutes_Get_Operation_Expenses]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_ApprovalRoutes_Get_Operation_Expenses
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get Operation Expenses
Date:		06/02/2021
Example:

	EXEC spQuotation_ApprovalRoutes_Get_Operation_Expenses @piFolio = 1, @piVersion = 1
	EXEC spQuotation_ApprovalRoutes_Get_Operation_Expenses @piFolio = 10, @piVersion = 1 , @pvIdItem = 'P8000'

*/
CREATE PROCEDURE [dbo].spQuotation_ApprovalRoutes_Get_Operation_Expenses
@piFolio				Int,
@piVersion				Int,
@pvIdItem				Varchar(50) = ''
AS

	SELECT	Id_Header				= QH.Id_Header,
			Id_Item					= QH.Item_Template,
			Configured_Cost			= SUM(QD.Standard_Cost),
			Configured_Price		= SUM(QD.Price),
			Allocation_Percent		= QH.Allocation,
			Allocation_Amount		= SUM(QD.Price) * (QH.Allocation / 100),
			Transfer_Price			= QH.Transfer_Price,
			Transport_Cost_Percent	= QH.Transport_Cost,
			Transport_Cost_Amount	= QH.Transfer_Price * (QH.Transport_Cost / 100),
			Taxes_Duties_Percent	= QH.Taxes,
			Taxes_Duties_Amount		= QH.Transfer_Price * (QH.Taxes / 100),
			Landed_Cost				= QH.Landed_Cost,
			Warehousing_Percent		= QH.Warehousing,
			Warehousing_Amount		= QH.Transfer_Price * (QH.Warehousing / 100),
			Local_Transport_Percent	= QH.Local_Transport,
			Local_Transport_Amount	= QH.Transfer_Price * (QH.Local_Transport / 100),
			Services_Percent		= QH.[Services],
			Services_Amount			= QH.Transfer_Price * (QH.[Services] / 100),
			Local_Cost				= QH.Local_Cost
			
	FROM Quotation_Header QH
	INNER JOIN Quotation_Detail QD ON 
	QH.Folio = QD.Folio AND
	QH.[Version] = QD.[Version] AND
	QH.Id_Header = QH.Id_Header AND
	QH.Item_Template = QD.Item_Template 
	WHERE QH.Folio = @piFolio 
	AND	QH.[Version] = @piVersion
	AND (@pvIdItem = '' OR QH.Item_Template = @pvIdItem)
	GROUP BY QH.Id_Header, QH.Item_Template, QH.Allocation, QH.Transfer_Price, QH.Transport_Cost, QH.Taxes, QH.Landed_Cost, QH.Warehousing,QH.Local_Transport,QH.[Services],QH.Local_Cost

