USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spQuotation_ApprovalRoutes_Upd_Workflow]    Script Date: 3/23/2025 12:51:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Autor:		Alejandro Zepeda
Desc:		Update Approval  WorkFlow
Date:		09/02/2021
Example:

			DECLARE  @udtApprovalWorkflow		UDT_Approval_Workflow

			SELECT * FROM @udtApprovalWorkflow
			INSERT INTO @udtApprovalWorkflow
			SELECT	Id_Approval_Workflow, 'Commentraio' + cast(Id_Approval_Workflow as varchar)
--			SELECT *
			FROM Approval_Workflow  
			WHERE Id_Approval_Workflow IN (328,332)

			EXEC spQuotation_ApprovalRoutes_Upd_Workflow  @pvIdLanguageUser = 'ANG', @pvIdApprovalStatus = 'REJ', @pudtApprovalWorkflow = @udtApprovalWorkflow, @pvUser = 'RUGOMEZ', @pvIP ='192.168.1.254'

*/
ALTER PROCEDURE [dbo].[spQuotation_ApprovalRoutes_Upd_Workflow]
@pvIdLanguageUser		Varchar(10) = 'ANG',
@pvIdApprovalStatus		Varchar(10),
@pudtApprovalWorkflow	UDT_Approval_Workflow	 Readonly,
@pvUser					Varchar(50),
@pvIP					Varchar(20)
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD	Varchar(50) = dbo.fnGetOperationCRUD('U')
	DECLARE @iNumRegistros		Int			= (SELECT COUNT(*) FROM @pudtApprovalWorkflow)
	DECLARE @TableResponse		TABLE([Successful] bit, MessageType varchar(30), [Message] varchar(max), IdTransacLog numeric(18,0), Folio Int, [Version] Int)
	DECLARE @iFolio				Int
	DECLARE @iVersion			Smallint
	DECLARE @iIdApprovalSection Smallint
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Quotation Approval WorkFlow - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spQuotation_ApprovalRoutes_Upd_Workflow @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdApprovalStatus = '" + CAST(@pvIdApprovalStatus AS VARCHAR) + "', @pudtApprovalWorkflow = '" + ISNULL(CAST(@iNumRegistros AS VARCHAR),'NULL') + " rows affected', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	
	--------------------------------------------------------------------
	--Update WorkFlow By 1 - Discounts
	--------------------------------------------------------------------
	
		SET @iIdApprovalSection = 1 -- Discounts

		SELECT DISTINCT 
		@iFolio		= AW.Folio, 
		@iVersion	=  AW.[Version]
		FROM Approval_Workflow AW 
		INNER JOIN @pudtApprovalWorkflow UDT ON 
		AW.Id_Approval_Workflow = UDT.Id_Approval_Workflow
		WHERE(UDT.Id_Approval_Section = @iIdApprovalSection OR UDT.Id_Approval_Section IS NULL)

		UPDATE AW
		SET AW.Id_Approval_Status	= @pvIdApprovalStatus,
			AW.Comments				= UDT.Comments,
			AW.Modify_By			= @pvUser,
			AW.Modify_Date			= GETDATE(),
			AW.Modify_IP			= @pvIP
		FROM Approval_Workflow AW
		INNER JOIN @pudtApprovalWorkflow UDT ON 
		AW.Id_Approval_Workflow = UDT.Id_Approval_Workflow
		WHERE(UDT.Id_Approval_Section = @iIdApprovalSection OR UDT.Id_Approval_Section IS NULL)

	--------------------------------------------------------------------
	--Update WorkFlow By 2 - Quotation Seccion
	--------------------------------------------------------------------

		SET @iIdApprovalSection = 2 -- Quotation

		SELECT DISTINCT 
		@iFolio		= AW.Folio,
		@iVersion	= AW.[Version]
		FROM Approval_Workflow_Quotation AW 
		INNER JOIN @pudtApprovalWorkflow UDT ON 
		AW.Id_Approval_WF_Quotation = UDT.Id_Approval_Workflow
		WHERE(UDT.Id_Approval_Section = @iIdApprovalSection)

		UPDATE AW
		SET AW.Id_Approval_Status	= @pvIdApprovalStatus,
			AW.Comments				= UDT.Comments,
			AW.Modify_By			= @pvUser,
			AW.Modify_Date			= GETDATE(),
			AW.Modify_IP			= @pvIP
		FROM Approval_Workflow_Quotation AW
		INNER JOIN @pudtApprovalWorkflow UDT ON 
		AW.Id_Approval_WF_Quotation = UDT.Id_Approval_Workflow
		WHERE(UDT.Id_Approval_Section = @iIdApprovalSection)




	--------------------------------------------------------------------
	--Update Actualizacion de ApprovalStatus
	--------------------------------------------------------------------
	--VRC 26-DIC-2024 SE COMENTA PORQUE SE ESTA INSERTANDO DOBLE
	--IF @pvIdApprovalStatus = 'REJ'--REJECTED
	--BEGIN		
		--Update Status Quotation
		--INSERT INTO @TableResponse
		--EXEC spQuotation_Quotation_CRUD_Records @pvIdLanguageUser = @pvIdLanguageUser, @pvOptionCRUD = 'U', @piFolio = @iFolio, @piVersion = @iVersion , @pvIdQuotationStatus = 'DIRE', @pvUser = @pvUser, @pvIP = @pvIP
	--END 


	----4. Quotation Pending to Approve
	IF @pvIdApprovalStatus = 'APP' -- 
		EXEC spNotification_Quotation_Pending_to_Approve_List_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = @pvIdLanguageUser, @piIdNotification = 4, @piFolio =  @iFolio , @piVersion = @iVersion, @pvUser = @pvUser

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
	SELECT  Successful = 1 , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog
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
