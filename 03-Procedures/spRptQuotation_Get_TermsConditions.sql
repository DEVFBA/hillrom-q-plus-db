
USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spRptQuotation_Get_TermsConditions
/* ==================================================================================*/	
PRINT 'Crea Procedure: spRptQuotation_Get_TermsConditions'
IF OBJECT_ID('[dbo].[spRptQuotation_Get_TermsConditions]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spRptQuotation_Get_TermsConditions
GO
/*
Autor:		Alejandro Zepeda
Desc:		Report Quotation Terms and Conditions
Date:		12/02/2021
Example:

	EXEC spRptQuotation_Get_TermsConditions @pvIdLanguageUser = 'BRA'

*/
CREATE PROCEDURE [dbo].spRptQuotation_Get_TermsConditions
@pvIdLanguageUser AS VARCHAR(50)
AS
	DECLARE @Result TABLE
(Id_Translation int, 
 Id_Language varchar(10), 
 Language_Desc varchar(50), 
 Interface varchar(50),
 [Object] varchar(50),
 SubObject varchar(50),
 Translation varchar(MAX),
 Modify_By varchar(50),
 Modify_Date datetime,
 Modify_IP  varchar(20)
)

				
	insert into @Result			
	EXEC spLenguages_Translation @pvOptionCRUD = 'R', @pvIdLanguageUser = @pvIdLanguageUser, @pvInterface = 'RptQutation', @pvObject = 'PDF_TermsConditions'

	SELECT 
			TermsConditions = Translation
		
	FROM @Result 
	order by Id_Translation
