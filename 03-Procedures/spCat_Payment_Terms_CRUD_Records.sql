USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Payment_Terms_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Payment_Terms_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Payment_Terms_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Payment_Terms_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Payment_Terms | Create - Read - Upadate - Delete 
Date:		31/12/2020
Example:
			spCat_Payment_Terms_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdLanguage = 'ANG', @pvIdPaymentTerm = 130, @piIdApprovalFlow = NULL, @pvShortDesc = '130 Days', @pvLongDesc = '130 Days 2', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Payment_Terms_CRUD_Records @pvOptionCRUD = 'R'
			spCat_Payment_Terms_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguage = 'ANG', @pvIdPaymentTerm = 30
			spCat_Payment_Terms_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguage = 'ANG'
			spCat_Payment_Terms_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdLanguage = 'ANG', @pvIdPaymentTerm = 130, @piIdApprovalFlow = 2, @pvShortDesc = '30 Days', @pvLongDesc = '30 Days 2', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Payment_Terms_CRUD_Records @pvOptionCRUD = 'D'
			select * from Cat_Payment_Terms

			 
*/
CREATE PROCEDURE [dbo].spCat_Payment_Terms_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@pvIdLanguage		Varchar(10) = '',
@pvIdPaymentTerm	Varchar(10) = '',
@piIdApprovalFlow	Smallint	= 0,
@pvShortDesc		Varchar(50) = '',
@pvLongDesc			Varchar(255)= '',
@pbStatus			Bit			= '',
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_Payment_Terms - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Payment_Terms_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdLanguage = '" + ISNULL(@pvIdLanguage,'NULL') + "', @pvIdPaymentTerm = '" + ISNULL(@pvIdPaymentTerm,'NULL') + "', @piIdApprovalFlow = '" + ISNULL(CAST(@piIdApprovalFlow AS VARCHAR),'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Payment_Terms WHERE Id_Language = @pvIdLanguage AND Id_Payment_Term = @pvIdPaymentTerm )
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END		
		ELSE -- Don´t Exists
		BEGIN
			IF @piIdApprovalFlow = 0 SET @piIdApprovalFlow = NULL

			INSERT INTO Cat_Payment_Terms(
				Id_Language,
				Id_Payment_Term,
				Id_Approval_Flow,
				Short_Desc,
				Long_Desc,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdLanguage,
				@pvIdPaymentTerm,
				@piIdApprovalFlow,
				@pvShortDesc,
				@pvLongDesc,
				@pbStatus,
				GETDATE(),
				@pvUser,
				@pvIP)
		END
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
		PT.Id_Language,
		Desc_Language		= L.Short_Desc,
		PT.Id_Approval_Flow,
		Approval_Flow_Desc	= AF.Short_Desc,
		Id_Catalog			= PT.Id_Payment_Term,
		PT.Short_Desc,
		PT.Long_Desc,
		PT.[Status],
		PT.Modify_Date,
		PT.Modify_By,
		PT.Modify_IP

		FROM Cat_Payment_Terms PT WITH(NOLOCK)
		
		INNER JOIN Cat_Languages L WITH(NOLOCK) ON 
		PT.Id_Language = L.Id_Language  AND
		PT.Id_Language = L.Id_Language_Translation

		LEFT OUTER JOIN Cat_Approvals_Flows AF WITH(NOLOCK) ON 
		PT.Id_Approval_Flow = AF.Id_Approval_Flow

		WHERE 
		(@pvIdLanguage		= ''	OR PT.Id_Language		= @pvIdLanguage) AND
		(@pvIdPaymentTerm	= ''	OR PT.Id_Payment_Term	= @pvIdPaymentTerm) AND
		(@piIdApprovalFlow	= 0		OR PT.Id_Approval_Flow	= @piIdApprovalFlow) 

		ORDER BY PT.Id_Language, Id_Catalog
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		IF @piIdApprovalFlow = 0 SET @piIdApprovalFlow = NULL

		UPDATE Cat_Payment_Terms 
		SET 
			Id_Approval_Flow = @piIdApprovalFlow,
			Short_Desc		 = @pvShortDesc,
			Long_Desc		 = @pvLongDesc,
			[Status]		 = @pbStatus,			
			Modify_Date		 = GETDATE(),
			Modify_By		 = @pvUser,
			Modify_IP		 = @pvIP
		WHERE Id_Language = @pvIdLanguage AND Id_Payment_Term = @pvIdPaymentTerm
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
