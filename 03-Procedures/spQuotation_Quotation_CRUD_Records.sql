USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_Quotation_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_Quotation_CRUD_Records'

IF OBJECT_ID('[dbo].[spQuotation_Quotation_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_Quotation_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Quotation | Create - Read - Upadate - Delete 
Date:		06/02/2021
Example:
			EXEC spQuotation_Quotation_CRUD_Records @pvOptionCRUD = 'C',
													@pvIdLanguageUser = 'ANG',
													@pvIdCustomerBillTo = 5, 
													@pvIdCustomerTypeBillTo = 'BILL', 
													@pvIdCountryBillTo = 'VE',
													@pvIdCustomerFinal = 6, 
													@pvIdCustomerTypeFinal = 'FINA', 
													@pvIdCountryFinal = 'VE',
													@pvIdVoltage = '120V',
													@pvIdLanguage = 'SPA',
													@pvIdPlug = 'US',
													@pvIdIncoterm = 'NA',
													@pvIdCurrency = 'USD',
													@piIdExchangeRate = 1,
													@pvIdSalesType = 'DIRSA',
													@pvIdPriceList = 'MAIN',
													@pvIdValidityPrice = '30',
													@pvIdSalesExecutive = 'RUGOMEZ',
													@pvIdPaymentTerm    = 60,
													@pvSPRNumber = 0,
													@piPurchaseOrder = 0,
													@pvComments = 'COMMENTS TEST 3 AZR',
													@pvUser = 'RUGOMEZ', 
													@pvIP ='192.168.1.254'

			EXEC spQuotation_Quotation_CRUD_Records @pvOptionCRUD = 'R'
			EXEC spQuotation_Quotation_CRUD_Records @pvOptionCRUD = 'R',
													@pvIdLanguageUser = 'ANG',
													@piFolio = 554, 
													@piVersion = 1,
													@pvIdCustomerBillTo = 5, 
													@pvIdCustomerTypeBillTo = 'BILL', 
													@pvIdCountryBillTo = 'VE',
													@pvIdCustomerFinal = 6, 
													@pvIdCustomerTypeFinal = 'FINA', 
													@pvIdCountryFinal = 'VE',
													@pvIdVoltage = '120V',
													@pvIdLanguage = 'SPA',
													@pvIdPlug = 'US',
													@pvIdIncoterm = 'NA',
													@pvIdCurrency = 'USD',
													@piIdExchangeRate = 1,
													@pvIdSalesType = 'DIRSA',
													@pvIdPriceList = 'MAIN',
													@pvIdQuotationStatus = 'ROUT',
													@pvIdLanguageTranslation = 'SPA',
													@pvIdSalesExecutive = 'RUGOMEZ',
													@pvSPRNumber = 0,
													@piPurchaseOrder = 0,
													@pvCustomerBillTo  = 'VENEZ',
													@pvSalesExecutive  = 'RUB�N',
													@pvCreationDateIni = '20210101',
													@pvCreationDateFin  = '20210103'



			EXEC spQuotation_Quotation_CRUD_Records @pvOptionCRUD = 'U',
													@pvIdLanguageUser = 'ANG',
													@piFolio = 9, 
													@piVersion = 1 , 
													@pvIdQuotationStatus = 'DIRE',
													@piPurchaseOrder = 0,
													@pvSPRNumber = 0											
													@pvUser = 'RUGOMEZ', 
													@pvIP ='192.168.1.254'

			EXEC spQuotation_Quotation_CRUD_Records @pvOptionCRUD = 'R', @pvIdSalesExecutive = 'VIROJAS';
*/
CREATE PROCEDURE [dbo].spQuotation_Quotation_CRUD_Records
@pvOptionCRUD				Varchar(1),
@pvIdLanguageUser			Varchar(10) = 'ANG',
@piFolio					Int			= 0,
@piVersion					Int			= 0,
@pvIdCustomerBillTo			Int			= 0,
@pvIdCustomerTypeBillTo		Varchar(10)	= '',
@pvIdCountryBillTo			Varchar(10)	= '',
@pvIdCustomerFinal			Int			= 0,
@pvIdCustomerTypeFinal		Varchar(10)	= '',
@pvIdCountryFinal			Varchar(10)	= '',
@pvIdVoltage				Varchar(10)	= '',
@pvIdLanguage				Varchar(10)	= '',
@pvIdPlug					Varchar(10)	= '',
@pvIdIncoterm				Varchar(10)	= '',
@pvIdCurrency				Varchar(10)	= '',
@piIdExchangeRate			Smallint	= 0,
@pvIdSalesType				Varchar(10)	= '',
@pvIdPriceList				Varchar(10)	= '',
@pvIdValidityPrice			Varchar(10) = '',
@pvIdQuotationStatus		Varchar(10)	= '',
@pvIdLanguageTranslation	Varchar(10)	= '',
@pvIdSalesExecutive			Varchar(20)	= '',
@pvIdPaymentTerm			Varchar(10) = '',
@pvSPRNumber				Varchar(50)	= '0',
@piPurchaseOrder			Int			=0 ,
@pvComments					Varchar(1000)= '',
@pvUser						Varchar(50) = '',
@pvIP						Varchar(20) = '',
----------------------------------------------
--Additional search parameters
----------------------------------------------
@pvCustomerBillTo		Varchar(255)= '',
@pvSalesExecutive		Varchar(255)= '',
@pvCreationDateIni		Varchar(8)	= '',
@pvCreationDateFin		Varchar(8)	= ''
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
	DECLARE @vDescription	Varchar(255)	= 'Quotation - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK', @pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD, @pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spQuotation_Quotation_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piFolio = '" + ISNULL(CAST(@piFolio AS VARCHAR),'NULL') + "', @piVersion = '" + ISNULL(CAST(@piVersion AS VARCHAR),'NULL') + "',  @pvIdCustomerBillTo = '" + ISNULL(CAST(@pvIdCustomerBillTo AS VARCHAR),'NULL') + "', @pvIdCustomerTypeBillTo = '" + ISNULL(@pvIdCustomerTypeBillTo,'NULL') + "', @pvIdCountryBillTo = '" + ISNULL(@pvIdCountryBillTo,'NULL') + "', @pvIdCustomerFinal = '" + ISNULL(CAST(@pvIdCustomerFinal AS VARCHAR),'NULL') + "', @pvIdCustomerTypeFinal = '" + ISNULL(@pvIdCustomerTypeFinal,'NULL') + "', @pvIdCountryFinal = '" + ISNULL(@pvIdCountryFinal,'NULL') + "', @pvIdVoltage = '" + ISNULL(@pvIdVoltage,'NULL') + "', @pvIdLanguage = '" + ISNULL(@pvIdLanguage,'NULL') + "', @pvIdPlug = '" + ISNULL(@pvIdPlug,'NULL') + "', @pvIdIncoterm = '" + ISNULL(@pvIdIncoterm,'NULL') + "', @pvIdCurrency = '" + ISNULL(@pvIdCurrency,'NULL') + "', @piIdExchangeRate = '" + ISNULL(CAST(@piIdExchangeRate AS VARCHAR),'NULL') + "', @pvIdSalesType = '" + ISNULL(@pvIdSalesType,'NULL') + "', @pvIdPriceList = '" + ISNULL(@pvIdPriceList,'NULL') + "', @pvIdValidityPrice = '" + ISNULL(@pvIdValidityPrice,'NULL') + "', @pvIdQuotationStatus = '" + ISNULL(@pvIdQuotationStatus,'NULL') + "', @pvIdSalesExecutive = '" + ISNULL(@pvIdSalesExecutive,'NULL') + "', @pvSPRNumber = '" + ISNULL(@pvSPRNumber,'NULL') + "', @piPurchaseOrder = '" + ISNULL(CAST(@piPurchaseOrder AS VARCHAR),'NULL') + "', @pvComments = '" + ISNULL(@pvComments,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		IF @piFolio = 0
		SET @piFolio	= (SELECT ISNULL(MAX(Folio) + 1 ,1) FROM Quotation)

		SET @piVersion	= (SELECT ISNULL(MAX([Version]) + 1 ,1) FROM Quotation WHERE Folio = @piFolio)
		SET @pvIdQuotationStatus = 'DRAF' 

		IF @pvIdLanguageTranslation = '' 			
			SET @pvIdLanguageTranslation = NULL 

		IF @pvIdPaymentTerm = ''
			SET @pvIdPaymentTerm = NULL
  
		INSERT INTO Quotation(
			Folio,
			[Version],
			Id_Customer_Bill_To,
			Id_Customer_Type_Bill_To,
			Id_Country_Bill_To,
			Id_Customer_Final,
			Id_Customer_Type_Final,
			Id_Country_Final,
			Id_Voltage,
			Id_Language,
			Id_Plug,
			Id_Incoterm,
			Id_Currency,
			Id_Exchange_Rate,
			Id_Sales_Type,
			Id_Price_List,
			Id_Validity_Price,
			Id_Quotation_Status,
			Id_Language_Translation,
			Id_Payment_Term,
			Sales_Executive,
			Creation_Date,
			SPR_Number,
			Purchase_Order,
			Comments,
			Modify_By,
			Modify_Date,
			Modify_IP)

		VALUES(
			@piFolio,
			@piVersion,
			@pvIdCustomerBillTo,
			@pvIdCustomerTypeBillTo,
			@pvIdCountryBillTo,
			@pvIdCustomerFinal,
			@pvIdCustomerTypeFinal,
			@pvIdCountryFinal,
			@pvIdVoltage,
			@pvIdLanguage,
			@pvIdPlug,
			@pvIdIncoterm,
			@pvIdCurrency,
			@piIdExchangeRate,
			@pvIdSalesType,
			@pvIdPriceList,
			@pvIdValidityPrice,
			@pvIdQuotationStatus,
			@pvIdLanguageTranslation,
			@pvIdPaymentTerm,
			@pvIdSalesExecutive,
			GETDATE(),
			@pvSPRNumber,
			@piPurchaseOrder,
			@pvComments,			
			@pvUser,
			GETDATE(),
			@pvIP)

	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
			Folio,
			[Version],
			Id_Customer_Bill_To,
			Customer_Bill_To,
			Id_Customer_Type_Bill_To,
			Customer_Type_Bill_To,
			Id_Country_Bill_To,
			Country_Bill_To,
			Id_Customer_Final,
			Customer_Final,
			Id_Customer_Type_Final,
			Customer_Type_Final,
			Id_Country_Final,
			Country_Final,
			Id_Voltage,
			Voltage_Desc,
			Id_Language,
			Language_Desc,
			Id_Plug,
			Plug_Desc,
			Id_Incoterm,
			Incoterm_Desc,
			Id_Currency,
			Currency_Desc,
			Id_Exchange_Rate,
			Exchange_Rate,
			Id_Sales_Type,
			Sales_Type_Desc,
			Id_Price_List,
			Price_List_Desc,
			Id_Validity_Price,
			Validity_Price_Desc,
			Id_Quotation_Status,
			Quotation_Status_Desc,
			Id_Language_Translation, 
			Language_Translation_Desc, 
			Id_Payment_Terms,
			Payment_Terms_Desc,
			Id_Sales_Executive,
			Sales_Executive,
			Creation_Date,
			SPR_Number,
			Purchase_Order,
			Comments,

			Next_Approver = (CASE WHEN Id_Quotation_Status = 'DIRE' THEN ''
            ELSE
            (ISNULL((	SELECT DISTINCT Role_Desc 
									FROM vwWorkflows  AWF
									WHERE AWF.Folio = vwQuotation.Folio  AND AWF.[Version] = vwQuotation.[Version] AND Id_Approval_Status = 'PTA' 
									AND AWF.Approval_Flow_Sequence = (	SELECT MIN(Approval_Flow_Sequence)	
																		FROM vwWorkflows 
																		WHERE  Folio = vwQuotation.Folio AND [Version] = vwQuotation.[Version]  AND Id_Approval_Status = 'PTA' 
																	 )
							     ), ''))
            END
                            ),

			Rejected_Approver =ISNULL((	SELECT DISTINCT Role_Desc 
									FROM vwWorkflows  AWF
									WHERE AWF.Folio = vwQuotation.Folio  AND AWF.[Version] = vwQuotation.[Version] AND Id_Approval_Status = 'REJ'
									AND AWF.Approval_Flow_Sequence = (	SELECT MIN(Approval_Flow_Sequence)	
																		FROM vwWorkflows 
																		WHERE  Folio = vwQuotation.Folio AND [Version] = vwQuotation.[Version]  AND Id_Approval_Status = 'REJ' 
																	 )
							     ), ''),
			Modify_By,
			Modify_Date,
			Modify_IP
		
		FROM [fnQuotation](@pvIdLanguageUser) AS vwQuotation
		WHERE	(@piFolio					= 0		OR Folio						= @piFolio) AND 
				(@piVersion					= 0		OR [Version]					= @piVersion) AND 
				(@pvIdCustomerBillTo		= 0		OR Id_Customer_Bill_To			= @pvIdCustomerBillTo) AND
				(@pvIdCustomerTypeBillTo	= ''	OR Id_Customer_Type_Bill_To		= @pvIdCustomerTypeBillTo) AND
				(@pvIdCountryBillTo			= ''	OR Id_Country_Bill_To			= @pvIdCountryBillTo  ) AND 
				(@pvIdCustomerFinal			= 0		OR Id_Customer_Final			= @pvIdCustomerFinal) AND
				(@pvIdCustomerTypeFinal		= ''	OR Id_Customer_Type_Final		= @pvIdCustomerTypeFinal) AND
				(@pvIdCountryFinal			= ''	OR Id_Country_Final				= @pvIdCountryFinal) AND 
				(@pvIdVoltage				= ''	OR Id_Voltage					= @pvIdVoltage) AND   
				(@pvIdLanguage				= ''	OR Id_Language					= @pvIdLanguage) AND   
				(@pvIdPlug					= ''	OR Id_Plug						= @pvIdPlug) AND   
				(@pvIdIncoterm				= ''	OR Id_Incoterm					= @pvIdIncoterm) AND   
				(@pvIdCurrency				= ''	OR Id_Currency					= @pvIdCurrency) AND   
				(@piIdExchangeRate			= 0		OR Id_Exchange_Rate				= @piIdExchangeRate) AND   
				(@pvIdSalesType				= ''	OR Id_Sales_Type				= @pvIdSalesType) AND   
				(@pvIdPriceList				= ''	OR Id_Price_List				= @pvIdPriceList) AND   
				(@pvIdValidityPrice			= ''	OR Id_Validity_Price			= @pvIdValidityPrice) AND   
				(@pvIdQuotationStatus		= ''	OR Id_Quotation_Status			= @pvIdQuotationStatus) AND   
				(@pvIdLanguageTranslation	= ''	OR Id_Language_Translation		= @pvIdLanguageTranslation) AND   
				(@pvIdPaymentTerm			= ''	OR Id_Payment_Terms				= @pvIdPaymentTerm) AND   
				(@pvIdSalesExecutive		= ''	OR @pvIdSalesExecutive			= 'ADMIN'		OR Id_Sales_Executive			= @pvIdSalesExecutive) AND  
				(@pvSPRNumber				= '0'	OR SPR_Number					LIKE '%' +  CAST(@pvSPRNumber AS VARCHAR) + '%') AND   
				(@piPurchaseOrder			= 0		OR Purchase_Order				LIKE '%' +  CAST(@piPurchaseOrder AS VARCHAR) + '%') AND 
				--Additional search parameters
				(@pvCustomerBillTo			= ''	OR Customer_Bill_To				LIKE '%' +  @pvCustomerBillTo + '%') AND 
				(@pvSalesExecutive			= ''	OR Sales_Executive				LIKE '%' +  @pvSalesExecutive + '%') AND 
				(@pvCreationDateIni			= ''	OR CONVERT(VARCHAR(8), Creation_Date,112) >= @pvCreationDateIni) AND
				(@pvCreationDateFin			= ''	OR CONVERT(VARCHAR(8), Creation_Date,112) <= @pvCreationDateFin)  

		ORDER BY  Folio DESC, [Version] 
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
IF @pvOptionCRUD = 'U'
	BEGIN

		IF @pvIdQuotationStatus <> ''
		BEGIN
			--------------------------------------------------------------------------
			IF @pvIdQuotationStatus = 'SENT'
			BEGIN
				UPDATE Quotation
				SET Id_Quotation_Status = @pvIdQuotationStatus,
					Creation_Date		= GETDATE(),
					Modify_By			= @pvUser,
					Modify_Date			= GETDATE(),
					Modify_IP			= @pvIP
				WHERE Folio = @piFolio AND [Version] = @piVersion
			END
			ELSE
			BEGIN
				UPDATE Quotation
				SET Id_Quotation_Status = @pvIdQuotationStatus,
					Modify_By			= @pvUser,
					Modify_Date			= GETDATE(),
					Modify_IP			= @pvIP
				WHERE Folio = @piFolio AND [Version] = @piVersion
			END

			--------------------------------------------------------------------------
			--	Insert Notification
			--------------------------------------------------------------------------
			-- Get Previous Status
			DECLARE @pvIdQuotationStatusPrevious VARCHAR(10) = (SELECT Id_Quotation_Status 
																FROM Quotation_Log 
																WHERE Id_Quotation_Log = (SELECT MAX(Id_Quotation_Log) FROM Quotation_Log WHERE Folio = @piFolio AND [Version] = @piVersion))

			----1. Quotation Send to Client
			IF @pvIdQuotationStatus = 'SENT' 
				EXEC spNotification_Quotation_Status_CRUD_Records @pvOptionCRUD = 'C',  @piIdNotification = 1, @piFolio =  @piFolio , @piVersion = @piVersion, @pvUser = @pvUser

			----2. Quotation Approved 
			IF @pvIdQuotationStatus = 'SENT' 
			BEGIN
				IF @pvIdQuotationStatusPrevious = 'ROUT'
				EXEC spNotification_Quotation_Status_CRUD_Records @pvOptionCRUD = 'C',  @piIdNotification = 2, @piFolio =  @piFolio , @piVersion = @piVersion, @pvUser = @pvUser
			END
			----3. Quotation Rejected
			IF @pvIdQuotationStatus = 'DIRE' -- 
				EXEC spNotification_Quotation_Status_CRUD_Records @pvOptionCRUD = 'C',  @piIdNotification = 3, @piFolio =  @piFolio , @piVersion = @piVersion, @pvUser = @pvUser
		
		END

		
			
		

		IF @piPurchaseOrder <> 0
		BEGIN
			UPDATE Quotation
			SET Purchase_Order		= @piPurchaseOrder,
				Modify_By			= @pvUser,
				Modify_Date			= GETDATE(),
				Modify_IP			= @pvIP
			WHERE Folio = @piFolio AND [Version] = @piVersion
		END

		IF @pvSPRNumber <> '0'
		BEGIN
			UPDATE Quotation
			SET 
				SPR_Number 			= @pvSPRNumber,
				Modify_By			= @pvUser,
				Modify_Date			= GETDATE(),
				Modify_IP			= @pvIP				
			WHERE Folio = @piFolio AND [Version] = @piVersion		
		END	
		

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


	-------------------------------------------------------------------- 
	--Register Quotation Log
	--------------------------------------------------------------------
	IF @pvOptionCRUD <> 'R'
	BEGIN
		EXEC spQuotation_Log_CRUD_Records @pvOptionCRUD = @pvOptionCRUD, @piFolio =@piFolio , @piVersion = @piVersion, @pvIdQuotationStatus = @pvIdQuotationStatus, @pvUser = @pvUser

		SET NOCOUNT OFF

		SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog, Folio = @piFolio, [Version] = @piVersion
	END
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
		SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog, Folio = @piFolio, [Version] = @piVersion
		
END CATCH
