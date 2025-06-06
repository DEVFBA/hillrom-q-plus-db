USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spApproval_Tracker_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spApproval_Tracker_CRUD_Records'

IF OBJECT_ID('[dbo].[spApproval_Tracker_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spApproval_Tracker_CRUD_Records
GO
/*
Autor:		Angel Gutiérrez
Desc:		Approval Tracker | Create - Read - Upadate - Delete 
Date:		06/04/25
Example:

        EXEC spApproval_Tracker_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvUser = 'ANGUTIERRE'
			
*/

CREATE PROCEDURE [dbo].spApproval_Tracker_CRUD_Records
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10)		= '',
@pvUser					Varchar(50)		= '',
@pvIdApprovalFlow		Smallint		= 0,
@pvIdRole				Varchar(10)		= ''
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
	DECLARE @vDescription	Varchar(255)	= 'Approved_Discounts - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spApproved_Discounts_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') 
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	



	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
        SELECT
            AF.Id_Approval_Flow AS [Approval_Flow_Id],
            AF.Short_Desc AS [Approval_Flow_Desc],
            APT.Id_Role AS [Role_Id],
            SR.Short_Desc AS [Role_Desc],
            SR.Approval_Flow_Sequence AS [Sequence],
            AF.[Status] AS [Status]
        FROM Cat_Approvals_Flows AS AF INNER JOIN Approval_Tracker AS APT ON
									        AF.Id_Approval_Flow = APT.Id_Approval_Flow
							           INNER JOIN Security_Roles AS SR ON
									        APT.Id_Role = SR.Id_Role
		WHERE
				(@pvIdApprovalFlow = 0 OR AF.Id_Approval_Flow = @pvIdApprovalFlow)
			AND (@pvIdRole = '' OR APT.Id_Role = @pvIdRole)
        ORDER BY 
		    AF.Id_Approval_Flow ASC,
		    SR.Approval_Flow_Sequence ASC
            
        RETURN
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	



	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	


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
