
USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spDashboard_Get_Top_5_Customers
/* ==================================================================================*/	
PRINT 'Crea Procedure: spDashboard_Get_Top_5_Customers'
IF OBJECT_ID('[dbo].[spDashboard_Get_Top_5_Customers]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spDashboard_Get_Top_5_Customers
GO
/*
Autor:		Alejandro Zepeda
Desc:		spDashboard Top 5 Customers
Date:		05/06/2021
Periods 
			CM = Mes Actual <Current Month>,
			LM = Mes Anterior <Last Month>,
			CY = Acumulado Anual <Year To Date>

Example:
	EXEC spDashboard_Get_Top_5_Customers @pvIdLanguageUser = 'ANG', @pvPeriod = 'LM', @pvUser = 'ANGUTIERRE', @pvIdZone = ''
	EXEC spDashboard_Get_Top_5_Customers @pvIdLanguageUser = 'ANG', @pvPeriod = 'CM', @pvUser = 'ANGUTIERRE', @pvIdZone = ''
*/
CREATE PROCEDURE [dbo].spDashboard_Get_Top_5_Customers
@pvIdLanguageUser	Varchar(10) = 'ANG',
@pvPeriod			Varchar(20) = 'LM',
@pvUser				Varchar(20) = '',
@pvIdZone			Varchar(10) = '' 

AS

	/*============================================================*/
	-- VARIABLES
	/*============================================================*/
	DECLARE @vInitialDate			Varchar(8)  = (SELECT InitialDate FROM fnGetPeriodDates(@pvPeriod))
	DECLARE @vFinalDate				Varchar(8)	= (SELECT FinalDate FROM fnGetPeriodDates(@pvPeriod))
	DECLARE @vUserRol				Varchar(10)  = ISNULL((SELECT Id_Role FROM Security_Users WHERE [User] = @pvUser), '')
	DECLARE @vIdSalesExecutive		Varchar(10) = (CASE WHEN @vUserRol = 'ADMIN' THEN '' ELSE @pvUser END)
	DECLARE @vTotalColor			Varchar(30) = (SELECT [Value] FROM Cat_General_Parameters WHERE Id_Parameter = 43) 
	DECLARE @vTotalQuotationColor	Varchar(30) = (SELECT [Value] FROM Cat_General_Parameters WHERE Id_Parameter = 42) 
	DECLARE @tblTOP5				Table(Customer Varchar(255), Total_Sale Float, Total_Sale_Color Varchar(30) , Total_Quotation float, Total_Quotation_Color Varchar(30))

	/*============================================================*/
	-- TOTALS
	/*============================================================*/
	INSERT INTO @tblTOP5
	SELECT	TOP  5
			Customer				= Q.Customer_Bill_To,
			Total_Sale				= ROUND(SUM(QH.Total * Exchange_Rate),2),
			Total_Sale_Color		= @vTotalColor,
			Total_Quotation			= COUNT(Q.Id_Customer_Bill_To),
			Total_Quotation_Color	= @vTotalQuotationColor

	FROM  [fnQuotation](@pvIdLanguageUser) Q
	
	INNER JOIN Quotation_Header QH ON 
	Q.Folio =  QH.Folio AND
	Q.[Version] = QH.[Version]

	INNER JOIN Security_Users U ON 
	Q.Id_Sales_Executive = U.[User]
	
	WHERE Q.Id_Quotation_Status = 'ACCE'
	AND (@vIdSalesExecutive = '' OR Q.Id_Sales_Executive = @vIdSalesExecutive)
	AND (@pvIdZone = '' OR U.Id_Zone = @pvIdZone)
	AND CONVERT(varchar(8), Q.Creation_Date, 112) BETWEEN @vInitialDate AND @vFinalDate
	GROUP BY	Q.Id_Customer_Bill_To,  
				Q.Customer_Bill_To
	ORDER BY Total_Sale DESC

	/*============================================================*/
	-- TOTALS TOP 5
	/*============================================================*/
	SELECT 
			Customer	,
			Total_Sale,
			Total_Sale_Color,
			Percentaje_Sale = ROUND(((Total_Sale / (SELECT SUM(Total_Sale) FROM @tblTOP5)) * 100),2),
			Total_Quotation	,
			Total_Quotation_Color,			
			Percentaje_Quotation = ROUND(((Total_Quotation / (SELECT SUM(Total_Quotation) FROM @tblTOP5)) * 100),2)
	FROM @tblTOP5

	


	