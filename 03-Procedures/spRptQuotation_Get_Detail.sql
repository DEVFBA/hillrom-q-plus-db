
USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spRptQuotation_Get_Detail
/* ==================================================================================*/	
PRINT 'Crea Procedure: spRptQuotation_Get_Detail'
IF OBJECT_ID('[dbo].[spRptQuotation_Get_Detail]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spRptQuotation_Get_Detail
GO
/*
Autor:		Alejandro Zepeda
Desc:		Report Quotation Detail
Date:		12/02/2021
Example:

	EXEC spRptQuotation_Get_Detail @pvIdLanguageUser = 'ANG', @piFolio = 472, @piVersion = 1 
	select * from Quotation_Detail where Folio = 295

	SELECT * FROM Quotation_Header WHERE Folio = 2 AND [Version] = 1 ORDER BY Id_Item
	SELECT * FROM Quotation_Detail WHERE Folio = 2 AND [Version] = 1 order by Item_Template
*/
CREATE PROCEDURE [dbo].spRptQuotation_Get_Detail
@pvIdLanguageUser	Varchar(10) = 'ANG',
@piFolio					Int,
@piVersion					Int
AS

	SELECT
			Quotation_Payment_Terms		= Q.Payment_Terms_Desc,
			Header_Model				= IH.Model,
			Header_Country				= C.Short_Desc,
			Header_Weight				= IH.[Weight],
			Header_Measurements			= IH.Measurements,
			Header_Quantity				= QH.Quantity,
			Header_Id_Item				= QH.Item_Template,
			Header_Item					= IH.Short_Desc,
			Header_Price				= QH.Final_Price,
		    Header_Amount_Warranty		= QH.Amount_Warranty,
		    Header_Year_Warranty		= ISNULL((SELECT Long_Desc FROM Cat_Years_Warranty WHERE Id_Year_Warranty =  QH.Id_Year_Warranty AND Id_Language = @pvIdLanguageUser),''),
		    Header_Percentage_Warranty	= QH.Percentage_Warranty,
			Header_Code_Warranty		= ISNULL((	SELECT DISTINCT Code_Warranty 
													FROM Cat_Extended_Warranties CE
													INNER JOIN Items_Configuration IC ON
													CE.Id_Line = IC.Id_Line AND
													IC.Id_Item = QH.Item_Template
													WHERE Id_Year_Warranty =  QH.Id_Year_Warranty ),''), --Validar
			Header_Taxes_Total			= QH.General_Taxes_Total,
			Header_General_Taxes_Warranty= QH.General_Taxes_Warranty,
		    Header_Grand_Total			= QH.Grand_Total,
			Detail_Id_Header			= QD.Id_Header,
			Detail_Id_Item				= ID.Id_Item,
			Detail_Item					= ID.Short_Desc,
			Detail_Quantity				= (CASE WHEN ID.Id_Item_Class = 'ACCE' THEN QD.Quantity * QH.Quantity  ELSE QD.Quantity END),
			Detail_Price				= (CASE WHEN QD.Kit_Items_Desc IS NULL THEN QD.Price  ELSE ISNULL(QD.Kit_Price,0) END) * (1 - (QH.Discount/100)),
			Detail_Class				= ID.Id_Item_Class,
			Detail_Subclass				= ID.Id_Item_SubClass,
			Detail_Kit					= REPLACE(ISNULL(QD.Kit_Items_Desc,''),'|',' + '),
			Detail_Factory_Desc			= ISNULL((CASE WHEN  ID.Id_Item_SubClass = 'PLUG' THEN 
											(SELECT Factory_Desc  FROM Cat_Factory_Plugs WHERE Id_Plug = ID.Id_Item AND Id_Country = IH.Id_Country) 
											ELSE '' 
										   END),'')

	FROM [fnQuotation](@pvIdLanguageUser) Q
	
	INNER JOIN Quotation_Header QH ON 
	Q.Folio =  QH.Folio AND
	Q.[Version] = QH.[Version]
	
	INNER JOIN Quotation_Detail QD ON 
	QH.Folio		 =  QD.Folio AND
	QH.[Version]	 = QD.[Version] AND
	QH.Id_Header	 = QD.Id_Header AND
	QH.Item_Template = QD.Item_Template

	INNER JOIN Cat_Item IH ON
	QH.Item_Template = IH.Id_Item

	INNER JOIN Cat_Item ID ON
	QD.Id_Item = ID.Id_Item

	INNER JOIN Cat_Countries C ON
	IH.Id_Country = C.Id_Country

	WHERE Q.Folio = @piFolio AND  Q.[Version] = @piVersion
	order by QD.Id_Header, QD.Item_Template ASC, ID.Id_Item_Class DESC, ID.Short_Desc ASC


	
