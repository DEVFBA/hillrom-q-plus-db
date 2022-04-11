USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_Questionnaire_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_Questionnaire_CRUD_Records'

IF OBJECT_ID('[dbo].[spQuotation_Questionnaire_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_Questionnaire_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		spQuotation Questionnaire | Create - Read - Upadate - Delete 
Date:		06/02/2021
Example:

	DECLARE  @udtQuotationQuestionnaire		UDT_Quotation_Questionnaire 

	INSERT INTO @udtQuotationQuestionnaire
	SELECT * FROM Quotation_Questionnaire 
	WHERE Folio = 6 AND Version = 1		

	EXEC spQuotation_Questionnaire_CRUD_Records @pvOptionCRUD = 'C', @piFolio = 6, @piVersion = 1, @pudtQuotationQuestionnaire = @udtQuotationQuestionnaire, @pvUser = 'RUGOMEZ', @pvIP ='192.168.1.254'

	EXEC spQuotation_Questionnaire_CRUD_Records @pvOptionCRUD = 'R'
	EXEC spQuotation_Questionnaire_CRUD_Records @pvOptionCRUD = 'R', @piFolio = 6, @piVersion = 1											

*/

CREATE PROCEDURE [dbo].spQuotation_Questionnaire_CRUD_Records
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10) = '',
@piFolio				Int			= 0,
@piVersion				Int			= 0,
@pudtQuotationQuestionnaire		UDT_Quotation_Questionnaire Readonly,
@pvUser					Varchar(50) = '',
@pvIP					Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @iNumRegistros		Int			= (SELECT COUNT(*) FROM @pudtQuotationQuestionnaire)

	
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Quotation Questionnaire - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spQuotation_Questionnaire_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piFolio = '" + ISNULL(CAST(@piFolio AS VARCHAR),'NULL') + "', @piVersion = '" + ISNULL(CAST(@piVersion AS VARCHAR),'NULL') + "', @pudtQuotationQuestionnaire = '" + ISNULL(CAST(@iNumRegistros AS VARCHAR),'NULL') + " rows affected', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C' OR @pvOptionCRUD = 'U'
	BEGIN
		----------------
		--Delete tables
		----------------
		DELETE Quotation_Questionnaire	WHERE Folio = @piFolio and [Version] = @piVersion

		----------------
		--Insert Questionnaire
		----------------
		INSERT INTO Quotation_Questionnaire(
			Folio,
			[Version],
			Question_Number,
			Question,
			Answer_Value)
	
		SELECT 
			Folio,
			[Version],
			Question_Number,
			Question,
			Answer_Value
		FROM @pudtQuotationQuestionnaire

	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
			Folio,
			[Version],
			Question_Number,
			Question,
			Answer_Value
		FROM Quotation_Questionnaire
		WHERE	(@piFolio	= 0	OR Folio	 = @piFolio) AND 
				(@piVersion	= 0	OR [Version] = @piVersion) 
	
		ORDER BY  Folio, [Version], Question_Number
		
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
