USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Incoterm_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Incoterm_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Incoterm_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Incoterm_CRUD_Records
GO
/*
Autor:		Alejandro Zepeda
Desc:		Cat_Incoterm | Create - Read - Upadate - Delete 
Date:		01/01/2021
Example:
			spCat_Incoterm_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser= 'ANG', @pvIdIncoterm = 'INC1' , @pvShortDesc = 'Incoterm Record 1', @pvLongDesc = 'Incoterm Record 1', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Incoterm_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser= 'ANG'
			spCat_Incoterm_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser= 'SPA', @pvIdIncoterm = 'INC1' 
			spCat_Incoterm_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser= 'ANG', @pvIdIncoterm = 'INC1' , @pvShortDesc = 'Incoterm Record 1', @pvLongDesc = 'Incoterm Record 1 Long desc', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Incoterm_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser= 'ANG', @pvIdIncoterm = 'INC1' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Incoterm_CRUD_Records @pvOptionCRUD = 'X', @pvIdLanguageUser= 'ANG', @pvIdIncoterm = 'INC1' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

			spCat_Incoterm_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser= 'ANG', @pvIdIncoterm = 'INC2' , @pvShortDesc = 'Incoterm Record 2', @pvLongDesc = 'Incoterm Record 2 Long desc', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Incoterm_CRUD_Records @pvOptionCRUD = 'R'
*/
CREATE PROCEDURE [dbo].spCat_Incoterm_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@pvIdIncoterm		Varchar(10) = '',
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
	DECLARE @iOrder				Int = (SELECT ISNULL(MAX([ORDER]), 0) + 10 FROM Cat_Incoterm WHERE 2=3 )

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Cat_Incoterm - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Incoterm_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdIncoterm = '" + ISNULL(@pvIdIncoterm,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Incoterm WHERE Id_Incoterm = @pvIdIncoterm AND Id_Language = @pvIdLanguageUser)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Cat_Incoterm(
				Id_Language, 
				Id_Incoterm,
				Short_Desc,
				Long_Desc,
				[Order],
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdLanguageUser,
				@pvIdIncoterm,
				@pvShortDesc,
				@pvLongDesc,
				@iOrder,
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
		Id_Catalog = A.Id_Incoterm,
		A.Short_Desc,
		A.Long_Desc,
		A.[Order],
		A.[Status],
		A.Modify_Date,
		A.Modify_By,
		A.Modify_IP
		FROM Cat_Incoterm A

		INNER JOIN Cat_Languages L ON 
		A.Id_Language = L.Id_Language AND
		A.Id_Language = L.Id_Language_Translation

		WHERE 
			(@pvIdLanguageUser	= '' OR L.Id_Language = @pvIdLanguageUser) AND 
			(@pvIdIncoterm		= '' OR Id_Incoterm = @pvIdIncoterm)
		ORDER BY [Order],Id_Catalog

	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Incoterm 
		SET Short_Desc	= @pvShortDesc,
			Long_Desc	= @pvLongDesc,
			[Status]	= @pbStatus,
			Modify_Date	= GETDATE(),
			Modify_By	= @pvUser,
			Modify_IP	= @pvIP
		WHERE Id_Incoterm = @pvIdIncoterm
		AND Id_Language = @pvIdLanguageUser

		IF @pbStatus = 0 
		BEGIN
			 --Disable Sales_Types in the Cat_Quotation_Commercial_Policies
			UPDATE Cat_Quotation_Commercial_Policies 
			SET [Status]	= @pbStatus,
				Modify_Date	= GETDATE(),
				Modify_By	= @pvUser,
				Modify_IP	= @pvIP
			WHERE Id_Incoterm = @pvIdIncoterm
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
