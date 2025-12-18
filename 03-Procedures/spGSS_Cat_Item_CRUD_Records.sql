USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_Cat_Item_CRUD_Records]    Script Date: 12/16/2025 6:52:45 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Autor:		Angel Gutierrez
Desc:		GSS_Cat_Item | Create - Read - Upadate - Delete 
Date:		11/09/2025
Example:
			EXEC spGSS_Cat_Item_CRUD_Records @pvOptionCRUD		= 'C',
									@pvIdLanguageUser	= 'ANG', 
									@pvIdItem			= 'TST121201', 
									@pvIdCountry		= 'US' , 
									@pvIdItemClass		= 'GSSPROD', 
									@pvIdItemSubClass	= 'PROD', 
									@pvIdDiscountCategory = 'GSSNA',
									@pvIdCountryPackage = '',
									@pvIdItemRelated    = '',
									@pvShortDesc		= 'Test 12122501', 
									@pvLongDesc			= 'Test 12122501 Long Desc', 
									@pvModel			= 'Model',
									@pvSpecifications	= 'Specs',
									@pvWeight			= '12 KG',
									@pvMeasurements		= '125 CM',
									@pvImagePath		= '',
									@pbStatus			= 1, 
									@pvItemSPR			= '0',
									@pvUser				= 'ANGUTIERRE', 
									@pvIP				='TESTING',
									@pfPrice			= 12345,
									@pfStandardCost		= 10,
									@pbOnRequest		= 0,
									@pvCurrency			= 'EUR';

			EXEC spGSS_Cat_Item_CRUD_Records	@pvOptionCRUD			= 'R', 
									@pvFamily				= 'ORLIGHTS', 
									@pvLine					= 'HELUXPRO25', 
									@pvLevel3Parent			= 'HELPRCEIVE',
									@pvLevel4Parent			= 'CEANRACEI',
									@pvLevel5Parent			= 'SOLOINSTA',
									@pvShortDesc			= '',
									@pvIdItemClass			= 'GSSPROD',
									@pvIdItemSubClass		= 'PROD',
									@pvIdItem				= '';

			EXEC spGSS_Cat_Item_CRUD_Records	@pvOptionCRUD			= 'R', 
												@pvFamily				= '', 
												@pvLine					= '', 
												@pvLevel3Parent			= '',
												@pvLevel4Parent			= '',
												@pvLevel5Parent			= '',
												@pvShortDesc			= '',
												@pvIdItemClass			= '',
												@pvIdItemSubClass		= '',
												@pvIdItem				= '2069687'; 
 
			EXEC spGSS_Cat_Item_CRUD_Records @pvOptionCRUD		= 'U', 
									@pvIdLanguageUser	= 'ANG', 
									@pvIdItem			= 'TST121201', 
									@pvIdCountry		= 'US' , 
									@pvIdItemClass		= 'GSSPROD', 
									@pvIdItemSubClass	= 'PROD', 
									@pvIdDiscountCategory = 'GSSNA',
									@pvIdCountryPackage = '',
									@pvIdItemRelated    = '',
									@pvShortDesc		= 'Test 12122501', 
									@pvLongDesc			= 'Test 12122501 Long Desc', 
									@pvModel			= 'Model',
									@pvSpecifications	= 'Specs',
									@pvWeight			= '12 KG',
									@pvMeasurements		= '125 CM',
									@pvImagePath		= '',
									@pbStatus			= 1, 
									@pvItemSPR			= '0',
									@pvUser				= 'ANGUTIERRE', 
									@pvIP				='TESTING',
									@pfPrice			= 12345,
									@pfStandardCost		= 10,
									@pbOnRequest		= 0,
									@pvCurrency			= 'EUR';

*/
CREATE PROCEDURE [dbo].[spGSS_Cat_Item_CRUD_Records]
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10)		= 'ANG',
@pvIdItem						Varchar(50)		= '',
@pvIdItemDetalle				Varchar(50)		= '',
@pvIdCountry					Varchar(10)		= 'All',
@pvIdItemClass					Varchar(10)		= '',
@pvIdItemSubClass				Varchar(10)		= '',
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
@pfPrice						Float			= 0,
@pfStandardCost					Float			= 0,
@pvCurrency						Varchar(10)		= '',
@pbOnRequest					Bit				= 0,
@pvFamily						Varchar(10)		= '',
@pvLine							Varchar(10)		= '',
@pvLevel3Parent					Varchar(10)		= '',
@pvLevel4Parent					Varchar(10)		= '',
@pvLevel5Parent					Varchar(10)		= '',
--------------------------------------------------------------
@pvIdCountryComercialRealease	Varchar(10)		= ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------

	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @iIdStsAvailable	Varchar(50)	= 1 -- Avalible/Disponible
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
			INSERT INTO GSS_Cat_Item(
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
				Modify_IP, 
				Price,
				Standard_Cost,
				Id_Currency,
				Id_Language,
				On_Request
				)
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
				@pvIP,
				@pfPrice,
				@pfStandardCost,
				@pvCurrency,
				'ANG',
				@pbOnRequest
				)

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

		WITH Base AS (
				SELECT
					h.Id_Category_Hierarchy,
					h.Id_Category,
					h.Parent,
					h.[Level],
					h.[Order],
					h.[Path],
					h.[Status],
					ROW_NUMBER() OVER (
						PARTITION BY h.Parent
						ORDER BY h.[Order], h.Id_Category_Hierarchy
					) AS SiblingSeq,
					c.Short_Desc
				FROM GSS_Categories_Hierarchies h
				INNER JOIN GSS_Cat_Categories c
					ON h.Id_Category = c.Id_Category
			),
			Tree AS (
				-- Anchor
				SELECT
					b.Id_Category_Hierarchy,
					b.Id_Category,
					b.Parent,
					b.[Level],
					b.[Order],
					CAST(b.Id_Category AS VARCHAR(MAX)) AS Path,   
					b.[Status],
					b.SiblingSeq,
					b.Short_Desc,
					CAST(b.Short_Desc AS VARCHAR(MAX)) AS Path_Desc,
					CAST(RIGHT('000000' + CAST(b.SiblingSeq AS VARCHAR(10)), 6) AS VARCHAR(1000)) AS SortKey
				FROM Base b
				WHERE b.Parent = 0

				UNION ALL

				-- Recursivo
				SELECT
					ch.Id_Category_Hierarchy,
					ch.Id_Category,
					ch.Parent,
					ch.[Level],
					ch.[Order],
					CAST(t.Path + '|' + CAST(ch.Id_Category AS VARCHAR(50)) AS VARCHAR(MAX)) AS Path,   
					ch.[Status],
					ch.SiblingSeq,
					ch.Short_Desc,
					CAST(t.Path_Desc + '|' + ch.Short_Desc AS VARCHAR(MAX)) AS Path_Desc,               
					CAST(t.SortKey + '.' + RIGHT('000000' + CAST(ch.SiblingSeq AS VARCHAR(10)), 6) AS VARCHAR(1000)) AS SortKey
				FROM Base ch
				INNER JOIN Tree t
					ON ch.Parent = t.Id_Category_Hierarchy
			)
		SELECT
			--REPLICATE('   ', T.[Level]-1) + CAST(T.Id_Category AS VARCHAR(50)) AS TreeView,
			--T.Id_Category_Hierarchy,
			--T.Id_Category,
			--REPLICATE('   ', T.[Level]-1) + CAST(T.Short_Desc AS VARCHAR(50)) AS CategoryTreeView,
			--T.Short_Desc AS Category,
			--T.Parent AS Parent_Id,
			--CASE 
				--WHEN GCH.Id_Category IS NULL THEN '#'
				--ELSE CAST(GCH.Id_Category AS VARCHAR(100))
			--END AS Parent,
			--T.[Level],
			--T.[Path],
			--T.Path_Desc,

			-- Parents parsed with STRING_SPLIT (names)
			P.Parent1,
			P.Parent2,
			P.Parent3,
			P.Parent4,
			P.Parent5,

			-- Parents parsed with STRING_SPLIT (Ids)
			PI.ParentId1,
			PI.ParentId2,
			PI.ParentId3,
			PI.ParentId4,
			PI.ParentId5,

			--T.[Status] AS Hierarchy_Status,
			--T.[Order],
			--T.SortKey,
			GCI.Id_Item_Class,
			CIC.Short_Desc AS Class,
			GCI.Id_Item_SubClass,
			CISC.Short_Desc AS SubClass,
			GCI.Id_Item,
			GCI.Short_Desc,
			GCI.Long_Desc,
			GCI.Id_Currency,
			CC.Short_Desc AS Currency,
			GCI.Specifications, 
			GCI.On_Request, 
			GCI.Model, 
			GCI.[Weight], 
			GCI.Measurements, 
			GCI.Id_Discount_Category,
			GCI.Id_Country, 
			GCI.Price,
			GCI.Standard_Cost,
			GCI.[Status],
			GCI.Modify_By,
			GCI.Modify_Date,
			GCI.Modify_IP
			--GCC.PDF_Layout
		FROM Tree T
		OUTER APPLY (
			SELECT
				MAX(CASE WHEN rn = 1 THEN token END) AS Parent1,
				MAX(CASE WHEN rn = 2 THEN token END) AS Parent2,
				MAX(CASE WHEN rn = 3 THEN token END) AS Parent3,
				MAX(CASE WHEN rn = 4 THEN token END) AS Parent4,
				MAX(CASE WHEN rn = 5 THEN token END) AS Parent5
			FROM (
				SELECT 
					ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn,
					value AS token
				FROM STRING_SPLIT(T.Path_Desc, '|')
			) s
		) P
		OUTER APPLY (
			SELECT
				MAX(CASE WHEN rn = 1 THEN token END) AS ParentId1,
				MAX(CASE WHEN rn = 2 THEN token END) AS ParentId2,
				MAX(CASE WHEN rn = 3 THEN token END) AS ParentId3,
				MAX(CASE WHEN rn = 4 THEN token END) AS ParentId4,
				MAX(CASE WHEN rn = 5 THEN token END) AS ParentId5
			FROM (
				SELECT 
					ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn,
					value AS token
				FROM STRING_SPLIT(T.Path, '|')
			) s
		) PI
		LEFT JOIN GSS_Cat_Categories AS GCC 
			ON T.Id_Category = GCC.Id_Category
		LEFT JOIN GSS_Categories_Hierarchies AS GCH 
			ON T.Parent = GCH.Id_Category_Hierarchy
		LEFT JOIN GSS_Items_Configuration AS GIC
			ON T.Id_Category_Hierarchy = GIC.Id_Category_Hierarchy
		INNER JOIN GSS_Cat_Item AS GCI -- LEFT JOIN For PDF Query
			ON GIC.Id_Item = GCI.Id_Item
		INNER JOIN Cat_Item_Classes AS CIC 
			ON GCI.Id_Item_Class = CIC.Id_Item_Class
		INNER JOIN Cat_Item_SubClasses AS CISC 
			ON GCI.Id_Item_SubClass = CISC.Id_Item_SubClass
				AND CISC.Id_Item_Class = CIC.Id_Item_Class
		INNER JOIN Cat_Currencies AS CC 
			ON CC.Id_Currency = GCI.Id_Currency
				AND CC.Id_Language = @pvIdLanguageUser
		WHERE
				(@pvFamily = '' OR ParentId1 = @pvFamily) AND
				(@pvLine = '' OR ParentId2 = @pvLine) AND
				(@pvLevel3Parent = '' OR ParentId3 = @pvLevel3Parent) AND
				(@pvLevel4Parent = '' OR ParentId4 = @pvLevel4Parent) AND
				(@pvLevel5Parent = '' OR ParentId5 = @pvLevel5Parent) AND
				(@pvShortDesc = '' OR GCI.Short_Desc LIKE '%' + @pvShortDesc + '%') AND
				(@pvIdItemClass = '' OR GCI.Id_Item_Class = @pvIdItemClass) AND
				(@pvIdItemSubClass = '' OR GCI.Id_Item_SubClass = @pvIdItemSubClass) AND
				(@pvIdItem = '' OR GCI.Id_Item = @pvIdItem)
		ORDER BY T.SortKey;
	
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE GSS_Cat_Item 
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
				Modify_IP			= @pvIP,
				Price				= @pfPrice,
				Standard_Cost		= @pfStandardCost,
				Id_Currency			= @pvCurrency,
				Id_Language			= 'ANG',
				On_Request			= @pbOnRequest
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
