USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spUsers_Sale_Types_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spUsers_Sale_Types_CRUD_Records'

IF OBJECT_ID('[dbo].[spUsers_Sale_Types_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spUsers_Sale_Types_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Users_Sale_Types | Create - Read - Upadate - Delete 
Date:		04/05/2025
Example:
			spUsers_Sale_Types_CRUD_Records @pvOptionCRUD = 'C', @pvIdUser = 'ALZEPEDA', @pvIdSalesType = 'DIRSA', @pvIdLanguageUser = 'ANG', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spUsers_Sale_Types_CRUD_Records @pvOptionCRUD = 'C', @pvIdUser = 'ANGUTIERRE', @pvIdSalesType = 'DIRSA', @pvIdLanguageUser = 'SPA', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spUsers_Sale_Types_CRUD_Records @pvOptionCRUD = 'R'
			spUsers_Sale_Types_CRUD_Records @pvOptionCRUD = 'R', @pvIdUser = 'ALZEPEDA'
			spUsers_Sale_Types_CRUD_Records @pvOptionCRUD = 'R', @pvIdSalesType = 'DIRSA' 
			spUsers_Sale_Types_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG'
			spUsers_Sale_Types_CRUD_Records @pvOptionCRUD = 'R', @pvIdUser = 'ALZEPEDA', @pvIdSalesType = 'DIRSA', @pvIdLanguageUser = 'ANG'
			spUsers_Sale_Types_CRUD_Records @pvOptionCRUD = 'U', @pvIdUser = 'ALZEPEDA', @pvIdSalesType = 'DIRSA', @pvIdLanguageUser = 'ANG', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spUsers_Sale_Types_CRUD_Records @pvOptionCRUD = 'D', @pvIdUser = 'ALZEPEDA', @pvIdSalesType = 'DIRSA', @pvIdLanguageUser = 'ANG', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			select * from Users_Sale_Types
			 
*/
CREATE PROCEDURE [dbo].spUsers_Sale_Types_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdUser			Varchar(10) = '',
@pvIdSalesType		Varchar(10) = '',
@pvIdLanguageUser	Varchar(10) = '',
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
	DECLARE @vDescription	Varchar(255)	= 'Users_Sale_Types - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spUsers_Sale_Types_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdUser =  '" + ISNULL(@pvIdUser,'NULL') + "', @pvIdSalesType = '" + ISNULL(@pvIdSalesType,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Users_Sale_Types WHERE [User] = @pvIdUser AND Id_Sales_Type = @pvIdSalesType AND Id_Language = @pvIdLanguageUser )
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END		
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Users_Sale_Types(
				[User],
				Id_Sales_Type,
				Id_Language,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdUser,
				@pvIdSalesType,
				@pvIdLanguageUser,
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
		UST.[User],
		USR.[Name], 
		UST.Id_Sales_Type,
		Sales_Type = ST.Short_Desc,
		UST.Id_Language,
		Desc_Language = L.Short_Desc,
		UST.[Status],
		UST.Modify_Date,
		UST.Modify_By,
		UST.Modify_IP
		FROM Users_Sale_Types UST WITH(NOLOCK)
		
		INNER JOIN Security_Users USR WITH(NOLOCK) ON 
		UST.[User] = USR.[User]

		INNER JOIN Cat_Sales_Types ST WITH(NOLOCK) ON 
		UST.Id_Sales_Type = ST.Id_Sales_Type AND
		UST.Id_Language = ST.Id_Language 
		
		INNER JOIN Cat_Languages L WITH(NOLOCK) ON 
		UST.Id_Language = L.Id_Language  AND
		UST.Id_Language = L.Id_Language_Translation

		WHERE (@pvIdUser = ''  OR UST.[User] = @pvIdUser ) AND
		(@pvIdSalesType = '' OR UST.Id_Sales_Type = @pvIdSalesType) AND
		(@pvIdLanguageUser = '' OR  UST.Id_Language = @pvIdLanguageUser) 

		ORDER BY UST.[User], UST.Id_Sales_Type, UST.Id_Language
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Users_Sale_Types 
		SET 
			[Status]		= @pbStatus,			
			Modify_Date		= GETDATE(),
			Modify_By		= @pvUser,
			Modify_IP		= @pvIP
		WHERE [User] = @pvIdUser AND Id_Sales_Type = @pvIdSalesType AND Id_Language = @pvIdLanguageUser
	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D'
	BEGIN
		DELETE Users_Sale_Types 
		WHERE [User] = @pvIdUser AND Id_Sales_Type = @pvIdSalesType AND Id_Language = @pvIdLanguageUser
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
