USE [DBQS]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGSSGetQuotationGrossTotal]    Script Date: 4/11/2026 3:37:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


/*
Author:		Angel Gutierrez
Desc:		Gets the Quotation Gross Total
Creation:	04/11/2026
Return 
			@QuotationGrossTotal FLOAT
Example:	
			Declare @QuotationGrossTotal FLOAT
			SET @QuotationGrossTotal = dbo.fnGSSGetQuotationGrossTotal(15,1)
			SELECT @QuotationGrossTotal
*/
CREATE FUNCTION [dbo].[fnGSSGetQuotationGrossTotal](@pvFolio Int, @pvVersion Int)
RETURNS FLOAT
AS
BEGIN

	DECLARE @QuotationGrossTotal FLOAT;

	WITH agg_quotation_detail AS (
	
		SELECT
			Level_4.Folio,
			Level_4.[Version],
			Level_4.Id_Parent,
			Level_4.Level_4_Total,
			Level_3.[Description] AS Level_3_Desc,
			Level_3.Quantity AS Level_3_Qty,
			Level_3.Id_Parent AS Level_3_Id_Parent,
			Level_2.[Description] AS Level_2_Desc,
			Level_2.Quantity AS Level_2_Quantity,
			(Level_4_Total * Level_3.Quantity * Level_2.Quantity) AS Gross_Totals
		FROM (SELECT	
				Folio,
				[Version],
				Id_Parent,
				SUM(Quantity * Unit_Price) AS Level_4_Total
			  FROM GSS_Quotation_Detail
			  WHERE	
					Folio = @pvFolio
				AND [Version] = @pvVersion
				AND Level_Number = 4
			  GROUP BY Folio, [Version], Id_Parent) AS Level_4 INNER JOIN GSS_Quotation_Detail AS Level_3 ON
																			Level_3.Id_Detail = Level_4.Id_Parent
															   INNER JOIN GSS_Quotation_Detail AS Level_2 ON
																			Level_2.Id_Detail = Level_3.Id_Parent
	)

	SELECT @QuotationGrossTotal = SUM(Gross_Totals) FROM agg_quotation_detail;
	
	RETURN @QuotationGrossTotal;

END

