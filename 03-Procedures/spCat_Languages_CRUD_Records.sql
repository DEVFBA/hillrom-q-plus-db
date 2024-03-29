USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Languages_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Languages_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Languages_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Languages_CRUD_Records
GO
/*
Autor:		Alejandro Zepeda
Desc:		Cat_Languages | Create - Read - Upadate - Delete 
Date:		01/01/2021
Example:
			spCat_Languages_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'SPA', @pvIdLanguage = 'LMX' , @pvShortDesc = 'Espa�ol Latam', @pvLongDesc = 'Espa�ol Latinoamerica', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Languages_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'SPA', @pvIdLanguage = 'LMX' 
			spCat_Languages_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'SPA', @pvIdLanguage = 'LMX' , @pvShortDesc = 'Espa�ol Latam', @pvLongDesc = 'Espa�ol Latinoamerica Log Desc', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Languages_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'SPA', @pvIdLanguage = 'LMX' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Languages_CRUD_Records @pvOptionCRUD = 'X', @pvIdLanguageUser = 'SPA', @pvIdLanguage = 'LMX' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

			spCat_Languages_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'SPA', @pvIdLanguage = 'LUS' , @pvShortDesc = 'Americano', @pvLongDesc = 'Americano Long desc', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Languages_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'SPA'
*/
CREATE PROCEDURE [dbo].spCat_Languages_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@pvIdLanguage		Varchar(10) = '',
@pvShortDesc		Varchar(50) = '',
@pvLongDesc			Varchar(255)= '',
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_Languages - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Languages_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdLanguage = '" + ISNULL(@pvIdLanguage,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Languages WHERE Id_Language = @pvIdLanguage AND Id_Language_Translation = @pvIdLanguageUser)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don�t Exists
		BEGIN
			INSERT INTO Cat_Languages(
				Id_Language_Translation,
				Id_Language,
				Short_Desc,
				Long_Desc,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdLanguageUser,
				@pvIdLanguage,
				@pvShortDesc,
				@pvLongDesc,
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
		Id_Language = Id_Language_Translation,
		Desc_Language = (SELECT Short_Desc FROM Cat_Languages A WHERE A.Id_Language_Translation = Cat_Languages.Id_Language_Translation  AND A.Id_Language = Cat_Languages.Id_Language_Translation),
		Id_Catalog = Id_Language,
		Short_Desc,
		Long_Desc,
		[Status],
		Modify_Date,
		Modify_By,
		Modify_IP
		FROM Cat_Languages 
		WHERE (@pvIdLanguage = '' OR Id_Language = @pvIdLanguage) AND
			  (@pvIdLanguageUser = '' OR Id_Language_Translation = @pvIdLanguageUser)
		ORDER BY Id_Language_Translation, Id_Catalog		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Languages 
		SET Short_Desc	= @pvShortDesc,
			Long_Desc	= @pvLongDesc,
			[Status]	= @pbStatus,
			Modify_Date	= GETDATE(),
			Modify_By	= @pvUser,
			Modify_IP	= @pvIP
		WHERE Id_Language = @pvIdLanguage
		AND Id_Language_Translation = @pvIdLanguageUser

		--Disable regions in the Cat_Countries_Languages
		IF @pbStatus = 0 
		BEGIN
			UPDATE Cat_Countries_Languages 
			SET [Status]	= @pbStatus,
				Modify_Date	= GETDATE(),
				Modify_By	= @pvUser,
				Modify_IP	= @pvIP
			WHERE Id_Language = @pvIdLanguage
		END 
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
