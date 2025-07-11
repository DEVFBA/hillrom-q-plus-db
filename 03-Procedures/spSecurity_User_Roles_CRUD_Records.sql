USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spSecurity_User_Roles_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spSecurity_User_Roles_CRUD_Records'

IF OBJECT_ID('[dbo].[spSecurity_User_Roles_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spSecurity_User_Roles_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Security_User_Roles | Create - Read - Upadate - Delete 
Date:		12/01/2021
Example:
			spSecurity_User_Roles_CRUD_Records @pvOptionCRUD = 'C',@pvIdUser = 'ALZEPEDA' , 
																@pvIdRole = 'ADMIN', 
																@pvIdZone = 'ALLZ', 
																@pvIdLanguage ='SPA', 
																@pbPrincipal = 0, 
																@pbStatus = 1, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'

			spSecurity_User_Roles_CRUD_Records @pvOptionCRUD = 'R', @pvIdUser = 'ADVEGA', @pvIdRole = 'SALES', @pvIdZone = 'CEN' 
			spSecurity_User_Roles_CRUD_Records @pvOptionCRUD = 'R', @pvIdUser = 'ALZEPEDA'
			spSecurity_User_Roles_CRUD_Records @pvOptionCRUD = 'R', @pvIdUser = 'ALZEPEDA', @pbPrincipal = 1
			spSecurity_User_Roles_CRUD_Records @pvOptionCRUD = 'R', @pvIdZone = 'MEX' 
			spSecurity_User_Roles_CRUD_Records @pvOptionCRUD = 'R', @pvIdRole = 'SAAPP|MAAPP|FIAPP|VPAPP|LPAPP'  
			spSecurity_User_Roles_CRUD_Records @pvOptionCRUD = 'R', @pvIdBusinessLine = 'PSS_LIKO' 
			spSecurity_User_Roles_CRUD_Records @pvOptionCRUD = 'R'
			spSecurity_User_Roles_CRUD_Records @pvOptionCRUD = 'U',	@pvIdUser = 'ALZEPEDA' , 
																@pvIdRole = 'ADMIN', 
																@pvIdZone = 'ALLZ', 
																@pvIdLanguage ='SPA', 
																@pbPrincipal = 0, 
																@pbStatus = 1, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'

			spSecurity_User_Roles_CRUD_Records @pvOptionCRUD = 'D', @pvIdUser = 'ALZEPEDA', @pvIdRole = 'ADMIN', @pbStatus = 1, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'
			spSecurity_User_Roles_CRUD_Records @pvOptionCRUD = 'X', @pvIdUser = 'ALZEPEDA', @pvIP ='192.168.1.254'
			
*/
CREATE PROCEDURE [dbo].spSecurity_User_Roles_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@pvIdUser			Varchar(20) = '',
@pvIdRole			Varchar(100) = '', --'SAAPP|MAAPP|FIAPP|VPAPP|LPAPP'
@pvIdZone			Varchar(10)	= '',
@pvIdLanguage		Varchar(10)	= '',
@pvIdBusinessLine	Varchar(10) = '',
@pbPrincipal		Bit			= NULL,	 
@pbStatus			Bit			= '',
@pvUser				Varchar(50) = '',
@pvIP				Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD		Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @EffectiveDay			Int			= (SELECT Value FROM Cat_General_Parameters WHERE Id_Parameter = 2)
	DECLARE @vFinal_Effective_Date	Varchar(8)	= CONVERT(VARCHAR(8),DATEADD(DAY,@EffectiveDay,GETDATE()),112)
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Security_User_Roles - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spSecurity_User_Roles_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdUser = '" + ISNULL(@pvIdUser,'NULL') + "', @pvIdRole = '" + ISNULL(@pvIdRole,'NULL') + "', @pvIdZone = '" + ISNULL(@pvIdZone,'NULL') + "', @pvIdLanguage = '" + ISNULL(@pvIdLanguage,'NULL') + "',  @pvIdBusinessLine = '" + ISNULL(@pvIdBusinessLine,'NULL') + "', @pbPrincipal = '" + ISNULL(CAST(@pbPrincipal AS VARCHAR),'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Security_User_Roles WHERE [User] = @pvIdUser AND Id_Role = @pvIdRole)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Security_User_Roles (
				[User],
				Id_Role,
				Id_Zone,
				Principal,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdUser,
				@pvIdRole,
				@pvIdZone,
				@pbPrincipal,
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
		U.[User],
		U.Id_Role,
		Role_Desc = R.Short_Desc,
		RZ.Id_Region,
		Region_Desc = RE.Short_Desc,
		U.Id_Zone,
		Zone_Desc = Z.Short_Desc,
		Principal,
		R.Id_Business_Line,
		U.[Status],
		U.Modify_Date,
		U.Modify_By,
		U.Modify_IP
		FROM Security_User_Roles U

		INNER JOIN Security_Roles R ON 
		U.Id_Role = R.Id_Role

		INNER JOIN Cat_Zones Z ON
		U.Id_Zone = Z.Id_Zone

		INNER JOIN Cat_Region_Zones RZ ON 
		Z.Id_Zone = RZ.Id_Zone

		INNER JOIN Cat_Regions RE ON
		RZ.Id_Region = RE.Id_Region


		WHERE 
		(@pvIdUser		 = ''	OR U.[User] = @pvIdUser) AND
		(@pvIdRole		= ''	OR U.Id_Role IN(SELECT VALOR FROM fnSplit(@pvIdRole,'|'))) AND
		(@pvIdZone		= ''	OR U.Id_Zone = @pvIdZone) AND
		(@pvIdBusinessLine = '' OR R.Id_Business_Line = @pvIdBusinessLine) AND
		(@pbPrincipal IS NULL   OR U.Principal = @pbPrincipal)
		ORDER BY  [User],U.Id_Role
		RETURN
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Security_User_Roles 
		SET Id_Role				= @pvIdRole,
			Id_Zone				= @pvIdZone,
			Principal			= @pbPrincipal,
			[Status]			= @pbStatus,
			Modify_Date			= GETDATE(),
			Modify_By			= @pvUser,
			Modify_IP			= @pvIP
		WHERE [User]			= @pvIdUser AND
			  Id_Role			= @pvIdRole
	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D'
	BEGIN
		DELETE Security_User_Roles 
		WHERE [User]			= @pvIdUser AND
			  Id_Role			= @pvIdRole
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
