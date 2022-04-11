USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_Commissions_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_Commissions_CRUD_Records'

IF OBJECT_ID('[dbo].[spQuotation_Commissions_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_Commissions_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Quotation_Commissions | Create - Read - Upadate - Delete 
Date:		06/02/2021
Example:

	DECLARE  @udtQuotationCommissions  UDT_Quotation_Commissions 

	INSERT @udtQuotationCommissions VALUES (11,1,1,12.4,198.67)

	EXEC spQuotation_Commissions_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @piFolio = 11, @piVersion = 1, @pudtQuotationCommissions = @udtQuotationCommissions, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'
	EXEC spQuotation_Commissions_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG'
	EXEC spQuotation_Commissions_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piFolio = 579, @piVersion =1											
	EXEC spQuotation_Commissions_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @piFolio = 11, @piVersion = 1, @pudtQuotationCommissions = @udtQuotationCommissions, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'
	EXEC spQuotation_Commissions_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser='ANG',@piFolio='271',@piVersion='1'
*/
CREATE PROCEDURE [dbo].spQuotation_Commissions_CRUD_Records
@pvOptionCRUD				Varchar(1),
@pvIdLanguageUser			Varchar(10) = 'ANG',
@piFolio					Int			= 0,
@piVersion					Int			= 0,
@pudtQuotationCommissions	UDT_Quotation_Commissions Readonly,
@pvUser						Varchar(50) = '',
@pvIP						Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @iNumRegistros		Int			= (SELECT COUNT(*) FROM @pudtQuotationCommissions)
	DECLARE @tblQuotationHeader	Table(Folio int, [Version] smallint, Id_Header bigint, Item_Template varchar(50), Id_Header_New smallint)
	
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Quotation_Commissions - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spQuotation_Commissions_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piFolio = '" + ISNULL(CAST(@piFolio AS VARCHAR),'NULL') + "', @piVersion = '" + ISNULL(CAST(@piVersion AS VARCHAR),'NULL') + "', @pudtQuotationCommissions = '" + ISNULL(CAST(@iNumRegistros AS VARCHAR),'NULL') + " rows affected', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C' OR @pvOptionCRUD = 'U'
	BEGIN
		----------------
		--Delete tables
		----------------
		DELETE Quotation_Commissions WHERE Folio = @piFolio and [Version] = @piVersion

		----------------
		--Insert Header
		----------------
		INSERT INTO Quotation_Commissions (
			Folio,
			[Version],
			Id_Commission,
			[Percentage],
			Amount)
		SELECT 
			Folio,
			[Version],
			Id_Commission,
			[Percentage],
			Amount
		FROM @pudtQuotationCommissions

	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
			QC.Folio,
			QC.[Version],
			Id_Catalog = QC.Id_Commission,
			CC.Short_Desc,
			CC.[Status],
			QC.[Percentage],
			QC.Amount,
			C.Symbol
		FROM Quotation_Commissions QC

		INNER JOIN Quotation Q ON
		QC.Folio	 = Q.Folio AND 
		QC.[Version] = Q.[Version]

		INNER JOIN Cat_Countries_Commissions CC ON 
		Q.Id_Country_Bill_To = CC.Id_Country AND
		QC.Id_Commission = CC.Id_Commission AND
		CC.Id_Language = @pvIdLanguageUser

		INNER JOIN Cat_Currencies C ON 
		Q.Id_Currency = C.Id_Currency AND
		C.Id_Language = @pvIdLanguageUser

		WHERE	(@piFolio	= 0	OR QC.Folio	 = @piFolio) AND 
				(@piVersion	= 0	OR QC.[Version] = @piVersion) 
	
		ORDER BY  QC.Folio, QC.[Version], Id_Catalog
		
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
