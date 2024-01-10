USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_ApprovalRoutes_Get_Header_Detail
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_ApprovalRoutes_Get_Header_Detail'
IF OBJECT_ID('[dbo].[spQuotation_ApprovalRoutes_Get_Header_Detail]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_ApprovalRoutes_Get_Header_Detail
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get Approval Header and Detail
Date:		01/02/2021
Example:

	EXEC spQuotation_ApprovalRoutes_Get_Header_Detail @piFolio = 710, @piVersion = 1 , @pvUser = 'JOMONTANER'
	EXEC spQuotation_ApprovalRoutes_Get_Header_Detail @piFolio = 457, @piVersion = 1 , @pvUser = 'MAQUINTERO'
	EXEC spQuotation_ApprovalRoutes_Get_Header_Detail @piFolio = 457, @piVersion = 1 , @pvUser = 'LUMUNOZ'
	EXEC spQuotation_ApprovalRoutes_Get_Header_Detail @piFolio = 658, @piVersion = 1, @pvUser='MAQUINTERO';
	EXEC spQuotation_ApprovalRoutes_Get_Header_Detail @piFolio = 672, @piVersion = 1, @pvUser='MAQUINTERO';
	EXEC spQuotation_ApprovalRoutes_Get_Header_Detail @piFolio = 679, @piVersion = 1, @pvUser='MAQUINTERO';
*/
CREATE PROCEDURE [dbo].[spQuotation_ApprovalRoutes_Get_Header_Detail]
@pvIdLanguageUser	Varchar(10) = 'ANG',
@piFolio			Int,
@piVersion			Int,
@pvUser				Varchar(50)
AS

	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @tblApprovalDetails	TABLE(Folio Int, [Version] Int, Id_Header smallint, Quantity Int, Item_Code Varchar(50), Item_Description Varchar(255), Gross_Price Float, 
									  Approved_Disc_Percent Float, Offered_Disc_Percent Float, Offered_Disc_Amount Float, Net_Price Float, Transfer_Price Float, Operation_Expenses Float, Final_Price Float, Total Float, Margin Float,
									  Id_Year_Warranty SmallInt, Amount_Warranty Float, Flow_SequenceDiscount Int, Flow_SequenceWarranty Int, Grand_Total Float )

	DECLARE @iUserFlowSequence INT = (	SELECT Approval_Flow_Sequence 
										FROM Security_Roles R
										INNER JOIN Security_Users U ON 
										R.Id_Role = U.Id_Role
										WHERE  [USER] = @pvUser)

	--------------------------------------------------------------------
	--Insert Approval Details
	--------------------------------------------------------------------
	INSERT INTO @tblApprovalDetails
	SELECT 
	QH.Folio,
	QH.[Version],
	QH.Id_Header,
	Quantity				= QH.Quantity,
	Item_Code				= QH.Item_Template ,
	Item_Description		= Item.Short_Desc,
	Gross_Price				= (SELECT SUM((CASE WHEN QD.Kit_Items_Desc IS NULL THEN QD.Price  ELSE ISNULL(QD.Kit_Price,0) END)) FROM Quotation_Detail QD WHERE  QD.Folio = QH.Folio AND QD.[Version] = QH.[Version] AND QD.Id_Header = QH.Id_Header AND QD.Item_Template = QH.Item_Template),
	Approved_Disc_Percent	= (SELECT ISNULL(MIN(Bottom_Limit),0) 
							   FROM Approved_Discounts 
							   WHERE Id_Discount_Category IN ( SELECT Id_Discount_Category FROM Cat_Item WHERE Id_Item = Item.Id_Item)
							   AND Id_Zone = (SELECT Z.Id_Zone FROM Cat_Zones_Countries ZC
												INNER JOIN Cat_Zones Z ON 
												ZC.Id_Zone = Z.Id_Zone AND
												Z.Id_Zone_Type = 'DISC' AND
												ZC.[Status] = 1
												WHERE Id_Country = Q.Id_Country_Bill_To)
							),
	Offered_Disc_Percent	= QH.Discount,
	Offered_Disc_Amount		= (SELECT SUM((CASE WHEN QD.Kit_Items_Desc IS NULL THEN QD.Price  ELSE ISNULL(QD.Kit_Price,0) END)) FROM Quotation_Detail QD WHERE  QD.Folio = QH.Folio AND QD.[Version] = QH.[Version]  AND QD.Id_Header = QH.Id_Header AND QD.Item_Template = QH.Item_Template) * (QH.Discount / 100),
	Net_Price				= (SELECT SUM((CASE WHEN QD.Kit_Items_Desc IS NULL THEN QD.Price  ELSE ISNULL(QD.Kit_Price,0) END)) FROM Quotation_Detail QD WHERE  QD.Folio = QH.Folio AND QD.[Version] = QH.[Version]  AND QD.Id_Header = QH.Id_Header AND QD.Item_Template = QH.Item_Template) - ( (SELECT SUM(Price) FROM Quotation_Detail QD WHERE  QD.Folio = QH.Folio AND QD.[Version] = QH.[Version]  AND QD.Id_Header = QH.Id_Header AND QD.Item_Template = QH.Item_Template) * (QH.Discount / 100)),
	Transfer_Price			= QH.Transfer_Price,
	Operation_Expenses		= QH.Landed_Cost + QH.Local_Cost,
	Final_Price				= QH.Final_Price,
	Total					= QH.Total,
	Margin					= QH.Margin,
	Id_Year_Warranty		= QH.Id_Year_Warranty,
	Amount_Warranty			= QH.Amount_Warranty,

	Flow_SequenceDiscount	= (SELECT MIN(Approval_Flow_Sequence) FROM Approval_Workflow 
								WHERE Folio = QH.Folio AND [Version] = QH.[Version] 
								AND Id_Header = QH.Id_Header AND Item_Template  = QH.Item_Template 
								AND Id_Approval_Status = 'PTA' 
								AND Id_Approval_Section = 1 -- Quotation Header
								AND Id_Approval_Type = 1), --Discount
										
	Flow_SequenceWarranty	= (SELECT MIN(Approval_Flow_Sequence) FROM Approval_Workflow 
								WHERE Folio = QH.Folio AND [Version] = QH.[Version] 
								AND Id_Header = QH.Id_Header AND Item_Template  = QH.Item_Template 
								AND Id_Approval_Status = 'PTA' 
								AND Id_Approval_Section = 1 -- Quotation Header
								AND Id_Approval_Type = 2), --Warranty

	Grand_Total				= QH.Grand_Total



	FROM [fnQuotation](@pvIdLanguageUser) Q
	
	INNER JOIN Quotation_Header QH ON
	Q.Folio = QH.Folio AND
	Q.[Version]  = QH.[Version] 

	INNER JOIN Cat_Item Item ON
	QH.Item_Template = Item.Id_Item

	WHERE QH.Folio = @piFolio AND QH.[Version] = @piVersion


	--------------------------------------------------------------------
	--GET Approval Header
	--------------------------------------------------------------------
	SELECT	Header.Folio,
			Header.[Version],
			Q.Customer_Bill_To,
			Q.Id_Currency,
			ER.Exchange_Rate,
			Gross_Total		= SUM(Gross_Price * Quantity),
			Discount		= SUM(Offered_Disc_Amount * Quantity),
			Discount_Percent= ROUND((SUM(Offered_Disc_Amount * Quantity) / SUM(Gross_Price * Quantity)) * 100, 2),
			Net_Total		= SUM(Gross_Price * Quantity) - SUM(Offered_Disc_Amount * Quantity),
			Transfer_Price	= SUM(Transfer_Price),
			Total_Comissions = SUM(((Net_Price + Operation_Expenses) * Quantity)) * ISNULL((SELECT SUM(Percentage) / 100 FROM Quotation_Commissions WHERE Folio  = Header.Folio AND [Version] = Header.[Version]),0),
			Final_Total		= SUM(Total),
			Margin			= (((SUM(Gross_Price * Quantity) - SUM(Offered_Disc_Amount * Quantity)) -  SUM(Transfer_Price * Quantity)) / (SUM(Gross_Price * Quantity) - SUM(Offered_Disc_Amount * Quantity))) * 100,
			Total_Amount_Warranty = (SELECT SUM(Amount_Warranty) FROM @tblApprovalDetails),
			Final_Grand_Total = SUM(Grand_Total)
		

			
	FROM @tblApprovalDetails Header
	
	INNER JOIN [fnQuotation](@pvIdLanguageUser) Q ON 
	Header.Folio	 = Q.Folio AND
	Header.[Version] = Q.[Version]

	INNER JOIN Cat_Exchange_Rates ER ON 
	Q.Id_Exchange_Rate = ER.Id_Exchange_Rate AND 
	Q.Id_Currency = ER.Id_Currency

	GROUP BY Header.Folio, Header.[Version],Q.Customer_Bill_To, Q.Id_Currency, ER.Exchange_Rate

	--------------------------------------------------------------------
	--GET Approval Details (Discount)
	--------------------------------------------------------------------
	SELECT	
			Id_Approval_Workflow = ISNULL(Id_Approval_Workflow,0),
			Approval_Types_Desc = (SELECT Short_Desc FROM Cat_Approval_Types WHERE Id_Approval_Section = 1 AND Id_Approval_Type = 1),
			D.Folio, 
			D.[Version], 
			D.Id_Header,
			Quantity, 
			Item_Code, 
			Item_Description, 
			Gross_Price, 
			Max_Approved_Net_Price  = (Gross_Price * (1- (Approved_Disc_Percent/100))), 
			Approved_Disc_Percent, 
			Offered_Disc_Percent, 
			Offered_Disc_Amount, 
			Discount_Offered_Variance = ( Offered_Disc_Amount - (Gross_Price * (Approved_Disc_Percent/100))),
			Net_Price, 
			ASP = (Net_Price / Quantity),
			Transfer_Price, 
			Operation_Expenses, 
			Total_Comissions = ((Net_Price + Operation_Expenses) * Quantity) * ISNULL((SELECT SUM(Percentage) / 100 FROM Quotation_Commissions WHERE Folio  = D.Folio AND [Version] = D.[Version]),0),
			Final_Price, 
			Total, 
			Margin,
			Approval_Flag = (CASE WHEN AW.Approval_Flow_Sequence = @iUserFlowSequence THEN 1 ELSE 0 END),
			Grand_Total,
			Amount_Warranty

	FROM @tblApprovalDetails D

	LEFT OUTER JOIN Approval_Workflow AW ON 
	D.Folio = AW.Folio AND
	D.[Version] = AW.[Version]  AND
	D.Id_Header = AW.Id_Header AND 
	D.Item_Code = AW.Item_Template AND 
	D.Flow_SequenceDiscount = AW.Approval_Flow_Sequence AND 
	AW.Id_Approval_Section = 1 AND -- Quotation Header
	AW.Id_Approval_Type = 1 --Discount


	--------------------------------------------------------------------
	--GET Approval Details (Warranty)
	--------------------------------------------------------------------
	SELECT
			Id_Approval_Workflow = ISNULL(Id_Approval_Workflow,0),
			Approval_Types_Desc = T.Short_Desc,
			D.Folio, 
			D.[Version], 
			D.Id_Header,
			Quantity, 
			Item_Code, 
			Item_Description, 
			Code_Warranty		= ISNULL((	SELECT DISTINCT Code_Warranty 
													FROM Cat_Extended_Warranties CE
													INNER JOIN Items_Configuration IC ON
													CE.Id_Line = IC.Id_Line AND
													IC.Id_Item = D.Item_Code
													WHERE Id_Year_Warranty = D.Id_Year_Warranty ),''), --Validar
			Year_Warranty_Desc = (SELECT Short_Desc FROM Cat_Years_Warranty WHERE Id_Language = @pvIdLanguageUser AND Id_Year_Warranty = D.Id_Year_Warranty),
			D.Amount_Warranty,
			Approval_Flag = (CASE WHEN  AW.Approval_Flow_Sequence = @iUserFlowSequence THEN 1 ELSE 0 END)
	
	FROM @tblApprovalDetails D

	INNER JOIN Approval_Workflow AW ON 
	D.Folio = AW.Folio AND
	D.[Version] = AW.[Version]  AND
	D.Item_Code = AW.Item_Template AND 
	D.Flow_SequenceWarranty = AW.Approval_Flow_Sequence AND 
	AW.Id_Approval_Section = 1 AND -- Quotation Header
	AW.Id_Approval_Type = 2 --Warranty

	INNER JOIN Cat_Approval_Types T ON
	AW.Id_Approval_Section = T.Id_Approval_Section  AND -- Quotation Header
	AW.Id_Approval_Type = T.Id_Approval_Type  --WWarranty



