USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Countries_Voltages_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Countries_Voltages_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Countries_Voltages_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Countries_Voltages_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Countries_Voltages | Create - Read - Upadate - Delete 
Date:		05/01/2021
Example:
			spCat_Countries_Voltages_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX' , @pvIdVoltage = 'VOLT1', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Countries_Voltages_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX' , @pvIdVoltage = 'VOLT1' 
			spCat_Countries_Voltages_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX' , @pvIdVoltage = 'VOLT1', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Countries_Voltages_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX' , @pvIdVoltage = 'VOLT1', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Countries_Voltages_CRUD_Records @pvOptionCRUD = 'X', @pvIdLanguageUser = 'ANG',  @pvIdCountry = 'MX' , @pvIdVoltage = 'VOLT1', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

			spCat_Countries_Voltages_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG',  @pvIdCountry = 'US' , @pvIdVoltage = 'VOLT2', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Countries_Voltages_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG' 
			spCat_Countries_Voltages_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG',  @pvIdCountry = 'BR'
			
*/
CREATE PROCEDURE [dbo].spCat_Countries_Voltages_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@pvIdCountry		Varchar(10) = '',
@pvIdVoltage		Varchar(10) = '',
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_Countries_Voltages - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Countries_Voltages_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL') + "', @pvIdVoltage = '" + ISNULL(@pvIdVoltage,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Countries_Voltages WHERE Id_Country = @pvIdCountry and Id_Voltage= @pvIdVoltage)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Cat_Countries_Voltages(
				Id_Country,
				Id_Voltage,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdCountry,
				@pvIdVoltage,
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
		CV.Id_Country,
		Country_Desc = C.Short_Desc,
		CV.Id_Voltage,
		Voltage_Desc = V.Short_Desc,
		CV.[Status],
		CV.Modify_Date,
		CV.Modify_By,
		CV.Modify_IP
		FROM Cat_Countries_Voltages CV WITH(NOLOCK)
		
		INNER JOIN Cat_Countries C WITH(NOLOCK) ON 
		CV.Id_Country = C.Id_Country
		
		INNER JOIN Cat_Voltages V WITH(NOLOCK) ON 
		CV.Id_Voltage = V.Id_Voltage
		
		WHERE (@pvIdCountry = '' OR CV.Id_Country = @pvIdCountry) AND
			  (@pvIdVoltage = '' OR CV.Id_Voltage = @pvIdVoltage)
		ORDER BY CV.Id_Country, CV.Id_Voltage		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Countries_Voltages 
		SET [Status]	= @pbStatus,
			Modify_Date	= GETDATE(),
			Modify_By	= @pvUser,
			Modify_IP	= @pvIP
		WHERE Id_Country = @pvIdCountry AND Id_Voltage = @pvIdVoltage
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
