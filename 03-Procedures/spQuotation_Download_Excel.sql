USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spQuotation_Download_Excel]    Script Date: 4/7/2026 10:43:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Autor:		Angel Gutierrez
Desc:		PSS Quotation Excel Download 
Date:		02/24/2026
Example:
			
			EXEC spQuotation_Download_Excel @piFolio = 3375, @piVersion = 1, @pvIdRole = 'ADMIN';
			EXEC spQuotation_Download_Excel @piFolio = 3375, @piVersion = 1, @pvIdRole = 'SALES';
			EXEC spQuotation_Download_Excel @piFolio = 3375, @piVersion = 1, @pvIdRole = 'GSSSALES';
*/
CREATE PROCEDURE [dbo].[spQuotation_Download_Excel]
@piFolio			Int = 0,
@piVersion          Int = 0,
@pvIdRole			Varchar(10) 
AS

SET NOCOUNT ON
BEGIN 

	DECLARE @vbViewCosts AS Bit;
	DECLARE @vbViewMargin AS Bit;

	SET @vbViewCosts = ISNULL((SELECT Visibility FROM Security_Role_Functions WHERE Id_Role = @pvIdRole AND SubObject_Name = 'Cost'),0);
	SET @vbViewMargin = ISNULL((SELECT Visibility FROM Security_Role_Functions WHERE Id_Role = @pvIdRole AND SubObject_Name = 'Margin'),0);

	--PRINT 'View Costs: ' + CAST(@vbViewCosts AS VARCHAR(1));

	-- Header

		SELECT
			Item_Id = (CASE CI.Id_Item_Class
							WHEN 'PACK' THEN CI.Id_Item_Related
							WHEN 'PACKD' THEN CI.Id_Item_Related
							ELSE QH.Item_Template
						END),
			[Description] = CI.Short_Desc,
			SubClass_Id = CI.Id_Item_SubClass,
			Price_List = ROUND((IT.Price * CER.Exchange_Rate),2),
			Cost = (CASE @vbViewCosts
						WHEN 0 THEN NULL
						ELSE (SELECT
									ROUND(SUM(SDQ.Standard_Cost), 2)
							  FROM Quotation_Detail AS SDQ
							  WHERE 
											SDQ.Folio = QH.Folio
										AND SDQ.[Version] = QH.[Version]
										AND SDQ.Id_Header = QH.Id_Header)
						END),
			Discount = CAST(ROUND(QH.Discount,2) AS VARCHAR(6)) + '%',
			QH.Quantity,
			Customer_Price = ROUND(QH.Final_Price, 2),
			Subtotal = ROUND(QH.Total, 2),
			Ext_Warr_Years = QH.Id_Year_Warranty,
			Ext_Warr_$ = ROUND(QH.Amount_Warranty, 2),
			Total = ROUND(QH.Grand_Total, 2),
			Margin = (CASE @vbViewMargin
							WHEN  0 THEN NULL
							ELSE QH.Margin
					  END)
		FROM Quotation_Header AS QH INNER JOIN Items_Templates AS IT 
										ON QH.Item_Template = IT.Id_Item
									INNER JOIN Quotation AS Q 
										ON QH.Folio = Q.Folio AND
										   QH.[Version] = Q.[Version]
									INNER JOIN Cat_Exchange_Rates AS CER
										ON Q.Id_Currency = CER.Id_Currency AND
										   CER.[Status] = 1
									INNER JOIN Cat_Item AS CI 
										ON QH.Item_Template = CI.Id_Item
		WHERE 
					QH.Folio = @piFolio
				AND QH.[Version] = @piVersion;
	
	-- Detail

		SELECT
			Template_Description = CI2.Short_Desc,
			Section = (CASE
							WHEN CI.Id_Item_Class <> 'ACCE' THEN 'Configuration'
							ELSE 'Accessories'
					   END),
			SubClass = CISC.Short_Desc,
			Item_Id = (CASE CI.Id_Item_Class
							WHEN 'PACK' THEN CI.Id_Item_Related
							WHEN 'PACKD' THEN CI.Id_Item_Related
							ELSE QD.Id_Item
						END),
			[Description] = CI.Short_Desc,
			QD.Quantity,
			Price = ROUND(QD.Price, 2),
			Cost = (CASE @vbViewCosts
							WHEN 0 THEN NULL
							ELSE ROUND(QD.Standard_Cost, 2)
					END),
			Quantity_Total = (CASE
									WHEN CI.Id_Item_Class = 'ACCE' THEN (QD.Quantity * QH.Quantity)
									ELSE NULL
							  END)
		FROM Quotation_Detail AS QD INNER JOIN Cat_Item AS CI ON
										QD.Id_Item = CI.Id_Item
									INNER JOIN Cat_Item_SubClasses AS CISC ON
										CI.Id_Item_SubClass = CISC.Id_Item_SubClass AND
										CI.Id_Item_Class = CISC.Id_Item_Class
									INNER JOIN Cat_Item AS CI2 ON
										QD.Item_Template = CI2.Id_Item
									INNER JOIN Quotation_Header AS QH  ON
										QD.Folio = QH.Folio AND
										QD.[Version] = QH.[Version] AND
										QD.Id_Header = QH.Id_Header
		WHERE
					QD.Folio = @piFolio
				AND QD.[Version] = @piVersion
		ORDER BY 
					QD.Id_Header ASC,
					CI.Id_Item_Class DESC;

END