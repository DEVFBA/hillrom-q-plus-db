USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Countries_Commissions_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Countries_Commissions_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Countries_Commissions_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Countries_Commissions_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Countries_Commissions | Create - Read - Upadate - Delete 
Date:		31/12/2020
Example:
			spCat_Countries_Commissions_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX' , @pvShortDesc = 'Installation', @pvLongDesc = 'Installation 2', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Countries_Commissions_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'SPA', @pvIdCountry = 'MX' , @pvShortDesc = 'Instalacion', @pvLongDesc = 'Instalacion', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Countries_Commissions_CRUD_Records @pvOptionCRUD = 'R'
			spCat_Countries_Commissions_CRUD_Records @pvOptionCRUD = 'R', @pvIdCountry = 'MX'
			spCat_Countries_Commissions_CRUD_Records @pvOptionCRUD = 'R', @pvIdCountry = 'MX' , @piIdCommission = 1 
			spCat_Countries_Commissions_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'SPA', @pvIdCountry = 'MX' ,  @piIdCommission = 1, @pvShortDesc = 'Installation', @pvLongDesc = 'Installation', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Countries_Commissions_CRUD_Records @pvOptionCRUD = 'D'
			select * from Cat_Countries_Commissions
			 
*/
CREATE PROCEDURE [dbo].spCat_Countries_Commissions_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@pvIdCountry		Varchar(10) = '',
@piIdCommission		Smallint	= 0,
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_Countries_Commissions - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Countries_Commissions_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL') + "', @piIdCommission = '" + ISNULL(CAST(@piIdCommission AS VARCHAR),'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Countries_Commissions WHERE Id_Country = @pvIdCountry AND Short_Desc = @pvShortDesc )
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END		
		ELSE -- Don´t Exists
		BEGIN
			SET @piIdCommission = (SELECT ISNULL(MAX(Id_Commission) + 1,1) FROM Cat_Countries_Commissions WHERE Id_Country = @pvIdCountry)
			INSERT INTO Cat_Countries_Commissions(
				Id_Country,
				Id_Language,
				Id_Commission,
				Short_Desc,
				Long_Desc,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdCountry,
				@pvIdLanguageUser,
				@piIdCommission,
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
		CC.Id_Country,
		Country_Desc = C.Short_Desc,
		CC.Id_Language,
		Desc_Language = L.Short_Desc,
		Id_Catalog = CC.Id_Commission,
		CC.Short_Desc,
		CC.Long_Desc,
		CC.[Status],
		CC.Modify_Date,
		CC.Modify_By,
		CC.Modify_IP
		FROM Cat_Countries_Commissions CC WITH(NOLOCK)
		
		INNER JOIN Cat_Countries C WITH(NOLOCK) ON 
		CC.Id_Country = C.Id_Country
		
		INNER JOIN Cat_Languages L WITH(NOLOCK) ON 
		CC.Id_Language = L.Id_Language  AND
		CC.Id_Language = L.Id_Language_Translation

		WHERE (@pvIdCountry = ''  OR CC.Id_Country = @pvIdCountry ) AND
		(@pvIdLanguageUser = '' OR  L.Id_Language = @pvIdLanguageUser) AND
		(@piIdCommission = 0 OR CC.Id_Commission = @piIdCommission) 
	--	AND (@pvIdLanguageUser = '' OR  L.Id_Language_Translation = @pvIdLanguageUser)

		ORDER BY CC.Id_Country, CC.Id_Language,Id_Catalog
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Countries_Commissions 
		SET 
			Short_Desc		= @pvShortDesc,
			Long_Desc		= @pvLongDesc,
			[Status]		= @pbStatus,			
			Modify_Date		= GETDATE(),
			Modify_By		= @pvUser,
			Modify_IP		= @pvIP
		WHERE Id_Country = @pvIdCountry AND Id_Language = @pvIdLanguageUser AND Id_Commission = @piIdCommission
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
