USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spItems_Templates_CRUD_Records]    Script Date: 23/04/2024 09:01:28 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autor:		Alejandro Zepeda
Desc:		Items_Templates | Create - Read - Upadate - Delete 
Date:		25/01/2021
Example:

			DECLARE  @udtItemsTemplates  UDT_Items_Templates 

			INSERT INTO @udtItemsTemplates
			SELECT * FROM Items_Templates 
			WHERE Id_Item = 'PAH005010184-1' 

			

			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvItemTemplate = 'X3', @pudtItemsTemplates = @udtItemsTemplates , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'			
			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG'
			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvItemTemplate = 'X3' , @pvIdCountryComercialRealease = 'CU'
			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvItemTemplate = 'PAH005010184-1', @pvIdCurrency = 'MXN'
			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvItemTemplate = 'X3', @pudtItemsTemplates = @udtItemsTemplates , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvItemTemplate = 'X3' 
			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'L', @pvIdLanguageUser = 'ANG', @pudtItemsTemplates = @udtItemsTemplates, @pvUser = 'AZEPEDA', @pvIP = '10.230.0.0'
			
			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvItemTemplate = 'P7501-Tplus'
			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvItemTemplate = 'P7501-Tplus', @pvIdItem = 'P7540A0121000.'
			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pbDynamicFieldIsDynamic = 0
			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pbDynamicFieldIsDynamic = 1

			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'R', @pvItemTemplate ='ACCELA',@pvIdCurrency ='USD', @pvIdCountryComercialRealease='BR'
<<<<<<< HEAD

			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'R', @pvItemTemplate = 'ACCELLA', @pvIdCurrency = 'USD', @pvIdCountryComercialRealease = 'AG'
			
			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'RC', @pvItemTemplate = 'CENTURISX3', @pvIdCurrency = 'USD', @pvIdCountryComercialRealease = 'MX', 
			@piFolioOrig = 688, @piVersionOrig = 1, @piFolioClon = 689, @piVersionClon = 1

			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'T', @pvItemTemplate = 'ACCELLA', @pvIdCurrency = 'USD', @pvIdCountryComercialRealease = 'AG'

			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'T', @pvItemTemplate = 'TEST23091701 ', @pvIdCurrency = 'USD', @pvIdCountryComercialRealease = 'AG'
			SELECT * FROM 

			EXEC spItems_Templates_CRUD_Records @pvoptioncrud = 'T', @pvidlanguageuser = 'ANG', @pvitemtemplate = 'BR_ACCELLA_STD1', @pvidcurrency = 'USD'

=======

			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'R', @pvItemTemplate = 'ACCELLA', @pvIdCurrency = 'USD', @pvIdCountryComercialRealease = 'AG'
			
			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'RC', @pvItemTemplate = 'CENTURISX3', @pvIdCurrency = 'USD', @pvIdCountryComercialRealease = 'MX', 
			@piFolioOrig = 688, @piVersionOrig = 1, @piFolioClon = 689, @piVersionClon = 1

			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'T', @pvItemTemplate = 'ACCELLA', @pvIdCurrency = 'USD', @pvIdCountryComercialRealease = 'AG'
>>>>>>> d593e1c92917e85ce2c99ba4c328b374fcc2ee65

			EXEC spItems_Templates_CRUD_Records @pvOptionCRUD = 'R', @pvItemTemplate = '21113001', @pvIdFamily = 'STR',  @pvIdCurrency = 'USD', @pvIdCountryComercialRealease = 'AG'

*/
ALTER PROCEDURE [dbo].[spItems_Templates_CRUD_Records]
@pvOptionCRUD					Varchar(2),
@pvIdLanguageUser				Varchar(10) = 'ANG',
@pvItemTemplate					Varchar(50) = '',
@pudtItemsTemplates				UDT_Items_Templates Readonly ,
@pvIdCurrency					Varchar(10) = 'USD',
@pvIdFamily						Varchar(10) = '',
@pvUser							Varchar(50) = '',
@pvIP							Varchar(20) = '',
@pvIdCountryComercialRealease	Varchar(10)	= '',
@piFolioOrig					Int			= 0,
@piVersionOrig					Int			= 0,
@piFolioClon					Int			= 0,
@piVersionClon					Int			= 0,
@pbDynamicFieldIsDynamic		Bit			= 0,
@pvIdItem						Varchar(50) = ''								

AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @iNumRegistros		Int			= (SELECT COUNT(*) FROM @pudtItemsTemplates)
	DECLARE @fExchange_Rate		Float		= (SELECT Exchange_Rate FROM Cat_Exchange_Rates WHERE Id_Currency = @pvIdCurrency AND [Status] = 1)
	DECLARE @vStsAvailable		Varchar(50)	= (SELECT Short_Desc FROM Cat_Status_Commercial_Release WHERE Id_Status_Commercial_Release = 1  AND Id_Language = @pvIdLanguageUser)
	DECLARE @vItemTemplateClass Varchar(10) = (SELECT Id_Item_Class FROM Cat_Item WHERE Id_item = @pvItemTemplate)
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Items_Templates - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spItems_Templates_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvItemTemplate = '" + ISNULL(@pvItemTemplate,'NULL') + "', @pudtItemsTemplates = '" + ISNULL(CAST(@iNumRegistros AS VARCHAR),'NULL') + " rows affected',  @pvIdCurrency = '" + ISNULL(@pvIdCurrency,'NULL') + "',  @pvIdFamily = '" + ISNULL(@pvIdFamily,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "', @pbDynamicFieldIsDynamic = '" + ISNULL(CAST(@pbDynamicFieldIsDynamic AS VARCHAR),'NULL') + ""
	
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		DELETE Items_Templates WHERE Item_Template = @pvItemTemplate

		INSERT INTO Items_Templates(
			Item_Template,
			Id_Family,
			Id_Category,
			Id_Line,
			Id_Item,
			Id_Price_List,
			[Required],
			[Default],
			Price,
			Standard_Cost,
			Quantity,
			DynamicField_DefaultValue,
			DynamicField_AssignedValue,
			DynamicField_ReplaceCharacter,
			DynamicField_IsDynamic,
			DynamicField_IdItem,
			Modify_By,
			Modify_Date,
			Modify_IP)

		SELECT 
			Item_Template,
			Id_Family,
			Id_Category,
			Id_Line,
			Id_Item,
			Id_Price_List,
			[Required],
			[Default],
			Price,
			Standard_Cost,
			Quantity,
			DynamicField_DefaultValue		= NULL,
			DynamicField_AssignedValue		= NULL,
			DynamicField_ReplaceCharacter	= NULL,
			DynamicField_IsDynamic			= 0, -- Modification 23/04/24 (Vic, Angel)
			DynamicField_IdItem				= NULL,
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtItemsTemplates

		
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT
		T.Item_Template,
		Item_Desc =I.Short_Desc,
		I.Id_Item_Class, 
		Item_Class_Desc = ICL.Short_Desc,
		I.Id_Item_SubClass, 
		Item_SubClass_Desc = ISCL.Short_Desc,
		FCL.Id_Family,
		Family_Desc = F.Short_Desc,
		FCL.Id_Category,
		Category_Desc = C.Short_Desc,
		FCL.Id_Line,
		Line_Desc = L.Short_Desc,
		T.Id_Price_List,
		Price_List_Desc = P.Short_Desc,
		T.Id_Item,		
		I.Image_Path,
		[Required],
		[Default],
		Price =	Price * @fExchange_Rate,
		Standard_Cost = Standard_Cost *@fExchange_Rate,
		T.Quantity,
		FCL.Modify_By,
		FCL.Modify_Date,
		FCL.Modify_IP,
		Status_Commercial_Release = ISNULL((SELECT SCR.Short_Desc 
											FROM Commercial_Release CR
											INNER JOIN Cat_Status_Commercial_Release SCR ON
											CR.Id_Status_Commercial_Release = SCR.Id_Status_Commercial_Release AND
											SCR.Id_Language = @pvIdLanguageUser
											WHERE Id_Item = T.Id_Item AND Id_Country = @pvIdCountryComercialRealease ), @vStsAvailable ),
		DynamicField_DefaultValue,
		DynamicField_AssignedValue,
		DynamicField_ReplaceCharacter,
		DynamicField_IsDynamic,
		DynamicField_IdItem
			
		FROM Items_Templates T WITH(NOLOCK) 
		
		INNER JOIN Items_Configuration IC WITH(NOLOCK) ON
		T.Id_Family = IC.Id_Family AND 
		T.Id_Category = IC.Id_Category AND 
		T.Id_Line = IC.Id_Line AND
		T.Item_Template = IC.Id_Item
		
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

		INNER JOIN Cat_Item I  WITH(NOLOCK) ON		
		T.Id_Item = I.Id_Item
		--AND I.Status = 1 AZR 20221003 Se omite ya que cuando se trata de activar no se muestra 

		INNER JOIN Cat_Prices_Lists P WITH(NOLOCK) ON 
		T.Id_Price_List = P.Id_Price_List AND 
		P.Id_Language = @pvIdLanguageUser

		INNER JOIN Cat_Item_Classes ICL WITH(NOLOCK) ON 
		I.Id_Item_Class = ICL.Id_Item_Class
		AND ICL.Status = 1

		INNER JOIN Cat_Item_SubClasses ISCL WITH(NOLOCK) ON 
		I.Id_Item_Class = ISCL.Id_Item_Class AND
		I.Id_Item_SubClass = ISCL.Id_Item_SubClass
		AND ISCL.Status = 1
			
		WHERE 
		(@pvItemTemplate = ''   OR T.Item_Template = @pvItemTemplate ) AND 
		(@pvIdFamily = ''		OR T.Id_Family = @pvIdFamily ) AND 
		(@pvIdItem = ''			OR T.Id_Item = @pvIdItem ) AND  -- 20240310 -- DynamicFields
		(T.DynamicField_IsDynamic = @pbDynamicFieldIsDynamic) -- 20240310 -- DynamicFields
		--***AQUI SE COMENTO*** OR T.DynamicField_IsDynamic IS NULL
		ORDER BY I.Id_Item_Class, I.Id_Item_SubClass, T.Id_Family , T.Id_Category , T.Id_Line , T.[Required] ASC ,T.[Default] DESC, T.Id_Item ASC
		
	END

	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'RC'
	BEGIN
		DECLARE @vIdVoltageOrig		Varchar(10) = (SELECT Id_Voltage  FROM Quotation WHERE Folio = @piFolioOrig AND Version = @piVersionOrig)
		DECLARE @vIdPlugOrig		Varchar(10) = (SELECT Id_Plug	  FROM Quotation WHERE Folio = @piFolioOrig AND Version = @piVersionOrig)
		DECLARE @vIdLanguageOrig	Varchar(10) = (SELECT Id_Language FROM Quotation WHERE Folio = @piFolioOrig AND Version = @piVersionOrig)

		DECLARE @vIdVoltageClon		Varchar(10) = (SELECT Id_Voltage  FROM Quotation WHERE Folio = @piFolioClon AND Version = @piVersionClon) 
		DECLARE @vIdPlugClon		Varchar(10) = (SELECT Id_Plug	  FROM Quotation WHERE Folio = @piFolioClon AND Version = @piVersionClon)
		DECLARE @vIdLanguageClon	Varchar(10) = (SELECT Id_Language FROM Quotation WHERE Folio = @piFolioClon AND Version = @piVersionClon)

		SELECT
			T.Item_Template,
			Item_Desc =I.Short_Desc,
			I.Id_Item_Class, 
			Item_Class_Desc = ICL.Short_Desc,
			I.Id_Item_SubClass, 
			Item_SubClass_Desc = ISCL.Short_Desc,
			FCL.Id_Family,
			Family_Desc = F.Short_Desc,
			FCL.Id_Category,
			Category_Desc = C.Short_Desc,
			FCL.Id_Line,
			Line_Desc = L.Short_Desc,
			T.Id_Price_List,
			Price_List_Desc = P.Short_Desc,
			T.Id_Item,		
			QD.Id_Item,	
			I.Image_Path,
			[Required],
			[Default],
			Price = ( CASE WHEN QD.Id_Item IS NULL THEN T.Price * @fExchange_Rate
						   ELSE QD.Price
					  END),
			Standard_Cost =  ( CASE WHEN QD.Id_Item IS NULL THEN T.Standard_Cost *@fExchange_Rate
									ELSE QD.Standard_Cost
								END),

			Quantity =  (CASE
							------------------------------------------------------------------------------------------------------------------------------
							WHEN  I.Id_Item_SubClass  = 'VOLTAGE' AND T.Id_Item = @vIdVoltageClon THEN  (	SELECT Quantity FROM Quotation_Detail 
																											WHERE Folio = @piFolioOrig 
																											AND Version = @piVersionOrig 
																											AND Item_Template = @pvItemTemplate 
																											AND Id_Item = @vIdVoltageOrig 
																											AND Id_Detail = QD.Id_Detail)
							WHEN  I.Id_Item_SubClass  = 'VOLTAGE' AND T.Id_Item = QD.Id_Item THEN T.Quantity
							------------------------------------------------------------------------------------------------------------------------------
							
							WHEN  I.Id_Item_SubClass  = 'PLUG' AND T.Id_Item = @vIdPlugClon THEN (	SELECT Quantity FROM Quotation_Detail 
																											WHERE Folio = @piFolioOrig 
																											AND Version = @piVersionOrig 
																											AND Item_Template = @pvItemTemplate 
																											AND Id_Item = @vIdPlugOrig 
																											AND Id_Detail = QD.Id_Detail)
							WHEN  I.Id_Item_SubClass  = 'PLUG' AND T.Id_Item = QD.Id_Item THEN T.Quantity

							------------------------------------------------------------------------------------------------------------------------------
							WHEN  I.Id_Item_SubClass  = 'LANGUAGE' AND T.Id_Item = @vIdLanguageClon THEN (	SELECT Quantity FROM Quotation_Detail 
																											WHERE Folio = @piFolioOrig 
																											AND Version = @piVersionOrig 
																											AND Item_Template = @pvItemTemplate 
																											AND Id_Item = @vIdLanguageOrig 
																											AND Id_Detail = QD.Id_Detail)
							WHEN  I.Id_Item_SubClass  = 'LANGUAGE' AND T.Id_Item = QD.Id_Item THEN T.Quantity
							------------------------------------------------------------------------------------------------------------------------------
							ELSE
								(CASE WHEN QD.Id_Item IS NULL THEN T.Quantity
										ELSE QD.Quantity
								END)
						 END
						),
			FCL.Modify_By,
			FCL.Modify_Date,
			FCL.Modify_IP,
			Status_Commercial_Release = ISNULL((SELECT SCR.Short_Desc 
												FROM Commercial_Release CR
												INNER JOIN Cat_Status_Commercial_Release SCR ON
												CR.Id_Status_Commercial_Release = SCR.Id_Status_Commercial_Release AND
												SCR.Id_Language = @pvIdLanguageUser
												WHERE Id_Item = T.Id_Item AND Id_Country = @pvIdCountryComercialRealease ), @vStsAvailable ),
			DynamicField_DefaultValue,
			DynamicField_AssignedValue,
			DynamicField_ReplaceCharacter,
			DynamicField_IsDynamic,
			DynamicField_IdItem
			
		FROM Items_Templates T WITH(NOLOCK) 

		LEFT OUTER JOIN Quotation_Detail QD WITH(NOLOCK) ON
		T.Item_Template = QD.Item_Template AND
		T.Id_Item = QD.Id_Item AND
		QD.Folio = @piFolioOrig AND QD.Version = @piVersionOrig
		
		INNER JOIN Items_Configuration IC WITH(NOLOCK) ON
		T.Id_Family = IC.Id_Family AND 
		T.Id_Category = IC.Id_Category AND 
		T.Id_Line = IC.Id_Line AND
		T.Item_Template = IC.Id_Item
		
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

		INNER JOIN Cat_Item I  WITH(NOLOCK) ON		
		T.Id_Item = I.Id_Item
		AND I.Status = 1

		INNER JOIN Cat_Prices_Lists P WITH(NOLOCK) ON 
		T.Id_Price_List = P.Id_Price_List AND 
		P.Id_Language = @pvIdLanguageUser

		INNER JOIN Cat_Item_Classes ICL WITH(NOLOCK) ON 
		I.Id_Item_Class = ICL.Id_Item_Class
		AND ICL.Status = 1

		INNER JOIN Cat_Item_SubClasses ISCL WITH(NOLOCK) ON 
		I.Id_Item_Class = ISCL.Id_Item_Class AND
		I.Id_Item_SubClass = ISCL.Id_Item_SubClass
		AND ISCL.Status = 1
			
		WHERE 
		(@pvItemTemplate = ''   OR T.Item_Template = @pvItemTemplate ) AND 
		(@pvIdFamily = ''		OR T.Id_Family = @pvIdFamily ) AND		
		(@pvIdItem = ''			OR T.Id_Item = @pvIdItem ) AND  -- 20240310 -- DynamicFields
		(T.DynamicField_IsDynamic = @pbDynamicFieldIsDynamic OR T.DynamicField_IsDynamic IS NULL) -- 20240310 -- DynamicFields


		ORDER BY I.Id_Item_Class, I.Id_Item_SubClass, T.Id_Family , T.Id_Category , T.Id_Line , T.[Required] ASC ,T.[Default] DESC, T.Id_Item ASC
	END

	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'T'
	BEGIN
		SELECT DISTINCT
		T.Item_Template,
		Item_Desc =I.Short_Desc,
		I.Id_Item_Class, 
		Item_Class_Desc = ICL.Short_Desc,
		I.Id_Item_SubClass, 
		Item_SubClass_Desc = ISCL.Short_Desc,
		FCL.Id_Category,
		Category_Desc = C.Short_Desc,
		FCL.Id_Line,
		Line_Desc = L.Short_Desc,
		T.Id_Price_List,
		Price_List_Desc = P.Short_Desc,
		T.Id_Item,		
		I.Image_Path,
		[Required],
		[Default],
		Price =	Price * @fExchange_Rate,
		Standard_Cost = Standard_Cost *@fExchange_Rate,
		T.Quantity,
		FCL.Modify_By,
		FCL.Modify_Date,
		FCL.Modify_IP,
		Status_Commercial_Release = ISNULL((SELECT SCR.Short_Desc 
											FROM Commercial_Release CR
											INNER JOIN Cat_Status_Commercial_Release SCR ON
											CR.Id_Status_Commercial_Release = SCR.Id_Status_Commercial_Release AND
											SCR.Id_Language = @pvIdLanguageUser
											WHERE Id_Item = T.Id_Item AND Id_Country = @pvIdCountryComercialRealease ), @vStsAvailable ),
		DynamicField_DefaultValue,
		DynamicField_AssignedValue,
		DynamicField_ReplaceCharacter,
		DynamicField_IsDynamic,
		DynamicField_IdItem
			
		FROM Items_Templates T WITH(NOLOCK) 
		
		INNER JOIN Items_Configuration IC WITH(NOLOCK) ON
		T.Id_Family = IC.Id_Family AND 
		T.Id_Category = IC.Id_Category AND 
		T.Id_Line = IC.Id_Line AND
		T.Item_Template = IC.Id_Item
		
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

		INNER JOIN Cat_Item I  WITH(NOLOCK) ON		
		T.Id_Item = I.Id_Item
		AND I.Status = (CASE WHEN @vItemTemplateClass LIKE '%PACK%' THEN I.Status ELSE 1 END)-- QUITAR STATUS CUANDO SEA PAQUETE

		INNER JOIN Cat_Prices_Lists P WITH(NOLOCK) ON 
		T.Id_Price_List = P.Id_Price_List AND 
		P.Id_Language = @pvIdLanguageUser

		INNER JOIN Cat_Item_Classes ICL WITH(NOLOCK) ON 
		I.Id_Item_Class = ICL.Id_Item_Class
		AND ICL.Status = 1

		INNER JOIN Cat_Item_SubClasses ISCL WITH(NOLOCK) ON 
		I.Id_Item_Class = ISCL.Id_Item_Class AND
		I.Id_Item_SubClass = ISCL.Id_Item_SubClass
		AND ISCL.Status = 1
			
		WHERE 
		(@pvItemTemplate = ''   OR T.Item_Template = @pvItemTemplate ) AND 
		(@pvIdItem = ''			OR T.Id_Item = @pvIdItem ) 
		--***AQUI SE COMENTO*** AND  -- 20240310 -- DynamicFields  
		--***AQUI SE COMENTO*** (T.DynamicField_IsDynamic = @pbDynamicFieldIsDynamic OR T.DynamicField_IsDynamic IS NULL) -- 20240310 -- DynamicFields

		ORDER BY I.Id_Item_Class, I.Id_Item_SubClass, FCL.Id_Category, FCL.Id_Line, T.[Required] ASC ,T.[Default] DESC, T.Id_Item ASC
	
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		DELETE Items_Templates WHERE Item_Template = @pvItemTemplate

		INSERT INTO Items_Templates(
			Item_Template,
			Id_Family,
			Id_Category,
			Id_Line,
			Id_Item,
			Id_Price_List,
			[Required],
			[Default],
			Price,
			Standard_Cost,
			Quantity,
			DynamicField_DefaultValue,
			DynamicField_AssignedValue,
			DynamicField_ReplaceCharacter,
			DynamicField_IsDynamic,
			DynamicField_IdItem,
			Modify_By,
			Modify_Date,
			Modify_IP)

		SELECT 
			Item_Template,
			Id_Family,
			Id_Category,
			Id_Line,
			Id_Item,
			Id_Price_List,
			[Required],
			[Default],
			Price,
			Standard_Cost,
			Quantity,
			DynamicField_DefaultValue		= NULL,
			DynamicField_AssignedValue		= NULL,
			DynamicField_ReplaceCharacter	= NULL,
			DynamicField_IsDynamic			= 0, -- Modification 23/04/24 (Vic, Angel)
			DynamicField_IdItem				= NULL,
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtItemsTemplates
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
	--Load Records (Update Price and Standard_Cost)
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'L'
	BEGIN
		
		UPDATE T
		SET	T.Price			= L.Price,
			T.Standard_Cost = L.Standard_Cost,
			T.Modify_By		= @pvUser,
			T.Modify_Date	= GETDATE(),
			T.Modify_IP		= @pvIP
		FROM Items_Templates T
		INNER JOIN @pudtItemsTemplates L ON 
		T.Item_Template		= L.Item_Template AND 
		T.Id_Family			= L.Id_Family AND
		T.Id_Category		= L.Id_Category AND
		T.Id_Line			= L.Id_Line AND
		T.Id_Item			= L.Id_Item AND
		T.Id_Price_List		= L.Id_Price_List 		
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

	IF @pvOptionCRUD <> 'R' AND @pvOptionCRUD <> 'T' AND @pvOptionCRUD <> 'RC'
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