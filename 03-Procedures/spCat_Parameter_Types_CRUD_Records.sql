USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spCat_Parameter_Types_CRUD_Records]    Script Date: 8/17/2026 1:04:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autor:		Angel Gutierrez
Desc:		Cat_Parameter_Types | Create - Read - Upadate - Delete 
Date:		17/08/2026
Example:

			EXEC spCat_Parameter_Types_CRUD_Records @pvOptionCRUD = 'R', @pvUser = 'ANGUTIERRE';
			 
*/
CREATE PROCEDURE [dbo].[spCat_Parameter_Types_CRUD_Records]
@pvOptionCRUD		Varchar(1),
@pvUser				Varchar(50) = ''
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_Parameter_Types - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK','ANG')	--success
	DECLARE @vMessage		Varchar(Max)	=  dbo.fnGetTransacMessages(@vDescOperationCRUD,'ANG')
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Parameter_Types_CRUD_Records @pvOptionCRUD =  '" 
														+ ISNULL(@pvOptionCRUD,'NULL') 
														+ ", @pvUser = " + ISNULL(@pvUser,'NULL') 
														+ "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		SET @bSuccessful	= 0
		SET @vMessageType	= dbo.fnGetTransacMessages('WAR','ANG')	--Warning
		SET @vMessage		= dbo.fnGetTransacMessages('N/A','ANG')
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		
		SELECT
			Id_Type,
			Short_Desc,
			Long_Desc,
			Modify_By,
			Modify_Date,
			Modify_IP
		FROM Cat_Parameter_Types
		ORDER BY 
				Short_Desc;
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		SET @bSuccessful	= 0
		SET @vMessageType	= dbo.fnGetTransacMessages('WAR','ANG')	--Warning
		SET @vMessage		= dbo.fnGetTransacMessages('N/A','ANG')
	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D' OR @vDescOperationCRUD = 'N/A'
	BEGIN
		SET @bSuccessful	= 0
		SET @vMessageType	= dbo.fnGetTransacMessages('WAR','ANG')	--Warning
		SET @vMessage		= dbo.fnGetTransacMessages('N/A','ANG')
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
	SET @vMessageType	= dbo.fnGetTransacMessages('ERR','ANG')	--Error	
	SET @vMessage		= dbo.fnGetTransacErrorBD()
	SET @bSuccessful	= 0 --Execution with errors
	EXEC spSecurity_Transaction_Log_Ins_Record	@pvDescription	= @vDescription, 
												@pvExecCommand	= @vExecCommand,
												@pbSuccessful	= @bSuccessful, 
												@pvMessagetType = @vMessageType, 
												@pvMessage		= @vMessage, 
												@pvUser			= @pvUser, 
												@pnIdTransacLog	= @nIdTransacLog OUTPUT

	SET @vMessage		= dbo.fnGetTransacMessages('Generic Error','ANG')
	SET NOCOUNT OFF
	SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog
		
END CATCH