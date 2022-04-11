USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_File_Types
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_File_Types'

IF OBJECT_ID('[dbo].[spCat_File_Types]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_File_Types
GO
/*
Autor:		Alejandro Zepeda
Desc:		Cat_File_Types | Create - Read - Upadate - Delete 
Date:		14/09/2021
Example:
			spCat_File_Types @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG'
			spCat_File_Types @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvUse = 'Approval Routes'
			spCat_File_Types @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdFileType = 'FILE'
			spCat_File_Types @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG'
			spCat_File_Types @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG'
			 
*/
CREATE PROCEDURE [dbo].spCat_File_Types
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@pvIdFileType		Varchar(10) = '',
@pvShortDesc		Varchar(50) = '',
@pvName				Varchar(255)= '',
@pvExtension		Varchar(5)	= '',
@pvUse				Varchar(255)= '',
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_File_Types - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	=  dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_File_Types @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdFileType = " + ISNULL(CAST(@pvIdFileType AS VARCHAR),'NULL') + ", @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvName = '" + ISNULL(@pvName,'NULL') + "', @pvExtension = '" + ISNULL(@pvExtension,'NULL') + "', @pvUse = '" + ISNULL(@pvUse,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		SET @bSuccessful	= 0
		SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
		SET @vMessage		= dbo.fnGetTransacMessages('N/A',@pvIdLanguageUser)
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT
		A.Id_Language,
		Desc_Language  = L.Short_Desc,
		Id_Catalog = A.Id_File_Type,
		A.Short_Desc,
		A.[Name],
		A.[Extension],
		A.[Use],
		A.[Status],
		A.Modify_Date,
		A.Modify_By,
		A.Modify_IP
		FROM Cat_File_Types A

		INNER JOIN Cat_Languages L ON 
		A.Id_Language = L.Id_Language AND
		A.Id_Language = L.Id_Language_Translation

		WHERE 
		(@pvIdLanguageUser = ''  OR L.Id_Language = @pvIdLanguageUser) AND 
		(@pvIdFileType = '' OR A.Id_File_Type = @pvIdFileType) AND
		(@pvUse = '' OR A.[Use] = @pvUse)

		ORDER BY A.Id_Language,Id_Catalog
		
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
