USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spFLC_Customer_Categories_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spFLC_Customer_Categories_CRUD_Records'

IF OBJECT_ID('[dbo].[spFLC_Customer_Categories_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spFLC_Customer_Categories_CRUD_Records
GO
/*
Autor:		Alejandro Zepeda
Desc:		FLC_Customer_Categories | Create - Read - Upadate - Delete 
Date:		08/10/2023
Example:
			DECLARE  @udtCustomerCategories  UDT_FLC_Customer_Categories 

			INSERT INTO @udtCustomerCategories VALUES (2,'VISCAR','ABC',1)
			INSERT INTO @udtCustomerCategories VALUES (2,'EENT',NULL,1)
			INSERT INTO @udtCustomerCategories VALUES (2,'ENDOSC','DEF',1)
			INSERT INTO @udtCustomerCategories VALUES (2,'LIGHTI',NULL,1)
			INSERT INTO @udtCustomerCategories VALUES (2,'WOMHEA','GHI',1)
			

			EXEC spFLC_Customer_Categories_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @piIdCustomer = 1, @pudtCustomerCategories = @udtCustomerCategories, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spFLC_Customer_Categories_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piIdCustomer = 2
			EXEC spFLC_Customer_Categories_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piIdCustomer = 18, @pbStatus = 1
			EXEC spFLC_Customer_Categories_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piIdCustomer = 1, @pvIdFLCCategory = 'ABPMSY'
			EXEC spFLC_Customer_Categories_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @piIdCustomer = 1, @pudtCustomerCategories = @udtCustomerCategories, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			
'

Consideraciones:
			En caso de que la PK de la tabla de FLC_Customer_Categories se lleve
*/
CREATE PROCEDURE [dbo].spFLC_Customer_Categories_CRUD_Records
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10) = '',
@piIdCustomer			Int = 0,
@pvIdFLCCategory		Varchar(10) = '',
@pudtCustomerCategories	UDT_FLC_Customer_Categories Readonly,
@pbStatus				Bit			= NULL,
@pvUser					Varchar(50) = '',
@pvIP					Varchar(20) = ''
AS
SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vjsonUDT			NVarchar(MAX)	= (SELECT * FROM @pudtCustomerCategories FOR JSON AUTO);
	
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'FLC_Customer_Categories - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spFLC_Customer_Categories_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piIdCustomer = '" + ISNULL(CAST(@piIdCustomer AS VARCHAR),'NULL') + "', @pvIdFLCCategory = '" + ISNULL(@pvIdFLCCategory,'NULL') + "', @pudtCustomerCategories = '" + ISNULL(@vjsonUDT,'NULL') + "',  @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C' OR @pvOptionCRUD = 'U'
	BEGIN

		DELETE FLC
		FROM FLC_Customer_Categories FLC
		INNER JOIN @pudtCustomerCategories UDT ON
		FLC.Id_Customer = UDT.Id_Customer
		AND FLC.Id_FLC_Category = UDT.Id_FLC_Category


		INSERT INTO FLC_Customer_Categories(
			Id_Customer,
			Id_FLC_Category,
			Category_Discount,
			[Status],
			Modify_By,
			Modify_Date,
			Modify_IP)
		SELECT
			Id_Customer,
			Id_FLC_Category,
			Category_Discount,
			[Status],
			@pvUser,
			GETDATE(),				
			@pvIP
		FROM @pudtCustomerCategories
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
			Id_Customer = @piIdCustomer,
			Customer = (SELECT [Name] FROM FLC_Cat_Customers WHERE Id_Customer = @piIdCustomer),
			C.Id_FLC_Category,
			FLC_Category = C.Short_Desc,
			IC.Category_Discount,
			[Status] = ISNULL(IC.[Status],0),
			IC.Modify_Date,
			IC.Modify_By,
			IC.Modify_IP
		FROM FLC_Cat_Categories C 

		LEFT OUTER JOIN  FLC_Customer_Categories IC  ON
		C.Id_FLC_Category = IC.Id_FLC_Category AND
		IC.Id_Customer = @piIdCustomer
		-- Modif Ángel Gutiérrez 11/12/23
		INNER JOIN FLC_Cat_Categories AS CC ON
		C.Id_FLC_Category = CC.Id_FLC_Category 
		-----------------------------------
		WHERE C.[Status] = 1 
		AND (@pvIdFLCCategory = '' OR C.Id_FLC_Category = @pvIdFLCCategory)	
		AND (@pbStatus IS NULL OR IC.[Status] = @pbStatus)		
		ORDER BY CC.[Order], -- Modif Ángel Gutiérrez 11/12/23
				C.Id_FLC_Category
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
