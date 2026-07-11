USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Discount_Categories_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Discount_Categories_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Discount_Categories_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Discount_Categories_CRUD_Records
GO
/*
Autor:		Alejandro Zepeda
Desc:		Cat_Discount_Categories | Create - Read - Upadate - Delete 
Date:		20/02/2021
Example:
			spCat_Discount_Categories_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdDiscountCategory = 'DiscountCategory' , @pvShortDesc = 'DiscountCategory Record 1', @pvLongDesc = 'DiscountCategory Record 1 Long Desd', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254', @pvIdBusinessLine = 'PSSLIKO'
			spCat_Discount_Categories_CRUD_Records @pvOptionCRUD = 'R'
			spCat_Discount_Categories_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdDiscountCategory = 'DiscountCategory' 
			spCat_Discount_Categories_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdDiscountCategory = 'DiscountCategory', @pvIdBusinessLine = 'PSSLIKO'
			spCat_Discount_Categories_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdDiscountCategory = 'DiscountCategory' , @pvShortDesc = 'DiscountCategory Record 1', @pvLongDesc = 'DiscountCategory Record 1 Long Desc', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Discount_Categories_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvIdDiscountCategory = 'DiscountCategory' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Discount_Categories_CRUD_Records @pvOptionCRUD = 'X', @pvIdLanguageUser = 'ANG', @pvIdDiscountCategory = 'DiscountCategory' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
*/
CREATE PROCEDURE [dbo].spCat_Discount_Categories_CRUD_Records
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10) = '',
@pvIdDiscountCategory	Varchar(10) = '',
@pvShortDesc			Varchar(50) = '',
@pvLongDesc				Varchar(255)= '',
@pbStatus				Bit			= '',
@pvUser					Varchar(50) = '',
@pvIP					Varchar(20) = '',
@pvIdBusinessLine		Varchar(10) = ''
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_Discount_Categories - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Discount_Categories_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdDiscountCategory = '" + ISNULL(@pvIdDiscountCategory,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Discount_Categories WHERE Id_Discount_Category = @pvIdDiscountCategory)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Cat_Discount_Categories(
				Id_Discount_Category,
				Short_Desc,
				Long_Desc,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP,
				Id_Business_Line)
			VALUES (
				@pvIdDiscountCategory,
				@pvShortDesc,
				@pvLongDesc,
				@pbStatus,
				GETDATE(),
				@pvUser,
				@pvIP,
				@pvIdBusinessLine)
		END
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
		Id_Catalog				= CDC.Id_Discount_Category,
		CDC.Short_Desc,
		CDC.Long_Desc,
		Business_Line_Id		= CDC.Id_Business_Line,
		Business_Line_Desc		= CBL.Short_Desc,
		CDC.[Status],
		CDC.Modify_Date,
		CDC.Modify_By,
		CDC.Modify_IP
		FROM Cat_Discount_Categories AS CDC INNER JOIN Cat_Business_Line AS CBL ON
											CDC.Id_Business_Line = CBL.Id_Business_Line
		WHERE (@pvIdDiscountCategory = '' OR CDC.Id_Discount_Category = @pvIdDiscountCategory) AND
			  (@pvIdBusinessLine = '' OR CDC.Id_Business_Line = @pvIdBusinessLine)
		ORDER BY Id_Catalog
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Discount_Categories 
		SET Short_Desc			= @pvShortDesc,
			Long_Desc			= @pvLongDesc,
			[Status]			= @pbStatus,
			Modify_Date			= GETDATE(),
			Modify_By			= @pvUser,
			Modify_IP			= @pvIP,
			Id_Business_Line	= @pvIdBusinessLine
		WHERE Id_Discount_Category = @pvIdDiscountCategory
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
