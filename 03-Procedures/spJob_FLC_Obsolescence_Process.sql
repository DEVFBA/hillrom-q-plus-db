USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spJob_FLC_Obsolescence_Process
/* ==================================================================================*/	
PRINT 'Crea Procedure: spJob_FLC_Obsolescence_Process'

IF OBJECT_ID('[dbo].[spJob_FLC_Obsolescence_Process]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spJob_FLC_Obsolescence_Process
GO

/*
Autor:		Alejandro Zepeda
Desc:		FLC Obsolescence Process | Job
Date:		28/10/2023
Example:
			EXEC spJob_FLC_Obsolescence_Process @pvOptionCRUD =  'JM', -- Job Manual
												@pvIdLanguageUser = 'ANG', 
												@pvUser = 'AZEPEDA'

			EXEC spJob_FLC_Obsolescence_Process @pvOptionCRUD =  'JA' -- Job Automatico

*/
CREATE PROCEDURE [dbo].[spJob_FLC_Obsolescence_Process]
@pvOptionCRUD			Varchar(2) = 'JM',
@pvIdLanguageUser		Varchar(10) = 'ANG',
@pvUser					Varchar(50) = 'sa'
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @tblItemObsolescence TABLE(Id_Item varchar(50))

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescOperationCRUD Varchar(50) = (CASE WHEN @pvOptionCRUD = 'JM' THEN 'Job Manual' ELSE 'Job Automatic' END)
	DECLARE @vDescription	Varchar(255)	= 'Execution Item Obsolescence  - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= 'Job Executed Successfully '
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spJob_FLC_Obsolescence_Process @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "'"
	--------------------------------------------------------------------
	--Obsolescence Process
	--------------------------------------------------------------------
	INSERT INTO @tblItemObsolescence 
	SELECT Id_Item FROM FLC_Cat_Item WHERE Obsolescence = 1
		 
	UPDATE FLC_Cat_Item 
	SET Obsolescence = 0,
		[Status] = 0,
		Obsolescence_Date = GETDATE()		
	WHERE Obsolescence = 1

	SET @vMessage = @vMessage +  (SELECT '('  + CAST(COUNT(*) AS VARCHAR) + ' rows affected)' FROM @tblItemObsolescence )
	
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

	--------------------------------------------------------------------
	--Register Obsolescence Log
	--------------------------------------------------------------------

	INSERT INTO FLC_Log_Item_Obsolescence (Id_Transaction_Log,Id_Item)
	SELECT @nIdTransacLog, Id_Item FROM @tblItemObsolescence


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
