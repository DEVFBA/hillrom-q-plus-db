USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_Log_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_Log_CRUD_Records'

IF OBJECT_ID('[dbo].[spQuotation_Log_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_Log_CRUD_Records
GO
/*
Autor:		Alejandro Zepeda
Desc:		Quotation_Log | Create - Read - Upadate - Delete 
Date:		07/02/2021
Example:
			spQuotation_Log_CRUD_Records @pvOptionCRUD = 'C', @piFolio = 11 , @piVersion = 1, @pvIdQuotationStatus = 'DRAF', @pvUser = 'ALZEPEDA'
			spQuotation_Log_CRUD_Records @pvOptionCRUD = 'R', @piFolio = 11 , @piVersion = 1 
			spQuotation_Log_CRUD_Records @pvOptionCRUD = 'R'
		
*/
CREATE PROCEDURE [dbo].spQuotation_Log_CRUD_Records
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10) = 'ANG',
@piFolio				Int			= 0,
@piVersion				Int			= 0,
@pvIdQuotationStatus	Varchar(10)	= '',
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
	DECLARE @vDescription	Varchar(255)	= 'Quotation Log - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD, @pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spQuotation_Log_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piFolio = " + ISNULL(CAST(@piFolio AS VARCHAR),'NULL') + ", @piVersion = " + ISNULL(CAST(@piVersion AS VARCHAR),'NULL') + ", @pvIdQuotationStatus = '" + ISNULL(@pvIdQuotationStatus,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "'"
	--------------------------------------------------------------------
	--Create or Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C' OR @pvOptionCRUD = 'U'
	BEGIN
		INSERT INTO Quotation_Log(
			Folio,
			[Version],
			Id_Quotation_Status,
			[User],
			Register_Date)
		VALUES (
			@piFolio,
			@piVersion,
			@pvIdQuotationStatus,
			@pvUser,
			GETDATE())
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
		Id_Quotation_Log,
		Folio,
		[Version],
		Id_Quotation_Status,
		[User],
		Register_Date
		FROM Quotation_Log 
		WHERE	(@piFolio = 0 OR Folio = @piFolio) AND
				(@piVersion = 0 OR [Version] = @piVersion)
		ORDER BY Id_Quotation_Log
		
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
		
END CATCH
