USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Validity_Prices_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Validity_Prices_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Validity_Prices_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Validity_Prices_CRUD_Records
GO
/*
Autor:		Alejandro Zepeda
Desc:		Cat_Validity_Prices | Create - Read - Upadate - Delete 
Date:		15/03/2021
Example:
			spCat_Validity_Prices_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdValidityPrice = 'P1' , @pvShortDesc = 'ValidityPrice Record 1', @pvLongDesc = 'ValidityPrice Record 1 Long Desd', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Validity_Prices_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'SPA'
			spCat_Validity_Prices_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdValidityPrice = 'P1' 
			spCat_Validity_Prices_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdValidityPrice = 'P1' , @pvShortDesc = 'ValidityPrice Record 1', @pvLongDesc = 'ValidityPrice Record 1 Long Desc', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Validity_Prices_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvIdValidityPrice = 'P1' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Validity_Prices_CRUD_Records @pvOptionCRUD = 'X', @pvIdLanguageUser = 'ANG', @pvIdValidityPrice = 'P1' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
*/
CREATE PROCEDURE [dbo].spCat_Validity_Prices_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@pvIdValidityPrice	Varchar(10) = '',
@pvShortDesc		Varchar(50) = '',
@pvLongDesc			Varchar(255)= '',
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_Validity_Prices - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Validity_Prices_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdValidityPrice = '" + ISNULL(@pvIdValidityPrice,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Validity_Prices WHERE Id_Validity_Price = @pvIdValidityPrice AND Id_Language =  @pvIdLanguageUser)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don�t Exists
		BEGIN
			INSERT INTO Cat_Validity_Prices(
				Id_Language,
				Id_Validity_Price,
				Short_Desc,
				Long_Desc,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdLanguageUser,
				@pvIdValidityPrice,
				@pvShortDesc,
				@pvLongDesc,
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
		A.Id_Language,
		Desc_Language  = L.Short_Desc,
		Id_Catalog = A.Id_Validity_Price,
		A.Short_Desc,
		A.Long_Desc,
		A.[Status],
		A.Modify_Date,
		A.Modify_By,
		A.Modify_IP
		FROM Cat_Validity_Prices A

		INNER JOIN Cat_Languages L ON 
		A.Id_Language = L.Id_Language AND
		A.Id_Language = L.Id_Language_Translation

		WHERE 
		(@pvIdLanguageUser = ''  OR L.Id_Language = @pvIdLanguageUser) AND  
		(@pvIdValidityPrice = '' OR Id_Validity_Price = @pvIdValidityPrice)
		ORDER BY A.Id_Language, Id_Catalog
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Validity_Prices 
		SET Short_Desc	= @pvShortDesc,
			Long_Desc	= @pvLongDesc,
			[Status]	= @pbStatus,
			Modify_Date	= GETDATE(),
			Modify_By	= @pvUser,
			Modify_IP	= @pvIP
		WHERE Id_Validity_Price = @pvIdValidityPrice
		AND Id_Language = @pvIdLanguageUser

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
