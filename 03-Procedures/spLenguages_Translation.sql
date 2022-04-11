USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spLenguages_Translation
/* ==================================================================================*/	
PRINT 'Crea Procedure: spLenguages_Translation'

IF OBJECT_ID('[dbo].[spLenguages_Translation]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spLenguages_Translation
GO
/*
Autor:		Alejandro Zepeda
Desc:		Lenguages_Translation | Create - Read - Upadate - Delete 
Date:		28/06/2021
Example:
		
			spLenguages_Translation @pvOptionCRUD = 'C', @pvIdLanguageUser = 'SPA', @pvInterface = 'Mensaje', @pvObject = 'saludos', @pvSubObject = '', @pvTranslation = ' Hola', @pvUser = 'AZEPEDA', @pvIP = '10.245.123.12'
			spLenguages_Translation @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvInterface = 'Mensaje', @pvObject = 'saludos', @pvSubObject = '', @pvTranslation = ' Hello', @pvUser = 'AZEPEDA', @pvIP = '10.245.123.12'
			spLenguages_Translation @pvOptionCRUD = 'R'
			spLenguages_Translation @pvOptionCRUD = 'R', @piIdTranslation = '1',  @pvIdLanguageUser = '', @pvObject = '', @pvSubObject = ''
			spLenguages_Translation @pvOptionCRUD = 'U', @piIdTranslation = '1',  @pvIdLanguageUser = 'ANG', @pvInterface = 'Mensaje', @pvObject = 'Saludo', @pvSubObject = '', @pvTranslation = ' Hello !!!', @pvUser = 'AZEPEDA', @pvIP = '10.245.123.12'
			spLenguages_Translation @pvOptionCRUD = 'D'

			EXEC spLenguages_Translation @pvOptionCRUD = 'R', @pvIdLanguageUser = 'BRA', @pvInterface = 'RptQutation', @pvObject = 'PDF_TermsConditions'
			exec spLenguages_Translation @pvOptionCRUD = 'R',@pvIdLanguageUser='ANG',@pvInterface = 'Quotation',@pvObject = 'Modal-RejectionComments'
			
*/
CREATE PROCEDURE [dbo].spLenguages_Translation
@pvOptionCRUD		Varchar(1),
@piIdTranslation	Int = 0,
@pvIdLanguageUser	Varchar(10) = '',
@pvInterface		Varchar(50) = '',
@pvObject			Varchar(50) = '',
@pvSubObject		Varchar(50) = '',
@pvTranslation		Varchar(MAX) = '',
@pvUser				Varchar(50) = 'sa',
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
	DECLARE @vDescription	Varchar(255)	= 'Lenguages_Translation - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spLenguages_Translation @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @piIdTranslation = '" + ISNULL(CAST(@piIdTranslation AS VARCHAR),'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvInterface = '" + ISNULL(@pvInterface,'NULL') + "', @pvObject = '" + ISNULL(@pvObject,'NULL') + "', @pvSubObject = '" + ISNULL(@pvSubObject,'NULL') + "', @pvTraslation = '" + ISNULL(@pvTranslation,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN

		SET @piIdTranslation = ISNULL((SELECT Id_Translation FROM Lenguages_Translation),0) + 1 
		
		INSERT INTO Lenguages_Translation (
			Id_Translation,
			Id_Language,
			Interface_Name,
			[Object_Name],
			SubObject_Name,
			Translation,
			Modify_By,
			Modify_Date,
			Modify_IP)
		VALUES (
			@piIdTranslation,
			@pvIdLanguageUser,
			@pvInterface,
			@pvObject,
			@pvSubObject,
			@pvTranslation,
			@pvUser,
			GETDATE(),
			@pvIP)
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN

		SELECT	LT.Id_Translation,
				LT.Id_Language,
				Language_Desc	= CL.Short_Desc,
				Interface		= LT.Interface_Name,
				[Object]		= LT.[Object_Name],
				SubObject		= LT.SubObject_Name,
				Translation		= LT.Translation,
				LT.Modify_By,
				LT.Modify_Date,
				LT.Modify_IP
		FROM Lenguages_Translation LT

		INNER JOIN Cat_Languages CL ON
		LT.Id_Language = CL.Id_Language AND
		LT.Id_Language = CL.Id_Language_Translation 

		WHERE	(@piIdTranslation	= 0	 OR LT.Id_Translation	= @piIdTranslation) AND 
				(@pvIdLanguageUser	= '' OR LT.Id_Language		= @pvIdLanguageUser) AND
				(@pvInterface		= '' OR LT.Interface_Name	= @pvInterface) AND
				(@pvObject			= '' OR LT.[Object_Name]	= @pvObject) AND
				(@pvSubObject		= '' OR LT.SubObject_Name	= @pvSubObject)
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Lenguages_Translation
		SET Id_Language		= @pvIdLanguageUser,
			Interface_Name	= @pvInterface,
			[Object_Name]	= @pvObject,
			SubObject_Name	= @pvSubObject,
			Translation		= @pvTranslation,
			Modify_By		= @pvUser,
			Modify_Date		= GETDATE(),
			Modify_IP		= @pvIP
		WHERE Id_Translation	= @piIdTranslation
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
