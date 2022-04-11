USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Approval_Country_Incoterms_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Approval_Country_Incoterms_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Approval_Country_Incoterms_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Approval_Country_Incoterms_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Approval_Country_Incoterms | Create - Read - Upadate - Delete 
Date:		08/01/2021
Example:
			spCat_Approval_Country_Incoterms_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'CR' , @pvIdIncoterm = 'DDP', @piIdApprovalFlow = 2, @pbStatus = 1, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'
			spCat_Approval_Country_Incoterms_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'CR' , @pvIdIncoterm = 'DDP', @piIdApprovalFlow = 2
			spCat_Approval_Country_Incoterms_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'CR' , @pvIdIncoterm = 'DDP', @piIdApprovalFlow = 2, @pbStatus = 1, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'
			spCat_Approval_Country_Incoterms_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'CR' , @pvIdCategory = 'DDP', @piIdApprovalFlow = 2, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'
			spCat_Approval_Country_Incoterms_CRUD_Records @pvOptionCRUD = 'X', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'CR' , @pvIdIncoterm = 'DDP', @piIdApprovalFlow = 2, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'

*/
CREATE PROCEDURE [dbo].spCat_Approval_Country_Incoterms_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = 'ANG',
@pvIdCountry		Varchar(10) = '',
@pvIdIncoterm		Varchar(10) = '',
@piIdApprovalFlow	Varchar(10) = '',
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_Approval_Country_Incoterms - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Approval_Country_Incoterms_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL') + "', @pvIdIncoterm = '" + ISNULL(@pvIdIncoterm,'NULL') + "', @piIdApprovalFlow = '" + ISNULL(@piIdApprovalFlow,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Approval_Country_Incoterms WHERE Id_Country = @pvIdCountry and Id_Incoterm= @pvIdIncoterm AND Id_Approval_Flow = @piIdApprovalFlow)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Cat_Approval_Country_Incoterms(
				Id_Country,
				Id_Incoterm,
				Id_Approval_Flow,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdCountry,
				@pvIdIncoterm,
				@piIdApprovalFlow,
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
		ACI.Id_Country,
		Country_Desc = C.Short_Desc,
		ACI.Id_Incoterm,
		Incoterm_Desc = I.Short_Desc,
		ACI.Id_Approval_Flow,
		Approval_Flow_Desc = F.Short_Desc,
		ACI.[Status],
		ACI.Modify_Date,
		ACI.Modify_By,
		ACI.Modify_IP
		FROM Cat_Approval_Country_Incoterms ACI WITH(NOLOCK)
		
		INNER JOIN Cat_Countries C WITH(NOLOCK) ON 
		ACI.Id_Country = C.Id_Country

		INNER JOIN Cat_Incoterm I WITH(NOLOCK) ON 
		ACI.Id_Incoterm = I.Id_Incoterm AND
		I.Id_Language = @pvIdLanguageUser 

		INNER JOIN Cat_Approvals_Flows F WITH(NOLOCK) ON 
		ACI.Id_Approval_Flow = F.Id_Approval_Flow
			
		WHERE (@pvIdCountry			= '' OR ACI.Id_Country = @pvIdCountry) AND
			  (@pvIdIncoterm		= '' OR ACI.Id_Incoterm = @pvIdIncoterm) AND
			  (@piIdApprovalFlow	= '' OR ACI.Id_Approval_Flow = @piIdApprovalFlow)
	
		ORDER BY ACI.Id_Country , ACI.Id_Incoterm , ACI.Id_Approval_Flow 
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Approval_Country_Incoterms 
		SET [Status]	= @pbStatus,
			Modify_Date	= GETDATE(),
			Modify_By	= @pvUser,
			Modify_IP	= @pvIP
		 WHERE Id_Country = @pvIdCountry and Id_Incoterm= @pvIdIncoterm AND Id_Approval_Flow = @piIdApprovalFlow
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
