USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
 
/* ==================================================================================*/
-- spJob_Generation_Depuration_Backups
/* ==================================================================================*/	
PRINT 'Crea Procedure: spJob_Generation_Depuration_Backups'

IF OBJECT_ID('[dbo].[spJob_Generation_Depuration_Backups]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spJob_Generation_Depuration_Backups
GO

/*
Autor:		Alejandro Zepeda
Desc:		Generation and Depuration of the Backups | Job
Date:		06/12/2021
Example:
			EXEC spJob_Generation_Depuration_Backups 

*/
CREATE PROCEDURE [dbo].spJob_Generation_Depuration_Backups
@pvOptionCRUD			Varchar(1) = 'J',
@pvIdLanguageUser		Varchar(10) = 'ANG',
@pvUser					Varchar(50) = 'sa'
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)

	DECLARE @TypeExecution			Int				= 0 --  0 for backup files or 1 for report files.
	DECLARE @BackupsPath			Varchar(100)	= (SELECT [Value] FROM Cat_General_Parameters WHERE Id_Parameter = 49) --The folder to delete files. The path must end with a backslash "".
	DECLARE @BackupExtension		Varchar(100)	= N'bak' --File extension.This could be 'BAK' or 'TRN' or whatever you normally use.
	DECLARE @BackupDays				Int				= (SELECT [Value] * -1 FROM Cat_General_Parameters WHERE Id_Parameter = 50) --
	DECLARE @BackupCutOffDate		Datetime		= DATEADD(DAY , @BackupDays, GETDATE())--The cut off date for what files need to be deleted.
	DECLARE @BackupApplySubFolder	Int				= 0 --0 to ignore subFolders, 1 to delete files in subFolders.
	DECLARE @BackupPhatFileName		Varchar(100)	= @BackupsPath + 'DBQS_' + CONVERT(VARCHAR(8), GETDATE(),112) + '.bak'

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Generation and Depuration of the Backups - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= 'Job Executed Successfully'
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spJob_Generation_Depuration_Backups @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "'"
	--------------------------------------------------------------------
	--Generate Backup
	--------------------------------------------------------------------
	BACKUP DATABASE DBQS 
	TO DISK = @BackupPhatFileName

	--------------------------------------------------------------------
	--Depuration Backup
	--------------------------------------------------------------------
	EXECUTE master.dbo.xp_delete_file @TypeExecution, @BackupsPath, @BackupExtension, @BackupCutOffDate, @BackupApplySubFolder

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
	SET @vMessageType	= dbo.fnGetTransacMessages('ERR',@pvIdLanguageUser)	--Erro
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
