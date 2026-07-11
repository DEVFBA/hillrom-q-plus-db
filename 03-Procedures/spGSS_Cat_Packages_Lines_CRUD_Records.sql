USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_Cat_Packages_Lines_CRUD_Records]    Script Date: 5/16/2026 9:01:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Autor:		Angel Gutierrez
Desc:		GSS_Cat_Categories | Create - Read - Upadate - Delete || EFGSS002
Date:		05/16/2026
Example:
			EXEC spGSS_Cat_Packages_Lines_CRUD_Records	@pvOptionCRUD		= 'C', 
														@pvIdPackageLine	= 'TEST0001',	
														@pvShortDesc		= 'Test AG001 Short', 
														@pvLongDesc			= 'Test AG001 Long', 
														@pbStatus			= 1, 
														@pvUser				= 'ANGUTIERRE', 
														@pvIP				= 'CREATE TST';
			SELECT
				*
			FROM GSS_Cat_Packages_Lines
			WHERE 
					Id_Package_Line = 'TEST0001';

			EXEC spGSS_Cat_Packages_Lines_CRUD_Records	@pvOptionCRUD		= 'R', 
														@pvIdPackageLine	= 'NA', 
														@pvShortDesc		= '';
			
			EXEC spGSS_Cat_Packages_Lines_CRUD_Records	@pvOptionCRUD		= 'U', 
														@pvIdPackageLine	= 'TEST0001', 
														@pvShortDesc		= 'AEGH Update S', 
														@pvLongDesc			= 'AEGH Test Long Desc Updated', 
														@pbStatus			= 0,
														@pvUser				= 'ANGUTIERRE', 
														@pvIP				= 'UPD TST';

			SELECT
				*
			FROM GSS_Cat_Packages_Lines
			WHERE 
					Id_Package_Line = 'TEST0001';
			
*/
CREATE PROCEDURE [dbo].[spGSS_Cat_Packages_Lines_CRUD_Records]
@pvOptionCRUD		Varchar(1),
@pvIdPackageLine	Varchar(10)		= '',
@pvShortDesc		Varchar(50)		= '',
@pvLongDesc			Varchar(255)	= '',
@pbStatus			Bit				= '',
@pvUser				Varchar(50)		= '',
@pvIP				Varchar(20)		= '',
@pvIdLanguageUser	Varchar(10)		= 'ANG'
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
	DECLARE @vDescription	Varchar(255)	= 'GSS_Cat_Packages_Lines - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spGSSCat_Package_Lines_CRUD_Records @pvOptionCRUD =  '" 
												+ ISNULL(@pvOptionCRUD,'NULL') 
												+ "', @pvIdLanguageUser = '" 
												+ ISNULL(@pvIdLanguageUser,'NULL') 
												+ "', @pvIdPackageLine = '" 
												+ ISNULL(@pvIdPackageLine,'NULL')  
												+ "', @pvShortDesc = '" 
												+ ISNULL(@pvShortDesc,'NULL') 
												+ "', @pvLongDesc = '" 
												+ ISNULL(@pvLongDesc,'NULL') 
												+ "', @pbStatus = '" 
												+ ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') 
												+ "', @pvUser = '" + ISNULL(@pvUser,'NULL') 
												+ "', @pvIP = '" + ISNULL(@pvIP,'NULL')
												+ "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM GSS_Cat_Packages_Lines WHERE Id_Package_Line = @pvIdPackageLine)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don�t Exist
		BEGIN
			INSERT INTO GSS_Cat_Packages_Lines(
				Id_Package_Line,
				Short_Desc,
				Long_Desc,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP
				)
			VALUES (
				@pvIdPackageLine,
				@pvShortDesc,
				@pvLongDesc,
				@pbStatus,
				GETDATE(),
				@pvUser,
				@pvIP
				)
		END
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN

		SELECT
			Id_Package_Line,
			Short_Desc,
			Long_Desc,
			Modify_By,
			Modify_Date
			Modify_IP,
			[Status]
		FROM GSS_Cat_Packages_Lines
		WHERE
				(@pvIdPackageLine = '' OR Id_Package_Line = @pvIdPackageLine)
			AND (@pvShortDesc = '' OR Short_Desc LIKE '%' + @pvShortDesc + '%')
			AND (@pvLongDesc = '' OR Long_Desc LIKE '%' + @pvLongDesc + '%');
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE GSS_Cat_Packages_Lines 
		SET Short_Desc			= @pvShortDesc,
			Long_Desc			= @pvLongDesc,
			[Status]			= @pbStatus,
			Modify_Date			= GETDATE(),
			Modify_By			= @pvUser,
			Modify_IP			= @pvIP
		WHERE Id_Package_Line	= @pvIdPackageLine
 
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

	IF @pvOptionCRUD NOT IN ('R', 'V')
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