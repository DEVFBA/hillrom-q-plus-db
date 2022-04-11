USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spItems_Template_Kits_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spItems_Template_Kits_CRUD_Records'

IF OBJECT_ID('[dbo].[spItems_Template_Kits_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spItems_Template_Kits_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Items_Template_Kits | Create - Read - Upadate - Delete 
Date:		28/01/2021
Example:

			DECLARE  @udtItemsTemplateKits			UDT_Items_Template_Kits 
			DECLARE  @udtItemsTemplateKitsDetail	UDT_Items_Template_Kits_Detail 

			--Hearder
			INSERT INTO @udtItemsTemplateKits
			SELECT	Item_Template,
					Id_Template_Kit + 100000000,
					Id_Price_List,
					Price,
					[Status]
			FROM Items_Template_Kits
			WHERE Item_Template = 'X3'
			
			
			--Detail
			INSERT INTO @udtItemsTemplateKitsDetail
			SELECT	Item_Template,
					Id_Template_Kit + 100000000,
					Id_Item,
					Modify_By,
					Modify_Date,
					Modify_IP
			FROM Items_Template_Kits_Detail
			WHERE Item_Template = 'X3'

			EXEC spItems_Template_Kits_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvItemTemplate = 'X3', @pudtItemsTemplateKits = @udtItemsTemplateKits, @pudtItemsTemplateKitsDetail = @udtItemsTemplateKitsDetail, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'			
			EXEC spItems_Template_Kits_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG'
			EXEC spItems_Template_Kits_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvItemTemplate = 'X3' 
			EXEC spItems_Template_Kits_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvItemTemplate = 'X3', @pvIdCurrency = 'MXN' 
			EXEC spItems_Template_Kits_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvItemTemplate = 'HR900 X3', @pvIdCurrency = 'MXN' 
			EXEC spItems_Template_Kits_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvItemTemplate = 'X3', @pudtItemsTemplateKits = @udtItemsTemplateKits, @pudtItemsTemplateKitsDetail = @udtItemsTemplateKitsDetail, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spItems_Template_Kits_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvItemTemplate = 'X3' 
			
 
*/
CREATE PROCEDURE [dbo].[spItems_Template_Kits_CRUD_Records]
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10) = '',
@pvItemTemplate					Varchar(10) = '',
@pudtItemsTemplateKits			UDT_Items_Template_Kits Readonly ,
@pudtItemsTemplateKitsDetail	UDT_Items_Template_Kits_Detail Readonly,
@pvIdCurrency					Varchar(10) = 'USD',
@pvUser							Varchar(50) = '',
@pvIP							Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD		Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @iNumHeaderRecords		Int				= (SELECT COUNT(*) FROM @pudtItemsTemplateKits)
	DECLARE @iNumDetailRecords		Int				= (SELECT COUNT(*) FROM @pudtItemsTemplateKitsDetail)
	DECLARE @vMsjBackground_Color	Varchar(50)		= '#ff0000'
	DECLARE @vMsjFont_Color			Varchar(50)		= '#ffffff'
	DECLARE @fExchange_Rate			Float			= (SELECT Exchange_Rate FROM Cat_Exchange_Rates WHERE Id_Currency = @pvIdCurrency AND [Status] = 1)
	DECLARE @tblItemsTemplateKits	Table(Item_Template varchar(50), Id_Template_Kit BigInt, Id_Template_Kit_Row Int)
	

	INSERT INTO @tblItemsTemplateKits (Item_Template,Id_Template_Kit, Id_Template_Kit_Row  )
	SELECT	Item_Template,
			Id_Template_Kit, 
			Id_Template_Kit_Row = (ROW_NUMBER() OVER(ORDER BY Id_Template_Kit))	
	FROM @pudtItemsTemplateKits

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Items_Template_Kits - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spItems_Template_Kits_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvItemTemplate = '" + ISNULL(@pvItemTemplate,'NULL') + "', @pudtItemsTemplateKits = '" + ISNULL(CAST(@iNumHeaderRecords AS VARCHAR),'NULL') + " rows affected', @pudtItemsTemplateKitsDetail = '" + ISNULL(CAST(@iNumDetailRecords AS VARCHAR),'NULL') + " rows affected', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		
		--Delete Kit
		DELETE Items_Template_Kits_Detail WHERE Item_Template = @pvItemTemplate
		DELETE Items_Template_Kits WHERE Item_Template = @pvItemTemplate
		
		-------------------
		--Header Kit
		-------------------
		INSERT INTO Items_Template_Kits(
			Item_Template,
			Id_Template_Kit,
			Id_Price_List,
			Price,
			[Status])

		SELECT 
			TK.Item_Template,
		    TKN.Id_Template_Kit_Row,
			TK.Id_Price_List,
			TK.Price,
			TK.[Status]		
		FROM @pudtItemsTemplateKits TK

		INNER JOIN @tblItemsTemplateKits TKN ON 
		TK.Item_Template = TKN.Item_Template AND
		TK.Id_Template_Kit = TKN.Id_Template_Kit


		-------------------
		--Detail Kit
		-------------------
		INSERT INTO Items_Template_Kits_Detail(
			Item_Template,
			Id_Template_Kit,
			Id_Item,
			Modify_By,
			Modify_Date,
			Modify_IP)

		SELECT 
			TKD.Item_Template,
			TKN.Id_Template_Kit_Row,
			TKD.Id_Item,
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtItemsTemplateKitsDetail TKD

		INNER JOIN @tblItemsTemplateKits TKN ON 
		TKD.Item_Template = TKN.Item_Template AND
		TKD.Id_Template_Kit = TKN.Id_Template_Kit





		
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		-------------------
		--Header Kit
		-------------------
		SELECT
		TK.Item_Template,
		TK.Id_Template_Kit,
		TK.Id_Price_List,
		Price_List_Desc = PL.Short_Desc,
		Price = TK.Price * @fExchange_Rate,
		TK.[Status],
		Items = STUFF((select '|'+ Id_Item 
                      from Items_Template_Kits_Detail 
                      WHERE Id_Template_Kit = TK.Id_Template_Kit AND Item_Template = TK.Item_Template
                     FOR XML PATH('')),1,1,'')

		FROM Items_Template_Kits TK WITH(NOLOCK) 

		INNER JOIN Cat_Prices_Lists PL WITH(NOLOCK) ON
		TK.Id_Price_List = PL.Id_Price_List AND 
		PL.Id_Language = @pvIdLanguageUser
		
		WHERE ('' = @pvItemTemplate ) OR TK.Item_Template = @pvItemTemplate

		ORDER BY TK.Item_Template,TK.Id_Template_Kit,TK.Id_Price_List

		-------------------
		--Detail Kit
		-------------------
		SELECT 
			KD.Item_Template,
			KD.Id_Template_Kit,
			KD.Id_Item,
			Item_Desc = I.Long_Desc,
			KD.Modify_By,
			KD.Modify_Date,
			KD.Modify_IP
		FROM Items_Template_Kits_Detail KD WITH(NOLOCK) 

		INNER JOIN Cat_Item I WITH(NOLOCK) ON
		KD.Id_Item= I.Id_Item

		WHERE ('' = @pvItemTemplate ) OR KD.Item_Template = @pvItemTemplate

		ORDER BY KD.Item_Template, KD.Id_Template_Kit, KD.Id_Item
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		--Delete Kit
		DELETE Items_Template_Kits_Detail WHERE Item_Template = @pvItemTemplate
		DELETE Items_Template_Kits WHERE Item_Template = @pvItemTemplate
		
		-------------------
		--Header Kit
		-------------------
		INSERT INTO Items_Template_Kits(
			Item_Template,
			Id_Template_Kit,
			Id_Price_List,
			Price,
			[Status])

		SELECT 
			Item_Template,
			Id_Template_Kit,
			Id_Price_List,
			Price,
			[Status]
		FROM @pudtItemsTemplateKits

		-------------------
		--Detail Kit
		-------------------
		INSERT INTO Items_Template_Kits_Detail(
			Item_Template,
			Id_Template_Kit,
			Id_Item,
			Modify_By,
			Modify_Date,
			Modify_IP)

		SELECT 
			Item_Template,
			Id_Template_Kit,
			Id_Item,
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtItemsTemplateKitsDetail
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
