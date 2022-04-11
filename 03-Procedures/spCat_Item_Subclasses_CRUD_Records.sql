USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Item_Subclasses_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Item_Subclasses_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Item_Subclasses_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Item_Subclasses_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Item_Subclasses | Create - Read - Upadate - Delete 
Date:		08/01/2021
Example:
			spCat_Item_Subclasses_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdItemClass = 'COMP' , @pvIdItemSubClass = 'AZR', @pvShortDesc = 'SUB CLAS AZR' , @pvLongDesc = 'SUB CLAS AZR LONG', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Item_Subclasses_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdItemClass = 'COMP' , @pvIdItemSubClass = 'AZR' 
			spCat_Item_Subclasses_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdItemClass = 'COMP' , @pvIdItemSubClass = 'AZR', @pvShortDesc = 'SUB CLAS AZR' , @pvLongDesc = 'SUB CLAS AZR LONG', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Item_Subclasses_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvIdItemClass = 'COMP' , @pvIdItemSubClass = 'AZR', @pvShortDesc = 'SUB CLAS AZR' , @pvLongDesc = 'SUB CLAS AZR LONG', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Item_Subclasses_CRUD_Records @pvOptionCRUD = 'X', @pvIdLanguageUser = 'ANG', @pvIdItemClass = 'COMP' , @pvIdItemSubClass = 'AZR', @pvShortDesc = 'SUB CLAS AZR' , @pvLongDesc = 'SUB CLAS AZR LONG', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

			spCat_Item_Subclasses_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdItemClass = 'XXX' , @pvIdItemSubClass = 'AZR', @pvShortDesc = 'SUB CLAS AZR' , @pvLongDesc = 'SUB CLAS AZR LONG', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Item_Subclasses_CRUD_Records @pvOptionCRUD = 'R'
			spCat_Item_Subclasses_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdItemClass = 'COMP'
			spCat_Item_Subclasses_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdItemClass = 'COMP' , @pvIdItemSubClass = 'BRAKE' 

*/
CREATE PROCEDURE [dbo].spCat_Item_Subclasses_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@pvIdItemClass		Varchar(10) = '',
@pvIdItemSubClass	Varchar(10) = '',
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_Item_Subclasses - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Item_Subclasses_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdItemClass = '" + ISNULL(@pvIdItemClass,'NULL') + "', @pvIdItemSubClass = '" + ISNULL(@pvIdItemSubClass,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Item_Subclasses WHERE Id_Item_Class = @pvIdItemClass and Id_Item_SubClass= @pvIdItemSubClass)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Cat_Item_Subclasses(
				Id_Item_Class,
				Id_Item_SubClass,
				Short_Desc,
				Long_Desc,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdItemClass,
				@pvIdItemSubClass,
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
		ISC.Id_Item_Class,
		Item_Class_Desc = IC.Short_Desc,
		ISC.Id_Item_SubClass,
		ISC.Short_Desc,
		ISC.Long_Desc,
		ISC.[Status],
		ISC.Modify_Date,
		ISC.Modify_By,
		ISC.Modify_IP
		FROM Cat_Item_Subclasses ISC WITH(NOLOCK)
		
		INNER JOIN Cat_Item_Classes IC WITH(NOLOCK) ON 
		ISC.Id_Item_Class = IC.Id_Item_Class
		
		WHERE
		(@pvIdItemClass = '' OR ISC.Id_Item_Class = @pvIdItemClass ) AND
		(@pvIdItemSubClass = '' OR ISC.Id_Item_SubClass = @pvIdItemSubClass)
		
		ORDER BY ISC.Id_Item_Class, ISC.Id_Item_SubClass
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Item_Subclasses 
		SET Short_Desc	= @pvShortDesc,
			Long_Desc	= @pvLongDesc,
			[Status]	= @pbStatus,
			Modify_Date	= GETDATE(),
			Modify_By	= @pvUser,
			Modify_IP	= @pvIP
		WHERE Id_Item_Class = @pvIdItemClass and Id_Item_SubClass= @pvIdItemSubClass
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
