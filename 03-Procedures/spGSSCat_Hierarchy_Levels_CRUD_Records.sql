USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_Cat_Hierarchy_Levels_CRUD_Records]    Script Date: 9/14/2025 6:34:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Autor:		Angel Gutiérrez
Desc:		Cat_Hierarchy_Levels | Create - Read - Update - Delete | EFGSS002 
Date:		16/09/2025
Example:
			EXEC spGSS_Cat_Hierarchy_Levels_CRUD_Records @pvOptionCRUD = 'R', @pvIdHierarchyLevel = 'LINE' 
			EXEC spGSS_Cat_Hierarchy_Levels_CRUD_Records @pvOptionCRUD = 'R'
*/
CREATE PROCEDURE [dbo].[spGSS_Cat_Hierarchy_Levels_CRUD_Records]
@pvOptionCRUD		Varchar(1),
@pvIdHierarchyLevel   Varchar(10) = '',
@pvUser				Varchar(50) = '',
@pvIP				Varchar(20) = '',
@pvIdLanguageUser	Varchar(10) = 'ANG'
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_Hierarchy_Levels - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spGSS_Cat_Hierarchy_Levels_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + ISNULL(@pvIdHierarchyLevel,'NULL') + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		SET @bSuccessful	= 0
		SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
		SET @vMessage		= dbo.fnGetTransacMessages('N/A',@pvIdLanguageUser)		
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT
		Id_Catalog = A.Id_Hierarchy_Level,
		A.Short_Desc,
		A.Long_Desc,
		A.Level
		FROM GSS_Cat_Hierarchy_Levels A


		WHERE 
		(@pvIdHierarchyLevel = '' OR Id_Hierarchy_Level = @pvIdHierarchyLevel)
		ORDER BY  A.Short_Desc
		
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