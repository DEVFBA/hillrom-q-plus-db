USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spFLC_Commercial_Release_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spFLC_Commercial_Release_CRUD_Records'

IF OBJECT_ID('[dbo].[spFLC_Commercial_Release_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spFLC_Commercial_Release_CRUD_Records
GO
/*
Autor:		Alejandro Zepeda
Desc:		FLC_Commercial_Release | Create - Read - Upadate - Delete 
Date:		08/10/2023
Example:

			DECLARE  @pudtCommercialRelease  UDT_FLC_Commercial_Release 

			INSERT INTO @pudtCommercialRelease
			SELECT 'ID_0464', 'BR', 'ANG', 1, '20231022' UNION ALL
			SELECT 'ID_0465', 'BR', 'ANG', 1, '' UNION ALL
			SELECT 'ID_0466', 'BR', 'ANG', 1, ''

			SELECT * FROM @pudtCommercialRelease

			EXEC spFLC_Commercial_Release_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pudtCommercialRelease = @pudtCommercialRelease,  @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'			
			EXEC spFLC_Commercial_Release_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdItem = 'Id Item' , @pvIdCountry = 'BR'
			EXEC spFLC_Commercial_Release_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdItem = 'Id Item3'
			EXEC spFLC_Commercial_Release_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pudtCommercialRelease = @pudtCommercialRelease,  @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spFLC_Commercial_Release_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG'
			
			EXEC spFLC_Commercial_Release_CRUD_Records @pvoptioncrud = 'R',@pvIdItem=''


			SELECT * FROM FLC_CAT_ITEM
			SELECT * FROM CAT_LANGUAJES
			SELECT * FROM Cat_Status_Commercial_Release
			SELECT * FROM FLC_Commercial_Release
	
*/
CREATE PROCEDURE [dbo].spFLC_Commercial_Release_CRUD_Records
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10) = 'ANG',
@pvIdItem				Varchar(10) = '',
@pvIdCountry			Varchar(10) = '',
@pvIdLanguage			Varchar(10) = '',
@pvIdStatusComRelease	Smallint	= 0,
@pudtCommercialRelease	UDT_FLC_Commercial_Release Readonly,
@pvUser					Varchar(50) = '',
@pvIP					Varchar(20) = ''
AS
SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vjsonUDT			NVarchar(MAX)	= (SELECT * FROM @pudtCommercialRelease FOR JSON AUTO);
	DECLARE @vStsAvailable			Varchar(50)	= (SELECT Short_Desc FROM Cat_Status_Commercial_Release WHERE Id_Status_Commercial_Release = 1 AND Id_Language = @pvIdLanguageUser)
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'FLC_Commercial_Release - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spFLC_Commercial_Release_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdItem = '" + ISNULL(@pvIdItem,'NULL') + "', @pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL') + "', @pvIdLanguage = '" + ISNULL(@pvIdLanguage,'NULL') + "', @pvIdStatusComRelease = '" + ISNULL(CAST(@pvIdStatusComRelease AS VARCHAR),'NULL') + "',  @pudtCommercialRelease = '" + ISNULL(@vjsonUDT,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		DELETE FLC_Commercial_Release WHERE Id_Item IN (SELECT Id_Item FROM @pudtCommercialRelease)

		INSERT INTO FLC_Commercial_Release(
			Id_Item,
			Id_Country,
			Id_Language,
			Id_Status_Commercial_Release,
			Final_Effective_Date,
			Modify_By,
			Modify_Date,
			Modify_IP)
		SELECT 
			Id_Item,
			Id_Country,
			Id_Language,
			Id_Status_Commercial_Release,
			Final_Effective_Date = (CASE WHEN Final_Effective_Date  = '19000101' OR  Final_Effective_Date  = '' THEN NULL ELSE Final_Effective_Date END ),
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtCommercialRelease
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'B' -- No aplica este OptionCrud
	BEGIN
		SELECT 
			CR.Id_Item,
			Item = I.Short_Desc,
			CR.Id_Country,
			Country = C.Short_Desc,
			CR.Id_Language,
			[Language] = L.Short_Desc,
			CR.Id_Status_Commercial_Release,
			Status_Commercial_Release = SCR.Short_Desc,
			CR.Final_Effective_Date,
			CR.Modify_Date,
			CR.Modify_By,
			CR.Modify_IP
		FROM FLC_Commercial_Release CR

		INNER JOIN FLC_Cat_Item I ON 
		CR.Id_Item = I.Id_Item
		AND I.[Status] = 1

		INNER JOIN Cat_Countries C ON 
		CR.Id_Country = C.Id_Country
		AND C.[Status] = 1

		INNER JOIN Cat_Status_Commercial_Release SCR ON 
		CR.Id_Status_Commercial_Release = SCR.Id_Status_Commercial_Release
		AND CR.Id_Language = SCR.Id_Language
		AND SCR.[Status] = 1

		INNER JOIN Cat_Languages L ON 
		SCR.Id_Language = L.Id_Language
		AND SCR.Id_Language = L.Id_Language_Translation 
		AND L.[Status] = 1


		WHERE (@pvIdItem = '' OR CR.Id_Item = @pvIdItem )
		AND (@pvIdCountry = '' OR CR.Id_Country = @pvIdCountry)
		AND (@pvIdLanguage = '' OR CR.Id_Language = @pvIdLanguage )
		AND (@pvIdStatusComRelease = 0 OR CR.Id_Status_Commercial_Release = @pvIdStatusComRelease )
		
		ORDER BY Id_Item,Id_Country,Id_Status_Commercial_Release, Final_Effective_Date
	END

	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT
		Id_Item							= @pvIdItem,
		Id_Country						= C.Id_Country,
		Country_Desc					= C.Short_Desc,
		Id_Status_Commercial_Release	= ISNULL(CR.Id_Status_Commercial_Release,'1'),
		Status_Commercial_Release_Desc  = ISNULL(SCR.Short_Desc,@vStsAvailable),
		Final_Effective_Date			= ISNULL(CONVERT(VARCHAR(8),CR.Final_Effective_Date,112),''),
		Modify_By						= ISNULL(CR.Modify_By,''),
		Modify_Date						= ISNULL(CR.Modify_Date,''),
		Modify_IP						= ISNULL(CR.Modify_IP,'')
		
		FROM Cat_Countries C
		
		LEFT OUTER JOIN FLC_Commercial_Release CR WITH(NOLOCK) ON
		C.Id_Country = CR.Id_Country AND
		CR.Id_Item = @pvIdItem 

		LEFT OUTER JOIN Cat_Status_Commercial_Release SCR WITH(NOLOCK) ON
		CR.Id_Status_Commercial_Release = SCR.Id_Status_Commercial_Release AND
		SCR.Id_Language = @pvIdLanguageUser

		WHERE 
		(@pvIdCountry = '' OR CR.Id_Country = @pvIdCountry)

		ORDER BY C.Id_Country

	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		DELETE FLC_Commercial_Release WHERE Id_Item IN (SELECT Id_Item FROM @pudtCommercialRelease)

		INSERT INTO FLC_Commercial_Release(
			Id_Item,
			Id_Country,
			Id_Language,
			Id_Status_Commercial_Release,
			Final_Effective_Date,
			Modify_By,
			Modify_Date,
			Modify_IP)
		SELECT 
			Id_Item,
			Id_Country,
			Id_Language,
			Id_Status_Commercial_Release,
			Final_Effective_Date = (CASE WHEN Final_Effective_Date  = '19000101' OR  Final_Effective_Date  = '' THEN NULL ELSE Final_Effective_Date END ),
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtCommercialRelease

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
	
	--SET @vMessage		= dbo.fnGetTransacMessages('Generic Error',@pvIdLanguageUser)
	SET @vMessage		= ( SELECT Message FROM Security_Transaction_Log WHERE  Id_Transaction_Log = @nIdTransacLog)
	SET NOCOUNT OFF
	SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog
		
END CATCH
