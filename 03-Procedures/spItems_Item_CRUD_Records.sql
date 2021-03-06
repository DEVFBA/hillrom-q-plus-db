USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- [spItems_Item_CRUD_Records]
/* ==================================================================================*/	
PRINT 'Crea Procedure: [spItems_Item_CRUD_Records]'

IF OBJECT_ID('[dbo].[spItems_Item_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].[spItems_Item_CRUD_Records]
GO
/*
Autor:		Alejandro Zepeda
Desc:		Cat_Item | Create - Read - Upadate - Delete 
Date:		01/17/2021
Example:
			

			
*/
CREATE PROCEDURE [dbo].[spItems_Item_CRUD_Records]
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10) = '',
@pvIdItem						Varchar(50)		= '',
@pvIdCountry					Varchar(10)		= '',
@pvIdItemClass					Varchar(10)		= '',
@pvIdItemSubClass				Varchar(10)		= '',
@pvShortDesc					Varchar(50)		= '',
@pvLongDesc						Varchar(255)	= '',
@pvModel						Varchar(100)	= '',
@pvSpecifications				Varchar(1000)	= '',
@pvWeight						Varchar(50)		= '',
@pvMeasurements					Varchar(50)		= '',
@pvIdDiscountCategory			Varchar(10)		= '',
@pvIdCountryPackage				Varchar(10)		= 'All',
@pvIdItemRelated 				Varchar(50)		= '',
@pvImagePath					Varchar(255)	= '',
@pbStatus						Bit				= 0,
@pudtItemsConfiguration			UDT_Items_Configuration Readonly,
@pvItemTemplate					Varchar(50) = '',
@pudtItemsTemplates				UDT_Items_Templates Readonly,
@pudtItemsTemplateExceptions	UDT_Items_Template_Exceptions Readonly,
@pudtItemsTemplateKits			UDT_Items_Template_Kits Readonly,
@pudtItemsTemplateKitsDetail	UDT_Items_Template_Kits_Detail Readonly,
@pudtOperationCost				UDT_Operation_Cost Readonly,
@pudtCommercialRelease			UDT_Commercial_Release Readonly,
@pvItemSPR						Varchar(50)		= '',
@pvAccessoryMessage				Varchar(255)	= '',
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

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Item - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spItems_Item_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdItem = '" + ISNULL(@pvIdItem,'NULL') + "', @pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL') + "', @pvIdItemClass = '" + ISNULL(@pvIdItemClass,'NULL') + "', @pvIdItemSubClass = '" + ISNULL(@pvIdItemSubClass,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pvModel = '" + ISNULL(@pvModel,'NULL') + "', @pvSpecifications = '" + ISNULL(@pvSpecifications,'NULL') + "', @pvWeight = '" + ISNULL(@pvWeight,'NULL') + "', @pvMeasurements = '" + ISNULL(@pvMeasurements,'NULL') + "', @pvImagePath = '" + ISNULL(@pvImagePath,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvItemSPR = '" + ISNULL(CAST(@pvItemSPR AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"


	DECLARE @TableResponse TABLE(  
    [Successful] bit,  
    MessageType varchar(30),  
    [Message] varchar(max),  
    IdTransacLog numeric(18,0)
	); 


	INSERT INTO @TableResponse
   EXEC	spCat_Item_CRUD_Records @pvOptionCRUD = @pvOptionCRUD, 
									@pvIdItem = @pvIdItem, 
									@pvIdCountry = @pvIdCountry, 
									@pvIdItemClass = @pvIdItemClass, 
									@pvIdItemSubClass = @pvIdItemSubClass, 
									@pvIdDiscountCategory = @pvIdDiscountCategory,
									@pvIdCountryPackage = @pvIdCountryPackage,
									@pvIdItemRelated = @pvIdItemRelated,
									@pvShortDesc = @pvShortDesc, 
									@pvLongDesc = @pvLongDesc, 
									@pvModel = @pvModel,
									@pvSpecifications = @pvSpecifications,
									@pvWeight = @pvWeight,
									@pvMeasurements = @pvMeasurements,
									@pvImagePath = @pvImagePath,
									@pbStatus = @pbStatus, 
									@pvItemSPR = @pvItemSPR,
									@pvAccessoryMessage = @pvAccessoryMessage,
									@pvUser = @pvUser, 
									@pvIP = @pvIP


	IF @pvOptionCRUD = 'U'
	BEGIN
		DELETE FROM Commercial_Release			WHERE Id_Item = @pvIdItem
		DELETE FROM Operation_Cost				WHERE Id_Item = @pvIdItem
		DELETE FROM Items_Template_Kits_Detail	WHERE Item_Template = @pvItemTemplate
		DELETE FROM Items_Template_Kits			WHERE Item_Template = @pvItemTemplate
		DELETE FROM Items_Template_Exceptions	WHERE Item_Template = @pvItemTemplate
		DELETE FROM Items_Templates				WHERE Item_Template = @pvItemTemplate
		DELETE FROM Items_Configuration			WHERE Id_Item = @pvIdItem
		

	END


	INSERT INTO @TableResponse
	EXEC spItems_Configuration_CRUD_Records @pvOptionCRUD = @pvOptionCRUD, @pvIdItem = @pvIdItem, @pudtItemsConfiguration = @pudtItemsConfiguration,  @pvUser = @pvUser, @pvIP = @pvIP
									
	INSERT INTO @TableResponse
	EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = @pvOptionCRUD, @pvItemTemplate = @pvItemTemplate, @pudtItemsTemplates = @pudtItemsTemplates,  @pvUser = @pvUser, @pvIP = @pvIP

	INSERT INTO @TableResponse
	EXEC spItems_Template_Exceptions_CRUD_Records @pvOptionCRUD = @pvOptionCRUD, @pvItemTemplate = @pvItemTemplate, @pudtItemsTemplateExceptions = @pudtItemsTemplateExceptions,  @pvUser = @pvUser, @pvIP = @pvIP

	INSERT INTO @TableResponse
	EXEC spItems_Template_Kits_CRUD_Records @pvOptionCRUD = @pvOptionCRUD, @pvItemTemplate = @pvItemTemplate, @pudtItemsTemplateKits = @pudtItemsTemplateKits, @pudtItemsTemplateKitsDetail = @pudtItemsTemplateKitsDetail,  @pvUser = @pvUser, @pvIP = @pvIP

	INSERT INTO @TableResponse
	EXEC spOperation_Cost_CRUD_Records @pvOptionCRUD = @pvOptionCRUD, @pvIdItem = @pvIdItem, @pudtOperationCost = @pudtOperationCost,  @pvUser = @pvUser, @pvIP = @pvIP

	INSERT INTO @TableResponse
	EXEC spCommercial_Release_CRUD_Records @pvOptionCRUD = @pvOptionCRUD,  @pudtCommercialRelease = @pudtCommercialRelease, @pvUser = @pvUser, @pvIP = @pvIP


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
