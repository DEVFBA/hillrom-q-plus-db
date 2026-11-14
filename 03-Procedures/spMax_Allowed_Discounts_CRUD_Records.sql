USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spMax_Allowed_Discounts_CRUD_Records]    Script Date: 8/17/2026 1:04:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spMax_Allowed_Discounts_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spMax_Allowed_Discounts_CRUD_Records'

IF OBJECT_ID('[dbo].[spMax_Allowed_Discounts_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spMax_Allowed_Discounts_CRUD_Records
GO
/*
Autor:		Angel Gutierrez
Desc:		Max_Allowed_Discounts | Create - Read - Upadate - Delete 
Date:		29/08/2026
Example:

			EXEC spMax_Allowed_Discounts_CRUD_Records @pvOptionCRUD = 'R', @pvUser = 'ANGUTIERRE', @pvIP = 'TEST', @pvIdLanguageUser = 'ANG';
            EXEC spMax_Allowed_Discounts_CRUD_Records @pvOptionCRUD = 'R', @pvUser = 'ANGUTIERRE', @pvIP = 'TEST', @pvIdLanguageUser = 'ANG', @pvIdDiscountCategory = 'CENTU';
			EXEC spMax_Allowed_Discounts_CRUD_Records @pvOptionCRUD = 'R', @pvUser = 'ANGUTIERRE', @pvIP = 'TEST', @pvIdLanguageUser = 'ANG', @pvIdBusinessLine = 'PSSLIKO';
			EXEC spMax_Allowed_Discounts_CRUD_Records @pvOptionCRUD = 'R', @pvUser = 'ANGUTIERRE', @pvIP = 'TEST', @pvIdLanguageUser = 'ANG', @pvIdBusinessLine = 'PSSLIKO', @pvIdDiscountCategory = 'CENTU';

            EXEC spMax_Allowed_Discounts_CRUD_Records @pvOptionCRUD = 'C', @pvUser = 'ANGUTIERRE', @pvIP = 'TEST', @pvIdLanguageUser = 'ANG', @pvIdDiscountCategory = 'NA', @pfMaxAllowedDiscount = 30;

            EXEC spMax_Allowed_Discounts_CRUD_Records @pvOptionCRUD = 'U', @pvUser = 'ANGUTIERRE', @pvIP = 'TEST', @pvIdLanguageUser = 'ANG', @pvIdDiscountCategory = 'NA', @pfMaxAllowedDiscount = 40;

            EXEC spMax_Allowed_Discounts_CRUD_Records @pvOptionCRUD = 'D', @pvUser = 'ANGUTIERRE', @pvIP = 'TEST', @pvIdLanguageUser = 'ANG', @pvIdDiscountCategory = 'NA', @pfMaxAllowedDiscount = 40;

*/
CREATE PROCEDURE [dbo].[spMax_Allowed_Discounts_CRUD_Records]
@pvOptionCRUD		        Varchar(1),
@pvUser				        Varchar(50)     = '',
@pvIdDiscountCategory       Varchar(10)     = '',
@pfMaxAllowedDiscount       Float           = NULL,
@pvIp                       Varchar(20)     = '',
@pvIdLanguageUser           Varchar(10)		= 'ANG',
@pvIdBusinessLine			Varchar(10)		= ''
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
	DECLARE @vDescription	Varchar(255)	= 'Max_Allowed_Discounts - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	=  dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spMax_Allowed_Discounts_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') 
														+ "', @pvUser = '" + ISNULL(@pvUser,'NULL') 
                                                        + "', @pvIdDiscountCategory = '" + ISNULL(@pvIdDiscountCategory,'NULL') 
                                                        + "', @pfMaxAllowedDiscount = " + ISNULL(CAST(@pfMaxAllowedDiscount AS Varchar),'NULL')
														+ ", @pvIp = '" + ISNULL(@pvIp,'NULL')
														+ "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL')
														+ "', @pvIdBusinessLine = '" + ISNULL(@pvIdBusinessLine,'NULL')
														+ "'"

	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN

        PRINT 'Create Records';

        INSERT INTO Max_Allowed_Discounts 
        (
            Id_Discount_Category, 
            Max_Allowed_Discount, 
            Modify_By,
            Modify_IP,
            Modify_Date
        ) VALUES (
            @pvIdDiscountCategory,
            @pfMaxAllowedDiscount,
            @pvUser,
            @pvIp,
            GETDATE()
        ); 

	END

	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		
		PRINT 'Read Records';

        SELECT
            CDC.Id_Business_Line,
            CBL.Short_Desc AS BusinessLine,
			MAD.Id_Discount_Category,
            CDC.Short_Desc AS Discount_Category,
            MAD.Max_Allowed_Discount,
            MAD.Modify_By,
            MAD.Modify_IP,
            MAD.Modify_Date
        FROM Max_Allowed_Discounts AS MAD INNER JOIN Cat_Discount_Categories AS CDC ON
                                                MAD.Id_Discount_Category = CDC.Id_Discount_Category
										  INNER JOIN Cat_Business_Line AS CBL ON
												CDC.Id_Business_Line = CBL.Id_Business_Line
        WHERE 
                (@pvIdDiscountCategory = '' OR MAD.Id_Discount_Category = @pvIdDiscountCategory)
            AND (@pvIdBusinessLine = '' OR CDC.Id_Business_Line = @pvIdBusinessLine);
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN

        PRINT 'Update Records';

        UPDATE Max_Allowed_Discounts SET Max_Allowed_Discount = @pfMaxAllowedDiscount,
                                         Modify_By = @pvUser,
                                         Modify_IP = @pvIp,
                                         Modify_Date = GETDATE()
        WHERE Id_Discount_Category = @pvIdDiscountCategory;

	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D' OR @vDescOperationCRUD = 'N/A'
	BEGIN

        PRINT 'Delete Records';

        DELETE FROM Max_Allowed_Discounts
        WHERE Id_Discount_Category = @pvIdDiscountCategory;
	
	END

	--------------------------------------------------------------------
	--Get Records to Add
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'A'
	BEGIN
		
		PRINT 'Get Records to Add';

        SELECT
            CDC.Id_Discount_Category,
			CDC.Short_Desc AS Discount_Category,
			CDC.[Status],
			MAD.Max_Allowed_Discount
		FROM Cat_Discount_Categories AS CDC LEFT OUTER JOIN Max_Allowed_Discounts AS MAD ON
															CDC.Id_Discount_Category = MAD.Id_Discount_Category
		WHERE 
				MAD.Max_Allowed_Discount IS NULL
			AND CDC.[Status] = 1
			AND (@pvIdBusinessLine = '' OR CDC.Id_Business_Line = @pvIdBusinessLine);
		
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
	SET @vMessageType	= dbo.fnGetTransacMessages('ERR','ANG')	--Error	
	SET @vMessage		= dbo.fnGetTransacErrorBD()
	SET @bSuccessful	= 0 --Execution with errors
	EXEC spSecurity_Transaction_Log_Ins_Record	@pvDescription	= @vDescription, 
												@pvExecCommand	= @vExecCommand,
												@pbSuccessful	= @bSuccessful, 
												@pvMessagetType = @vMessageType, 
												@pvMessage		= @vMessage, 
												@pvUser			= @pvUser, 
												@pnIdTransacLog	= @nIdTransacLog OUTPUT

	SET @vMessage		= dbo.fnGetTransacMessages('Generic Error','ANG')
	SET NOCOUNT OFF
	SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog
		
END CATCH