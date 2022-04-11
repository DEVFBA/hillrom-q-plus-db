USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Countries_Currencies_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Countries_Currencies_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Countries_Currencies_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Countries_Currencies_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Countries_Currencies | Create - Read - Upadate - Delete 
Date:		05/01/2021
Example:
			spCat_Countries_Currencies_CRUD_Records @pvOptionCRUD = 'C',  @pvIdLanguageUser = 'SPA', @pvIdCountry = 'MX' , @pvIdCurrency = 'MXN', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Countries_Currencies_CRUD_Records @pvOptionCRUD = 'R'
			spCat_Countries_Currencies_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'SPA', @pvIdCountry = 'MX' , @pvIdCurrency = 'MXN' 
			spCat_Countries_Currencies_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'SPA', @pvIdCountry = 'MX' , @pvIdCurrency = 'MXN', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Countries_Currencies_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'SPA', @pvIdCountry = 'MX' , @pvIdCurrency = 'MXN', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			
			spCat_Countries_Currencies_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'SPA', @pvIdCountry = 'MX' , @pvIdCurrency = 'USD', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Countries_Currencies_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'SPA', @pvIdCountry = 'MX' , @pvIdCurrency = 'USD'
			SELECT * FROM Cat_Countries_Currencies
*/
CREATE PROCEDURE [dbo].spCat_Countries_Currencies_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = 'ANG',
@pvIdCountry		Varchar(10) = '',
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_Countries_Currencies - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Countries_Currencies_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL') + "', @pvIdCurrency = '" + ISNULL(@pvIdCurrency,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Countries_Currencies WHERE Id_Country = @pvIdCountry and Id_Currency= @pvIdCurrency)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Cat_Countries_Currencies(
				Id_Country,
				Id_Currency,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdCountry,
				@pvIdCurrency,
				@pbStatus,
				GETDATE(),
				@pvUser,
				@pvIP)
		END
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
		CP.Id_Country,
		Country_Desc = C.Short_Desc,
		CP.Id_Currency,
		Currency_Desc = P.Short_Desc,
		CP.[Status],
		CP.Modify_Date,
		CP.Modify_By,
		CP.Modify_IP
		FROM Cat_Countries_Currencies CP WITH(NOLOCK)
		
		INNER JOIN Cat_Countries C WITH(NOLOCK) ON 
		CP.Id_Country = C.Id_Country
		
		INNER JOIN Cat_Currencies P WITH(NOLOCK) ON 
		CP.Id_Currency = P.Id_Currency
	
		WHERE 
		 (@pvIdLanguageUser = '' OR P.Id_Language = @pvIdLanguageUser ) AND
		 (@pvIdCountry = '' OR CP.Id_Country = @pvIdCountry ) AND
		 (@pvIdCurrency = '' OR CP.Id_Currency = @pvIdCurrency)
		ORDER BY CP.Id_Country, CP.Id_Currency
	
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Countries_Currencies 
		SET [Status]	= @pbStatus,
			Modify_Date	= GETDATE(),
			Modify_By	= @pvUser,
			Modify_IP	= @pvIP
		WHERE Id_Country = @pvIdCountry AND Id_Currency = @pvIdCurrency
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
