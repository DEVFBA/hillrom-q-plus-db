USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Families_Categories_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spItems_Configuration_CRUD_Records'

IF OBJECT_ID('[dbo].[spItems_Configuration_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spItems_Configuration_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Items_Configuration | Create - Read - Upadate - Delete 
Date:		21/01/2021
Example:

			DECLARE  @udtItemsConfiguration  UDT_Items_Configuration 

			INSERT INTO @udtItemsConfiguration
			SELECT * FROM Items_Configuration 
			WHERE Id_Item = 'X3' 

			EXEC spItems_Configuration_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdItem = 'X3', @pudtItemsConfiguration = @udtItemsConfiguration , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'			
			EXEC spItems_Configuration_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdItem = 'X3' 
			EXEC spItems_Configuration_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG'
			EXEC spItems_Configuration_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdItem = 'X3', @pudtItemsConfiguration = @udtItemsConfiguration , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spItems_Configuration_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvIdItem = 'X3' 
			EXEC spItems_Configuration_CRUD_Records @pvOptionCRUD = 'X', @pvIdLanguageUser = 'ANG', @pvIdItem = 'X3' 
*/
CREATE PROCEDURE [dbo].spItems_Configuration_CRUD_Records
@pvOptionCRUD				Varchar(1),
@pvIdLanguageUser			Varchar(10) = '',
@pvIdItem					Varchar(50) = '',
@pudtItemsConfiguration		UDT_Items_Configuration Readonly ,
@pvUser						Varchar(50) = '',
@pvIP						Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @iNumRegistros		Int = (SELECT COUNT(*) FROM @pudtItemsConfiguration)
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Items_Configuration - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spItems_Configuration_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdItem = '" + ISNULL(@pvIdItem,'NULL') + "', @pudtItemsConfiguration = '" + ISNULL(CAST(@iNumRegistros AS VARCHAR),'NULL') + " rows affected', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		DELETE Items_Configuration WHERE Id_Item = @pvIdItem

		INSERT INTO Items_Configuration(
			Id_Family,
			Id_Category,
			Id_Line,
			Id_Item,
			[Status],
			Modify_By,
			Modify_Date,
			Modify_IP)

		SELECT 
			Id_Family,
			Id_Category,
			Id_Line,
			Id_Item,
			[Status],
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtItemsConfiguration

		
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
		IC.Id_Item,
		Item_Desc =I.Long_Desc,
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
		FROM Items_Configuration IC WITH(NOLOCK) 

		INNER JOIN Cat_Item I  WITH(NOLOCK) ON		
		I.Id_Item = IC.Id_Item
		AND IC.Status = 1
		
		INNER JOIN Cat_Families_Categories FCL WITH(NOLOCK) ON
		IC.Id_Family = FCL.Id_Family AND 
		IC.Id_Category = FCL.Id_Category AND 
		IC.Id_Line = FCL.Id_Line
		AND FCL.Status = 1

		
		INNER JOIN Cat_Families F WITH(NOLOCK) ON 
		FCL.Id_Family = F.Id_Family
		AND F.Status = 1

		INNER JOIN Cat_Categories C WITH(NOLOCK) ON 
		FCL.Id_Category = C.Id_Category
		AND C.Status = 1

		INNER JOIN Cat_Lines L WITH(NOLOCK) ON 
		FCL.Id_Line = L.Id_Line
		AND L.Status = 1
			
		WHERE ('' = @pvIdItem ) OR IC.Id_Item = @pvIdItem

		ORDER BY FCL.Id_Family , FCL.Id_Category , FCL.Id_Line 

	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		DELETE Items_Configuration WHERE Id_Item = @pvIdItem

		INSERT INTO Items_Configuration(
			Id_Family,
			Id_Category,
			Id_Line,
			Id_Item,
			[Status],
			Modify_By,
			Modify_Date,
			Modify_IP)

		SELECT 
			Id_Family,
			Id_Category,
			Id_Line,
			Id_Item,
			[Status],
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtItemsConfiguration
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
