USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spFLC_Generate_Price_List
/* ==================================================================================*/	
PRINT 'Crea Procedure: [spFLC_PDF_Requests_CRUD_Records]'

IF OBJECT_ID('[dbo].[spFLC_PDF_Requests_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spFLC_PDF_Requests_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		FLC_PDF_Requests | Create - Read - Upadate - Delete 
Date:		16/11/2023
Example:
			EXEC spFLC_PDF_Requests_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvModality = 'Master', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spFLC_PDF_Requests_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvModality = 'Cluster', @pvCluster = 'FLCCLUCOL', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spFLC_PDF_Requests_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvModality = 'Distributor', @pvDistributor = '1', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spFLC_PDF_Requests_CRUD_Records @pvOptionCRUD = 'R'
			spFLC_PDF_Requests_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piFolio = 1
			spFLC_PDF_Requests_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvModality = 'Master' 
			spFLC_PDF_Requests_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @piFolio = 7,  @pvPath = 'C:\Archivo.pdf', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

			DELETE FLC_PDF_Requests
*/
CREATE PROCEDURE [dbo].[spFLC_PDF_Requests_CRUD_Records]
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = 'ANG',
@piFolio			Int			= 0,
@pvModality			Varchar(50)  = '',
@pvCluster			Varchar(100) = NULL,
@pvDistributor		Varchar(100) = NULL,
@pvPath				Varchar(255) = '',
@pbStatus			Bit			= 0,
@pvUser				Varchar(50) = '',
@pvIP				Varchar(20) = ''
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
	DECLARE @vDescription	Varchar(255)	= 'FLC_PDF_Requests - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spFLC_PDF_Requests_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piFolio = '" + ISNULL(CAST(@piFolio AS VARCHAR),'NULL') + "', @pvModality = '" + ISNULL(@pvModality,'NULL') + "', @pvCluster = '" + ISNULL(@pvCluster,'NULL') + "', @pvDistributor = '" + ISNULL(@pvDistributor,'NULL') + "', @pvPath = '" + ISNULL(@pvPath,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF @pvModality = 'Master' AND EXISTS(SELECT * FROM FLC_PDF_Requests WHERE Modality = @pvModality AND [Status] = 0 )
			SET @bSuccessful	= 0

		IF @pvModality = 'Cluster' AND EXISTS(SELECT * FROM FLC_PDF_Requests WHERE Modality = @pvModality AND Cluster = @pvCluster AND [Status] = 0 )
			SET @bSuccessful	= 0
		
		IF @pvModality = 'Distributor' AND EXISTS(SELECT * FROM FLC_PDF_Requests WHERE Modality = @pvModality AND Distributor = @pvDistributor AND [Status] = 0 )
			SET @bSuccessful	= 0
		
		-- Validate if the record already exists
		IF @bSuccessful = 0 
		BEGIN
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END		
		ELSE -- Don´t Exists Inserta el Registro
		BEGIN
			SET @piFolio = ISNULL((SELECT MAX(Folio) + 1 from FLC_PDF_Requests),1)
			INSERT INTO FLC_PDF_Requests (
				Folio,
				Modality,
				Cluster,
				Distributor,
				Initial_Date,
				[Status],
				Modify_By,
				Modify_IP)
			VALUES(
				@piFolio,
				@pvModality,
				@pvCluster,
				@pvDistributor,
				GETDATE(),
				@pbStatus,
				@pvUser,
				@pvIP)
		END
		
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		WITH RankedData AS (
			SELECT
				Folio,
				Modality,
				Cluster,
				Distributor,
				Initial_Date,
				Final_Date,
				[Path],
				[Status],
				ROW_NUMBER() OVER (PARTITION BY Modality, Cluster, Distributor ORDER BY Folio DESC) AS RowNum
			FROM
				FLC_PDF_Requests
		)
		SELECT
			Folio,
			Modality,
			Cluster,
			Distributor,
			Initial_Date,
			Final_Date,
			[Path],
			[Status]
		FROM
			RankedData
		WHERE
		RowNum = 1
		AND (@piFolio = 0 OR Folio = @piFolio)
		AND  (@pvModality = '' OR Modality = @pvModality)
		AND  (@pvCluster IS NULL OR Modality = @pvModality)
		AND  (@pvDistributor IS NULL OR Modality = @pvModality)

		ORDER BY Folio DESC 
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE FLC_PDF_Requests 
		SET [Path]			= @pvPath,
			[Status]		= @pbStatus,
			Final_Date		= (CASE WHEN @pbStatus = 1 THEN GETDATE() END),
			Modify_By		= @pvUser,
			Modify_IP		= @pvIP
		WHERE Folio = @piFolio

	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D'
	BEGIN
		DELETE FLC_PDF_Requests 
		WHERE Folio = @piFolio
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
	SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog, Folio = @piFolio

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
	SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog, Folio = @piFolio		
END CATCH
