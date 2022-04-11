USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuestionnaire_Template_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuestionnaire_Template_CRUD_Records'

IF OBJECT_ID('[dbo].[spQuestionnaire_Template_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuestionnaire_Template_CRUD_Records
GO
/*
Autor:		Alejandro Zepeda
Desc:		Questionnaire_Template | Create - Read - Upadate - Delete 
Date:		25/02/2021
Example:
			spQuestionnaire_Template_CRUD_Records	@pvOptionCRUD			= 'C', 
													@pvIdLanguageUser		= 'ANG', 
													@pvQuestion				= 'Cual es tu nombre',
													@pvObjectType			= 'TextBox',
													@pvDataType				= 'Cadena',
													@pvDataJSON				= '',
													@piDataLen				= '50',
													@pvRegularExpression	= '',
													@piOrder				= 1,
													@pbRequired				= 1,
													@pvUser					= 'AZEPEDA', 
													@pvIP					='192.168.1.254'

			spQuestionnaire_Template_CRUD_Records	@pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG',  @piIdQuestion = 4

			spQuestionnaire_Template_CRUD_Records	@pvOptionCRUD			= 'U',
													@pvIdLanguageUser		= 'ANG', 
													@piIdQuestion			= 3,
													@pvQuestion				= 'Cual es tu edad?',
													@pvObjectType			= 'TextBox',
													@pvDataType				= 'Entero',
													@pvDataJSON				= '',
													@piDataLen				= '2',
													@pvRegularExpression	= '',
													@piOrder				= 2,
													@pbRequired				= 0,
													@pvUser					= 'AZEPEDA', 
													@pvIP					='192.168.1.254'

			spQuestionnaire_Template_CRUD_Records	@pvOptionCRUD = 'D', @piIdQuestion = 1 
*/

CREATE PROCEDURE [dbo].spQuestionnaire_Template_CRUD_Records
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10) = '',
@piIdQuestion			Int				= 0,
@pvQuestion				varchar(100)	= '',
@pvObjectType			varchar(50)		= '',
@pvDataType				varchar(30)		= '',
@pvDataJSON				varchar	(8000)	= '',
@piDataLen				smallint		= 0,
@pvRegularExpression	varchar	(8000)	= '',
@piOrder				smallint		= 0,
@pbRequired				bit				= 0,
@pvUser					Varchar(50)		= '',
@pvIP					Varchar(20)		= ''
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
	DECLARE @vDescription	Varchar(255)	= 'Questionnaire_Template - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spQuestionnaire_Template_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piIdQuestion = " + ISNULL(CAST(@piIdQuestion AS VARCHAR),'NULL') + ", @pvQuestion = '" + ISNULL(@pvQuestion,'NULL') + "', @pvObjectType = '" + ISNULL(@pvObjectType,'NULL') + "', @pvDataType = '" + ISNULL(@pvDataType,'NULL') + "', @pvDataJSON = '" + ISNULL(@pvDataJSON,'NULL') + "', @piDataLen = " + ISNULL(CAST(@piDataLen AS VARCHAR),'NULL') + ", @pvRegularExpression = '" + ISNULL(@pvRegularExpression,'NULL') + "', @piOrder = " + ISNULL(CAST(@piOrder AS VARCHAR),'NULL') + ", @pbRequired = " + ISNULL(CAST(@pbRequired AS VARCHAR),'NULL') + ", @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN

		INSERT INTO Questionnaire_Template(
				Question,
				Object_Type,
				Data_Type,
				Data_JSON,
				Data_Len,
				Regular_Expression,
				[Order],
				[Required],
				Modify_By,
				Modify_Date,
				Modify_IP)
		VALUES (
				@pvQuestion,
				@pvObjectType,
				@pvDataType,
				@pvDataJSON,
				@piDataLen,
				@pvRegularExpression,
				@piOrder,
				@pbRequired,
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
		Question,
		Object_Type,
		Data_Type,
		Data_JSON,
		Data_Len,
		Regular_Expression,
		[Order],
		[Required],
		Modify_By,
		Modify_Date,
		Modify_IP
		FROM Questionnaire_Template 
		WHERE 0 = @piIdQuestion OR Id_Question = @piIdQuestion
		ORDER BY [Order]
		RETURN
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Questionnaire_Template 
		SET Question			= @pvQuestion,
			Object_Type			= @pvObjectType,
			Data_Type			= @pvDataType,
			Data_JSON			= @pvDataJSON,
			Data_Len			= @piDataLen,
			Regular_Expression	= @pvRegularExpression,
			[Order]				= @piOrder,
			[Required]			= @pbRequired,
			Modify_By			= @pvUser,
			Modify_Date			= GETDATE(),
			Modify_IP			= @pvIP
		WHERE Id_Question = @piIdQuestion

	
	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D'
	BEGIN
		DELETE Questionnaire_Template 
		WHERE Id_Question = @piIdQuestion
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
