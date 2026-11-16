USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuestionnaire_Template_Translations_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuestionnaire_Template_Translations_CRUD_Records'

IF OBJECT_ID('[dbo].[spQuestionnaire_Template_Translations_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuestionnaire_Template_Translations_CRUD_Records
GO
/*
Autor:		Ángel Gutiérrez
Desc:		Questionnaire_Template_Translations | Create - Read - Upadate - Delete 
Date:		16/11/2026
Example:

        -- Create

        EXEC spQuestionnaire_Template_Translations_CRUD_Records @pvOptionCRUD = 'C', 
														@piIdQuestion = 9, 
														@pvIdLanguage = 'BRA', 
														@pvQuestion = 'Tipo de Oportunidade*', 
														@pvDataJSON = '[{"value":"Licitação","text":"Licitação"},{"value":"Privado","text":"Privado"},{"value":"Construção","text":"Construção"},{"value":"Outros","text":"Outros"}]',
														@pvUser = 'ANGUTIERRE',
														@pvIP = 'TEST',
														@pvIdLanguageUser = 'ANG';

        -- Read

        EXEC spQuestionnaire_Template_Translations_CRUD_Records @pvOptionCRUD = 'R',
														@piIdQuestion = 9,
														@pvIdLanguage = 'BRA'; 

        -- Update

        EXEC spQuestionnaire_Template_Translations_CRUD_Records @pvOptionCRUD = 'U',
														@piIdQuestion = 9,
														@pvIdLanguage = 'BRA',
														@pvQuestion = 'Test Question',
														@pvDataJSON = 'Test Upd JSON',
														@pvUser = 'ANGUTIERRE',
														@pvIP = 'TEST UPD'; 

        -- Delete	

        EXEC spQuestionnaire_Template_Translations_CRUD_Records @pvOptionCRUD = 'D',
														@piIdQuestion = 57,
														@pvIdLanguage = 'BRA',
														@pvUser = 'ANGUTIERRE',
														@pvIP = 'TEST UPD'; 

*/

CREATE PROCEDURE [dbo].spQuestionnaire_Template_Translations_CRUD_Records
@pvOptionCRUD			    Varchar(1),
@pvIdLanguageUser		    Varchar(10)     = '', -- User Language to translate output and DB Messages
@piIdQuestion			    Int				= 0,
@pvQuestion				    varchar(100)	= '',
@pvIdLanguage			    varchar(10)		= '', -- Language of the record
@pvIdLanguageTranslation	varchar(10)	    = 'ANG', -- Language for translation of Languages Catalog || This must be 'ANG' as Default
@pvDataJSON				    varchar	(8000)	= '',
@pvUser					    Varchar(50)		= '',
@pvIP					    Varchar(20)		= ''
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
	DECLARE @vDescription	Varchar(255)	= 'Questionnaire_Template_Translations - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spQuestionnaire_Template_Translations_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') 
                                                    + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') 
                                                    + "', @piIdQuestion = " + ISNULL(CAST(@piIdQuestion AS VARCHAR),'NULL') 
                                                    + ", @pvQuestion = '" + ISNULL(@pvQuestion,'NULL') 
                                                    + "', @pvDataJSON = '" + ISNULL(@pvDataJSON,'NULL') 
                                                    + "', @pvUser = '" + ISNULL(@pvUser,'NULL') 
                                                    + "', @pvIP = '" + ISNULL(@pvIP,'NULL') 
                                                    + "', @pvIdLanguage = '" + ISNULL(@pvIdLanguage,'NULL') 
                                                    + "', @pvIdLanguageTranslation = '" + ISNULL(@pvIdLanguageTranslation,'NULL') 
                                                    + "'"

	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN

		INSERT INTO Questionnaire_Template_Translations(
                Id_Question,
				Id_Language,
                Id_Language_Translation,
                Question,
				Data_JSON,
				Modify_By,
				Modify_Date,
				Modify_IP)
		VALUES (
				@piIdQuestion,
				@pvIdLanguage,
				@pvIdLanguageTranslation,
				@pvQuestion,
				@pvDataJSON,
				@pvUser,
				GETDATE(),
				@pvIP)
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
		Id_Question,
		Id_Language,
		Question,
		Data_JSON,
		Modify_By,
		Modify_Date,
		Modify_IP
		FROM Questionnaire_Template_Translations 
		WHERE 
                (@piIdQuestion = 0 OR Id_Question = @piIdQuestion)
            AND (@pvIdLanguage = '' OR Id_Language = @pvIdLanguage)
		ORDER BY 
               Id_Question
		RETURN
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Questionnaire_Template_Translations
		SET Question			= @pvQuestion,
			Data_JSON			= @pvDataJSON,
			Modify_By			= @pvUser,
			Modify_Date			= GETDATE(),
			Modify_IP			= @pvIP
		WHERE 
                Id_Question = @piIdQuestion
            AND Id_Language = @pvIdLanguage
            AND Id_Language_Translation = @pvIdLanguageTranslation

	
	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D'
	BEGIN
		DELETE Questionnaire_Template_Translations
		WHERE 
                Id_Question = @piIdQuestion
            AND Id_Language = @pvIdLanguage
            AND Id_Language_Translation = @pvIdLanguageTranslation
	END

	--------------------------------------------------------------------
	--Other Type
	--------------------------------------------------------------------
	IF @vDescOperationCRUD = 'N/A'
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
