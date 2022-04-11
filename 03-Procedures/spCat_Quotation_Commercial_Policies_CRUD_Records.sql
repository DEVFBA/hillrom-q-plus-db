USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Quotation_Commercial_Policies_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Quotation_Commercial_Policies_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Quotation_Commercial_Policies_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Quotation_Commercial_Policies_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Quotation_Commercial_Policies | Create - Read - Upadate - Delete 
Date:		05/01/2021
Example:
			spCat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX' , @pvIdSalesType = 'DIRSA', @pvIdIncoterm = 'EXW', @pvIdCurrency = 'USD', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG'
			spCat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX'
			spCat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX', @pvIdSalesType = 'DISSA' 
			spCat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX', @pvIdSalesType = 'DISSA', @pvIdIncoterm = 'EXW'
			spCat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX', @pvIdSalesType = 'DIRSA', @pvIdIncoterm = 'EXW', @pvIdCurrency = 'USD'

			spCat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX' , @pvIdSalesType = 'DIRSA', @pvIdIncoterm = 'EXW', @pvIdCurrency = 'USD', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			
			spCat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX', @pvIdSalesType = 'DIRSA', @pvIdIncoterm = 'EXW', @pvIdCurrency = 'USD'

			
			
*/
CREATE PROCEDURE [dbo].spCat_Quotation_Commercial_Policies_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = 'ANG',
@pvIdCountry		Varchar(10) = '',
@pvIdSalesType		Varchar(10) = '',
@pvIdIncoterm		Varchar(10) = '',
@pvIdCurrency		Varchar(10) = '',
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_Quotation_Commercial_Policies - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Quotation_Commercial_Policies_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL') + "', @pvIdSalesType = '" + ISNULL(@pvIdSalesType,'NULL') + "', @pvIdIncoterm = '" + ISNULL(@pvIdIncoterm,'NULL') + "', @pvIdCurrency = '" + ISNULL(@pvIdCurrency,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Quotation_Commercial_Policies WHERE Id_Country = @pvIdCountry and Id_Sales_Type= @pvIdSalesType AND Id_Incoterm = @pvIdIncoterm AND Id_Currency = @pvIdCurrency)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Cat_Quotation_Commercial_Policies(
				Id_Country,
				Id_Sales_Type,
				Id_Incoterm,
				Id_Currency,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdCountry,
				@pvIdSalesType,
				@pvIdIncoterm,
				@pvIdCurrency,
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
		ST.Id_Language,

		CST.Id_Country,
		Country_Desc = C.Short_Desc,

		CST.Id_Sales_Type,
		Sales_Type_Desc = ST.Short_Desc,

		CST.Id_Incoterm,
		Incoterm_Desc = I.Short_Desc,

		CST.Id_Currency,
		Currency_Desc = CR.Short_Desc,

		CST.[Status],
		CST.Modify_Date,
		CST.Modify_By,
		CST.Modify_IP
		FROM Cat_Quotation_Commercial_Policies CST WITH(NOLOCK)
		
		INNER JOIN Cat_Countries C WITH(NOLOCK) ON 
		CST.Id_Country = C.Id_Country
		
		INNER JOIN Cat_Sales_Types ST WITH(NOLOCK) ON 
		CST.Id_Sales_Type = ST.Id_Sales_Type AND
		ST.Id_Language = @pvIdLanguageUser

		INNER JOIN Cat_Incoterm  I WITH(NOLOCK) ON 
		CST.Id_Incoterm = I.Id_Incoterm AND
		I.Id_Language = @pvIdLanguageUser
		
		INNER JOIN Cat_Currencies CR WITH(NOLOCK) ON 
		CST.Id_Currency = CR.Id_Currency AND
		CR.Id_Language = @pvIdLanguageUser

		WHERE (@pvIdCountry = '' OR CST.Id_Country = @pvIdCountry) AND
			  (@pvIdSalesType = '' OR CST.Id_Sales_Type = @pvIdSalesType) AND
			  (@pvIdIncoterm = '' OR CST.Id_Incoterm = @pvIdIncoterm) AND
			  (@pvIdCurrency = '' OR CST.Id_Currency = @pvIdCurrency)
		ORDER BY CST.Id_Country, CST.Id_Sales_Type, CST.Id_Incoterm, CST.Id_Currency		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Quotation_Commercial_Policies 
		SET [Status]	= @pbStatus,
			Modify_Date	= GETDATE(),
			Modify_By	= @pvUser,
			Modify_IP	= @pvIP
		WHERE Id_Country = @pvIdCountry AND Id_Sales_Type = @pvIdSalesType
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
