
USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spDashboard_Get_Sales
/* ==================================================================================*/	
PRINT 'Crea Procedure: spDashboard_Get_Sales'
IF OBJECT_ID('[dbo].[spDashboard_Get_Sales]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spDashboard_Get_Sales
GO
/*
Autor:		Alejandro Zepeda
Desc:		spDashboard Sales
Date:		05/06/2021
Periods 
			LY = Acumulado Anual Anterior <Last Year>
			CY = Acumulado Anual Actual <Year To Date>

Example:
	EXEC spDashboard_Get_Sales @pvIdLanguageUser = 'ANG', @pvPeriod = 'CY', @pvUser = 'ANGUTIERRE', @pvIdZone = ''
	EXEC spDashboard_Get_Sales @pvIdLanguageUser = 'ANG', @pvPeriod = 'LY', @pvUser = 'ANGUTIERRE', @pvIdZone = ''
*/
CREATE PROCEDURE [dbo].spDashboard_Get_Sales
@pvIdLanguageUser	Varchar(10) = 'ANG',
@pvPeriod			Varchar(20) = 'CY',
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

	/*============================================================*/
	-- TOTALS
	/*============================================================*/

	SELECT	
			IdMonth					= RIGHT('0' + RTRIM(MONTH(Creation_Date)), 2),
			[Month]					= DATENAME(MONTH, Q.Creation_Date),
			Total_Sale				= ROUND(SUM(QH.Total * Exchange_Rate),2)

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
	GROUP BY	 MONTH(Q.Creation_Date),  
				DATENAME(MONTH, Q.Creation_Date)
	ORDER BY IdMonth

	