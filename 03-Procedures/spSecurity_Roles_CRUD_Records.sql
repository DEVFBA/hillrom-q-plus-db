USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spSecurity_Roles_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spSecurity_Roles_CRUD_Records'

IF OBJECT_ID('[dbo].[spSecurity_Roles_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spSecurity_Roles_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Security_Roles | Create - Read - Upadate - Delete 
Date:		12/01/2021
Example:
			spSecurity_Roles_CRUD_Records @pvOptionCRUD = 'C', @pvIdRole = 'ADMIN' , @pvShortDesc = 'System Administrator', @pvLongDesc = 'System Administrator', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spSecurity_Roles_CRUD_Records @pvOptionCRUD = 'R', @pvIdRole = 'ADMIN' 
			spSecurity_Roles_CRUD_Records @pvOptionCRUD = 'R', @pvIdBusinessLine = 'PSS_LIKO' 
			spSecurity_Roles_CRUD_Records @pvOptionCRUD = 'R'
			spSecurity_Roles_CRUD_Records @pvOptionCRUD = 'U', @pvIdRole = 'ADMIN' , @pvShortDesc = 'System Administrator', @pvLongDesc = 'System Administrator', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spSecurity_Roles_CRUD_Records @pvOptionCRUD = 'D', @pvIdRole = 'ADMIN' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spSecurity_Roles_CRUD_Records @pvOptionCRUD = 'X', @pvIdRole = 'ADMIN' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

*/
CREATE PROCEDURE [dbo].spSecurity_Roles_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@pvIdRole			Varchar(10) = 'All',
@pvIdBusinessLine	Varchar(10) = '',
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
	DECLARE @vDescription	Varchar(255)	= 'Security_Roles - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spSecurity_Roles_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdRole = '" + ISNULL(@pvIdRole,'NULL') + "',  @pvIdBusinessLine = '" + ISNULL(@pvIdBusinessLine,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
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
		Id_Role,
		Short_Desc,
		Long_Desc,
		Approval_Flow_Sequence,
		Id_Business_Line,
		[Status],
		Modify_Date,
		Modify_By,
		Modify_IP
		FROM Security_Roles 
		WHERE (@pvIdRole = 'All' OR Id_Role = @pvIdRole) 
		AND   (@pvIdBusinessLine = '' OR Id_Business_Line = @pvIdBusinessLine)
		ORDER BY  Id_Role
		
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
