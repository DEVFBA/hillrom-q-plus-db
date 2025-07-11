USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- [spFLC_Items_Item_CRUD_Records]
/* ==================================================================================*/	
PRINT 'Crea Procedure: [spFLC_Items_Item_CRUD_Records]'

IF OBJECT_ID('[dbo].[spFLC_Items_Item_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].[spFLC_Items_Item_CRUD_Records]
GO
/*
Autor:		Alejandro Zepeda
Desc:		Integration Items | Create - Read - Upadate - Delete 
Date:		22/10/2023
Example:


			DECLARE  @pudtItemsConfiguration  UDT_FLC_Items_Configuration 
			DECLARE  @pudtCommercialRelease  UDT_FLC_Commercial_Release 

			--Inserta en udt  pudtItemsConfiguration
			INSERT INTO @pudtItemsConfiguration
			SELECT 'CARDIO','S4TELMSPOA',	'SURVEY',	'Id Item3',	0 UNION ALL
			SELECT 'CIWS',	'CIWSOTHACC',	'CIWSAC',	'Id Item3',	1 UNION ALL
			SELECT 'EENT',	'FIBOPTTRAN',	'ILLUMI',	'Id Item3',	1
			
			--Inserta en udt  pudtCommercialRelease
			INSERT INTO @pudtCommercialRelease
			SELECT 'Id Item3', 'BR', 'ANG', 1, '20231022' 



			--EXEC spFLC_Items_Item_CRUD_Records @pvOptionCRUD	= 'C',
			EXEC spFLC_Items_Item_CRUD_Records @pvOptionCRUD	= 'U',
									@pvIdLanguageUser	= 'ANG', 
									@pvIdItem			= 'Id Item3', 
									@pvShortDesc		= 'Item', 
									@pvLongDesc			= 'Long Item', 
									@pvComment			= 'ninguno',
									@pfPrice			= 10.5,
									@pfStandardCost		= 13.5,
									@pbObsolescence		= 0,
									@pvObsolescenceDate	= '', --YYYYMMDD
									@pvImagePath		= 'c:\',
									@pvSubstituteItem	= 'sibitem',
									@pbStatus			= 1,
									@pudtItemsConfiguration = @pudtItemsConfiguration,
									@pudtCommercialRelease = @pudtCommercialRelease,
									@pvUser				= 'AZEPEDA', 
									@pvIP				='192.168.1.254'


			
*/
CREATE PROCEDURE [dbo].[spFLC_Items_Item_CRUD_Records]
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10) = '',
@pvIdItem						Varchar(50)		= '',
@pvShortDesc					Varchar(50)		= '',
@pvLongDesc						Varchar(255)	= '',
@pvComment						Varchar(500)	= '',
@pfPrice						Float			= 0,
@pfStandardCost					Float			= 0,
@pbObsolescence					Bit				= 0,
@pvObsolescenceDate				Varchar(8)		= '', --YYYYMMDD
@pvImagePath					Varchar(255)	= '',
@pvSubstituteItem				Varchar(50)		= '',
@pbStatus						Bit				= 0,
@pudtItemsConfiguration			UDT_FLC_Items_Configuration Readonly,
@pudtCommercialRelease			UDT_FLC_Commercial_Release Readonly,
@pvUser							Varchar(50)		= '',
@pvIP							Varchar(20)		= ''
AS

SET NOCOUNT ON
BEGIN TRANSACTION;  
  
BEGIN TRY  
   
   --------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vSQL Varchar(MAX)
	
	DECLARE @vjsonUDT1			NVarchar(MAX)	= (SELECT * FROM @pudtItemsConfiguration FOR JSON AUTO);
	DECLARE @vjsonUDT2			NVarchar(MAX)	= (SELECT * FROM @pudtCommercialRelease FOR JSON AUTO);
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Items_Item - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spFLC_Items_Item_CRUD_Records @pvOptionCRUD =   '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdItem = '" + ISNULL(@pvIdItem,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pvComment = '" + ISNULL(@pvComment,'NULL') + "', @pfPrice = " + ISNULL(CAST(@pfPrice AS VARCHAR),'NULL') + ", @pfStandardCost = " + ISNULL(CAST(@pfStandardCost AS VARCHAR),'NULL') + ", @pbObsolescence = '" + ISNULL(CAST(@pbObsolescence AS VARCHAR),'NULL') + "',  @pvObsolescenceDate = '" + ISNULL(@pvObsolescenceDate,'NULL') + "',  @pvImagePath = '" + ISNULL(@pvImagePath,'NULL') + "',  @pvSubstituteItem = '" + ISNULL(@pvSubstituteItem,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "',  @pudtItemsConfiguration = '" + ISNULL(@vjsonUDT1,'NULL') + "',  @pudtCommercialRelease = '" + ISNULL(@vjsonUDT2,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"

	DECLARE @TableResponse TABLE([Successful] bit, MessageType varchar(30), [Message] varchar(max), IdTransacLog numeric(18,0)); 


   INSERT INTO @TableResponse
	EXEC spFLC_Cat_Item_CRUD_Records @pvOptionCRUD	= @pvOptionCRUD,
									@pvIdLanguageUser	= @pvIdLanguageUser, 
									@pvIdItem			= @pvIdItem, 
									@pvShortDesc		= @pvShortDesc, 
									@pvLongDesc			= @pvLongDesc, 
									@pvComment			= @pvComment,
									@pfPrice			= @pfPrice,
									@pfStandardCost		= @pfStandardCost,
									@pbObsolescence		= @pbObsolescence,
									@pvObsolescenceDate	= @pvObsolescenceDate, --YYYYMMDD
									@pvImagePath		= @pvImagePath,
									@pvSubstituteItem	= @pvSubstituteItem,
									@pbStatus			= @pbStatus,
									@pvUser				= @pvUser, 
									@pvIP				= @pvIP


	INSERT INTO @TableResponse
	EXEC spFLC_Items_Configuration_CRUD_Records @pvOptionCRUD = @pvOptionCRUD, @pvIdLanguageUser = @pvIdLanguageUser, @pudtItemsConfiguration = @pudtItemsConfiguration,   @pvUser = @pvUser, @pvIP = @pvIP		

	INSERT INTO @TableResponse
	EXEC spFLC_Commercial_Release_CRUD_Records @pvOptionCRUD = @pvOptionCRUD, @pvIdLanguageUser = @pvIdLanguageUser, @pudtCommercialRelease = @pudtCommercialRelease, @pvUser = @pvUser, @pvIP = @pvIP
	

	IF (select COUNT(*) from @TableResponse where Successful = 0) > 0
	BEGIN
	SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Error	
	SET @vMessage		= (select MAX([Message]) from @TableResponse where Successful = 0)	
	SET @bSuccessful	= 0 --Execution with errors

		 IF @@TRANCOUNT > 0  
        ROLLBACK TRANSACTION; 
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
	IF @bSuccessful = 0
		SET @vMessage		= dbo.fnGetTransacMessages('Generic Error',@pvIdLanguageUser)


	SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog


END TRY  
BEGIN CATCH  

 IF @@TRANCOUNT > 0  
        ROLLBACK TRANSACTION; 

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

  
    
END CATCH;  
  
IF @@TRANCOUNT > 0  
    COMMIT TRANSACTION;  
