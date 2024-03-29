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


		DECLARE  @pudtItemsConfiguration		UDT_Items_Configuration 
		DECLARE  @pudtItemsTemplates			UDT_Items_Templates 
		DECLARE  @pudtItemsTemplateExceptions	UDT_Items_Template_Exceptions 
		DECLARE  @pudtItemsTemplateKits			UDT_Items_Template_Kits 
		DECLARE  @pudtItemsTemplateKitsDetail	UDT_Items_Template_Kits_Detail 
		DECLARE  @pudtOperationCost				UDT_Operation_Cost 
		DECLARE  @pudtCommercialRelease			UDT_Commercial_Release 

			--Hearder
		INSERT INTO @pudtItemsConfiguration
		select * from pudtItemsConfiguration

		INSERT INTO @pudtItemsTemplates
		select * from pudtItemsTemplates

		INSERT INTO @pudtItemsTemplateExceptions
		select * from pudtItemsTemplateExceptions
   
		INSERT INTO @pudtItemsTemplateKits
		select * from pudtItemsTemplateKits 
   
		INSERT INTO @pudtItemsTemplateKitsDetail
		select * from pudtItemsTemplateKitsDetail 
   
		INSERT INTO @pudtOperationCost
		select * from pudtOperationCost 
   
		INSERT INTO @pudtCommercialRelease
		select * from pudtCommercialRelease 


		exec spItems_Item_CRUD_Records @pvOptionCRUD='C',
		@pvIdItem='DP-1',
		@pvIdCountry='FR',
		@pvIdItemClass='PACKD',
		@pvIdItemSubClass='PACKD',
		@pvShortDesc='260521-Prueba',
		@pvLongDesc='260521-Prueba',
		@pvModel='X3',
		@pvSpecifications='Split siderails with integrated controls',
		@pvWeight='155 KG',
		@pvMeasurements='100 x 50 x 235 CM',
		@pvIdDiscountCategory='HR900',
		@pvIdCountryPackage='AG',
		@pvIdItemRelated='HR900 X3',
		@pvImagePath=null,
		@pbStatus=True,
		@pudtItemsConfiguration=  @pudtItemsConfiguration,
		@pvItemTemplate='DP-1',
		@pudtItemsTemplates=@pudtItemsTemplates, 
		@pudtItemsTemplateExceptions=@pudtItemsTemplateExceptions,
		@pudtItemsTemplateKits=@pudtItemsTemplateKits,
		@pudtItemsTemplateKitsDetail=@pudtItemsTemplateKitsDetail,
		@pudtOperationCost=@pudtOperationCost,
		@pudtCommercialRelease=@pudtCommercialRelease,
		@pvItemSPR='280521',
		@pvAccessoryMessage='',
		@pvUser='VIROJAS',
		@pvIP='127.0.0.1'


			

			
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


--FOR TEST
/*
		SELECT * INTO pudtItemsConfiguration FROM @pudtItemsConfiguration  
		SELECT * INTO pudtItemsTemplates FROM @pudtItemsTemplates  
		SELECT * INTO pudtItemsTemplateExceptions FROM @pudtItemsTemplateExceptions  
		SELECT * INTO pudtItemsTemplateKits FROM @pudtItemsTemplateKits  
		SELECT * INTO pudtItemsTemplateKitsDetail FROM @pudtItemsTemplateKitsDetail  
		SELECT * INTO pudtOperationCost FROM @pudtOperationCost  
		SELECT * INTO pudtCommercialRelease FROM @pudtCommercialRelease

*/

BEGIN TRANSACTION;  
  
BEGIN TRY  
   
   --------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vSQL Varchar(MAX)

	DECLARE @vjsonUDTConfiguration		NVarchar(MAX)	= (SELECT * FROM @pudtItemsConfiguration FOR JSON AUTO);
	DECLARE @vjsonUDTTemplates			NVarchar(MAX)	= (SELECT * FROM @pudtItemsTemplates FOR JSON AUTO);
	DECLARE @vjsonUDTTemplateExceptions	NVarchar(MAX)	= (SELECT * FROM @pudtItemsTemplateExceptions FOR JSON AUTO);
	DECLARE @vjsonUDTTemplateKits		NVarchar(MAX)	= (SELECT * FROM @pudtItemsTemplateKits FOR JSON AUTO);
	DECLARE @vjsonUDTTemplateKitsDetail	NVarchar(MAX)	= (SELECT * FROM @pudtItemsTemplateKitsDetail FOR JSON AUTO);
	DECLARE @vjsonUDTOperationCost		NVarchar(MAX)	= (SELECT * FROM @pudtOperationCost FOR JSON AUTO);
	DECLARE @vjsonUDTCommercialRelease	NVarchar(MAX)	= (SELECT * FROM @pudtCommercialRelease FOR JSON AUTO);

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Item - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spItems_Item_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdItem = '" + ISNULL(@pvIdItem,'NULL') + "', @pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL') + "', @pvIdItemClass = '" + ISNULL(@pvIdItemClass,'NULL') + "', @pvIdItemSubClass = '" + ISNULL(@pvIdItemSubClass,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pvModel = '" + ISNULL(@pvModel,'NULL') + "', @pvSpecifications = '" + ISNULL(@pvSpecifications,'NULL') + "', @pvWeight = '" + ISNULL(@pvWeight,'NULL') + "', @pvMeasurements = '" + ISNULL(@pvMeasurements,'NULL') + "', @pvImagePath = '" + ISNULL(@pvImagePath,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvItemSPR = '" + ISNULL(CAST(@pvItemSPR AS VARCHAR),'NULL') + "', 
	@vjsonUDTConfiguration = '" + ISNULL(@vjsonUDTConfiguration,'NULL') + "',
	@vjsonUDTTemplates = '" + ISNULL(@vjsonUDTTemplates,'NULL') + "',
	@vjsonUDTTemplateExceptions = '" + ISNULL(@vjsonUDTTemplateExceptions,'NULL') + "',
	@vjsonUDTTemplateKits = '" + ISNULL(@vjsonUDTTemplateKits,'NULL') + "',
	@vjsonUDTTemplateKitsDetail = '" + ISNULL(@vjsonUDTTemplateKitsDetail,'NULL') + "',
	@vjsonUDTOperationCost = '" + ISNULL(@vjsonUDTOperationCost,'NULL') + "',
	@vjsonUDTCommercialRelease = '" + ISNULL(@vjsonUDTCommercialRelease,'NULL') + "',
	@pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"


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
