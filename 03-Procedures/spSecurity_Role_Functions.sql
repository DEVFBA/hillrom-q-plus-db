USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spSecurity_Role_Functions
/* ==================================================================================*/	
PRINT 'Crea Procedure: spSecurity_Role_Functions'

IF OBJECT_ID('[dbo].[spSecurity_Role_Functions]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spSecurity_Role_Functions
GO
/*
Autor:		Alejandro Zepeda
Desc:		Security_Role_Functions | Create - Read - Upadate - Delete 
Date:		18/04/2023
Example:
		
			spSecurity_Role_Functions @pvOptionCRUD = 'C' -- Create no disponible
			spSecurity_Role_Functions @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG'
			spSecurity_Role_Functions @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdRole = 'SALES'
			spSecurity_Role_Functions @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdRole = 'SALES', @pvInterface = 'Quotation', @pvUser = 'AZEPEDA', @pvIP = '10.245.123.12'
			spSecurity_Role_Functions @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdRole = 'SALES', @pvInterface = 'Quotation', @pvObject = 'Add-Update', @pvUser = 'AZEPEDA', @pvIP = '10.245.123.12'
			spSecurity_Role_Functions @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdRole = 'SALES', @pvInterface = 'Quotation', @pvObject = 'Add-Update', @pvSubObject = 'Margin', @pvUser = 'AZEPEDA', @pvIP = '10.245.123.12'
			spSecurity_Role_Functions @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdBusinessLine = 'PSS_LIKO'
			spSecurity_Role_Functions @pvOptionCRUD = 'U', @pvIdLanguageUser = 'SPA', @pvIdRole = 'SALES', @piIdFuncion = 1, @pbVisibility = 0, @pvUser = 'AZEPEDA', @pvIP = '10.245.123.12'
			spSecurity_Role_Functions @pvOptionCRUD = 'D' -- Delete no disponible

			EXEC spSecurity_Role_Functions @pvOptionCRUD = 'R', @pvIdRole = 'BRA', @pvInterface = 'RptQutation', @pvObject = 'PDF_TermsConditions'
			exec spSecurity_Role_Functions @pvOptionCRUD = 'R',@pvIdRole='ANG',@pvInterface = 'Quotation',@pvObject = 'Modal-RejectionComments'
		SELECT * FROM Security_Role_Functions	
*/
CREATE PROCEDURE [dbo].spSecurity_Role_Functions
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = 'ANG',
@pvIdRole			Varchar(10) = '',
@piIdFuncion		Int			= 0,
@pvIdBusinessLine	Varchar(10) = '',
@pvInterface		Varchar(50) = '',
@pvObject			Varchar(50) = '',
@pvSubObject		Varchar(50) = '',
@pbVisibility		Bit			= 0,
@pvUser				Varchar(50) = 'sa',
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
	DECLARE @vDescription	Varchar(255)	= 'Security_Role_Functions - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spSecurity_Role_Functions @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "',  @pvIdRole = '" + ISNULL(@pvIdRole,'NULL') + "',  @piIdFuncion = '" + ISNULL(CAST(@piIdFuncion AS VARCHAR),'NULL') + "',  @pvIdBusinessLine = '" + ISNULL(@pvIdBusinessLine,'NULL') + "', @pvInterface = '" + ISNULL(@pvInterface,'NULL') + "', @pvObject = '" + ISNULL(@pvObject,'NULL') + "', @pvSubObject = '" + ISNULL(@pvSubObject,'NULL') + "', @pbVisibility = '" + ISNULL(CAST(@pbVisibility AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
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

		SELECT	SRF.Id_Role,
				[Role] = SR.Short_Desc,
				SRF.Id_Function,
				Interface		= SRF.Interface_Name,
				[Object]		= SRF.[Object_Name],
				SubObject		= SRF.SubObject_Name,
				Visibility,
				SR.Id_Business_Line,
				SRF.Modify_By,
				SRF.Modify_Date,
				SRF.Modify_IP
		FROM Security_Role_Functions SRF

		INNER JOIN Security_Roles SR ON
		SRF.Id_Role = SR.Id_Role AND
		SR.Status = 1

		WHERE	(@piIdFuncion	= 0	 OR SRF.Id_Function	= @piIdFuncion) AND 
				(@pvIdRole		= '' OR SRF.Id_Role		= @pvIdRole) AND
				(@pvInterface	= '' OR SRF.Interface_Name	= @pvInterface) AND
				(@pvObject		= '' OR SRF.[Object_Name]	= @pvObject) AND
				(@pvSubObject	= '' OR SRF.SubObject_Name	= @pvSubObject) AND
				(@pvIdBusinessLine = '' OR SR.Id_Business_Line = @pvIdBusinessLine)
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Security_Role_Functions
		SET Visibility		= @pbVisibility,
			Modify_By		= @pvUser,
			Modify_Date		= GETDATE(),
			Modify_IP		= @pvIP
		WHERE 
		Id_Role		= @pvIdRole AND
		Id_Function	= @piIdFuncion
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
