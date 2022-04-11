USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spDiscounts_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spDiscounts_CRUD_Records'

IF OBJECT_ID('[dbo].[spDiscounts_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spDiscounts_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Approved_Discounts | Create - Read - Upadate - Delete 
Date:		06/03/2021
Example:
			spDiscounts_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdDiscountCategory = 'CENPR', @pvIdDiscountType = 'PERC', @pvIdZone = 'DNOL', @pvIdApprovalFlow = '1', @pfBottomLimit = 0, @pfUpperLimit = 1, @pbApplyAmount = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spDiscounts_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG'
			spDiscounts_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdDiscount = 73
			spDiscounts_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdDiscount = 73 , @pvIdDiscountCategory = 'CENPR', @pvIdDiscountType = 'PERC', @pvIdZone = 'DNOL', @pvIdApprovalFlow = '1', @pfBottomLimit = 0, @pfUpperLimit = 1, @pbApplyAmount = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spDiscounts_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvIdDiscount = 73 , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			
			
*/
CREATE PROCEDURE [dbo].spDiscounts_CRUD_Records
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10) = '',
@pvIdDiscount			Smallint	= 0,
@pvIdDiscountCategory	Varchar(10)	= '',
@pvIdDiscountType		Varchar(10) = '',
@pvIdZone				Varchar(10) = '',
@pvIdApprovalFlow		Smallint	= '',
@pfBottomLimit			Float		= 0,
@pfUpperLimit			Float		= 0,
@pbApplyAmount			Bit			= 0,
@pvUser					Varchar(50)	= '',
@pvIP					Varchar(20) = ''
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
	DECLARE @vDescription	Varchar(255)	= 'Approved_Discounts - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spDiscounts_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdDiscount = '" + ISNULL(CAST(@pvIdDiscount AS VARCHAR),'NULL') + "', @pvIdDiscountCategory = '" + ISNULL(@pvIdDiscountCategory,'NULL') + "', @pvIdDiscountType = '" + ISNULL(@pvIdDiscountType,'NULL') + "', @pvIdZone = '" + ISNULL(@pvIdZone,'NULL') + "', @pvIdApprovalFlow = '" + ISNULL(CAST(@pvIdApprovalFlow  AS VARCHAR),'NULL') + "', @pfBottomLimit = '" + ISNULL(CAST(@pfBottomLimit AS VARCHAR),'NULL') + "', @pfUpperLimit = '" + ISNULL(CAST(@pfUpperLimit AS VARCHAR),'NULL') + "', @pbApplyAmount = '" + ISNULL(CAST(@pbApplyAmount AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		SET @pvIdDiscount =  (SELECT ISNULL(MAX(Id_Discount),0) + 1  FROM Approved_Discounts)

		INSERT INTO Approved_Discounts(
			Id_Discount,
			Id_Discount_Category,
			Id_Discount_Type,
			Id_Zone,
			Id_Approval_Flow,
			Bottom_Limit,
			Upper_Limit,
			Apply_Amount,
			Modify_By,
			Modify_Date,
			Modify_IP)
		VALUES (
			@pvIdDiscount,
			@pvIdDiscountCategory,
			@pvIdDiscountType,
			@pvIdZone,
			@pvIdApprovalFlow,
			@pfBottomLimit,
			@pfUpperLimit,
			@pbApplyAmount,
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
			D.Id_Discount,
			D.Id_Discount_Category,
			Discount_Category_Desc = DC.Short_Desc,
			D.Id_Discount_Type,
			Discount_Type_Desc = DT.Short_Desc,
			D.Id_Zone,
			Zone_Desc = Z.Short_Desc,
			D.Id_Approval_Flow,
			Approval_Flow_Desc = AF.Short_Desc,
			D.Bottom_Limit,
			D.Upper_Limit,
			D.Apply_Amount,
			D.Modify_By,
			D.Modify_Date,
			D.Modify_IP	
		FROM Approved_Discounts D
		
		INNER JOIN Cat_Discount_Categories DC ON
		D.Id_Discount_Category = DC.Id_Discount_Category

		INNER JOIN Cat_Discount_Types DT ON
		D.Id_Discount_Type = DT.Id_Discount_Type

		INNER JOIN Cat_Zones Z ON 
		D.Id_Zone = Z.Id_Zone

		INNER JOIN Cat_Approvals_Flows AF ON
		D.Id_Approval_Flow = AF.Id_Approval_Flow

		WHERE @pvIdDiscount = 0 OR D.Id_Discount = @pvIdDiscount
		ORDER BY D.Id_Discount_Category, D.Id_Zone, D.Id_Approval_Flow, D.Id_Discount_Type

	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Approved_Discounts 
		SET 
			Id_Discount_Category	= @pvIdDiscountCategory,
			Id_Discount_Type		= @pvIdDiscountType,
			Id_Zone					= @pvIdZone,
			Id_Approval_Flow		= @pvIdApprovalFlow,
			Bottom_Limit			= @pfBottomLimit,
			Upper_Limit				= @pfUpperLimit,
			Apply_Amount			= @pbApplyAmount,
			Modify_Date				= GETDATE(),
			Modify_By				= @pvUser,
			Modify_IP				= @pvIP
		WHERE Id_Discount = @pvIdDiscount

	END


--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D' OR @vDescOperationCRUD = 'N/A'
	BEGIN
		DELETE Approved_Discounts WHERE Id_Discount = @pvIdDiscount 
	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @vDescOperationCRUD = 'N/A'
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
