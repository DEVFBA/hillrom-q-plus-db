USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCommercial_Release_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCommercial_Release_CRUD_Records'

IF OBJECT_ID('[dbo].[spCommercial_Release_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCommercial_Release_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Commercial_Release | Create - Read - Upadate - Delete 
Date:		29/01/2021
Example:

			DECLARE  @udtCommercialRelease  UDT_Commercial_Release 

			INSERT INTO @udtCommercialRelease
			SELECT	*
			FROM Commercial_Release  
			WHERE Id_Item = 'X7' 

			UPDATE @udtCommercialRelease
			SET Final_Effective_Date = ''

			select * from @udtCommercialRelease

			EXEC spCommercial_Release_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdItem = 'X3', @pudtCommercialRelease = @udtCommercialRelease , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'			
			EXEC spCommercial_Release_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdItem = 'X7' 
			EXEC spCommercial_Release_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdItem = 'X3', @pvIdCountry = 'GS'
			EXEC spCommercial_Release_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdItem = 'X3', @pudtCommercialRelease = @udtCommercialRelease , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spCommercial_Release_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvIdItem = 'X3' 
			EXEC spCommercial_Release_CRUD_Records @pvOptionCRUD = 'W', @pvIdLanguageUser = 'ANG' 
			EXEC spCommercial_Release_CRUD_Records @pvOptionCRUD = 'L', @pvIdLanguageUser = 'ANG' 
 
*/
CREATE PROCEDURE [dbo].spCommercial_Release_CRUD_Records
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10) = '',
@pvIdItem						Varchar(50) = '',
@pvIdCountry					Varchar(10) = '',
@pudtCommercialRelease			UDT_Commercial_Release Readonly,
@pvUser							Varchar(50) = '',
@pvIP							Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD		Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @iNumRegistros			Int			= (SELECT COUNT(*) FROM @pudtCommercialRelease)
	DECLARE @vStsAvailable			Varchar(50)	= (SELECT Short_Desc FROM Cat_Status_Commercial_Release WHERE Id_Status_Commercial_Release = 1 AND Id_Language = @pvIdLanguageUser)
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Commercial_Release - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCommercial_Release_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdItem = '" + ISNULL(@pvIdItem,'NULL') + "', @pudtCommercialRelease = '" + ISNULL(CAST(@iNumRegistros AS VARCHAR),'NULL') + " rows affected', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		DELETE Commercial_Release WHERE Id_Item = @pvIdItem

		INSERT INTO Commercial_Release(
			Id_Item,
			Id_Country,
			Id_Status_Commercial_Release,
			Final_Effective_Date,
			Modify_By,
			Modify_Date,
			Modify_IP)

		SELECT 
			Id_Item,
			Id_Country,
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
		
		LEFT OUTER JOIN Commercial_Release CR WITH(NOLOCK) ON
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
		DELETE Commercial_Release WHERE Id_Item = @pvIdItem

		INSERT INTO Commercial_Release(
			Id_Item,
			Id_Country,
			Id_Status_Commercial_Release,
			Final_Effective_Date,
			Modify_By,
			Modify_Date,
			Modify_IP)

		SELECT 
			Id_Item,
			Id_Country,
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
	--Download Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'W'
	BEGIN
		SELECT
		Id_Item							= CR.Id_Item,
		Item_Desc						= I.Short_Desc,
		Model							= I.Model,
		Id_Country						= CR.Id_Country,
		Country_Desc					= C.Short_Desc,
		Id_Status_Commercial_Release	= CR.Id_Status_Commercial_Release,
		Status_Commercial_Release_Desc  = SCR.Short_Desc,
		Final_Effective_Date			= ISNULL(CONVERT(VARCHAR(8),CR.Final_Effective_Date,112),''),
		Modify_By						= ISNULL(CR.Modify_By,''),
		Modify_Date						= ISNULL(CR.Modify_Date,''),
		Modify_IP						= ISNULL(CR.Modify_IP,'')
		
		FROM Commercial_Release CR WITH(NOLOCK) 

		INNER JOIN Cat_Status_Commercial_Release SCR WITH(NOLOCK) ON
		CR.Id_Status_Commercial_Release = SCR.Id_Status_Commercial_Release

		INNER JOIN Cat_Countries C ON 
		C.Id_Country = CR.Id_Country 

		INNER JOIN Cat_Item I ON
		I.Id_Item = CR.Id_Item 

		WHERE 
		(@pvIdLanguageUser = ''  OR SCR.Id_Language = @pvIdLanguageUser) AND 
		(@pvIdCountry = '' OR CR.Id_Country = @pvIdCountry)

		ORDER BY I.Model, CR.Id_Item, CR.Id_Country
		RETURN
	END

--------------------------------------------------------------------
	--Load Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'L'
	BEGIN

		UPDATE CR
		SET 
			CR.Id_Status_Commercial_Release = L.Id_Status_Commercial_Release,
			CR.Final_Effective_Date			= L.Final_Effective_Date,
			CR.Modify_By					= L.Modify_By,
			CR.Modify_Date					= L.Modify_Date,
			CR.Modify_IP					= L.Modify_IP
		FROM Commercial_Release CR
		INNER JOIN @pudtCommercialRelease L ON 
		CR.Id_Item = L.Id_Item AND
		CR.Id_Country = L.Id_Country

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
