USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
 
/* ==================================================================================*/
-- spCat_Absence_Reasons_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Absence_Reasons_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Absence_Reasons_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Absence_Reasons_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Absence_Reasons | Create - Read - Upadate - Delete 
Date:		27/07/2021
Example:
			spCat_Absence_Reasons_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvShortDesc = 'Ausencia', @pvLongDesc = 'Ausencia Larga', @pbStatus = 1, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'
			spCat_Absence_Reasons_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piIdAbsenceReasons = 1
			spCat_Absence_Reasons_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @piIdAbsenceReasons = 1 , @pvShortDesc = 'Ausencia .', @pvLongDesc = 'Ausencia Larga',  @pbStatus = 1, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'
			spCat_Absence_Reasons_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @piIdAbsenceReasons = 1 , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Absence_Reasons_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG'
			
*/
CREATE PROCEDURE [dbo].spCat_Absence_Reasons_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@piIdAbsenceReasons	Varchar(10) = 0,
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_Absence_Reasons - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Absence_Reasons_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piIdAbsenceReasons = '" + ISNULL(@piIdAbsenceReasons,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Absence_Reasons WHERE Short_Desc = @pvShortDesc)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN

			SET @piIdAbsenceReasons = (SELECT ISNULL(MAX(Id_Absence_Reasons) + 1,1) FROM Cat_Absence_Reasons) 

			INSERT INTO Cat_Absence_Reasons(
				Id_Absence_Reasons,
				Short_Desc,
				Long_Desc,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@piIdAbsenceReasons,
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
		Id_Catalog = Id_Absence_Reasons,
		Short_Desc,
		Long_Desc,
		[Status],
		Modify_Date,
		Modify_By,
		Modify_IP
		
		FROM Cat_Absence_Reasons A

		WHERE 
		(@piIdAbsenceReasons = 0  OR Id_Absence_Reasons = @piIdAbsenceReasons)
		
		ORDER BY Id_Catalog

	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Absence_Reasons 
		SET Short_Desc	= @pvShortDesc,
			Long_Desc	= @pvLongDesc,
			[Status]	= @pbStatus,
			Modify_Date	= GETDATE(),
			Modify_By	= @pvUser,
			Modify_IP	= @pvIP
		WHERE Id_Absence_Reasons = @piIdAbsenceReasons


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
	SET @vMessageType	= dbo.fnGetTransacMessages('ERR',@pvIdLanguageUser)	--Erro
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
