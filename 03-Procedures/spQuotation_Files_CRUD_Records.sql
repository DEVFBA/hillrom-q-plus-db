USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_Files_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_Files_CRUD_Records'

IF OBJECT_ID('[dbo].[spQuotation_Files_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_Files_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Quotation_Files | Create - Read - Upadate - Delete 
Date:		15/09/2021
Example:

	DECLARE  @udtQuotationFiles  UDT_Quotation_Files 


	INSERT @udtQuotationFiles 
	VALUES(122,1,'ABACCOM', 0,'C:\ARCHIVO.PDF','COMENTS','AZEPEDA',NULL,NULL)

	select * from @udtQuotationFiles 

	EXEC spQuotation_Files_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @piFolio = 11, @piVersion = 1, @udtQuotationFiles = @pudtQuotationFiles, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'
	EXEC spQuotation_Files_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piFolio = 282, @piVersion = 1
	EXEC spQuotation_Files_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piFolio = 282, @piVersion = 1, @pvIdFileType = 'FILE'											
	EXEC spQuotation_Files_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @piFolio = 11, @piVersion = 1, @udtQuotationFiles = @pudtQuotationFiles, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'
	EXEC spQuotation_Files_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser='ANG',@piFolio='271',@piVersion='1'
*/
CREATE PROCEDURE [dbo].spQuotation_Files_CRUD_Records
@pvOptionCRUD				Varchar(1),
@pvIdLanguageUser			Varchar(10) = 'ANG',
@piFolio					Int			= 0,
@piVersion					Int			= 0,
@pvIdFileType				Varchar(10) = '',
@pudtQuotationFiles			UDT_Quotation_Files Readonly,
@pvUser						Varchar(50) = '',
@pvIP						Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @iNumRegistros		Int			= (SELECT COUNT(*) FROM @pudtQuotationFiles)
	DECLARE @tblQuotationHeader	Table(Folio int, [Version] smallint, Id_Header bigint, Item_Template varchar(50), Id_Header_New smallint)
	
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Quotation_Files - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spQuotation_Files_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piFolio = '" + ISNULL(CAST(@piFolio AS VARCHAR),'NULL') + "', @piVersion = '" + ISNULL(CAST(@piVersion AS VARCHAR),'NULL') + "', @pudtQuotationCommissions = '" + ISNULL(CAST(@iNumRegistros AS VARCHAR),'NULL') + " rows affected', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C' OR @pvOptionCRUD = 'U'
	BEGIN
		----------------
		--Delete tables
		----------------
		DELETE Quotation_Files WHERE Folio = @piFolio and [Version] = @piVersion

		----------------
		--Insert Header
		----------------
		INSERT INTO Quotation_Files (
			Folio,
			[Version],
			Id_File_Type,
			File_Path,
			Comments,
			Modify_By,
			Modify_Date,
			Modify_IP)
		SELECT 
			Folio,
			[Version],
			Id_File_Type,
			File_Path,
			Comments,
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtQuotationFiles

	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
			QF.Folio,
			QF.[Version],
			QF.Id_File_Type,
			File_Type_Desc = CFT.Short_Desc,
			QF.Id_File,
			QF.File_Path,
			QF.Comments,
			QF.Modify_By,
			QF.Modify_Date,
			QF.Modify_IP
		FROM Quotation_Files QF

		INNER JOIN Quotation Q ON
		QF.Folio	 = Q.Folio AND 
		QF.[Version] = Q.[Version]

		INNER JOIN Cat_File_Types CFT ON 
		QF.Id_File_Type = CFT.Id_File_Type AND
		CFT.Id_Language = @pvIdLanguageUser

		WHERE	(@piFolio		= 0	 OR QF.Folio		= @piFolio) AND 
				(@piVersion		= 0	 OR QF.[Version]	= @piVersion) AND
				(@pvIdFileType	= '' OR QF.Id_File_Type = @pvIdFileType)
		ORDER BY  QF.Folio, QF.[Version]
		
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
