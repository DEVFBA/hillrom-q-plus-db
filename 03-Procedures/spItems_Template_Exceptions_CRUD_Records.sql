USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spItems_Template_Exceptions_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spItems_Template_Exceptions_CRUD_Records'

IF OBJECT_ID('[dbo].[spItems_Template_Exceptions_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spItems_Template_Exceptions_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Items_Template_Exceptions | Create - Read - Upadate - Delete 
Date:		25/01/2021
Example:

			DECLARE  @udtItemsTemplateExceptions  UDT_Items_Template_Exceptions 

			INSERT INTO @udtItemsTemplateExceptions(
					Item_Template,
					Id_Exception,
					Id_Item_Exception,
					Id_Item_Trigger,
					[Message],
					Message_Background_Color,
					Message_Font_Color,
					[Status],
					Modify_By,
					Modify_Date,
					Modify_IP)
			SELECT	Item_Template,
					Id_Exception,
					Id_Item_Exception,
					Id_Item_Trigger,
					[Message],
					Message_Background_Color,
					Message_Font_Color,
					[Status],
					Modify_By,
					Modify_Date,
					Modify_IP
			FROM Items_Template_Exceptions 
			WHERE Item_Template = 'X3' 

			EXEC spItems_Template_Exceptions_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvItemTemplate = 'X3', @pudtItemsTemplateExceptions = @udtItemsTemplateExceptions , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'			
			EXEC spItems_Template_Exceptions_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvItemTemplate = 'X3'
			EXEC spItems_Template_Exceptions_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG'
			EXEC spItems_Template_Exceptions_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvItemTemplate = 'X3', @pudtItemsTemplateExceptions = @udtItemsTemplateExceptions , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spItems_Template_Exceptions_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvItemTemplate = 'X3' 
 
*/
CREATE PROCEDURE [dbo].spItems_Template_Exceptions_CRUD_Records
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10) = '',
@pvItemTemplate					Varchar(10) = '',
@pudtItemsTemplateExceptions	UDT_Items_Template_Exceptions Readonly ,
@pvUser							Varchar(50) = '',
@pvIP							Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD		Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @iNumRegistros			Int = (SELECT COUNT(*) FROM @pudtItemsTemplateExceptions)
	DECLARE @vMsjBackground_Color	Varchar(50)  = '#ff0000'
	DECLARE @vMsjFont_Color			Varchar(50)  = '#ffffff'
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Items_Template_Exceptions - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spItems_Template_Exceptions_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvItemTemplate = '" + ISNULL(@pvItemTemplate,'NULL') + "', @pudtItemsTemplateExceptions = '" + ISNULL(CAST(@iNumRegistros AS VARCHAR),'NULL') + " rows affected', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		DELETE Items_Template_Exceptions WHERE Item_Template = @pvItemTemplate

		INSERT INTO Items_Template_Exceptions(
			Item_Template,
			Id_Exception,
			Id_Item_Exception,
			Id_Item_Trigger,
			[Message],
			Message_Background_Color,
			Message_Font_Color,
			[Status],
			Modify_By,
			Modify_Date,
			Modify_IP)

		SELECT 
			Item_Template,
			Id_Exception,
			Id_Item_Exception,
			Id_Item_Trigger,
			[Message],
			@vMsjBackground_Color,
			@vMsjFont_Color,
			[Status],
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtItemsTemplateExceptions

		
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT
		E.Id_Template_Exception,
		E.Item_Template,
		E.Id_Exception,
		Exception_Desc = EX.Short_Desc,
		Id_Item_SubClass_Exception = IE.Id_Item_SubClass,
		E.Id_Item_Exception,
		Item_Exception_Desc = IE.Short_Desc,
		Id_Item_SubClass_Trigger = IT.Id_Item_SubClass,
		E.Id_Item_Trigger,
		Item_Trigger_Desc = IT.Short_Desc,
		E.[Message],
		E.Message_Background_Color,
		E.Message_Font_Color,
		E.[Status],
		E.Modify_By,
		E.Modify_Date,
		E.Modify_IP

		FROM Items_Template_Exceptions E WITH(NOLOCK) 
			INNER JOIN Cat_Exceptions EX  WITH(NOLOCK) ON		
			EX.Id_Exception = E.Id_Exception
			AND EX.Status = 1
			INNER JOIN Cat_Item IE  WITH(NOLOCK) ON		
			E.Id_Item_Exception = IE.Id_Item
			AND IE.Status = 1
			INNER JOIN Cat_Item IT  WITH(NOLOCK) ON		
			E.Id_Item_Trigger = IT.Id_Item
			AND IT.Status = 1

		
		WHERE ('' = @pvItemTemplate ) OR Item_Template = @pvItemTemplate

		ORDER BY Item_Template,Id_Exception,Id_Item_Exception,Id_Item_Trigger

	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		DELETE Items_Template_Exceptions WHERE Item_Template = @pvItemTemplate

		INSERT INTO Items_Template_Exceptions(
			Item_Template,
			Id_Exception,
			Id_Item_Exception,
			Id_Item_Trigger,
			[Message],
			Message_Background_Color,
			Message_Font_Color,
			[Status],
			Modify_By,
			Modify_Date,
			Modify_IP)

		SELECT 
			Item_Template,
			Id_Exception,
			Id_Item_Exception,
			Id_Item_Trigger,
			[Message],
			@vMsjBackground_Color,
			@vMsjFont_Color,
			[Status],
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtItemsTemplateExceptions
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
