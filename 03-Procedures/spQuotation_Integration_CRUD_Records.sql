USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_Integration_INS_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_Integration_INS_Records'

IF OBJECT_ID('[dbo].[spQuotation_Integration_INS_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_Integration_INS_Records
GO


/*
Autor:		Alejandro Zepeda
Desc:		spQuotation Integration | Create - Upadate
Date:		29/01/2021
Example:
	DECLARE  @udtQuotationHeader			UDT_Quotation_Header 
	DECLARE  @udtQuotationDetail			UDT_Quotation_Detail
	DECLARE  @udtQuotationQuestionnaire		UDT_Quotation_Questionnaire 
	DECLARE  @udtQuotationCommissions		UDT_Quotation_Commissions 

	INSERT @udtQuotationHeader
	SELECT * FROM Quotation_Header
	WHERE Folio = 629 AND Version = 1		

	INSERT @udtQuotationDetail
	SELECT * FROM Quotation_Detail
	WHERE Folio = 629 AND Version = 1	

	INSERT INTO @udtQuotationQuestionnaire
	SELECT * FROM Quotation_Questionnaire 
	WHERE Folio = 629 AND Version = 1	

	INSERT INTO @udtQuotationCommissions
	SELECT * FROM Quotation_Commissions
	WHERE Folio = 629 AND Version = 1	


	SELECT * FROM @udtQuotationHeader
	SELECT * FROM @udtQuotationDetail
	SELECT * FROM @udtQuotationQuestionnaire
	SELECT * FROM @udtQuotationCommissions


	EXEC spQuotation_Integration_INS_Records	@pvOptionCRUD = 'C', 
												@piFolio = 9, @piVersion = 1, 
												@pudtQuotationHeader = @udtQuotationHeader,
												@pudtQuotationDetail = @udtQuotationDetail,
												@pudtQuotationQuestionnaire = @udtQuotationQuestionnaire, 
												@pudtQuotationCommissions	= @udtQuotationCommissions,
												@pvIdQuotationStatus = 'DIRE',
												@pvUser = 'RUGOMEZ', @pvIP ='192.168.1.254'

 
*/
CREATE PROCEDURE [dbo].[spQuotation_Integration_INS_Records]
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10) = 'ANG',
@piFolio						Int			= 0,
@piVersion						Int			= 0,
@pudtQuotationHeader			UDT_Quotation_Header Readonly,
@pudtQuotationDetail			UDT_Quotation_Detail Readonly,
@pudtQuotationQuestionnaire		UDT_Quotation_Questionnaire Readonly,
@pudtQuotationCommissions		UDT_Quotation_Commissions Readonly,
@pvIdQuotationStatus			Varchar(10),
@pvUser							Varchar(50)	= '',
@pvIP							Varchar(20)	= ''
AS




BEGIN TRY  
 SET NOCOUNT ON
 BEGIN TRANSACTION;  
   --------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @TableResponse TABLE([Successful] bit, MessageType varchar(30), [Message] varchar(max), IdTransacLog numeric(18,0))
	DECLARE @TableResponseQ TABLE([Successful] bit, MessageType varchar(30), [Message] varchar(max), IdTransacLog numeric(18,0), Folio Numeric, [Version] INT)


	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Quotation Intregration - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spQuotation_Integration_INS_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piFolio = '" + ISNULL(CAST(@piFolio AS VARCHAR),'NULL') + "', @piVersion = '" + ISNULL(CAST(@piVersion AS VARCHAR),'NULL') + "', @pvIdQuotationStatus = '" + ISNULL(@pvIdQuotationStatus,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C' OR @pvOptionCRUD = 'U'
	BEGIN
		----------------
		--Insert Header
		----------------
		INSERT INTO @TableResponse
		EXEC spQuotation_Header_CRUD_Records @pvOptionCRUD = @pvOptionCRUD, @pvIdLanguageUser = @pvIdLanguageUser, @piFolio = @piFolio, @piVersion = @piVersion, @pudtQuotationHeader = @pudtQuotationHeader, @pvUser = @pvUser, @pvIP = @pvIP

		----------------
		--Insert Details
		----------------

		INSERT INTO @TableResponse
		EXEC spQuotation_Detail_CRUD_Records @pvOptionCRUD = @pvOptionCRUD, @pvIdLanguageUser = @pvIdLanguageUser, @piFolio = @piFolio, @piVersion = @piVersion, @pudtQuotationDetail = @pudtQuotationDetail, @pvUser = @pvUser, @pvIP = @pvIP
		
		----------------
		--Insert Questionnaire
		----------------
		INSERT INTO @TableResponse
		EXEC spQuotation_Questionnaire_CRUD_Records @pvOptionCRUD = @pvOptionCRUD, @pvIdLanguageUser = @pvIdLanguageUser, @piFolio = @piFolio, @piVersion = @piVersion, @pudtQuotationQuestionnaire = @pudtQuotationQuestionnaire, @pvUser = @pvUser, @pvIP = @pvIP

		----------------
		--Insert Commissions
		----------------
		INSERT INTO @TableResponse
		EXEC spQuotation_Commissions_CRUD_Records @pvOptionCRUD = @pvOptionCRUD, @pvIdLanguageUser = @pvIdLanguageUser, @piFolio = @piFolio, @piVersion = @piVersion, @pudtQuotationCommissions = @pudtQuotationCommissions, @pvUser = @pvUser, @pvIP = @pvIP

		------------------------
		--Update Status QuotationS
		------------------------
		INSERT INTO @TableResponseQ
		EXEC spQuotation_Quotation_CRUD_Records  @pvOptionCRUD = 'U', @pvIdLanguageUser = @pvIdLanguageUser, @piFolio = @piFolio, @piVersion = @piVersion, @pvIdQuotationStatus = @pvIdQuotationStatus, @pvUser = @pvUser, @pvIP = @pvIP			
								

		INSERT INTO @TableResponse
		SELECT Successful, MessageType, Message, IdTransacLog FROM @TableResponseQ

		------------------------
		--Insert Route Approval
		------------------------

		INSERT @TableResponse
		EXEC spQuotation_ApprovalRoutes_Ins_Workflow_Quotation_Header  @piFolio = @piFolio, @piVersion = @piVersion, @pvUser = @pvUser, @pvIP = @pvIP
	
		INSERT INTO @TableResponse
		EXEC spQuotation_ApprovalRoutes_Ins_Workflow_Quotation  @piFolio = @piFolio, @piVersion = @piVersion, @pvUser = @pvUser, @pvIP = @pvIP

		IF @pvIdQuotationStatus = 'ROUT'
		EXEC spNotification_Quotation_Pending_to_Approve_List_CRUD_Records @pvOptionCRUD = 'C', @piIdNotification = 4, @piFolio =  @piFolio , @piVersion = @piVersion, @pvUser = @pvUser
			


		----------------
		-- Error validations
		----------------
		IF (SELECT COUNT(*) from @TableResponse where Successful = 0) > 0
		BEGIN
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Error	
			SET @vMessage		= dbo.fnGetTransacMessages('Generic Error',@pvIdLanguageUser)
			SET @bSuccessful	= 0 --Execution with errors

			ROLLBACK TRANSACTION; 
			--COMMIT TRANSACTION; 
		END
		ELSE
			COMMIT TRANSACTION;  

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
 ROLLBACK TRANSACTION
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

  
    
END CATCH;  
  

