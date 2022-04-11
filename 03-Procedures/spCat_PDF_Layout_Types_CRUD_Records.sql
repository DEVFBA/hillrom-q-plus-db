USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_PDF_Layout_Types_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_PDF_Layout_Types_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_PDF_Layout_Types_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_PDF_Layout_Types_CRUD_Records
GO
/*
Autor:		Alejandro Zepeda
Desc:		Cat_PDF_Layout_Types | Create - Read - Upadate - Delete 
Date:		02/01/2021
Example:
			spCat_PDF_Layout_Types_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdLayoutType = 'IPL' ,  @pvIdZoneType = 'PDFIPL',  @pvShortDesc = 'IPL Price List', @pvLongDesc = 'IPL Price List', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_PDF_Layout_Types_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG'
			spCat_PDF_Layout_Types_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdLayoutType = 'IPL'
			spCat_PDF_Layout_Types_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdLayoutType = 'IPL'
			spCat_PDF_Layout_Types_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdLayoutType = 'IPL' , @pvIdZoneType = 'PDFIPL', @pvShortDesc = 'IPL Price List', @pvLongDesc = 'IPL Price List', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_PDF_Layout_Types_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvIdLayoutType = 'IPL' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_PDF_Layout_Types_CRUD_Records @pvOptionCRUD = 'X', @pvIdLanguageUser = 'ANG', @pvIdLayoutType = 'IPL' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
*/
CREATE PROCEDURE [dbo].spCat_PDF_Layout_Types_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@pvIdLayoutType		Varchar(10) = '',
@pvIdZoneType		Varchar(10) = '',
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_PDF_Layout_Types - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	=  dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_PDF_Layout_Types_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdLayoutType = '" + ISNULL(@pvIdLayoutType,'NULL') + "', @pvIdZoneType = '" + ISNULL(@pvIdZoneType,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_PDF_Layout_Types WHERE Id_Layout_Type = @pvIdLayoutType)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Cat_PDF_Layout_Types(
				Id_Layout_Type,
				Id_Zone_Type,
				Short_Desc,
				Long_Desc,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdLayoutType,
				@pvIdZoneType,
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
		Id_Catalog = Z.Id_Layout_Type,
		Z.Id_Zone_Type,
		Zone_Type_Desc = ZT.Short_Desc,
		Z.Short_Desc,
		Z.Long_Desc,
		Z.[Status],
		Z.Modify_Date,
		Z.Modify_By,
		Z.Modify_IP
		FROM Cat_PDF_Layout_Types Z
		INNER JOIN Cat_Zone_Types ZT ON 
		Z.Id_Zone_Type = ZT.Id_Zone_Type
		WHERE (@pvIdLayoutType = '' OR Z.Id_Layout_Type = @pvIdLayoutType)
		AND (@pvIdZoneType = '' OR Z.Id_Zone_Type = @pvIdZoneType)
		ORDER BY Id_Catalog
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_PDF_Layout_Types 
		SET Id_Zone_Type = @pvIdZoneType,
			Short_Desc	 = @pvShortDesc,
			Long_Desc	 = @pvLongDesc,
			[Status]	 = @pbStatus,
			Modify_Date	 = GETDATE(),
			Modify_By	 = @pvUser,
			Modify_IP	 = @pvIP
		WHERE Id_Layout_Type = @pvIdLayoutType

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
