USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spSecurity_Users_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spSecurity_Users_CRUD_Records'

IF OBJECT_ID('[dbo].[spSecurity_Users_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spSecurity_Users_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Security_Users | Create - Read - Upadate - Delete 
Date:		12/01/2021
Example:
			spSecurity_Users_CRUD_Records @pvOptionCRUD = 'C',@pvIdUser = 'ALZEPEDA' , 
																@pvIdRole = 'ADMIN', 
																@pvIdZone = 'ALLZ', 
																@pvIdLanguage ='SPA', 
																@pvPassword = '6c690c09caf5abbab6178e980881cbf5568481e48cd344e4b726c34c6e81be57', 
																@pvName = 'Alejandro Zepeda', 
																@pvEmail = 'kelberoz@hotmail.com', 
																@pbTempPassword = 0, 
																@pbStatus = 1, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'

			spSecurity_Users_CRUD_Records @pvOptionCRUD = 'R', @pvIdUser = 'ADVEGA', @pvIdRole = 'SALES', @pvIdZone = 'CEN' 
			spSecurity_Users_CRUD_Records @pvOptionCRUD = 'R', @pvIdUser = 'KELBEROZ'
			spSecurity_Users_CRUD_Records @pvOptionCRUD = 'R', @pvIdZone = 'MEX' 
			spSecurity_Users_CRUD_Records @pvOptionCRUD = 'R', @pvIdRole = 'SAAPP|MAAPP|FIAPP|VPAPP|LPAPP'  
			spSecurity_Users_CRUD_Records @pvOptionCRUD = 'R'
			spSecurity_Users_CRUD_Records @pvOptionCRUD = 'U',	@pvIdUser = 'ALZEPEDA', 
																@pvIdRole = 'ADMIN', 
																@pvIdZone = 'ALLZ', 
																@pvIdLanguage ='SPA', 
																@pvPassword = '6c690c09caf5abbab6178e980881cbf5568481e48cd344e4b726c34c6e81be57', 
																@pvName = 'Alejandro Zepeda', 
																@pvEmail = 'kelberoz@hotmail.com', 
																@pbTempPassword = 0, 
																@pbStatus = 1, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'

			spSecurity_Users_CRUD_Records @pvOptionCRUD = 'D', @pvIdUser = 'KELBEROZ' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spSecurity_Users_CRUD_Records @pvOptionCRUD = 'X', @pvIdUser = 'KELBEROZ' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			
*/
CREATE PROCEDURE [dbo].spSecurity_Users_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@pvIdUser			Varchar(20) = '',
@pvIdRole			Varchar(100) = '', --'SAAPP|MAAPP|FIAPP|VPAPP|LPAPP'
@pvIdZone			Varchar(10)	= '',
@pvIdLanguage		Varchar(10)	= '',
@pvPassword			Varchar(255)= '',
@pvName				Varchar(255)= '',
@pvEmail			Varchar(50)	= '',
@pbTempPassword		Bit			= 0,	 
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
	DECLARE @vDescription	Varchar(255)	= 'Security_Users - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spSecurity_Users_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdUser = '" + ISNULL(@pvIdUser,'NULL') + "', @pvIdRole = '" + ISNULL(@pvIdRole,'NULL') + "', @pvIdZone = '" + ISNULL(@pvIdZone,'NULL') + "', @pvIdLanguage = '" + ISNULL(@pvIdLanguage,'NULL') + "', @pvPassword = '" + ISNULL(@pvPassword,'NULL') + "', @pvName = '" + ISNULL(@pvName,'NULL') + "', @pvEmail = '" + ISNULL(@pvEmail,'NULL') + "', @pbTempPassword = '" + ISNULL(CAST(@pbTempPassword AS VARCHAR),'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Security_Users WHERE [User] = @pvIdUser)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Security_Users (
				[User],
				Id_Role,
				Id_Zone,
				Id_Language,
				[Password],
				[Name],
				Email,
				Temporal_Password,
				Final_Effective_Date,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdUser,
				@pvIdRole,
				@pvIdZone,
				@pvIdLanguage,
				@pvPassword,
				@pvName,
				@pvEmail,
				@pbTempPassword,
				@vFinal_Effective_Date,
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
		U.Id_Language,
		Language_Desc = L.Short_Desc,
		U.[Password],
		U.[Name],
		U.Email,
		Temporal_Password,
		Final_Effective_Date,
		U.[Status],
		U.Modify_Date,
		U.Modify_By,
		U.Modify_IP
		FROM Security_Users U

		INNER JOIN Security_Roles R ON 
		U.Id_Role = R.Id_Role

		INNER JOIN Cat_Zones Z ON
		U.Id_Zone = Z.Id_Zone

		INNER JOIN Cat_Region_Zones RZ ON 
		Z.Id_Zone = RZ.Id_Zone

		INNER JOIN Cat_Regions RE ON
		RZ.Id_Region = RE.Id_Region

		LEFT OUTER JOIN Cat_Languages L ON 
		U.Id_Language = L.Id_Language AND
		U.Id_Language = L.Id_Language_Translation

		WHERE 
		(@pvIdLanguageUser = ''  OR L.Id_Language = @pvIdLanguageUser) AND
		(@pvIdUser		 = ''	OR U.[User] = @pvIdUser) AND
		(@pvIdRole		= ''	OR U.Id_Role IN(SELECT VALOR FROM fnSplit(@pvIdRole,'|'))) AND
		(@pvIdZone		= ''	OR U.Id_Zone = @pvIdZone) AND
		(@pvIdLanguage	= ''	OR U.Id_Language = @pvIdLanguage)
		ORDER BY  [User]
		RETURN
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Security_Users 
		SET Id_Role				= @pvIdRole,
			Id_Zone				= @pvIdZone,
			Id_Language			= @pvIdLanguage,
			[Password]			= @pvPassword,
			[Name]				= @pvName,
			Email				= @pvEmail,
			Temporal_Password	= @pbTempPassword,
			Final_Effective_Date= (CASE WHEN @pbTempPassword = 1 THEN @vFinal_Effective_Date ELSE Final_Effective_Date END),
			[Status]			= @pbStatus,
			Modify_Date			= GETDATE(),
			Modify_By			= @pvUser,
			Modify_IP			= @pvIP
		WHERE [User]			= @pvIdUser 
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
