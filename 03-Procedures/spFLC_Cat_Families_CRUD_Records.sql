USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spFLC_Cat_Families_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spFLC_Cat_Families_CRUD_Records'

IF OBJECT_ID('[dbo].[spFLC_Cat_Families_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spFLC_Cat_Families_CRUD_Records
GO
/*
Autor:		Alejandro Zepeda
Desc:		FLC_Cat_Families | Create - Read - Upadate - Delete 
Date:		24/09/2023
Example:
			spFLC_Cat_Families_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdFLCFamily = 'Id' , @pvShortDesc = 'Record 1', @pvLongDesc = 'Record 1 Long Desc', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spFLC_Cat_Families_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdFLCFamily = 'Id' 
			spFLC_Cat_Families_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdFLCFamily = 'Id' , @pvShortDesc = 'Record 1', @pvLongDesc = 'Record 1 Long Desc', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spFLC_Cat_Families_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvIdFLCFamily = 'Id' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spFLC_Cat_Families_CRUD_Records @pvOptionCRUD = 'X', @pvIdLanguageUser = 'ANG', @pvIdFLCFamily = 'Id' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254''
*/
CREATE PROCEDURE [dbo].spFLC_Cat_Families_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@pvIdFLCFamily		Varchar(10) = '',
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
	DECLARE @vDescription	Varchar(255)	= 'FLC_Cat_Families - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spFLC_Cat_Families_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdFLCFamily = '" + ISNULL(@pvIdFLCFamily,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM FLC_Cat_Families WHERE Id_FLC_Family = @pvIdFLCFamily)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO FLC_Cat_Families(
				Id_FLC_Family,
				Short_Desc,
				Long_Desc,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdFLCFamily,
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
		Id_Catalog = Id_FLC_Family,
		Short_Desc,
		Long_Desc,
		[Status],
		Modify_Date,
		Modify_By,
		Modify_IP
		FROM FLC_Cat_Families 
		WHERE @pvIdFLCFamily = '' OR Id_FLC_Family = @pvIdFLCFamily
		ORDER BY Id_Catalog
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE FLC_Cat_Families 
		SET Short_Desc	= @pvShortDesc,
			Long_Desc	= @pvLongDesc,
			[Status]	= @pbStatus,
			Modify_Date	= GETDATE(),
			Modify_By	= @pvUser,
			Modify_IP	= @pvIP
		WHERE Id_FLC_Family = @pvIdFLCFamily

		--Disable in Master Table
		IF @pbStatus = 0 
		BEGIN
			UPDATE FLC_Cat_Categories_Families 
			SET [Status]	= @pbStatus,
				Modify_Date	= GETDATE(),
				Modify_By	= @pvUser,
				Modify_IP	= @pvIP
			WHERE Id_FLC_Family = @pvIdFLCFamily

			UPDATE FLC_Items_Configuration 
			SET [Status]	= @pbStatus,
				Modify_Date	= GETDATE(),
				Modify_By	= @pvUser,
				Modify_IP	= @pvIP
			WHERE Id_FLC_Family = @pvIdFLCFamily
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
