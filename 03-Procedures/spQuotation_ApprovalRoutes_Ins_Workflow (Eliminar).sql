USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_ApprovalRoutes_Ins_Workflow
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_ApprovalRoutes_Ins_Workflow'

IF OBJECT_ID('[dbo].[spQuotation_ApprovalRoutes_Ins_Workflow]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_ApprovalRoutes_Ins_Workflow
GO

/*
Autor:		Alejandro Zepeda
Desc:		spQuotation Approval WorkFlow | Create - Read - Upadate - Delete 
Date:		09/02/2021
Example:

	EXEC spQuotation_ApprovalRoutes_Ins_Workflow  @piFolio = 200, @piVersion = 1, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'

*/
CREATE PROCEDURE [dbo].spQuotation_ApprovalRoutes_Ins_Workflow
@pvIdLanguageUser	Varchar(10) = '',
@piFolio			Int			= 0,
@piVersion			Int			= 0,
@pvUser				Varchar(50) = '',
@pvIP				Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD('C')
	DECLARE @TableResponse TABLE([Successful] bit, MessageType varchar(30), [Message] varchar(max), IdTransacLog numeric(18,0))
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Quotation Approval WorkFlow - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spQuotation_ApprovalRoutes_Ins_Workflow  @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piFolio = '" + ISNULL(CAST(@piFolio AS VARCHAR),'NULL') + "', @piVersion = '" + ISNULL(CAST(@piVersion AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"



	-------------------------------------------------------------------
	----Insert Workflow by Discounts
	-------------------------------------------------------------------
	INSERT @TableResponse
	EXEC spQuotation_ApprovalRoutes_Ins_Workflow_Discounts  @piFolio = @piFolio, @piVersion = @piVersion, @pvUser = @pvUser, @pvIP = @pvIP


	-------------------------------------------------------------------
	----Insert Workflow Quotation
	-------------------------------------------------------------------
	--INSERT @TableResponse
	--EXEC spQuotation_ApprovalRoutes_Ins_Workflow_Quotation  @piFolio = @piFolio, @piVersion = @piVersion, @pvUser = @pvUser, @pvIP = @pvIP

	-------------------------------------------------------------------
	----Insert Notification 4. Quotation Pending to Approve
	-------------------------------------------------------------------

--	IF  (SELECT COUNT(*) FROM @TableResponse WHERE Successful = 1) > 0
--	EXEC spNotification_Quotation_Pending_to_Approve_List_CRUD_Records @pvOptionCRUD = 'C', @piIdNotification = 4, @piFolio =  @piFolio , @piVersion = @piVersion, @pvUser = @pvUser
			

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

	--IF  (SELECT COUNT(*) FROM @TableResponse WHERE Successful = 1) > 0
	--SELECT TOP 1 Successful, MessageType, Message,IdTransacLog  FROM @TableResponse WHERE Successful = 1
	--ELSE
	--SELECT TOP 1 Successful, MessageType, Message,IdTransacLog  FROM @TableResponse WHERE Successful = 0

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
