USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spNotification_Quotation_Status_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spNotification_Quotation_Status_CRUD_Records'

IF OBJECT_ID('[dbo].[spNotification_Quotation_Status_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spNotification_Quotation_Status_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Notification_Quotation_Status | Create - Read - Upadate - Delete 
Date:		11/04/2021
Example:
			spNotification_Quotation_Status_CRUD_Records @pvOptionCRUD = 'C',  @piIdNotification = 1, @piFolio =  452 , @piVersion = 1, @pvUser = 'AZEPEDA'
			spNotification_Quotation_Status_CRUD_Records @pvOptionCRUD = 'R' 
			spNotification_Quotation_Status_CRUD_Records @pvOptionCRUD = 'R', @piIdNotification = 1 , @pbNotificationSend = 0
			spNotification_Quotation_Status_CRUD_Records @pvOptionCRUD = 'R', @pbNotificationSend = 0
			spNotification_Quotation_Status_CRUD_Records @pvOptionCRUD = 'R', @pnIdMailNotification = 1 
			spNotification_Quotation_Status_CRUD_Records @pvOptionCRUD = 'U', @pnIdMailNotification = 1 
		
*/
create PROCEDURE [dbo].spNotification_Quotation_Status_CRUD_Records
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10) = 'ANG',
@piIdNotification		Int			 = 0,
@pnIdMailNotification	Numeric		 = 0,
@piFolio				Int			 = 0,
@piVersion				Int			 = 0,
@pbNotificationSend		Bit			 = NULL,-- 0 = Not Sent | 1 = Sent 
@pvUser					Varchar(50)  = 'sa'

AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD		Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vCustomer				Varchar(255)
	DECLARE @vCustomerEmail			Varchar(50)
	DECLARE @vSalesExecutive		Varchar(255) 
	DECLARE @vSalesExecutiveEmail	Varchar(50)
	DECLARE @vSalesExecutiveRegion	Varchar(50)
	DECLARE @vSPRNumber				Varchar(50)
	DECLARE @vCountry				Varchar(50)
	DECLARE @vQuotationStatus		Varchar(50)
	
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Notification_Quotation_Status - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spNotification_Quotation_Status_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pnIdMailNotification = '" + ISNULL(CAST(@pnIdMailNotification AS VARCHAR),'NULL') + "', @piFolio = '" + ISNULL(CAST(@piFolio AS VARCHAR),'NULL') + "', @piVersion = '" + ISNULL(CAST(@piVersion AS VARCHAR),'NULL') + "', @piIdNotification = '" + ISNULL(CAST(@piIdNotification AS VARCHAR),'NULL') + "'"
	
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN

		----------------------------------------------------------
		SELECT 
			@vCustomer				= Customer_Bill_To,
			@vCustomerEmail			= Customer_Email,
			@vSalesExecutive		= Sales_Executive,
			@vSalesExecutiveEmail	= Sales_Executive_Email,
			@vSalesExecutiveRegion	= RE.Short_Desc,
			@vSPRNumber				= ISNULL(SPR_Number,''),
			@vCountry				= Q.Country_Bill_To,
			@vQuotationStatus		= Id_Quotation_Status,
			@pbNotificationSend		= 0 -- Not Sent
			
		FROM [fnQuotation](@pvIdLanguageUser) Q

		INNER JOIN Security_Users U ON 
		Q.Id_Sales_Executive = U.[User]

		INNER JOIN Cat_Region_Zones RZ ON 
		U.Id_Zone = RZ.Id_Zone 
	
		INNER JOIN Cat_Regions RE ON
		RZ.Id_Region =  RE.Id_Region

		WHERE Folio = @piFolio AND [Version] = @piVersion
		
		----------------------------------------------------------

		INSERT INTO Notification_Quotation_Status(
		    Id_Notification,
			Folio,
			[Version],
			Customer,
			Customer_Email,
			Sales_Executive,
			Sales_Executive_Email,
			Sales_Executive_Region,
			SPR_Number,
			Country,
			Quotation_Status,
			Register_Date,
			Notification_Send)
		VALUES (
			@piIdNotification,
			@piFolio,
			@piVersion,
			@vCustomer,
			@vCustomerEmail,
			@vSalesExecutive,
			@vSalesExecutiveEmail,
			@vSalesExecutiveRegion,
			@vSPRNumber,
			@vCountry,
			@vQuotationStatus,
			GETDATE(),
			@pbNotificationSend)
	END

	--------------------------------------------------------------------
	--Reads Records Not Send
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
			N.Id_Mail_Notification,
			N.Folio,
			N.[Version],
			N.Customer,
			N.Customer_Email,
			N.Sales_Executive,
			N.Sales_Executive_Email,
			N.Sales_Executive_Region,
			N.SPR_Number,
			N.Country,
			N.Quotation_Status,
			Q.Id_Language_Translation,
			N.Register_Date,
			N.Notification_Date,
			N.Notification_Send
		FROM Notification_Quotation_Status N 
		INNER JOIN [fnQuotation](@pvIdLanguageUser) Q ON 
		N.Folio = Q.Folio AND
		N.[Version] = Q.[Version]
		WHERE (@pnIdMailNotification = 0 OR N.Id_Mail_Notification = @pnIdMailNotification)
		AND   (@piIdNotification = 0  OR N.Id_Notification = @piIdNotification)
		AND   (@pbNotificationSend IS NULL OR N.Notification_Send = @pbNotificationSend) 
		ORDER BY N.Id_Mail_Notification

		RETURN
	END

	--------------------------------------------------------------------
	--Update Records Sent
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		SET  @pbNotificationSend = 1 -- Sent

		UPDATE Notification_Quotation_Status 
		SET Notification_Date = GETDATE(),
			Notification_Send = @pbNotificationSend
		WHERE Id_Mail_Notification = @pnIdMailNotification
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
	IF @pvOptionCRUD = 'U'
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
	IF @pvOptionCRUD = 'U'
		SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog
		
END CATCH