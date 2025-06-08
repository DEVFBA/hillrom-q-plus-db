USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spApproved_Discounts_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spApproved_Discounts_CRUD_Records'

IF OBJECT_ID('[dbo].[spApproved_Discounts_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spApproved_Discounts_CRUD_Records
GO
/*
Autor:		Angel Gutiérrez
Desc:		Approved Discounts | Create - Read - Update - Delete 
Date:		06/03/25
Example:
		
		DECLARE  @udtApproved_Discounts	UDT_Approved_Discounts 

		INSERT INTO @udtApproved_Discounts (Id_Discount, Id_Discount_Category, Id_Discount_Type, Id_Zone, Id_Approval_Flow, Bottom_Limit, Upper_Limit, Apply_Amount, Approval_Group, Id_Language, Id_Sales_Type)
		VALUES(0, 'HR900', 'PERC', 'DCLMEXI', 21, 1, 100, 0, '', 'ANG', 'DIRSAd'),
			  (0, 'COMPELLA', 'PERC', 'DCLMEXI', 21, 2, 99, 0, '', 'ANG', 'DIRSA'),
	          (0, 'STRET', 'PERC', 'DCLMEXI', 19, 3, 50, 0, '', 'ANG', 'DISSA')

		EXEC spApproved_Discounts_CRUD_Records @pvOptionCRUD = 'C', @pudtApprovedDiscounts = @udtApproved_Discounts, @pvUser = 'ANGUTIERRE', @pvIP = '0.0.0.0';

		EXEC spApproved_Discounts_CRUD_Records	@pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdSalesType = '', @pvIdZone = '', @pvIdDiscountCategory = '', @piIdApprovalFlow = 0
		
		EXEC spApproved_Discounts_CRUD_Records	@pvOptionCRUD = 'U', @piIdDiscount = 206, @piIdApprovalFlow = 19, @pfBottomLimit = 1, @pfUpperLimit = 99;

		EXEC spApproved_Discounts_CRUD_Records	@pvOptionCRUD = 'D', @piIdApprovalFlow = 0	
*/

CREATE PROCEDURE [dbo].spApproved_Discounts_CRUD_Records
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10)		= '',
@pvUser					Varchar(50)		= '',
@pvIdSalesType			Varchar(10)		= '',
@pvIdZone				Varchar(10)		= '',
@pvIdDiscountCategory	Varchar(10)		= '',
@piIdApprovalFlow		Numeric			= 0,
@piIdDiscount			Smallint		= 0,
@pfBottomLimit			Float			= 0,
@pfUpperLimit			Float			= 0,
@pudtApprovedDiscounts	UDT_Approved_Discounts READONLY,
@pvIP					Varchar(20)		= ''
AS
SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Approved_Discounts - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
    DECLARE @vExecCommand	Varchar(Max)	= "EXEC spApproved_Discounts_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL')
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		
		DECLARE @idDiscount				SMALLINT
		DECLARE @idDiscountCategory		VARCHAR(10)
		DECLARE @idDiscountType			VARCHAR(10)
		DECLARE @idZone					VARCHAR(10)
		DECLARE @idApprovalFlow			SMALLINT
		DECLARE @bottomLimit			FLOAT
		DECLARE @upperLimit				FLOAT
		DECLARE @applyAmount			BIT
		DECLARE @approvalGroup			VARCHAR(20)
		DECLARE @idLanguage				VARCHAR(10)
		DECLARE @idSalesType			VARCHAR(10)

		DECLARE curApprovedDiscounts CURSOR FOR
		SELECT
			Id_Discount,
			Id_Discount_Category,
			Id_Discount_Type,
			Id_Zone,
			Id_Approval_Flow,
			Bottom_Limit,
			Upper_Limit,
			Apply_Amount,
			Approval_Group,
			Id_Language,
			Id_Sales_Type
		FROM @pudtApprovedDiscounts

		OPEN curApprovedDiscounts

		FETCH NEXT FROM curApprovedDiscounts
		INTO
			@idDiscount,
			@idDiscountCategory,
			@idDiscountType,
			@idZone,
			@idApprovalFlow,
			@bottomLimit,
			@upperLimit,
			@applyAmount,
			@approvalGroup,
			@idLanguage,
			@idSalesType

		WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE @nextIdDiscount Smallint
			SET @nextIdDiscount = (SELECT MAX(Id_Discount) FROM Approved_Discounts) + 1

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
				Modify_IP,
				Approval_Group,
				Id_Language,
				Id_Sales_Type
			) VALUES(
				@nextIdDiscount,
				@idDiscountCategory,
				@idDiscountType,
				@idZone,
				@idApprovalFlow,
				@bottomLimit,
				@upperLimit,
				@applyAmount,
				@pvUser,
				GETDATE(),
				@pvIP,
				@approvalGroup,
				@idLanguage,
				@idSalesType
			)

			FETCH NEXT FROM curApprovedDiscounts
			INTO
				@idDiscount,
				@idDiscountCategory,
				@idDiscountType,
				@idZone,
				@idApprovalFlow,
				@bottomLimit,
				@upperLimit,
				@applyAmount,
				@approvalGroup,
				@idLanguage,
				@idSalesType
		END

		CLOSE curApprovedDiscounts;
		DEALLOCATE curApprovedDiscounts;

	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
        SELECT
			AD.Id_Discount AS [Discount_Id],
            AD.Id_Approval_Flow AS [Approval_Flow_Id],
            AD.Id_Sales_Type AS [Sales_Type_Id],
            CST.Short_Desc AS [Sales_Type],
            AD.Id_Zone AS [Zone_Id],
            CZ.Short_Desc AS [Zone],
            AD.Id_Discount_Category [Discount_Category_Id],
            CDC.Short_Desc AS [Discount_Category],
            AD.Bottom_Limit AS [Bottom_Limit],
            AD.Upper_Limit AS [Upper_Limit],
            AD.Id_Approval_Flow [Approval_Flow_Id],
            CAF.Short_Desc AS [Approval_Flow]
        FROM Approved_Discounts AS AD INNER JOIN Cat_Zones AS CZ ON
                                            AD.Id_Zone = CZ.Id_Zone
                                      INNER JOIN Cat_Discount_Categories AS CDC ON
                                            AD.Id_Discount_Category = CDC.Id_Discount_Category
                                      INNER JOIN Cat_Approvals_Flows AS CAF ON
                                            AD.Id_Approval_Flow = CAF.Id_Approval_Flow
                                      INNER JOIN Cat_Sales_Types AS CST ON
                                            AD.Id_Sales_Type = CST.Id_Sales_Type
        WHERE 
				(@pvIdLanguageUser = '' OR CST.Id_Language = @pvIdLanguageUser)
			AND (@pvIdSalesType = '' OR AD.Id_Sales_Type = @pvIdSalesType)
			AND (@pvIdZone = '' OR AD.Id_Zone = @pvIdZone)
			AND (@pvIdDiscountCategory = '' OR AD.Id_Discount_Category = @pvIdDiscountCategory)
			AND (@piIdApprovalFlow = 0 OR AD.Id_Approval_Flow = @piIdApprovalFlow)
         ORDER BY
                [Sales_Type] ASC,
                [Zone] ASC,
                [Discount_Category] ASC,
                [Bottom_Limit] ASC
        RETURN
	END

	--------------------------------------------------------------------
	--Validate if Approval Exist or has an overlapped Limit
	--------------------------------------------------------------------

	IF @pvOptionCRUD = 'V'
	BEGIN
        SELECT
			AD.Id_Discount AS [Discount_Id],
            AD.Id_Approval_Flow AS [Approval_Flow_Id],
            AD.Id_Sales_Type AS [Sales_Type_Id],
            CST.Short_Desc AS [Sales_Type],
            AD.Id_Zone AS [Zone_Id],
            CZ.Short_Desc AS [Zone],
            AD.Id_Discount_Category [Discount_Category_Id],
            CDC.Short_Desc AS [Discount_Category],
            AD.Bottom_Limit AS [Bottom_Limit],
            AD.Upper_Limit AS [Upper_Limit],
            AD.Id_Approval_Flow [Approval_Flow_Id],
            CAF.Short_Desc AS [Approval_Flow]
        FROM Approved_Discounts AS AD INNER JOIN Cat_Zones AS CZ ON
                                            AD.Id_Zone = CZ.Id_Zone
                                      INNER JOIN Cat_Discount_Categories AS CDC ON
                                            AD.Id_Discount_Category = CDC.Id_Discount_Category
                                      INNER JOIN Cat_Approvals_Flows AS CAF ON
                                            AD.Id_Approval_Flow = CAF.Id_Approval_Flow
                                      INNER JOIN Cat_Sales_Types AS CST ON
                                            AD.Id_Sales_Type = CST.Id_Sales_Type
        WHERE 
				(@pvIdLanguageUser = '' OR CST.Id_Language = @pvIdLanguageUser)
			AND (@pvIdSalesType = '' OR AD.Id_Sales_Type = @pvIdSalesType)
			AND (@pvIdZone = '' OR AD.Id_Zone = @pvIdZone)
			AND (@pvIdDiscountCategory = '' OR AD.Id_Discount_Category = @pvIdDiscountCategory)
			AND ((Bottom_Limit < @pfBottomLimit AND Upper_Limit > @pfBottomLimit) OR (Bottom_Limit < @pfUpperLimit AND Upper_Limit > @pfUpperLimit))
         ORDER BY
                [Sales_Type] ASC,
                [Zone] ASC,
                [Discount_Category] ASC,
                [Bottom_Limit] ASC
        RETURN
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	
    IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Approved_Discounts 
		SET Id_Approval_Flow			= @piIdApprovalFlow,
			Bottom_Limit				= @pfBottomLimit,
			Upper_Limit					= @pfUpperLimit
		WHERE Id_Discount = @piIdDiscount
	END
    
	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D'
	BEGIN
		DELETE Approved_Discounts
		WHERE Id_Discount = @piIdDiscount
	END
	--------------------------------------------------------------------
	--Other Type
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
