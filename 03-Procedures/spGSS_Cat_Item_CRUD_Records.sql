USE DBQS
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spGSS_Cat_Item_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spGSS_Cat_Item_CRUD_Records'

IF OBJECT_ID('[dbo].[spGSS_Cat_Item_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spGSS_Cat_Item_CRUD_Records
GO

/*
Autor:		Angel Gutierrez
Desc:		GSS_Cat_Item | Create - Read - Upadate - Delete 
Date:		11/09/2025
Example:
			spGSS_Cat_Item_CRUD_Records @pvOptionCRUD		= 'C',
									@pvIdLanguageUser	= 'ANG', 
									@pvIdItem			= 'XXXXX', 
									@pvIdCountry		= 'US' , 
									@pvIdItemClass		= 'PROD', 
									@pvIdItemSubClass	= 'PROD', 
									@pvIdDiscountCategory = 'XXX',
									@pvIdCountryPackage = '',
									@pvIdItemRelated    = '',
									@pvShortDesc		= 'Short Desc', 
									@pvLongDesc			= 'Long Desc', 
									@pvModel			= 'Model',
									@pvSpecifications	= 'Specs',
									@pvWeight			= 'XXX',
									@pvMeasurements		= 'XXXX',
									@pvImagePath		= 'XXXX',
									@pbStatus			= 1, 
									@pvItemSPR			= '0',
									@pvUser				= 'AZEPEDA', 
									@pvIP				='192.168.1.254'

			EXEC spGSS_Cat_Item_CRUD_Records @pvOptionCRUD		= 'R', 
									@pvIdLanguageUser = 'ANG', 
									@pvIdItemClass		= 'PACK', 
									@pvIdItemSubClass	= '',
									@pvIdDiscountCategory = 'HR900',
									@pvIdItem			= '',
									@pvIdCountryPackage = '',
									@pvIdItemRelated    = '',
									@pvShortDesc		= '',
									@pvIdFamily			= '',
									@pvIdCategory		= '',
									@pvIdLine			= '',
									@pvIdCountryComercialRealease = 'CU'

			EXEC spGSS_Cat_Item_CRUD_Records 
									@pvOptionCRUD		= 'R', 
									@pvIdItem			= 'XXXX',
									@pvIdCountryComercialRealease = 'BR'
 
			spGSS_Cat_Item_CRUD_Records @pvOptionCRUD		= 'U', 
									@pvIdItem			= 'BR_ACCELLA_STD3', 
									@pvIdCountry		= 'FR' , 
									@pvIdItemClass		= 'PACKD', 
									@pvIdItemSubClass	= 'PACKD', 
									@pvIdDiscountCategory = 'HRACC', 
									@pvIdCountryPackage = 'BR',
									@pvIdItemRelated    = 'ACCELLA',
									@pvShortDesc		= 'ACC3_CONN_THERAPY', 
									@pvLongDesc			= 'ACCELLA3_CONN_THERAPY', 
									@pvModel			= 'ACCELLA',
									@pvSpecifications	= '',
									@pvWeight			= '166 KG',
									@pvMeasurements		= '100 x 55 x 235',
									@pvImagePath		= '',
									@pbStatus			= 1, 
									@pvItemSPR			= '',
									@pvUser				= 'AZEPEDA', 
									@pvIP				='192.168.1.254'

*/
CREATE PROCEDURE [dbo].[spGSS_Cat_Item_CRUD_Records]
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10)		= 'ANG',
@pvIdItem						Varchar(50)		= '',
@pvIdItemDetalle				Varchar(50)		= '',
@pvIdCountry					Varchar(10)		= 'All',
@pvIdItemClass					Varchar(10)		= 'All',
@pvIdItemSubClass				Varchar(10)		= 'All',
@pvIdDiscountCategory			Varchar(10)		= 'All',
@pvIdFamily						Varchar(10)		= 'All',
@pvIdCategory					Varchar(10)		= 'All',
@pvIdLine						Varchar(10)		= 'All',
@pvIdCountryPackage				Varchar(10)		= 'All',
@pvIdItemRelated 				Varchar(50)		= '',
@pvShortDesc					Varchar(50)		= '',
@pvLongDesc						Varchar(255)	= '',
@pvModel						Varchar(100)	= '',
@pvSpecifications				Varchar(1000)	= '',
@pvWeight						Varchar(50)		= '',
@pvMeasurements					Varchar(50)		= '',
@pvImagePath					Varchar(255)	= '',
@pbStatus						Bit				= 0,
@pvItemSPR						Varchar(50)		= '',
@pvUser							Varchar(50)		= '',
@pvIP							Varchar(20)		= '',
@pvIdCountryComercialRealease	Varchar(10)		= ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------

	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @iIdStsAvailable	Varchar(50)	= 1 -- AValible/Disponible
	DECLARE @vStsAvailable		Varchar(50)	= ISNULL((SELECT Short_Desc FROM Cat_Status_Commercial_Release WHERE Id_Status_Commercial_Release = @iIdStsAvailable AND Id_Language = @pvIdLanguageUser),'')
	DECLARE @vSQL				Varchar(MAX)

	IF @pvOptionCRUD = 'C' OR @pvOptionCRUD = 'U'
	BEGIN
		IF @pvIdCountryPackage = '' SET @pvIdCountryPackage = NULL
		IF @pvIdItemRelated = ''	SET @pvIdItemRelated    = NULL
	END
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------

	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'GSS_Cat_Item - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spGSS_Cat_Item_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdItem = '" + ISNULL(@pvIdItem,'NULL') + "', @pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL') + "', @pvIdItemClass = '" + ISNULL(@pvIdItemClass,'NULL') + "', @pvIdItemSubClass = '" + ISNULL(@pvIdItemSubClass,'NULL') + "', @pvIdDiscountCategory = '" + ISNULL(@pvIdDiscountCategory,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pvModel = '" + ISNULL(@pvModel,'NULL') + "', @pvSpecifications = '" + ISNULL(@pvSpecifications,'NULL') + "', @pvWeight = '" + ISNULL(@pvWeight,'NULL') + "', @pvMeasurements = '" + ISNULL(@pvMeasurements,'NULL') + "', @pvImagePath = '" + ISNULL(@pvImagePath,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvItemSPR = '" + @pvItemSPR + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM GSS_Cat_Item WHERE Id_Item = @pvIdItem)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don�t Exists
		BEGIN
			INSERT INTO Cat_Item(
				Id_Item,
				Id_Country,
				Id_Item_Class,
				Id_Item_SubClass,
				Id_Discount_Category,
				Id_Country_Package,
				Id_Item_Related,
				Short_Desc,
				Long_Desc,
				Model,
				Specifications,
				[Weight],
				Measurements,
				Image_Path,
				[Status],
				Item_SPR,
				Modify_By,
				Modify_Date,
				Modify_IP)
			VALUES (
				@pvIdItem,
				@pvIdCountry,
				@pvIdItemClass,
				@pvIdItemSubClass,
				@pvIdDiscountCategory,
				@pvIdCountryPackage,
				@pvIdItemRelated,
				@pvShortDesc,
				@pvLongDesc,
				@pvModel,
				@pvSpecifications,
				@pvWeight,
				@pvMeasurements,
				@pvImagePath,
				@pbStatus,	
				@pvItemSPR,
				@pvUser,
				GETDATE(),
				@pvIP)


			IF( (@pvIdItemClass IN ('GSSPACK','GSSPACKD')) AND  NOT EXISTS (SELECT * FROM GSS_Commercial_Release WHERE Id_Item = @pvIdItem AND Id_Country = @pvIdCountryPackage) )
			BEGIN
				INSERT INTO GSS_Commercial_Release (Id_Item,Id_Country,Id_Status_Commercial_Release,Final_Effective_Date,Modify_By,Modify_Date,Modify_IP)
				VALUES (@pvIdItem, @pvIdCountryPackage, 1,NULL, @pvUser, GETDATE(), @pvIP)
			END

		END
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
	SET @vSQL = "SELECT 	
		I.Id_Item_Class, 
		Item_Class_Desc = ICL.Short_Desc,
		I.Id_Item_SubClass, 
		Item_SubClass_Desc = ISCL.Short_Desc,
		I.Id_Discount_Category,
		Discount_Category_Desc = DC.Short_Desc,
		I.Id_Country,
		Item_Country_Desc = CON.Short_Desc,
		Item_CountryPackage_Desc = CONPKG.Short_Desc,
		I.Id_Item,
		I.Short_Desc,
		I.Long_Desc,
		I.Model,
		I.Specifications,
		I.[Weight],
		I.Measurements,
		I.Image_Path,	
		I.[Status],
		I.Item_SPR,
		I.Id_Item_Related,
		Id_Item_Related_Desc = (SELECT Short_Desc FROM Cat_Item WHERE Id_Item = I.Id_Item_Related),"
		
		IF @pvIdItemClass = 'GSSPACK'
		BEGIN
		SET @vSQL += "	
		Id_Status_Commercial_Release = ISNULL((SELECT SCR.Id_Status_Commercial_Release
												FROM GSS_Commercial_Release CR
												INNER JOIN Cat_Status_Commercial_Release SCR ON
												CR.Id_Status_Commercial_Release = SCR.Id_Status_Commercial_Release
												AND SCR.Id_Language = '" +  @pvIdLanguageUser + "'
												WHERE Id_Item = I.Id_Item_Related AND Id_Country = '" +   @pvIdCountryComercialRealease + "')," + @iIdStsAvailable + "), 
		

		Status_Commercial_Release = ISNULL((SELECT SCR.Short_Desc 
												FROM GSS_Commercial_Release CR
												INNER JOIN Cat_Status_Commercial_Release SCR ON
												CR.Id_Status_Commercial_Release = SCR.Id_Status_Commercial_Release
												AND SCR.Id_Language = '" +  @pvIdLanguageUser + "'
												WHERE Id_Item = I.Id_Item_Related AND Id_Country = '" +   @pvIdCountryComercialRealease + "'),'" + @vStsAvailable + "'),"
		END
		ELSE
		BEGIN
		SET @vSQL += "	
		Id_Status_Commercial_Release = ISNULL((SELECT SCR.Id_Status_Commercial_Release 
											FROM GSS_Commercial_Release CR
											INNER JOIN Cat_Status_Commercial_Release SCR ON
											CR.Id_Status_Commercial_Release = SCR.Id_Status_Commercial_Release
											AND SCR.Id_Language = '" +  @pvIdLanguageUser + "'
											WHERE Id_Item = I.Id_Item AND Id_Country = '" +   @pvIdCountryComercialRealease + "')," + @iIdStsAvailable + "), 
		
		Status_Commercial_Release = ISNULL((SELECT SCR.Short_Desc 
											FROM GSS_Commercial_Release CR
											INNER JOIN Cat_Status_Commercial_Release SCR ON
											CR.Id_Status_Commercial_Release = SCR.Id_Status_Commercial_Release
											AND SCR.Id_Language = '" +  @pvIdLanguageUser + "'
											WHERE Id_Item = I.Id_Item AND Id_Country = '" +   @pvIdCountryComercialRealease + "'),'" + @vStsAvailable + "'),"
		
		END

		SET @vSQL += "		
		I.Modify_Date,
		I.Modify_By,
		I.Modify_IP

		FROM GSS_Cat_Item I

		INNER JOIN Cat_Item_Classes ICL WITH(NOLOCK) ON 
		I.Id_Item_Class = ICL.Id_Item_Class
		AND ICL.Status = 1

		INNER JOIN Cat_Item_SubClasses ISCL WITH(NOLOCK) ON 
		I.Id_Item_Class = ISCL.Id_Item_Class AND
		I.Id_Item_SubClass = ISCL.Id_Item_SubClass
		AND ISCL.Status = 1

		INNER JOIN Cat_Discount_Categories DC ON
		I.Id_Discount_Category = DC.Id_Discount_Category

		INNER JOIN Cat_Countries CON WITH(NOLOCK) ON 
		I.Id_Country = CON.Id_Country 
		AND CON.Status = 1

		LEFT OUTER JOIN Cat_Countries CONPKG WITH(NOLOCK) ON 
		I.Id_Country_Package = CONPKG.Id_Country 
		AND CON.Status = 1
		 
		INNER JOIN GSS_Items_Configuration IC  WITH(NOLOCK) ON
		I.Id_Item = IC.Id_Item
		AND IC.Status = 1

		WHERE 1= 1 "

		IF @pvIdItemClass <> 'ALL' AND @pvIdItemClass <> ''
		SET @vSQL += "AND I.Id_Item_Class = '" + @pvIdItemClass + "'"

		IF @pvIdItemSubClass <> 'ALL' AND @pvIdItemSubClass <> ''
		SET @vSQL += "AND I.Id_Item_SubClass = '" + @pvIdItemSubClass + "'"

		IF @pvIdDiscountCategory <> 'ALL' AND @pvIdDiscountCategory <> ''
		SET @vSQL += "AND I.Id_Discount_Category = '" + @pvIdDiscountCategory + "'"

		IF @pvIdItem <> ''
		SET @vSQL += "AND I.Id_Item LIKE '%" + @pvIdItem + "%'"

		IF @pvIdItemDetalle <> ''
		SET @vSQL += "AND I.Id_Item = '" + @pvIdItemDetalle + "'"

		IF @pvShortDesc <> ''
		SET @vSQL += "AND I.Short_Desc LIKE '%" + @pvShortDesc + "%'"

		IF @pvIdCountryPackage <> 'ALL' AND @pvIdCountryPackage <> ''
		SET @vSQL += "AND I.Id_Country_Package = '" + @pvIdCountryPackage + "'"

		IF @pvIdItemRelated <> ''
		SET @vSQL += "AND I.Id_Item_Related = '" + @pvIdItemRelated + "'"
		
		SET @vSQL += " ORDER BY IC.Id_Item, IC.Id_Family , IC.Id_Category , IC.Id_Line "
		PRINT (@vSQL)
		EXEC(@vSQL)
	
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Item 
		SET		Id_Country			= @pvIdCountry,
				Id_Item_Class		= @pvIdItemClass,
				Id_Item_SubClass	= @pvIdItemSubClass,
				Id_Discount_Category= @pvIdDiscountCategory,
				Id_Country_Package	= @pvIdCountryPackage,
				Id_Item_Related		= @pvIdItemRelated,
				Short_Desc			= @pvShortDesc,
				Long_Desc			= @pvLongDesc,
				Model				= @pvModel,
				Specifications		= @pvSpecifications,
				[Weight]			= @pvWeight,
				Measurements		= @pvMeasurements,
				Image_Path			= @pvImagePath,
				[Status]			= @pbStatus,
				Item_SPR			= @pvItemSPR,
				Modify_By			= @pvUser, 
				Modify_Date			= GETDATE(),		
				Modify_IP			= @pvIP
			WHERE Id_Item = @pvIdItem

			IF( (@pvIdItemClass IN ('GSSPACK','GSSPACKD')) AND  NOT EXISTS (SELECT * FROM GSS_Commercial_Release WHERE Id_Item = @pvIdItem AND Id_Country = @pvIdCountryPackage) )
			BEGIN
				INSERT INTO GSS_Commercial_Release (Id_Item,Id_Country,Id_Status_Commercial_Release,Final_Effective_Date,Modify_By,Modify_Date,Modify_IP)
				VALUES (@pvIdItem, @pvIdCountryPackage, 1,NULL, @pvUser, GETDATE(), @pvIP)
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
