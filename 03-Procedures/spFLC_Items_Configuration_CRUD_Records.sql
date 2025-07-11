USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spFLC_Items_Configuration_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spFLC_Items_Configuration_CRUD_Records'

IF OBJECT_ID('[dbo].[spFLC_Items_Configuration_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spFLC_Items_Configuration_CRUD_Records
GO
/*
Autor:		Alejandro Zepeda
Desc:		SELECT * FROM FLC_Items_Configuration | Create - Read - Upadate - Delete 
Date:		08/10/2023
Example:
			DECLARE  @pudtItemsConfiguration  UDT_FLC_Items_Configuration 

			INSERT INTO @pudtItemsConfiguration
			SELECT 'CARDIO','S4TELMSPOA',	'SURVEY',	'ID_0464',	0 UNION ALL
			SELECT 'CIWS',	'CIWSOTHACC',	'CIWSAC',	'ID_0465',	1 UNION ALL
			SELECT 'EENT',	'FIBOPTTRAN',	'ILLUMI',	'ID_0466',	1

			SELECT * FROM @pudtItemsConfiguration
			SELECT * FROM FLC_Items_Configuration WHERE Id_Item in ('ID item2')

			EXEC spFLC_Items_Configuration_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pudtItemsConfiguration = @pudtItemsConfiguration,  @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'			

			spFLC_Items_Configuration_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdFLCCategory = 'ABPMSY', @pItemDesc = 'IT'
			spFLC_Items_Configuration_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdFLCCategory = 'ABPMSY', @pvIdFLCGroup = 'ABPACC', @pItemDesc = 'IT'
			spFLC_Items_Configuration_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdFLCCategory = 'ABPMSY' , @pvIdFLCFamily = 'ABPM6100AC', @pvIdFLCGroup = 'ABPACC', @pvIdItem= 'Id Item'
			
			spFLC_Items_Configuration_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdItem = 'Id Item2'			

			spFLC_Items_Configuration_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdItem = 'Id Item2', @pbStatusItemsConfiguration = 1
			spFLC_Items_Configuration_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdItem = 'Id Item2', @pbStatusCategory = 1
			spFLC_Items_Configuration_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdItem = 'Id Item2', @pbStatusFamily = 1 
			spFLC_Items_Configuration_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdItem = 'Id Item2', @pbStatusGroup = 1
			spFLC_Items_Configuration_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdItem = 'Id Item2', @pbStatusItem = 1

			SELECT * FROM FLC_Items_Configuration

			spFLC_Items_Configuration_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdFLCCategory = 'Id' , @pvIdFLCFamily = 'Id', @pvIdFLCGroup = 'Id', @pvIdItem= 'Id_item', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			
			spFLC_Items_Configuration_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvIdFLCCategory = 'Id' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spFLC_Items_Configuration_CRUD_Records @pvOptionCRUD = 'X', @pvIdLanguageUser = 'ANG', @pvIdFLCCategory = 'Id' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254''
*/
CREATE PROCEDURE [dbo].spFLC_Items_Configuration_CRUD_Records
@pvOptionCRUD				Varchar(1),
@pvIdLanguageUser			Varchar(10) = 'ANG',
@pvIdFLCCategory			Varchar(10) = '',
@pvIdFLCFamily				Varchar(10) = '',
@pvIdFLCGroup				Varchar(10) = '',
@pvIdItem					Varchar(50) = '',
@pItemDesc					Varchar(10) = '',
@pudtItemsConfiguration		UDT_FLC_Items_Configuration Readonly ,
@pbStatusItemsConfiguration	Bit				= NULL,
@pbStatusCategory			Bit				= NULL,
@pbStatusFamily				Bit				= NULL,
@pbStatusGroup				Bit				= NULL,
@pbStatusItem				Bit				= NULL,
@pvUser						Varchar(50) = '',
@pvIP						Varchar(20) = ''
AS
SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vjsonUDT			NVarchar(MAX)	= (SELECT * FROM @pudtItemsConfiguration FOR JSON AUTO);
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'FLC_Items_Configuration - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spFLC_Items_Configuration_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdFLCCategory = '" + ISNULL(@pvIdFLCCategory,'NULL') + "', @pvIdFLCFamily = '" + ISNULL(@pvIdFLCFamily,'NULL') + "', @pvIdFLCGroup = '" + ISNULL(@pvIdFLCGroup,'NULL') + "', @pvIdItem = '" + ISNULL(@pvIdItem,'NULL') + "',  @pItemDesc = '" + ISNULL(@pItemDesc,'NULL') + "', @pudtItemsConfiguration = '" + ISNULL(@vjsonUDT,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		DELETE FLC_Items_Configuration WHERE Id_Item IN (SELECT Id_Item FROM @pudtItemsConfiguration)

		INSERT INTO FLC_Items_Configuration(
			Id_FLC_Category,
			Id_FLC_Family,
			Id_FLC_Group,
			Id_Item,
			[Status],
			Modify_By,
			Modify_Date,
			Modify_IP)
		SELECT 
			Id_FLC_Category,
			Id_FLC_Family,
			Id_FLC_Group,
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
			IC.Id_FLC_Category,
			FLC_Category = C.Short_Desc,
			IC.Id_FLC_Family,
			FLC_Family = F.Short_Desc,
			IC.Id_FLC_Group,
			FLC_Group = G.Short_Desc, 
			IC.Id_Item,
			Item = I.Short_Desc,
			I.Price,
			I.Standard_Cost,
			StatusItemsConfiguration = IC.[Status],
			StatusCategory = C.[Status],
			StatusFamily = F.[Status],
			StatusGroup = G.[Status],
			StatusItem = I.[Status],
			IC.Modify_Date,
			IC.Modify_By,
			IC.Modify_IP
		FROM FLC_Items_Configuration IC

		INNER JOIN FLC_Cat_Categories C ON 
		IC.Id_FLC_Category = C.Id_FLC_Category
		--AND C.[Status] = 1

		INNER JOIN FLC_Cat_Families F ON 
		IC.Id_FLC_Family = F.Id_FLC_Family
		--AND F.[Status] = 1

		INNER JOIN FLC_Cat_Groups G ON 
		IC.Id_FLC_Group = G.Id_FLC_Group
		--AND G.[Status] = 1

		INNER JOIN FLC_Cat_Item I ON
		IC.Id_Item = I.Id_Item
		--AND I.[Status] = 1

		WHERE (@pvIdFLCCategory = '' OR IC.Id_FLC_Category = @pvIdFLCCategory)
		AND (@pvIdFLCFamily = '' OR IC.Id_FLC_Family = @pvIdFLCFamily )
		AND (@pvIdFLCGroup = '' OR IC.Id_FLC_Group = @pvIdFLCGroup )
		AND (@pvIdItem = '' OR IC.Id_Item = @pvIdItem )
		AND (@pItemDesc = '' OR I.Short_Desc LIKE '%' + @pItemDesc + '%')
		AND (@pbStatusItemsConfiguration IS NULL OR IC.[Status] = @pbStatusItemsConfiguration)
		AND (@pbStatusCategory IS NULL OR C.[Status] = @pbStatusCategory)
		AND (@pbStatusFamily IS NULL OR F.[Status] = @pbStatusFamily)
		AND (@pbStatusGroup IS NULL OR G.[Status] = @pbStatusGroup)
		AND (@pbStatusItem IS NULL OR I.[Status] = @pbStatusItem)
		ORDER BY Id_FLC_Category,Id_FLC_Family,Id_FLC_Group, Id_Item
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		DELETE FLC_Items_Configuration WHERE Id_Item IN (SELECT Id_Item FROM @pudtItemsConfiguration)

		INSERT INTO FLC_Items_Configuration(
			Id_FLC_Category,
			Id_FLC_Family,
			Id_FLC_Group,
			Id_Item,
			[Status],
			Modify_By,
			Modify_Date,
			Modify_IP)
		SELECT 
			Id_FLC_Category,
			Id_FLC_Family,
			Id_FLC_Group,
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
	
	--SET @vMessage		= dbo.fnGetTransacMessages('Generic Error',@pvIdLanguageUser)
	SET @vMessage		= ( SELECT Message FROM Security_Transaction_Log WHERE  Id_Transaction_Log = @nIdTransacLog)
	SET NOCOUNT OFF
	SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog
		
END CATCH
