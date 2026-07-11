USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_RptQuotation_Get_Detail]    Script Date: 4/19/2026 8:05:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autor:		Angel Gutierrez
Desc:		Report Quotation Detail
Date:		04/19/2026
Example:

	EXEC spGSS_RptQuotation_Get_Detail @piFolio = 18, @piVersion = 1 
	select * from Quotation_Detail where Folio = 295

	SELECT * FROM Quotation_Header WHERE Folio = 2 AND [Version] = 1 ORDER BY Id_Item
	SELECT * FROM Quotation_Detail WHERE Folio = 2 AND [Version] = 1 order by Item_Template
*/
CREATE PROCEDURE [dbo].[spGSS_RptQuotation_Get_Detail]
--@pvIdLanguageUser	Varchar(10) = 'ANG',
@piFolio					Int,
@piVersion					Int
AS

	SELECT
		GSSQD.Level_Number,
		GSSQD.Quantity,
		(CASE GSSQD.Level_Number 
				WHEN 4 THEN GSSQD.Id_Item
				ELSE ''
		 END) AS [Item_Code],
		REPLICATE('    ', GSSQD.Level_Number) + GSSQD.[Description] AS [Item_Description],
		GSSQD.Discount AS [Offered_Discount],
		GSSQD.Unit_Price,
		GSSQD.Total_Price AS [Total]
	FROM GSS_Quotation_Detail AS GSSQD
	WHERE GSSQD.Folio = @piFolio AND  GSSQD.[Version] = @piVersion
	ORDER BY GSSQD.Position_Sort;


	
