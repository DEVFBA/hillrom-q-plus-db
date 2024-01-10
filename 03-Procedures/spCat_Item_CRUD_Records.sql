USE DBQS
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Item_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Item_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Item_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Item_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Item | Create - Read - Upadate - Delete 
Date:		01/17/2021
Example:
			spCat_Item_CRUD_Records @pvOptionCRUD		= 'C',
									@pvIdLanguageUser	= 'ANG', 
									@pvIdItem			= 'BR_ACCELLA_STD3', 
									@pvIdCountry		= 'FR' , 
									@pvIdItemClass		= 'PROD', 
									@pvIdItemSubClass	= 'PROD', 
									@pvIdDiscountCategory = 'HR900',
									@pvIdCountryPackage = '',
									@pvIdItemRelated    = '',
									@pvShortDesc		= 'Hill-Rom® 900 Accella', 
									@pvLongDesc			= 'Hill-Rom® 900 Accella', 
									@pvModel			= 'Bed Exit Alarm',
									@pvSpecifications	= 'especs',
									@pvWeight			= '80cm',
									@pvMeasurements		= 'sddfrfrr',
									@pvImagePath		= 'c:\',
									@pbStatus			= 1, 
									@pvItemSPR			= '0',
									@pvAccesoryMessage	= 'AccesoryMessag',
									@pvUser				= 'AZEPEDA', 
									@pvIP				='192.168.1.254'

			EXEC spCat_Item_CRUD_Records @pvOptionCRUD		= 'R', 
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

			EXEC spCat_Item_CRUD_Records 
									@pvOptionCRUD		= 'R', 
									@pvIdItem			= 'BR_ACCELLA_STD3',
									@pvIdCountryComercialRealease = 'BR'

			EXEC spCat_Item_CRUD_Records	@pvOptionCRUD		= 'R', 
											@pvIdLanguageUser	= 'BRA', 
											@pvIdItemClass		= 'PROD', 
											@pvIdItemSubClass	= 'PROD',
											@pvIdCountryComercialRealease = 'CL',
											@pvIdCountryPackage = ''

			EXEC spCat_Item_CRUD_Records @pvOptionCRUD='R',@pvIdItemClass='COMP',@pvIdItemSubClass='',@pvIdItem='M8',@pvShortDesc='',@pvIdFamily='',@pvIdCategory='',@pvIdLine=''
			EXEC spCat_Item_CRUD_Records @pvOptionCRUD='R',@pvIdItemClass='COMP',@pvIdItemSubClass='',@pvIdItemDetalle='M8',@pvShortDesc='',@pvIdFamily='',@pvIdCategory='',@pvIdLine=''
			 SELECT * FROM Cat_Item WHERE Id_Item ='BR_ACCELLA_STD3'
 
			spCat_Item_CRUD_Records @pvOptionCRUD		= 'U', 
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
									@pvAccessoryMessage	= '',
									@pvUser				= 'AZEPEDA', 
									@pvIP				='192.168.1.254'

*/
CREATE PROCEDURE [dbo].[spCat_Item_CRUD_Records]
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
@pvAccessoryMessage				Varchar(255)	= '',
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_Item - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Item_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdItem = '" + ISNULL(@pvIdItem,'NULL') + "', @pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL') + "', @pvIdItemClass = '" + ISNULL(@pvIdItemClass,'NULL') + "', @pvIdItemSubClass = '" + ISNULL(@pvIdItemSubClass,'NULL') + "', @pvIdDiscountCategory = '" + ISNULL(@pvIdDiscountCategory,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pvModel = '" + ISNULL(@pvModel,'NULL') + "', @pvSpecifications = '" + ISNULL(@pvSpecifications,'NULL') + "', @pvWeight = '" + ISNULL(@pvWeight,'NULL') + "', @pvMeasurements = '" + ISNULL(@pvMeasurements,'NULL') + "', @pvImagePath = '" + ISNULL(@pvImagePath,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvItemSPR = '" + @pvItemSPR + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Item WHERE Id_Item = @pvIdItem)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
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
				Accessory_Message,
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
				@pvAccessoryMessage,
				@pvUser,
				GETDATE(),
				@pvIP)


			IF( (@pvIdItemClass IN ('PACK','PACKD')) AND  NOT EXISTS (SELECT * FROM Commercial_Release WHERE Id_Item = @pvIdItem AND Id_Country = @pvIdCountryPackage) )
			BEGIN
				INSERT INTO Commercial_Release (Id_Item,Id_Country,Id_Status_Commercial_Release,Final_Effective_Date,Modify_By,Modify_Date,Modify_IP)
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
		IC.Id_Family,
		Family_Desc = F.Short_Desc,
		IC.Id_Category,
		Category_Desc = C.Short_Desc,
		IC.Id_Line,
		Line_Desc = L.Short_Desc,
		Line_Percentage_Taxes =  ISNULL((SELECT Percentage FROM Cat_Line_Taxes WHERE Id_Line = IC.Id_Line  AND Id_Country = '" +   @pvIdCountryComercialRealease + "' AND Status = 1),0),
		I.Id_Country_Package,
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
		Id_Item_Related_Desc = (SELECT Short_Desc FROM Cat_Item WHERE Id_Item = I.Id_Item_Related),		
		Extended_Warranties = ISNULL((SELECT DISTINCT 1 FROM Cat_Extended_Warranties WHERE Id_Line = IC.Id_Line ),0),
		Accessory_Message_Family =  ISNULL(F.Accessory_Message,''),
		Accessory_Message_Item	=  ISNULL(I.Accessory_Message,''),"

		IF @pvIdItemClass = 'PACK'
		BEGIN
		SET @vSQL += "	
		Id_Status_Commercial_Release = ISNULL((SELECT SCR.Id_Status_Commercial_Release
												FROM Commercial_Release CR
												INNER JOIN Cat_Status_Commercial_Release SCR ON
												CR.Id_Status_Commercial_Release = SCR.Id_Status_Commercial_Release
												AND SCR.Id_Language = '" +  @pvIdLanguageUser + "'
												WHERE Id_Item = I.Id_Item_Related AND Id_Country = '" +   @pvIdCountryComercialRealease + "')," + @iIdStsAvailable + "), 
		

		Status_Commercial_Release = ISNULL((SELECT SCR.Short_Desc 
												FROM Commercial_Release CR
												INNER JOIN Cat_Status_Commercial_Release SCR ON
												CR.Id_Status_Commercial_Release = SCR.Id_Status_Commercial_Release
												AND SCR.Id_Language = '" +  @pvIdLanguageUser + "'
												WHERE Id_Item = I.Id_Item_Related AND Id_Country = '" +   @pvIdCountryComercialRealease + "'),'" + @vStsAvailable + "'),"
		END
		ELSE
		BEGIN
		SET @vSQL += "	
		Id_Status_Commercial_Release = ISNULL((SELECT SCR.Id_Status_Commercial_Release 
											FROM Commercial_Release CR
											INNER JOIN Cat_Status_Commercial_Release SCR ON
											CR.Id_Status_Commercial_Release = SCR.Id_Status_Commercial_Release
											AND SCR.Id_Language = '" +  @pvIdLanguageUser + "'
											WHERE Id_Item = I.Id_Item AND Id_Country = '" +   @pvIdCountryComercialRealease + "')," + @iIdStsAvailable + "), 
		
		Status_Commercial_Release = ISNULL((SELECT SCR.Short_Desc 
											FROM Commercial_Release CR
											INNER JOIN Cat_Status_Commercial_Release SCR ON
											CR.Id_Status_Commercial_Release = SCR.Id_Status_Commercial_Release
											AND SCR.Id_Language = '" +  @pvIdLanguageUser + "'
											WHERE Id_Item = I.Id_Item AND Id_Country = '" +   @pvIdCountryComercialRealease + "'),'" + @vStsAvailable + "'),"
		
		END

		SET @vSQL += "		
		I.Modify_Date,
		I.Modify_By,
		I.Modify_IP

		FROM Cat_Item I

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
		 
		INNER JOIN Items_Configuration IC  WITH(NOLOCK) ON
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

		IF @pvIdFamily <> 'ALL' AND @pvIdFamily <> ''
		SET @vSQL += "AND IC.Id_Family = '" + @pvIdFamily + "'"

		IF @pvIdCategory <> 'ALL' AND @pvIdCategory <> ''
		SET @vSQL += "AND IC.Id_Category = '" + @pvIdCategory + "'"

		IF @pvIdLine <> 'ALL' AND @pvIdLine <> ''
		SET @vSQL += "AND IC.Id_Line = '" + @pvIdLine + "'"

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
				Accessory_Message	= @pvAccessoryMessage,
				Modify_By			= @pvUser, 
				Modify_Date			= GETDATE(),		
				Modify_IP			= @pvIP
			WHERE Id_Item = @pvIdItem

			IF( (@pvIdItemClass IN ('PACK','PACKD')) AND  NOT EXISTS (SELECT * FROM Commercial_Release WHERE Id_Item = @pvIdItem AND Id_Country = @pvIdCountryPackage) )
			BEGIN
				INSERT INTO Commercial_Release (Id_Item,Id_Country,Id_Status_Commercial_Release,Final_Effective_Date,Modify_By,Modify_Date,Modify_IP)
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
