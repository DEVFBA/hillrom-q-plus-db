USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Families_Categories_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Families_Categories_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Families_Categories_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Families_Categories_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Families_Categories | Create - Read - Upadate - Delete 
Date:		08/01/2021
Example:
			spCat_Families_Categories_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdFamily = 'FRH' , @pvIdCategory = 'TRC', @pvIdLine = 'ACCETHE', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Families_Categories_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdFamily = 'FRH' , @pvIdCategory = 'TRC', @pvIdLine = 'ACCETHE'
			spCat_Families_Categories_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdFamily = 'FRH' , @pvIdCategory = 'TRC', @pvIdLine = 'ACCETHE', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Families_Categories_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvIdFamily = 'FRH' , @pvIdCategory = 'TRC', @pvIdLine = 'ACCETHE', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Families_Categories_CRUD_Records @pvOptionCRUD = 'X', @pvIdLanguageUser = 'ANG', @pvIdFamily = 'FRH' , @pvIdCategory = 'TRC', @pvIdLine = 'ACCETHE', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

			spCat_Families_Categories_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdFamily = 'ZZ' , @pvIdCategory = 'TRC', @pvIdLine = 'ACCETHE', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Families_Categories_CRUD_Records @pvOptionCRUD = 'R'
			spCat_Families_Categories_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdFamily = 'FRH'
			spCat_Families_Categories_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdFamily = 'FRH',  @pvIdCategory = 'MES'
*/
CREATE PROCEDURE [dbo].spCat_Families_Categories_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@pvIdFamily			Varchar(10) = '',
@pvIdCategory		Varchar(10) = '',
@pvIdLine			Varchar(10) = '',
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_Families_Categories - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Families_Categories_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdFamily = '" + ISNULL(@pvIdFamily,'NULL') + "', @pvIdCategory = '" + ISNULL(@pvIdCategory,'NULL') + "', @pvIdLine = '" + ISNULL(@pvIdLine,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Families_Categories WHERE Id_Family = @pvIdFamily and Id_Category= @pvIdCategory AND Id_Line = @pvIdLine)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Cat_Families_Categories(
				Id_Family,
				Id_Category,
				Id_Line,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdFamily,
				@pvIdCategory,
				@pvIdLine,
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
		FCL.Id_Family,
		Family_Desc = F.Short_Desc,
		FCL.Id_Category,
		Category_Desc = C.Short_Desc,
		FCL.Id_Line,
		Line_Desc = L.Short_Desc,
		FCL.[Status],
		FCL.Modify_Date,
		FCL.Modify_By,
		FCL.Modify_IP
		FROM Cat_Families_Categories FCL WITH(NOLOCK)
		
		INNER JOIN Cat_Families F WITH(NOLOCK) ON 
		FCL.Id_Family = F.Id_Family

		INNER JOIN Cat_Categories C WITH(NOLOCK) ON 
		FCL.Id_Category = C.Id_Category

		INNER JOIN Cat_Lines L WITH(NOLOCK) ON 
		FCL.Id_Line = L.Id_Line
			
		WHERE (@pvIdFamily	 = '' OR FCL.Id_Family = @pvIdFamily) AND
			  (@pvIdCategory = '' OR FCL.Id_Category = @pvIdCategory) AND
			  (@pvIdLine	 = '' OR FCL.Id_Line = @pvIdLine)
	
		ORDER BY FCL.Id_Family , FCL.Id_Category , FCL.Id_Line 
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Families_Categories 
		SET [Status]	= @pbStatus,
			Modify_Date	= GETDATE(),
			Modify_By	= @pvUser,
			Modify_IP	= @pvIP
		 WHERE Id_Family = @pvIdFamily and Id_Category= @pvIdCategory AND Id_Line = @pvIdLine
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
