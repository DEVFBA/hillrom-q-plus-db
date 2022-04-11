USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
 
/* ==================================================================================*/
-- spApprovers_Absence_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spApprovers_Absence_CRUD_Records'

IF OBJECT_ID('[dbo].[spApprovers_Absence_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spApprovers_Absence_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Approvers_Absence | Create - Read - Upadate - Delete 
Date:		27/07/2021
Example:
			spApprovers_Absence_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @piIdAbsenceReasons = 1,  @pvAbsenceUser = 'ALZEPEDA', @pvBackupUser = 'ALLUQUE', @pvInitialEffectiveDate = '20210701', @pvFinalEffectiveDate ='20210730', @pvExplanation = 'EXPLICACION', @pvUser = 'ALZEPEDA'
			spApprovers_Absence_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG'
			spApprovers_Absence_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvAbsenceUser = 'LUMUNOZ'
			spApprovers_Absence_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pnIdApproversAbsence = 5
			spApprovers_Absence_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pnIdApproversAbsence = 6

*/
CREATE PROCEDURE [dbo].spApprovers_Absence_CRUD_Records
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10) = '',
@pnIdApproversAbsence	Numeric		= 0,
@piIdAbsenceReasons		Smallint	= 0,
@pvAbsenceUser			Varchar(20)	= '',
@pvBackupUser			Varchar(20)	= '',
@pvInitialEffectiveDate	Varchar(8)	= '',-- YYYYMMDD
@pvFinalEffectiveDate	Varchar(8)	= '',-- YYYYMMDD
@pvExplanation			Varchar(1000)	= '',
@pvUser					Varchar(50) = ''
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
	DECLARE @vDescription	Varchar(255)	= 'Approvers_Absence - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Absence_Reasons_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pnIdApproversAbsence = '" + ISNULL(CAST(@pnIdApproversAbsence AS VARCHAR),'NULL') + "', @piIdAbsenceReasons = '" + ISNULL(CAST(@piIdAbsenceReasons AS VARCHAR),'NULL') + "', @pvAbsenceUser = '" + ISNULL(@pvAbsenceUser,'NULL') + "', @pvBackupUser = '" + ISNULL(@pvBackupUser,'NULL') + "', @pvInitialEffectiveDate = '" + ISNULL(@pvInitialEffectiveDate,'NULL') + "', @pvFinalEffectiveDate = '" + ISNULL(@pvFinalEffectiveDate,'NULL') + "', @pvExplanation = '" + ISNULL(@pvExplanation,'NULL') + "' , @pvUser = '" + ISNULL(@pvUser,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Approvers_Absence 
				  WHERE Absence_User = @pvAbsenceUser AND 
				  ((@pvInitialEffectiveDate BETWEEN  Initial_Effective_Date AND Final_Effective_Date) OR (@pvFinalEffectiveDate BETWEEN  Initial_Effective_Date AND Final_Effective_Date))
				  )
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN

			INSERT INTO Approvers_Absence(
				Id_Absence_Reasons,
				Absence_User,
				Backup_User,
				Initial_Effective_Date,
				Final_Effective_Date,
				Explanation,
				Register_Date)
			VALUES (
				@piIdAbsenceReasons,
				@pvAbsenceUser,
				@pvBackupUser,
				@pvInitialEffectiveDate,
				@pvFinalEffectiveDate,
				@pvExplanation,
				GETDATE())
		END
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT
			A.Id_Approvers_Absence,
			A.Id_Absence_Reasons,
			Id_Absence_Reasons_Desc = AR.Short_Desc,
			A.Absence_User,
			Absence_User_Name = U1.[Name],
			A.Backup_User,
			Backup_User_Name = U2.[Name],
			A.Initial_Effective_Date,
			A.Final_Effective_Date,
			A.Explanation,
			A.Register_Date
		
		FROM Approvers_Absence A

		INNER JOIN Cat_Absence_Reasons AR ON 
		A.Id_Absence_Reasons = AR.Id_Absence_Reasons

		INNER JOIN Security_Users U1 ON 
		A.Absence_User = U1.[User]

		INNER JOIN Security_Users U2 ON 
		A.Backup_User = U2.[User]

		WHERE 
		(@pnIdApproversAbsence = 0  OR A.Id_Approvers_Absence = @pnIdApproversAbsence) AND
		(@pvAbsenceUser = '' OR A.Absence_User = @pvAbsenceUser) AND
		(@piIdAbsenceReasons = 0 OR A.Id_Absence_Reasons = @piIdAbsenceReasons ) AND
		(@pvInitialEffectiveDate = '' OR @pvInitialEffectiveDate BETWEEN  A.Initial_Effective_Date AND A.Final_Effective_Date)		
		
		ORDER BY Initial_Effective_Date DESC

	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		SET @bSuccessful	= 0
		SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
		SET @vMessage		= dbo.fnGetTransacMessages('N/A',@pvIdLanguageUser)
	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D' 
	BEGIN
		IF EXISTS(SELECT * FROM Approvers_Absence 
				  WHERE Id_Approvers_Absence = @pnIdApproversAbsence AND 
				  CONVERT(VARCHAR(8),GETDATE(),112) BETWEEN  CONVERT(VARCHAR(8),Initial_Effective_Date,112) AND CONVERT(VARCHAR(8),Final_Effective_Date,112)
				  )
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Absence is in progress',@pvIdLanguageUser)
		END

		ELSE
		BEGIN 
			DELETE Approvers_Absence WHERE Id_Approvers_Absence = @pnIdApproversAbsence
		END
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
