USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_Quotation_Get_Folios_Clone
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_Quotation_Get_Folios_Clone'

IF OBJECT_ID('[dbo].[spQuotation_Quotation_Get_Folios_Clone]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_Quotation_Get_Folios_Clone
GO

/*
Autor:		Alejandro Zepeda
Desc:		Quotation clone 
Date:		12/05/2021
Example:
	
	EXEC spQuotation_Quotation_Get_Folios_Clone @pvIdLanguageUser = 'SPA', @pvUser = 'ANGUTIERRE'
	EXEC spQuotation_Quotation_Get_Folios_Clone @piFolio = 593
	EXEC spQuotation_Quotation_Get_Folios_Clone @pvUser = 'ANGUTIERRE'
	EXEC spQuotation_Quotation_Get_Folios_Clone @pvCustomer = 'REDE'

*/
CREATE PROCEDURE [dbo].spQuotation_Quotation_Get_Folios_Clone
@pvIdLanguageUser	Varchar(10) = 'ANG',
@piFolio			Int = 0,
@pvUser				Varchar(50) = '',
@pvCustomer			Varchar(255) = ''
AS

 
SELECT	Folio,
		[Version],
		Customer_Bill_To
FROM [fnQuotation](@pvIdLanguageUser)
WHERE
	(@piFolio = 0 OR Folio = @piFolio) AND
	(@pvUser = '' OR Id_Sales_Executive = @pvUser) AND 
	(@pvCustomer = '' OR Customer_Bill_To LIKE '%' + @pvCustomer + '%')  
	--AND Id_Quotation_Status <> 'DRAF' --20220223 Ajuste realizado a solcitud de angel
ORDER BY Folio,Version

