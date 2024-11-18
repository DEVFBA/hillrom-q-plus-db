USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_Quotation_Copy_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_Quotation_Copy_Records'

IF OBJECT_ID('[dbo].[spQuotation_Quotation_Copy_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_Quotation_Copy_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		spQuotation Copy 
Date:		28/02/2021
Example:

	EXEC spQuotation_Quotation_Copy_Records @piFolio = 8, @piVersion = 3, @pvUser = 'RUGOMEZ', @pvIP ='192.168.1.254'
	EXEC spQuotation_Quotation_Copy_Records @piFolio = '580', @piVersion = '1', @pvUser = 'ANGUTIERRE', @pvIP = '187.190.161.230'
	EXEC spQuotation_Quotation_Copy_Records @piFolio = '620', @piVersion = '1', @pvUser = 'ANGUTIERRE', @pvIP = '189.203.204.248'
	 
*/
CREATE PROCEDURE [dbo].spQuotation_Quotation_Copy_Records
@pvIdLanguageUser		Varchar(10) = 'ANG',
@piFolio				Int			= 0,
@piVersion				Int			= 0,
@pvUser					Varchar(50) = '',
@pvIP					Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY 
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @pvOptionCRUD			Varchar(1)  = 'C'
	DECLARE @vDescOperationCRUD		Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vIdQuotationStatus		Varchar(10) = (SELECT Id_Quotation_Status FROM Quotation WHERE Folio = @piFolio AND [Version] = @piVersion )
	DECLARE @iFolioNew				Int 
	DECLARE @iVersionNew			Int 
	DECLARE @vIdQuotationStatusNew	Varchar(10) = 'DRAF'

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Quotation Copy - ' + @vDescOperationCRUD
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spQuotation_Quotation_Copy_Records @piFolio = '" + ISNULL(CAST(@piFolio AS VARCHAR),'NULL') + "', @piVersion = '" + ISNULL(CAST(@piVersion AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	
	
	--------------------------------------------------------------------
	--Create Copy of Records
	--------------------------------------------------------------------

		--------------------------------
		--Validations
		--------------------------------
		IF @vIdQuotationStatus IN ('SENT', 'ACCE', 'CURE', 'OUDA', 'CANC')
		BEGIN  -- New Folio & Version
			SET @iFolioNew		= (SELECT ISNULL(MAX(Folio) + 1 ,1) FROM Quotation)
			SET @iVersionNew	= 1
	
		END
		ELSE IF @vIdQuotationStatus = 'DIRE'
		BEGIN  -- Only New Version
			SET @iFolioNew		= @piFolio
			SET @iVersionNew	= (SELECT MAX([Version]) + 1 FROM Quotation WHERE Folio = @piFolio)
	
		END
		ELSE
		BEGIN 
				SET @bSuccessful	= 0
				SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
				SET @vMessage		= dbo.fnGetTransacMessages('WAR Q Sts Invalid', @pvIdLanguageUser)	

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

			SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog
			RETURN
		END

		--------------------------------
		--Insert Quotation
		--------------------------------
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

		SELECT 	@iFolioNew,
				@iVersionNew,
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
				@vIdQuotationStatusNew,
				Id_Language_Translation,
				Id_Payment_Term,
				Sales_Executive,
				Creation_Date		= GETDATE(),
				SPR_Number			= 0,
				Purchase_Order		= 0,
				Comments,
				@pvUser,
				GETDATE(),
				@pvIP
		FROM Quotation
		WHERE Folio	 = @piFolio AND [Version] = @piVersion
		
		--------------------------------
		--Insert  Header
		--------------------------------
		INSERT INTO Quotation_Header (
				Folio,
				[Version],
				Id_Header,
				Item_Template,
				Discount,
				Quantity,
				Allocation,
				Transfer_Price,
				Transport_Cost,
				Taxes,
				Landed_Cost,
				Local_Transport,
				[Services],
				Warehousing,
				Local_Cost,
				Final_Price,
				Total,
				Amount_Warranty,
				Id_Year_Warranty,
				Percentage_Warranty,
				General_Taxes_Percentage,
				General_Taxes_Total,
				General_Taxes_Warranty,
				Grand_Total,
				Margin,
				Item_SPR,
				Modify_By,
				Modify_Date,
				Modify_IP)


		SELECT 	
				@iFolioNew,
				@iVersionNew,
				QH.Id_Header,
				QH.Item_Template,
				QH.Discount,
				QH.Quantity,
				OC.Allocation,
				Transfer_Price		= 0,
				OC.Transport_Cost,
				OC.Taxes,
				Landed_Cost			= 0,
				OC.Local_Transport,
				OC.[Services],
				OC.Warehousing,
				Local_Cost			= 0,
				Final_Price			= 0,
				Total				= 0,
				Amount_Warranty		= 0,
				QH.Id_Year_Warranty,
				QH.Percentage_Warranty,
				General_Taxes_Percentage	= 0,
				General_Taxes_Total	= 0,
				General_Taxes_Warranty= 0,
				Grand_Total			= 0,
				Margin				= 0,
				Item_SPR			= NULL,
				@pvUser,
				GETDATE(),
				@pvIP
		FROM Quotation  Q
		
		INNER JOIN Quotation_Header QH ON
		Q.Folio		= QH.Folio AND
		Q.[Version] = QH.[Version]
		
		INNER JOIN Operation_Cost OC ON
		QH.Item_Template = OC.Id_Item ANd
		Q.Id_Country_Bill_To = OC.Id_Country

		WHERE Q.Folio	 = @piFolio AND Q.[Version] = @piVersion	

		--------------------------------
		--Insert Details
		--------------------------------
		INSERT INTO Quotation_Detail (
				Folio,
				[Version],
				Id_Header,
				Item_Template,
				Id_Detail,
				Id_Item,
				Quantity,
				Price,
				Standard_Cost,
				Modify_By,
				Modify_Date,
				Modify_IP)

		SELECT 	DISTINCT
				@iFolioNew,
				@iVersionNew,
				QD.Id_Header,
				QD.Item_Template,
				QD.Id_Detail,
				QD.Id_Item,
				QD.Quantity,
				IT.Price,
				IT.Standard_Cost,
				@pvUser,
				GETDATE(),
				@pvIP
		FROM Quotation  Q
		
		INNER JOIN Quotation_Detail QD ON
		Q.Folio		= QD.Folio AND
		Q.[Version] = QD.[Version]

		INNER JOIN Items_Templates IT ON
		QD.Item_Template = IT.Item_Template AND
		QD.Id_Item		 = IT.Id_Item AND
		Q.Id_Price_List  = IT.Id_Price_List AND 
		IT.DynamicField_IsDynamic = 0	-- 20240310 -- DynamicFields
	
		WHERE Q.Folio	 = @piFolio AND Q.[Version] = @piVersion	


	--------------------------------------------------------------------
	--Quotation Comissions
	--------------------------------------------------------------------
		INSERT INTO Quotation_Commissions (
				Folio,
				[Version],
				Id_Commission,
				[Percentage],
				Amount)
		
		SELECT 	@iFolioNew,
				@iVersionNew,
				Id_Commission,
				[Percentage],
				Amount
		FROM Quotation  Q
		
		INNER JOIN Quotation_Commissions QC ON
		Q.Folio		= QC.Folio AND
		Q.[Version] = QC.[Version]

		WHERE Q.Folio	 = @piFolio AND Q.[Version] = @piVersion	

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

	EXEC spQuotation_Log_CRUD_Records @pvOptionCRUD = @pvOptionCRUD, @piFolio =@iFolioNew , @piVersion = @iVersionNew, @pvIdQuotationStatus = @vIdQuotationStatusNew, @pvUser = @pvUser

	SET NOCOUNT OFF
	
	SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog, Folio = @iFolioNew, [Version] = @iVersionNew

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
	SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog, Folio = @iFolioNew, [Version] = @iVersionNew
		
END CATCH
