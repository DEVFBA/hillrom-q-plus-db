
USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spDashboard_Get_Top_5_Articles
/* ==================================================================================*/	
PRINT 'Crea Procedure: spDashboard_Get_Top_5_Articles'
IF OBJECT_ID('[dbo].[spDashboard_Get_Top_5_Articles]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spDashboard_Get_Top_5_Articles
GO
/*
Autor:		Alejandro Zepeda
Desc:		spDashboard Top 5 Articles
Date:		05/06/2021
Periods 
			CM = Mes Actual <Current Month>,
			LM = Mes Anterior <Last Month>,
			CY = Acumulado Anual <Year To Date>

Example:
	EXEC spDashboard_Get_Top_5_Articles @pvIdLanguageUser = 'ANG', @pvPeriod = 'LM', @pvUser = 'ANGUTIERRE', @pvIdZone = '', @pvRole = 'ADMIN'
	EXEC spDashboard_Get_Top_5_Articles @pvIdLanguageUser = 'ANG', @pvPeriod = 'CM', @pvUser = 'ANGUTIERRE', @pvIdZone = '', @pvRole = 'ADMIN'
*/
CREATE PROCEDURE [dbo].spDashboard_Get_Top_5_Articles
@pvIdLanguageUser	Varchar(10) = 'ANG',
@pvPeriod			Varchar(20) = 'LM',
@pvUser				Varchar(20) = '',
@pvIdZone			Varchar(10) = '', 
@pvRole				Varchar(10) = '' -- AEGH 05/08/25 -- Multiline Users Project

AS

	/*============================================================*/
	-- VARIABLES
	/*============================================================*/
	DECLARE @vInitialDate			Varchar(8)  = (SELECT InitialDate FROM fnGetPeriodDates(@pvPeriod))
	DECLARE @vFinalDate				Varchar(8)	= (SELECT FinalDate FROM fnGetPeriodDates(@pvPeriod))
	-- DECLARE @vUserRol				Varchar(10)  = ISNULL((SELECT Id_Role FROM Security_Users WHERE [User] = @pvUser), '') -- AEGH 05/08/25 -- Multiline Users Project
	DECLARE @vIdSalesExecutive		Varchar(10) = (CASE WHEN @pvRole = 'ADMIN' THEN '' ELSE @pvUser END)
	DECLARE @tblTOP5				Table(Id_Item Varchar(50), Item Varchar(50), Total_Sale Float)
	/*============================================================*/
	-- TOTALS
	/*============================================================*/
	INSERT INTO @tblTOP5
	SELECT	TOP  5
			Id_Item				= QH.Item_Template,
			Item				= I.Short_Desc,
			Total_Sale			= ROUND(SUM(QH.Total * Exchange_Rate),2)

	FROM  [fnQuotation](@pvIdLanguageUser) Q
	
	INNER JOIN Quotation_Header QH ON 
	Q.Folio =  QH.Folio AND
	Q.[Version] = QH.[Version]

	INNER JOIN Security_Users U ON 
	Q.Id_Sales_Executive = U.[User]

	INNER JOIN Cat_Item I ON 
	QH.Item_Template = I.Id_Item

	INNER JOIN Security_User_Roles SUR ON -- AEGH 05/08/25 -- Multiline Users Project
	U.[User] = SUR.[User]				  -- AEGH 05/08/25 -- Multiline Users Project
	
	WHERE Q.Id_Quotation_Status = 'ACCE'
	AND (@vIdSalesExecutive = '' OR Q.Id_Sales_Executive = @vIdSalesExecutive)
	AND (@pvIdZone = '' OR SUR.Id_Zone = @pvIdZone) -- AEGH 05/08/25 -- Multiline Users Project
	AND CONVERT(varchar(8), Q.Creation_Date, 112) BETWEEN @vInitialDate AND @vFinalDate
	
	GROUP BY	QH.Item_Template, I.Short_Desc
	
	ORDER BY Total_Sale DESC

	/*============================================================*/
	-- TOTALS TOP 5
	/*============================================================*/
	SELECT 
			Id_Item	,
			Item,
			Total_Sale,
			Percentaje_Sale = ROUND(((Total_Sale / (SELECT SUM(Total_Sale) FROM @tblTOP5)) * 100),2)
	FROM @tblTOP5

	


	