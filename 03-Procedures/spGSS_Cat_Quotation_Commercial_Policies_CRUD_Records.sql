USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_Cat_Quotation_Commercial_Policies_CRUD_Records]    Script Date: 5/1/2026 9:59:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Autor:		Angel Gutierrez
Desc:		GSS_Cat_Quotation_Commercial_Policies | Create - Read - Upadate - Delete 
Date:		04/15/2026
Example:
			spGSS_Cat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX' , @pvIdSalesType = 'DIRSA', @pvIdIncoterm = 'EXW', @pvIdCurrency = 'USD', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spGSS_Cat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'SPA'
			spGSS_Cat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX'
			spGSS_Cat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX', @pvIdSalesType = 'DISSA' 
			spGSS_Cat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX', @pvIdSalesType = 'DISSA', @pvIdIncoterm = 'EXW'
			spGSS_Cat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX', @pvIdSalesType = 'DIRSA', @pvIdIncoterm = 'EXW', @pvIdCurrency = 'USD'

			spGSS_Cat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'R', @pvIdUser = 'ALZEPEDA'
			spGSS_Cat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'R', @pvIdUser = 'ANGUTIERRE'

			spGSS_Cat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX' , @pvIdSalesType = 'DIRSA', @pvIdIncoterm = 'EXW', @pvIdCurrency = 'USD', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			
			spGSS_Cat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX', @pvIdSalesType = 'DIRSA', @pvIdIncoterm = 'EXW', @pvIdCurrency = 'USD'

SELECT * FROM Cat_Quotation_Commercial_Policies			
			
*/
CREATE PROCEDURE [dbo].[spGSS_Cat_Quotation_Commercial_Policies_CRUD_Records]
@pvOptionCRUD		Varchar(1),
@pvIdUser			Varchar(10) = '',
@pvIdLanguageUser	Varchar(10) = 'ANG',
@pvIdCountry		Varchar(10) = '',
@pvIdSalesType		Varchar(10) = '',
@pvIdIncoterm		Varchar(10) = '',
@pvIdCurrency		Varchar(10) = '',
@pbStatus			Bit			= '',
@pvUser				Varchar(50) = '',
@pvIP				Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'GSS_Cat_Quotation_Commercial_Policies - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spGSS_Cat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL') + "', @pvIdSalesType = '" + ISNULL(@pvIdSalesType,'NULL') + "', @pvIdIncoterm = '" + ISNULL(@pvIdIncoterm,'NULL') + "', @pvIdCurrency = '" + ISNULL(@pvIdCurrency,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		/*-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Quotation_Commercial_Policies WHERE Id_Country = @pvIdCountry and Id_Sales_Type= @pvIdSalesType AND Id_Incoterm = @pvIdIncoterm AND Id_Currency = @pvIdCurrency)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Cat_Quotation_Commercial_Policies(
				Id_Country,
				Id_Sales_Type,
				Id_Incoterm,
				Id_Currency,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdCountry,
				@pvIdSalesType,
				@pvIdIncoterm,
				@pvIdCurrency,
				@pbStatus,
				GETDATE(),
				@pvUser,
				@pvIP)
		END*/

		PRINT 'Create Records';
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R' 
	BEGIN

		SELECT
			GSSCQCP.ID_Country,
			CC.Short_Desc AS [Country_Desc],
			GSSCQCP.Id_Sales_Type,
			CST.Short_Desc AS [Sales_Type_Desc],
			GSSCQCP.Id_Incoterm,
			CI.Short_Desc AS [Incoterm_Desc],
			GSSCQCP.Id_Currency,
			CCurr.Short_Desc AS [Currency_Desc],
			GSSCQCP.[Status]
		FROM GSS_Cat_Quotation_Commercial_Policies AS GSSCQCP INNER JOIN Cat_Countries AS CC ON
																	GSSCQCP.Id_Country = CC.Id_Country
															  INNER JOIN Cat_Sales_Types AS CST ON
																	GSSCQCP.Id_Sales_Type = CST.Id_Sales_Type
																AND CST.Id_Language = @pvIdLanguageUser -- Param @pvIdLanguage
															  INNER JOIN Cat_Incoterm AS CI ON
																	GSSCQCP.Id_Incoterm = CI.Id_Incoterm
																AND CI.Id_Language = @pvIdLanguageUser -- Param @pvIdLanguage
															  INNER JOIN Cat_Currencies AS CCurr ON
																	GSSCQCP.Id_Currency = CCurr.Id_Currency
																AND CCurr.Id_Language = @pvIdLanguageUser -- Param @pvIdLanguage
															  INNER JOIN Users_Sale_Types AS UST ON
																	UST.Id_Sales_Type = GSSCQCP.Id_Sales_Type 
																AND UST.Id_Language = @pvIdLanguageUser -- Param @pvIdLanguage
																AND UST.[User] = @pvUser -- Param @pvUser
		WHERE (@pvIdCountry = '' OR GSSCQCP.Id_Country = @pvIdCountry);

				
		/*SELECT 
		ST.Id_Language,

		CST.Id_Country,
		Country_Desc = C.Short_Desc,

		CST.Id_Sales_Type,
		Sales_Type_Desc = ST.Short_Desc,

		CST.Id_Incoterm,
		Incoterm_Desc = I.Short_Desc,

		CST.Id_Currency,
		Currency_Desc = CR.Short_Desc,

		CST.[Status],
		CST.Modify_Date,
		CST.Modify_By,
		CST.Modify_IP
		FROM GSS_Cat_Quotation_Commercial_Policies AS CST WITH(NOLOCK)
		
		INNER JOIN Cat_Countries C WITH(NOLOCK) ON 
		CST.Id_Country = C.Id_Country
		
		INNER JOIN Cat_Sales_Types ST WITH(NOLOCK) ON 
		CST.Id_Sales_Type = ST.Id_Sales_Type AND
		ST.Id_Language = @pvIdLanguageUser

		INNER JOIN Cat_Incoterm  I WITH(NOLOCK) ON 
		CST.Id_Incoterm = I.Id_Incoterm AND
		I.Id_Language = @pvIdLanguageUser
		
		INNER JOIN Cat_Currencies CR WITH(NOLOCK) ON 
		CST.Id_Currency = CR.Id_Currency AND
		CR.Id_Language = @pvIdLanguageUser

		INNER JOIN Users_Sale_Types UST WITH(NOLOCK) ON 
		--UST.Id_Sales_Type = ST.Id_Sales_Type AND
		CST.Id_Sales_Type = ST.Id_Sales_Type AND
		UST.Id_Language = @pvIdLanguageUser AND
		UST.[User] = @pvIdUser

		WHERE (@pvIdCountry = '' OR CST.Id_Country = @pvIdCountry) AND
			  (@pvIdSalesType = '' OR CST.Id_Sales_Type = @pvIdSalesType) AND
			  (@pvIdIncoterm = '' OR CST.Id_Incoterm = @pvIdIncoterm) AND
			  (@pvIdCurrency = '' OR CST.Id_Currency = @pvIdCurrency)
		ORDER BY CST.Id_Country, CST.Id_Sales_Type, CST.Id_Incoterm, CST.Id_Currency		*/
	END
	
	/*
	IF @pvOptionCRUD = 'R' AND @pvIdUser = ''
	BEGIN
		SELECT 
		ST.Id_Language,

		CST.Id_Country,
		Country_Desc = C.Short_Desc,

		CST.Id_Sales_Type,
		Sales_Type_Desc = ST.Short_Desc,

		CST.Id_Incoterm,
		Incoterm_Desc = I.Short_Desc,

		CST.Id_Currency,
		Currency_Desc = CR.Short_Desc,

		CST.[Status],
		CST.Modify_Date,
		CST.Modify_By,
		CST.Modify_IP
		FROM Cat_Quotation_Commercial_Policies CST WITH(NOLOCK)
		
		INNER JOIN Cat_Countries C WITH(NOLOCK) ON 
		CST.Id_Country = C.Id_Country
		
		INNER JOIN Cat_Sales_Types ST WITH(NOLOCK) ON 
		CST.Id_Sales_Type = ST.Id_Sales_Type AND
		ST.Id_Language = @pvIdLanguageUser

		INNER JOIN Cat_Incoterm  I WITH(NOLOCK) ON 
		CST.Id_Incoterm = I.Id_Incoterm AND
		I.Id_Language = @pvIdLanguageUser
		
		INNER JOIN Cat_Currencies CR WITH(NOLOCK) ON 
		CST.Id_Currency = CR.Id_Currency AND
		CR.Id_Language = @pvIdLanguageUser

		WHERE (@pvIdCountry = '' OR CST.Id_Country = @pvIdCountry) AND
			  (@pvIdSalesType = '' OR CST.Id_Sales_Type = @pvIdSalesType) AND
			  (@pvIdIncoterm = '' OR CST.Id_Incoterm = @pvIdIncoterm) AND
			  (@pvIdCurrency = '' OR CST.Id_Currency = @pvIdCurrency)
		ORDER BY CST.Id_Country, CST.Id_Sales_Type, CST.Id_Incoterm, CST.Id_Currency		
	END

	--------------------------------------------------------------------
	--Reads Records By User
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R' AND @pvIdUser <> ''
	BEGIN
		SELECT 
		ST.Id_Language,

		CST.Id_Country,
		Country_Desc = C.Short_Desc,

		CST.Id_Sales_Type,
		Sales_Type_Desc = ST.Short_Desc,

		CST.Id_Incoterm,
		Incoterm_Desc = I.Short_Desc,

		CST.Id_Currency,
		Currency_Desc = CR.Short_Desc,

		CST.[Status],
		CST.Modify_Date,
		CST.Modify_By,
		CST.Modify_IP
		FROM Cat_Quotation_Commercial_Policies CST WITH(NOLOCK)
		
		INNER JOIN Cat_Countries C WITH(NOLOCK) ON 
		CST.Id_Country = C.Id_Country
		
		INNER JOIN Cat_Sales_Types ST WITH(NOLOCK) ON 
		CST.Id_Sales_Type = ST.Id_Sales_Type AND
		ST.Id_Language = @pvIdLanguageUser

		INNER JOIN Users_Sale_Types UST WITH(NOLOCK) ON 
		UST.Id_Sales_Type = ST.Id_Sales_Type AND
		UST.Id_Language = ST.Id_Language AND
		UST.[User] = @pvIdUser

		INNER JOIN Cat_Incoterm  I WITH(NOLOCK) ON 
		CST.Id_Incoterm = I.Id_Incoterm AND
		I.Id_Language = @pvIdLanguageUser
		
		INNER JOIN Cat_Currencies CR WITH(NOLOCK) ON 
		CST.Id_Currency = CR.Id_Currency AND
		CR.Id_Language = @pvIdLanguageUser

		WHERE (@pvIdCountry = '' OR CST.Id_Country = @pvIdCountry) AND
			  (@pvIdSalesType = '' OR CST.Id_Sales_Type = @pvIdSalesType) AND
			  (@pvIdIncoterm = '' OR CST.Id_Incoterm = @pvIdIncoterm) AND
			  (@pvIdCurrency = '' OR CST.Id_Currency = @pvIdCurrency)
		ORDER BY CST.Id_Country, CST.Id_Sales_Type, CST.Id_Incoterm, CST.Id_Currency		
	END
	*/
	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		/*UPDATE Cat_Quotation_Commercial_Policies 
		SET [Status]	= @pbStatus,
			Modify_Date	= GETDATE(),
			Modify_By	= @pvUser,
			Modify_IP	= @pvIP
		WHERE Id_Country = @pvIdCountry AND Id_Sales_Type = @pvIdSalesType*/

		PRINT 'Update Records';
	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D' OR @vDescOperationCRUD = 'N/A'
	BEGIN
		SET @bSuccessful	= 0
		SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
		SET @vMessage		= dbo.fnGetTransacMessages('N/A',@pvIdLanguageUser)
	END

	--------------------------------------------------------------------
	--Register Transaction Log
	--------------------------------------------------------------------
	EXEC spSecurity_Transaction_Log_Ins_Record	@pvDescription	= @vDescription, 
												@pvExecCommand	= @vExecCommand,
												@pbSuccessful	= @bSuccessful, 
												@pvMessagetType = @vMessageType,
												@pvMessage		= @vMessage, 
												@pvUser			= @pvUser, 
												@pnIdTransacLog	= @nIdTransacLog OUTPUT
	SET NOCOUNT OFF

	IF @pvOptionCRUD <> 'R'
	SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog
END TRY
BEGIN CATCH
	--------------------------------------------------------------------
	-- Exception Handling
	--------------------------------------------------------------------
	SET @vMessageType	= dbo.fnGetTransacMessages('ERR',@pvIdLanguageUser)	--Error
	SET @vMessage		= dbo.fnGetTransacErrorBD()
	SET @bSuccessful	= 0 --Execution with errors
	EXEC spSecurity_Transaction_Log_Ins_Record	@pvDescription	= @vDescription, 
												@pvExecCommand	= @vExecCommand,
												@pbSuccessful	= @bSuccessful, 
												@pvMessagetType = @vMessageType,
												@pvMessage		= @vMessage, 
												@pvUser			= @pvUser, 
												@pnIdTransacLog	= @nIdTransacLog OUTPUT

	SET @vMessage		= dbo.fnGetTransacMessages('Generic Error',@pvIdLanguageUser)
	SET NOCOUNT OFF
		SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog
		
END CATCH
