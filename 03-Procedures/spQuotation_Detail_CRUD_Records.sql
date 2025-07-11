USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_Detail_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_Detail_CRUD_Records'

IF OBJECT_ID('[dbo].[spQuotation_Detail_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_Detail_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		spQuotation Detail | Create - Read - Upadate - Delete 
Date:		06/02/2021
Example:

	DECLARE  @udtQuotationDetail  UDT_Quotation_Detail

	INSERT @udtQuotationDetail (Folio,Version,Id_Header,Item_Template,Id_Detail,Id_Item,Quantity,Price,Stan)


	SELECT * FROM Quotation_Detail
	WHERE Folio = 6 AND Version = 1		

	select * from @udtQuotationDetail

	EXEC spQuotation_Detail_CRUD_Records @pvOptionCRUD = 'C', @piFolio = 6, @piVersion = 1, @pudtQuotationDetail = @udtQuotationDetail, @pvUser = 'RUGOMEZ', @pvIP ='192.168.1.254'

	EXEC spQuotation_Detail_CRUD_Records @pvOptionCRUD = 'R'
	EXEC spQuotation_Detail_CRUD_Records @pvOptionCRUD = 'R', @piFolio = 81, @piVersion = 1											
	EXEC spQuotation_Detail_CRUD_Records @pvOptionCRUD = 'R', @piFolio = 81, @piVersion = 1, @pvIdCountry = 'MX'	
			

*/
CREATE PROCEDURE [dbo].spQuotation_Detail_CRUD_Records
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10) = '',
@piFolio				Int			= 0,
@piVersion				Int			= 0,
@piIdHeader             Int			= 0,
@pvIdCountry			Varchar(10) = '',
@pudtQuotationDetail	UDT_Quotation_Detail Readonly,
@pvUser					Varchar(50) = '',
@pvIP					Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @iNumRegistros		Int			= (SELECT COUNT(*) FROM @pudtQuotationDetail)
	DECLARE @tblQuotationHeader	Table(Folio int, [Version] smallint, Id_Header bigint, Item_Template varchar(50))
	DECLARE @tblQuotationDetail	Table(Folio int, [Version] smallint, Id_Header bigint, Item_Template varchar(50), Id_Header_New smallint)
	
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Quotation Detail - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spQuotation_Detail_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piFolio = '" + ISNULL(CAST(@piFolio AS VARCHAR),'NULL') + "', @piVersion = '" + ISNULL(CAST(@piVersion AS VARCHAR),'NULL') + "', @pudtQuotationDetail = '" + ISNULL(CAST(@iNumRegistros AS VARCHAR),'NULL') + " rows affected', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C' OR @pvOptionCRUD = 'U'
	BEGIN
		----------------
		--Delete tables
		----------------
		DELETE Quotation_Detail	WHERE Folio = @piFolio and [Version] = @piVersion

		----------------
		--Regenerate new Header_Id
		----------------
		INSERT INTO @tblQuotationHeader (Folio, [Version], Item_Template, Id_Header)
		SELECT	DISTINCT 
				Folio,
				[Version], 
				Item_Template,
				Id_Header
		FROM @pudtQuotationDetail
		Order by Id_Header

		INSERT INTO @tblQuotationDetail (Folio, [Version], Item_Template, Id_Header, Id_Header_New)
		SELECT	DISTINCT 
				Folio,
				[Version], 
				Item_Template,
				Id_Header,
				Id_Header_New = (ROW_NUMBER() OVER(ORDER BY Id_Header))	
		FROM @tblQuotationHeader
		Order by Id_Header

		----------------
		--Insert Details
		----------------
		INSERT INTO Quotation_Detail (
			Folio,
			[Version],
			Id_Header,			
			Item_Template,
			Id_Detail,
			Id_Item,
			Quantity,
			Price,
			Standard_Cost,
			Kit_Items_Desc,
			Kit_Price,
			Kit_Standard_Cost,
			Modify_By,
			Modify_Date,
			Modify_IP)

		SELECT
			UDT.Folio,
			UDT.[Version],
			TBL.Id_Header_New,			
			UDT.Item_Template,
			Id_Detail,
			Id_Item,
			Quantity,
			Price,
			Standard_Cost,
			Kit_Items_Desc,
			Kit_Price,
			Kit_Standard_Cost,
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtQuotationDetail UDT
		INNER JOIN @tblQuotationDetail TBL ON
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
			QD.Folio,
			QD.[Version],
			QD.Id_Header,
			QD.Item_Template,
			QD.Id_Detail,
			QD.Id_Item,
			Item_Desc = I.Short_Desc,
			I.Id_Item_Class, 
			Item_Class_Desc = ICL.Short_Desc,
			I.Id_Item_SubClass, 
			Item_SubClass_Desc = ISCL.Short_Desc,
			QD.Quantity,
			QD.Price,
			QD.Standard_Cost,
			QD.Kit_Items_Desc,
			QD.Kit_Price,
			QD.Kit_Standard_Cost,
			QD.Modify_By,
			QD.Modify_Date,
			QD.Modify_IP
		FROM Quotation_Detail QD

		INNER JOIN Cat_Item I ON
		QD.Id_Item = I.Id_Item

		INNER JOIN Cat_Item_Classes ICL WITH(NOLOCK) ON 
		I.Id_Item_Class = ICL.Id_Item_Class

		INNER JOIN Cat_Item_SubClasses ISCL WITH(NOLOCK) ON 
		I.Id_Item_Class = ISCL.Id_Item_Class AND
		I.Id_Item_SubClass = ISCL.Id_Item_SubClass

		WHERE	(@piFolio	= 0	OR QD.Folio	 = @piFolio) AND 
				(@piVersion	= 0	OR QD.[Version] = @piVersion) AND
                (@piIdHeader	= 0	OR QD.Id_Header = @piIdHeader) 
	
		ORDER BY QD.Folio, QD.[Version], QD.Item_Template,QD.Id_Item
		
	END

	--------------------------------------------------------------------
	--Reads Records with Country 
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R' AND  @pvIdCountry <> ''
	BEGIN
		SELECT 
			QD.Folio,
			QD.[Version],
			QD.Id_Header,
			QD.Item_Template,
			QD.Id_Detail,
			QD.Id_Item,
			Item_Desc = I.Short_Desc,
			I.Id_Item_Class, 
			Item_Class_Desc = ICL.Short_Desc,
			I.Id_Item_SubClass, 
			Item_SubClass_Desc = ISCL.Short_Desc,
			QD.Quantity,
			QD.Price,
			QD.Standard_Cost,
			QD.Kit_Items_Desc,
			QD.Kit_Price,
			QD.Kit_Standard_Cost,
			QD.Modify_By,
			QD.Modify_Date,
			QD.Modify_IP
		FROM Quotation_Detail QD

		INNER JOIN Cat_Item I ON
		QD.Id_Item = I.Id_Item

		INNER JOIN Cat_Item_Classes ICL WITH(NOLOCK) ON 
		I.Id_Item_Class = ICL.Id_Item_Class

		INNER JOIN Cat_Item_SubClasses ISCL WITH(NOLOCK) ON 
		I.Id_Item_Class = ISCL.Id_Item_Class AND
		I.Id_Item_SubClass = ISCL.Id_Item_SubClass

		INNER JOIN Commercial_Release CR ON
		QD.Id_Item  = CR.Id_Item
		AND Id_Status_Commercial_Release <> 0
		AND CR.Id_Country = @pvIdCountry

		WHERE	(@piFolio	= 0	OR QD.Folio	 = @piFolio) AND 
				(@piVersion	= 0	OR QD.[Version] = @piVersion) 
	
		ORDER BY QD.Folio, QD.[Version], QD.Item_Template,QD.Id_Item
		
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
