USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_RptQuotation_Get_Footer]    Script Date: 4/20/2026 6:48:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autor:		Angel Gutierrez
Desc:		GSS Report Quotation Footer
Date:		04/20/2026
Example:

	EXEC spGSS_RptQuotation_Get_Footer @pvIdLanguageUser = 'ANG', @piFolio = 343, @piVersion = 1 


*/
CREATE PROCEDURE [dbo].[spGSS_RptQuotation_Get_Footer]
@pvIdLanguageUser	Varchar(10) = 'ANG',
@piFolio			Int,
@piVersion			Int
AS
	SELECT
		(SELECT
			SUM(Total_Price)
		 FROM GSS_Quotation_Detail
		 WHERE 
				Folio = @piFolio 
			AND [Version] = @piVersion 
			AND Level_Number = 2) AS Net_Total