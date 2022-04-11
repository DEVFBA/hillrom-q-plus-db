USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_Header_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_Header_CRUD_Records'

IF OBJECT_ID('[dbo].[spQuotation_Header_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_Header_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		spQuotation Header | Create - Read - Upadate - Delete 
Date:		06/02/2021
Example:

	DECLARE  @udtQuotationHeader  UDT_Quotation_Header 

	select * from @udtQuotationHeader
	INSERT @udtQuotationHeader
	SELECT * FROM Quotation_Header
	WHERE Folio = 9 AND Version = 1		

	EXEC spQuotation_Header_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @piFolio = 9, @piVersion = 1, @pudtQuotationHeader = @udtQuotationHeader, @pvUser = 'RUGOMEZ', @pvIP ='192.168.1.254'
	EXEC spQuotation_Header_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG'
	EXEC spQuotation_Header_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piFolio = 80, @piVersion = 1											
	EXEC spQuotation_Header_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piFolio = 80, @piVersion = 1, @pvIdCountry = 'CR'		
			

*/
CREATE PROCEDURE [dbo].spQuotation_Header_CRUD_Records
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10) = '',
@piFolio				Int			= 0,
@piVersion				Int			= 0,
@pvIdCountry			Varchar(10) = '',
@pudtQuotationHeader	UDT_Quotation_Header Readonly,
@pvUser					Varchar(50) = '',
@pvIP					Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @iNumRegistros		Int			= (SELECT COUNT(*) FROM @pudtQuotationHeader)
	DECLARE @tblQuotationHeader	Table(Folio int, [Version] smallint, Id_Header bigint, Item_Template varchar(50), Id_Header_New smallint)
	
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Quotation Header - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spQuotation_Header_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piFolio = '" + ISNULL(CAST(@piFolio AS VARCHAR),'NULL') + "', @piVersion = '" + ISNULL(CAST(@piVersion AS VARCHAR),'NULL') + "', @pudtQuotationHeader = '" + ISNULL(CAST(@iNumRegistros AS VARCHAR),'NULL') + " rows affected', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C' OR @pvOptionCRUD = 'U'
	BEGIN
		----------------
		--Delete tables
		----------------
		DELETE Quotation_Detail	WHERE Folio = @piFolio and [Version] = @piVersion
		DELETE Quotation_Header	WHERE Folio = @piFolio and [Version] = @piVersion

		----------------
		--Regenerate new Header_Id
		----------------
		INSERT INTO @tblQuotationHeader (Folio, [Version], Item_Template, Id_Header, Id_Header_New)
		SELECT	Folio,
				[Version], 
				Item_Template,
				Id_Header,
				Id_Header_New = (ROW_NUMBER() OVER(ORDER BY Id_Header))	
		FROM @pudtQuotationHeader
		Order by Id_Header

		----------------
		--Insert Header
		----------------
		INSERT INTO Quotation_Header (
			Folio,
			[Version],
			Id_Header,
			Item_Template,
			Discount,
			Quantity,
			Allocation,
			Transfer_Price,
			Transport_Cost,
			Taxes,
			Landed_Cost,
			Local_Transport,
			[Services],
			Warehousing,
			Local_Cost,
			Final_Price,
			Total,
			Margin,
			Amount_Warranty,
			Id_Year_Warranty,
			Percentage_Warranty,
			General_Taxes_Percentage,
			General_Taxes_Total,
			General_Taxes_Warranty,
			Grand_Total,
			Item_SPR,
			Modify_By,
			Modify_Date,
			Modify_IP)
		SELECT 
			UDT.Folio,
			UDT.[Version],
			TBL.Id_Header_New,
			UDT.Item_Template,
			Discount,
			Quantity,
			Allocation,
			Transfer_Price,
			Transport_Cost,
			Taxes,
			Landed_Cost,
			Local_Transport,
			[Services],
			Warehousing,
			Local_Cost,
			Final_Price,
			Total,
			Margin,
			Amount_Warranty,
			Id_Year_Warranty,
			Percentage_Warranty,
			General_Taxes_Percentage,
			General_Taxes_Total,
			General_Taxes_Warranty,
			Grand_Total,
			Item_SPR,
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtQuotationHeader UDT
		INNER JOIN @tblQuotationHeader TBL ON
		UDT.Folio = TBL.Folio AND 
		UDT.[Version] = TBL.[Version] AND
		UDT.Id_Header = TBL.Id_Header AND
		UDT.Item_Template =  TBL.Item_Template

	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R' AND @pvIdCountry = ''
	BEGIN
		SELECT 
			QH.Folio,
			QH.[Version],
			QH.Id_Header,
			QH.Item_Template,
			Item_Desc = I.Short_Desc,
			I.Id_Item_Class, 
			Item_Class_Desc = ICL.Short_Desc,
			I.Id_Item_SubClass, 
			Item_SubClass_Desc = ISCL.Short_Desc,
			IC.Id_Line,
			QH.Discount,
			QH.Quantity,
			QH.Allocation,
			QH.Transfer_Price,
			QH.Transport_Cost,
			QH.Taxes,
			QH.Landed_Cost,
			QH.Local_Transport,
			QH.[Services],
			QH.Warehousing,
			QH.Local_Cost,
			QH.Final_Price,
			QH.Total,
			QH.Margin,
			QH.Amount_Warranty,
			QH.Id_Year_Warranty,
			QH.Percentage_Warranty,
			QH.General_Taxes_Percentage,
			QH.General_Taxes_Total,
			QH.General_Taxes_Warranty,
			QH.Grand_Total,
			QH.Item_SPR,
			Extended_Warranties = ISNULL((SELECT DISTINCT 1 FROM Cat_Extended_Warranties WHERE Id_Line = IC.Id_Line ),0),
			Accessory_Message_Family =  ISNULL(F.Accessory_Message,''),
			Accessory_Message_Item	=  ISNULL(I.Accessory_Message,''),
			Line_Percentage_Taxes =  ISNULL((SELECT Percentage FROM Cat_Line_Taxes WHERE Id_Line = IC.Id_Line  AND Id_Country = @pvIdCountry AND Status = 1),0),
			QH.Modify_By,
			QH.Modify_Date,
			QH.Modify_IP
		FROM Quotation_Header QH
	
		INNER JOIN Cat_Item I ON
		QH.Item_Template = I.Id_Item

		INNER JOIN Items_Configuration IC  WITH(NOLOCK) ON
		I.Id_Item = IC.Id_Item
		AND IC.Status = 1

		INNER JOIN Cat_Families_Categories FCL WITH(NOLOCK) ON
		IC.Id_Family = FCL.Id_Family AND 
		IC.Id_Category = FCL.Id_Category AND 
		IC.Id_Line = FCL.Id_Line
		
		INNER JOIN Cat_Families F WITH(NOLOCK) ON 
		FCL.Id_Family = F.Id_Family

		INNER JOIN Cat_Item_Classes ICL WITH(NOLOCK) ON 
		I.Id_Item_Class = ICL.Id_Item_Class

		INNER JOIN Cat_Item_SubClasses ISCL WITH(NOLOCK) ON 
		I.Id_Item_Class = ISCL.Id_Item_Class AND
		I.Id_Item_SubClass = ISCL.Id_Item_SubClass


		WHERE	(@piFolio	= 0	OR QH.Folio	 = @piFolio) AND 
				(@piVersion	= 0	OR QH.[Version] = @piVersion) 
	
		ORDER BY  QH.Folio, QH.[Version], QH.Item_Template
		
	END

	--------------------------------------------------------------------
	--Reads Records with Country 
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R' AND  @pvIdCountry <> ''
	BEGIN
		SELECT 
			QH.Folio,
			QH.[Version],
			QH.Id_Header,
			QH.Item_Template,
			Item_Desc = I.Short_Desc,
			I.Id_Item_Class, 
			Item_Class_Desc = ICL.Short_Desc,
			I.Id_Item_SubClass, 
			Item_SubClass_Desc = ISCL.Short_Desc,
			IC.Id_Line,
			QH.Discount,
			QH.Quantity,
			QH.Allocation,
			QH.Transfer_Price,
			QH.Transport_Cost,
			QH.Taxes,
			QH.Landed_Cost,
			QH.Local_Transport,
			QH.[Services],
			QH.Warehousing,
			QH.Local_Cost,
			QH.Final_Price,
			QH.Total,
			QH.Margin,
			QH.Amount_Warranty,
			QH.Id_Year_Warranty,
			QH.Percentage_Warranty,
			QH.General_Taxes_Percentage,
			QH.General_Taxes_Total,
			QH.General_Taxes_Warranty,
			QH.Grand_Total,
			QH.Item_SPR,
			Extended_Warranties = ISNULL((SELECT DISTINCT 1 FROM Cat_Extended_Warranties WHERE Id_Line = IC.Id_Line ),0),
			Accessory_Message_Family =  ISNULL(F.Accessory_Message,''),
			Accessory_Message_Item	=  ISNULL(I.Accessory_Message,''),
			Line_Percentage_Taxes =  ISNULL((SELECT Percentage FROM Cat_Line_Taxes WHERE Id_Line = IC.Id_Line  AND Id_Country = @pvIdCountry AND Status = 1),0),
			QH.Modify_By,
			QH.Modify_Date,
			QH.Modify_IP
		FROM Quotation_Header QH
	
		INNER JOIN Cat_Item I ON
		QH.Item_Template = I.Id_Item

		INNER JOIN Items_Configuration IC  WITH(NOLOCK) ON
		I.Id_Item = IC.Id_Item
		AND IC.Status = 1

		INNER JOIN Cat_Families_Categories FCL WITH(NOLOCK) ON
		IC.Id_Family = FCL.Id_Family AND 
		IC.Id_Category = FCL.Id_Category AND 
		IC.Id_Line = FCL.Id_Line
		
		INNER JOIN Cat_Families F WITH(NOLOCK) ON 
		FCL.Id_Family = F.Id_Family

		INNER JOIN Cat_Item_Classes ICL WITH(NOLOCK) ON 
		I.Id_Item_Class = ICL.Id_Item_Class

		INNER JOIN Cat_Item_SubClasses ISCL WITH(NOLOCK) ON 
		I.Id_Item_Class = ISCL.Id_Item_Class AND
		I.Id_Item_SubClass = ISCL.Id_Item_SubClass

		INNER JOIN Commercial_Release CR ON
		QH.Item_Template = CR.Id_Item
		AND Id_Status_Commercial_Release <> 0
		AND CR.Id_Country = @pvIdCountry


		WHERE	(@piFolio	= 0	OR QH.Folio	 = @piFolio) AND 
				(@piVersion	= 0	OR QH.[Version] = @piVersion) 
	
		ORDER BY  QH.Folio, QH.[Version], QH.Item_Template
		
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
