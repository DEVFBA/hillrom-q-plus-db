USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_Approval_Workflow_CRUD_Records]    Script Date: 4/29/2026 10:25:28 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Autor:		Angel Gutierrez
Desc:		GSS_Approval_Workflow | Create - Read - Upadate - Delete 
Date:		04/07/26
Example:

			EXEC spGSS_Approval_Workflow_CRUD_Records @pvOptionCRUD				= 'C',
													  @pvIdLanguageUser			= 'ANG',
													  @pvUser					= 'ANGUTIERRE',
													  @pvIP						= '0.0.0.0',
													  @piFolio					= 1,
													  @piVersion				= 1,
													  @piIdDetail				= 1,
													  @pvIdItem					= '2078108',
													  @piIdApprovalFlow			= 21;

			EXEC spGSS_Approval_Workflow_CRUD_Records @pvOptionCRUD				= 'R',
													  @pvIdLanguageUser			= 'ANG',
													  @pvUser					= 'ANGUTIERRE',
													  @pvIP						= '0.0.0.0',
													  @piFolio					= 1,
													  @piVersion				= 1;	
			
			EXEC spGSS_Approval_Workflow_CRUD_Records @pvOptionCRUD				= 'U',
													  @pvIdLanguageUser			= 'ANG',
													  @pvUser					= 'ANGUTIERRE',
													  @pvIP						= '0.0.0.0',
													  @piFolio					= 17,
													  @piVersion				= 1,
													  @pvIdRole					= 'SAAPP',
													  @pvIdApprovalStatus		= 'APP';


*/
CREATE PROCEDURE [dbo].[spGSS_Approval_Workflow_CRUD_Records]
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10)		= 'ANG',
@pvUser							Varchar(50),
@pvIP							Varchar(20),
@piFolio						Int				= 0,
@piVersion						Int				= 0,
@piIdDetail						Int				= 0,
@pvIdItem						Varchar(50)		= '',
@piIdApprovalFlow				Smallint		= 0,
@pvIdRole						Varchar(10)		= '',
@pvIdApprovalStatus				Varchar(10)		= '',
@pvComments						Varchar(1000)	= '',
@pvSPRNumber					Varchar(50)		= ''				
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------

	Declare @vDescOperationCRUD				Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD);
	DECLARE @viNextIdApprovalWorkflow		Bigint			= (SELECT ISNULL(MAX(Id_Approval_Workflow), 0) FROM GSS_Approval_Workflow) + 1;

	--------------------------------------------------------------------
	--Cursor Variables
	--------------------------------------------------------------------
	
	DECLARE @cvIdRole						Varchar(10)
	DECLARE @ciApprovalFlowSequence			Smallint

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------

	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'GSS_Approval_Workflow - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spGSS_Approval_Workflow_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') 
													+ "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') 
													+ "', @pvUser =  '" + ISNULL(@pvUser,'NULL') 
													+ "', @piFolio =  '" + ISNULL(CAST(@piFolio AS Varchar(MAx)),'NULL') 
													+ "', @piVersion =  '" + ISNULL(CAST(@piVersion AS Varchar(MAx)),'NULL') 
													+ "', @piIdDetail =  '" + ISNULL(CAST(@piIdDetail AS Varchar(MAx)),'NULL') 
													+ "', @pvIdItem =  '" + ISNULL(@pvIdItem,'NULL')
													+ "', @piIdApprovalFlow =  '" + ISNULL(CAST(@piIdApprovalFlow AS Varchar(MAx)),'NULL')
													+ "', @pvIdRole =  '" + ISNULL(@pvIdRole,'NULL')
													+ "', @pvComments =  '" + ISNULL(@pvComments,'NULL')
													+ "'";

	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		
		PRINT 'Create Records';

		DECLARE curApprovalFlowTracker CURSOR FOR
					  (SELECT
							AppT.Id_Role,
							SR.Approval_Flow_Sequence
					   FROM Approval_Tracker AS AppT INNER JOIN Security_Roles AS SR ON
															AppT.Id_Role = SR.Id_Role
					   WHERE AppT.Id_Approval_Flow = @piIdApprovalFlow);

		OPEN curApprovalFlowTracker;

		FETCH NEXT FROM curApprovalFlowTracker INTO @cvIdRole, @ciApprovalFlowSequence;

		WHILE @@FETCH_STATUS = 0
		BEGIN
		  
		  INSERT INTO GSS_Approval_Workflow (
			Folio,
			[Version],
			Id_Detail,
			Id_Item,
			Id_Approval_Flow,
			Id_Role,
			Id_Approval_Status,
			Approval_Flow_Sequence,
			Comments,
			Modify_By,
			Modify_Date,
			Modify_IP
		  )
		  VALUES (
			@piFolio,
			@piVersion,
			@piIdDetail,
			@pvIdItem,
			@piIdApprovalFlow,
			@cvIdRole,
			'PTA',
			@ciApprovalFlowSequence,
			'',
			@pvUser,
			GETDATE(),
			@pvIP
		  )

		  --SET @viNextNumber = @viNextNumber + 1;

		  FETCH NEXT FROM curApprovalFlowTracker INTO @cvIdRole, @ciApprovalFlowSequence;

		END

		CLOSE curApprovalFlowTracker;
		DEALLOCATE curApprovalFlowTracker;
		
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN

		PRINT 'Read Records'
	
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		
		UPDATE GSS_Approval_Workflow SET Id_Approval_Status = @pvIdApprovalStatus, Modify_By = @pvUser, Modify_Date = GETDATE(), Modify_IP = @pvIP, Comments = @pvComments
		WHERE
				Folio = @piFolio
			AND [Version] = @piVersion
			AND Id_Role = @pvIdRole

		IF @pvIdApprovalStatus = 'REJ'
		BEGIN
			EXEC spGSS_Quotation_CRUD_Records @pvOptionCRUD = 'U',
													@pvIdLanguageUser = 'ANG',
													@pvIdQuotationStatus = 'DIRE',
													@pvUser = @pvUser,
													@pvIP = @pvIP,
													@piFolio = @piFolio,
													@piVersion = @piVersion;
		END

		DECLARE @viApprovalPendingCount INT = (SELECT 
													COUNT(Id_Approval_Status) 
											   FROM GSS_Approval_Workflow
											   WHERE 
														Folio = @piFolio
													AND [Version] = @piVersion
													AND Id_Approval_Status = 'PTA');

		IF @viApprovalPendingCount = 0
		BEGIN
			EXEC spGSS_Quotation_CRUD_Records @pvOptionCRUD = 'U',
													@pvIdLanguageUser = 'ANG',
													@pvIdQuotationStatus = 'SENT',
													@pvUser = @pvUser,
													@pvIP = @pvIP,
													@piFolio = @piFolio,
													@piVersion = @piVersion,
													@pvSPRNumber = @pvSPRNumber;
		END

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




