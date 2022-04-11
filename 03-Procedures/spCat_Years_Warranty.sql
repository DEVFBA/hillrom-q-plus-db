USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Years_Warranty
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Years_Warranty'

IF OBJECT_ID('[dbo].[spCat_Years_Warranty]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Years_Warranty
GO
/*
Autor:		Alejandro Zepeda
Desc:		Cat_Years_Warranty | Create - Read - Upadate - Delete 
Date:		10/06/2021
Example:
			spCat_Years_Warranty @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @piIdYearWarranty = 1,  @pvShortDesc = '1 year', @pvLongDesc = 'Extend Warranty 1 year', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Years_Warranty @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG'
			spCat_Years_Warranty @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piIdYearWarranty = 1
			spCat_Years_Warranty @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @piIdYearWarranty = 1,  @pvShortDesc = '1 Year', @pvLongDesc = 'Extend Warranty 1 year', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Years_Warranty @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @piIdYearWarranty = 1,  @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Years_Warranty @pvOptionCRUD = 'X', @pvIdLanguageUser = 'ANG', @piIdYearWarranty = 1,  @pvShortDesc = '1 year', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Years_Warranty  @pvOptionCRUD = 'R',@pvIdLanguageUser = 'ANG', @piIdYearWarranty = 0
			spCat_Years_Warranty  @pvOptionCRUD = 'R',@pvIdLanguageUser = 'ANG', 
*/
CREATE PROCEDURE [dbo].spCat_Years_Warranty
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@piIdYearWarranty	Smallint	= -1,
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_Years_Warranty - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	=  dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Years_Warranty @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piIdYearWarranty = " + ISNULL(CAST(@piIdYearWarranty AS VARCHAR),'NULL') + ", @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "',@pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Years_Warranty WHERE Id_Year_Warranty = @piIdYearWarranty AND Id_Language =  @pvIdLanguageUser)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Cat_Years_Warranty(
				Id_Language,
				Id_Year_Warranty,
				Short_Desc,
				Long_Desc,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdLanguageUser,
				@piIdYearWarranty,
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
		Id_Catalog = A.Id_Year_Warranty,
		A.Short_Desc,
		A.Long_Desc,
		A.[Status],
		A.Modify_Date,
		A.Modify_By,
		A.Modify_IP
		FROM Cat_Years_Warranty A

		INNER JOIN Cat_Languages L ON 
		A.Id_Language = L.Id_Language AND
		A.Id_Language = L.Id_Language_Translation

		WHERE 
		(@pvIdLanguageUser = ''  OR L.Id_Language = @pvIdLanguageUser) AND 
		(@piIdYearWarranty = -1 OR Id_Year_Warranty = @piIdYearWarranty)

		ORDER BY A.Id_Language,Id_Catalog
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Years_Warranty 
		SET Short_Desc	 = @pvShortDesc,
			Long_Desc	 = @pvLongDesc,
			[Status]	 = @pbStatus,
			Modify_Date	 = GETDATE(),
			Modify_By	 = @pvUser,
			Modify_IP	 = @pvIP
		WHERE Id_Year_Warranty = @piIdYearWarranty

		--Disable Extended Warranties  in the Cat_Extended_Warranties
		IF @pbStatus = 0 
		BEGIN
			UPDATE Cat_Extended_Warranties 
			SET [Status]	= @pbStatus,
				Modify_Date	= GETDATE(),
				Modify_By	= @pvUser,
				Modify_IP	= @pvIP
			WHERE Id_Year_Warranty = @piIdYearWarranty
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
