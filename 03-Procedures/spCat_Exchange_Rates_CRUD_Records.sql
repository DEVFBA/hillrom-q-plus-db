USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Exchange_Rates_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Exchange_Rates_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Exchange_Rates_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Exchange_Rates_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Exchange_Rates | Create - Read - Upadate - Delete 
Date:		08/01/2021
Example:
			spCat_Exchange_Rates_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', '@pvId_Currency = 'USD' , @pfExchange_Rate = 1.1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Exchange_Rates_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvId_Currency = 'USD' , @pvIdExchangeRate = 1
			spCat_Exchange_Rates_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvId_Currency = 'USD' , @pvIdExchangeRate = 1 , @pfExchange_Rate = 10.40, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Exchange_Rates_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvId_Currency = 'USD' , @pvIdExchangeRate = 1 , @pfExchange_Rate = 10.40, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Exchange_Rates_CRUD_Records @pvOptionCRUD = 'X', @pvIdLanguageUser = 'ANG', @pvId_Currency = 'USD' , @pvIdExchangeRate = 1 , @pfExchange_Rate = 10.40, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

			spCat_Exchange_Rates_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvId_Currency = 'MXN' , @pfExchange_Rate = 0.050401, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Exchange_Rates_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'SPA'
			spCat_Exchange_Rates_CRUD_Records @pvOptionCRUD = 'R', @pvId_Currency = 'USD'
			
*/
CREATE PROCEDURE [dbo].spCat_Exchange_Rates_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = 'ANG',
@pvId_Currency		Varchar(10) = '',
@pvIdExchangeRate	Int			= 0,
@pfExchange_Rate	Float		= 0,
@pvUser				Varchar(50) = '',
@pvIP				Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	Declare @pvFinalDate		Date		= GETDATE()
	Declare @pvInitialDate		Date		= GETDATE()

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Cat_Exchange_Rates - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Exchange_Rates_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvId_Currency = '" + ISNULL(@pvId_Currency,'NULL') + "', @pvIdExchangeRate = " + ISNULL(CAST(@pvIdExchangeRate AS varchar),'NULL') + ", @pfExchange_Rate = " + ISNULL(CAST(@pfExchange_Rate AS varchar),'NULL') + ",  @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Exchange_Rates WHERE Id_Currency = @pvId_Currency and Exchange_Rate = @pfExchange_Rate and [Status] = 1)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN

			--Update previous record
			UPDATE Cat_Exchange_Rates
			SET [Status] = 0,
				Final_Effective_Date = @pvFinalDate
			WHERE Id_Currency = @pvId_Currency 
			AND  [Status] = 1

			--Insert new record
			SET @pvIdExchangeRate = (SELECT ISNULL(MAX(Id_Exchange_Rate),0) + 1 FROM Cat_Exchange_Rates WHERE Id_Currency = @pvId_Currency)

			INSERT INTO Cat_Exchange_Rates(
				Id_Currency,
				Id_Exchange_Rate,
				Exchange_Rate,
				Initial_Effective_Date,
				Final_Effective_Date,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvId_Currency,
				@pvIdExchangeRate,
				@pfExchange_Rate,
				@pvInitialDate,
				NULL,
				1, --Enable
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
		ER.Id_Currency,
		Currency_Desc = C.Short_Desc,
		ER.Id_Exchange_Rate,
		ER.Exchange_Rate,
		ER.Initial_Effective_Date,
		ER.Final_Effective_Date,
		ER.[Status],
		ER.Modify_Date,
		ER.Modify_By,
		ER.Modify_IP
		FROM Cat_Exchange_Rates ER WITH(NOLOCK)
		
		INNER JOIN Cat_Currencies C WITH(NOLOCK) ON 
		ER.Id_Currency = C.Id_Currency AND
		C.Id_Language = @pvIdLanguageUser
		WHERE (@pvId_Currency	 = ''	OR ER.Id_Currency = @pvId_Currency) AND 
			  (@pvIdExchangeRate = 0	OR ER.Id_Exchange_Rate = @pvIdExchangeRate)
		
		ORDER BY ER.Id_Currency, ER.Id_Exchange_Rate		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		SET @bSuccessful	= 0
		SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
		SET @vMessage		= dbo.fnGetTransacMessages('N/A',@pvIdLanguageUser)
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
