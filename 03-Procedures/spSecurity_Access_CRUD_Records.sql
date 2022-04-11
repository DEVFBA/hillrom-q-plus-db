USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spSecurity_Access_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spSecurity_Access_CRUD_Records'

IF OBJECT_ID('[dbo].[spSecurity_Access_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spSecurity_Access_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Security_Access | Create - Read - Upadate - Delete 
Date:		13/01/2021
Example:

			DECLARE  @udtSecurityAccess  UDT_Security_Access 

			INSERT INTO @udtSecurityAccess
			SELECT * FROM Security_Access
			WHERE Id_Role = 'SALES' 

			EXEC spSecurity_Access_CRUD_Records @pvOptionCRUD = 'C',  @pvIdLanguageUser = 'ANG', @pvIdRole = 'SALES', @pudtSecurityAccess = @udtSecurityAccess , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

			EXEC spSecurity_Access_CRUD_Records @pvOptionCRUD = 'R',  @pvIdLanguageUser = 'ANG', @pvIdRole = 'SALES' 
			EXEC spSecurity_Access_CRUD_Records @pvOptionCRUD = 'U',  @pvIdLanguageUser = 'ANG', @pvIdRole = 'ACCE' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spSecurity_Access_CRUD_Records @pvOptionCRUD = 'D',  @pvIdLanguageUser = 'ANG', @pvIdRole = 'ACCE' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spSecurity_Access_CRUD_Records @pvOptionCRUD = 'X',  @pvIdLanguageUser = 'ANG', @pvIdRole = 'ACCE' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

*/
CREATE PROCEDURE [dbo].spSecurity_Access_CRUD_Records
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10) = '',
@pvIdRole				Varchar(10),
@pudtSecurityAccess		UDT_Security_Access Readonly ,
@pvUser					Varchar(50) = '',
@pvIP					Varchar(20) = ''
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
	DECLARE @vDescription	Varchar(255)	= 'Security_Access - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spSecurity_Access_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "',  @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', , @pvIdItemClass = '" + ISNULL(@pvIdRole,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		DELETE Security_Access WHERE Id_Role = @pvIdRole

		INSERT INTO Security_Access(
			Id_Role,
			Id_Module,
			Id_SubModule,
			Id_SubModuleOption,
			[Url],
			[Status],
			Modify_By,
			Modify_Date,
			Modify_IP)
		SELECT 
			Id_Role,
			Id_Module,
			Id_SubModule,
			Id_SubModuleOption,
			[Url],
			[Status],
			Modify_By	= @pvUser,
			Modify_Date = GETDATE(),
			Modify_IP	= @pvIP
		FROM @pudtSecurityAccess
		WHERE Id_Role = @pvIdRole
		AND [Status] = 1

	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT	Id_Role = @pvIdRole,
				SYSC.Id_Module,
				Module_Desc = M.Short_Desc,
				SYSC.Id_SubModule,
				SubModule_Desc = SM.Short_Desc,
				SYSC.Id_SubModuleOption,
				Option_Desc = SMO.Short_Desc,
				SYSC.[Url],
				[Status] = ISNULL(SA.[Status],0),
				SA.Modify_By,
				SA.Modify_Date,
				SA.Modify_IP 		
		FROM Security_Access SYSC 

		LEFT OUTER JOIN Security_Access SA ON 
		SYSC.Id_Module			= SA.Id_Module AND 
		SYSC.Id_SubModule		= SA.Id_SubModule AND 
		SYSC.Id_SubModuleOption = SA.Id_SubModuleOption AND
		SA.Id_Role = @pvIdRole

		INNER JOIN Security_Modules M ON
		SYSC.Id_Module = M.Id_Module

		INNER JOIN Security_SubModules SM ON 
		SYSC.Id_SubModule = SM.Id_SubModule

		INNER JOIN Security_SubModules_Options SMO ON 
		SYSC.Id_SubModuleOption = SMO.Id_SubModuleOption

		WHERE SYSC.Id_Role = 'SYS_CONFIG' 
		ORDER BY M.[Order], SM.[Order], SMO.[Order]
		
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
