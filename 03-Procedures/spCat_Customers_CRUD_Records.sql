USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Customers_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Customers_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Customers_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Customers_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Customers | Create - Read - Upadate - Delete 
Date:		22/01/2021
Example:
			spCat_Customers_CRUD_Records @pvOptionCRUD		= 'C', 
										@piIdCustomer		= 0, --automatic assignment
										@pvIdCountry		= 'MX',
										@pvIdCustomerType	= 'BILL',
										@pvName				= 'Alejandro Zepeda Rosas',
										@pnNumberJDE		= 9626,
										@pvAddressStreet	= 'COVE',
										@pvAddressInt		= '1',
										@pvAddressExt		= '',
										@pvAddressState		= 'Mexico',
										@pvAddressZipCode	= 05276,
										@pvAddressCity		= 'MEXICO',
										@pvAddressCounty	= 'HUIXQUILUCAN',
										@pvEmail			= 'KELBEROZ@HOTMAIL.COM',
										@pvPhoneNumber		= '5512864745',
										@pvContact			= 'NONGUNO',
										@pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

			spCat_Customers_CRUD_Records @pvOptionCRUD = 'R', @piIdCustomer	= 681, @pvUser = 'ALZEPEDA'
			
			spCat_Customers_CRUD_Records @pvOptionCRUD = 'R', @piIdCustomer	= 681,  @pvIdCountry = 'MX', @pvIdCustomerType = 'BILL'

			SELECT * FROM Cat_Customers

			spCat_Customers_CRUD_Records @pvOptionCRUD = 'R', 
										@pvIdLanguageUser = 'SPA',
										@pvUser = 'ALZEPEDA'
			
			spCat_Customers_CRUD_Records @pvOptionCRUD = 'U', 
										@piIdCustomer		= 681, --automatic assignment
										@pvIdCountry		= 'MX',
										@pvIdCustomerType	= 'BILL',
										@pvName				= 'Alejandro Zepeda Rosas',
										@pnNumberJDE		= 9626,
										@pvAddressStreet	= 'COVE',
										@pvAddressInt		= '1',
										@pvAddressExt		= '',
										@pvAddressState		= 'Mexico',
										@pvAddressZipCode	= 05276,
										@pvAddressCity		= 'MEXICO',
										@pvAddressCounty	= 'HUIXQUILUCAN',
										@pvEmail			= 'KELBEROZ@HOTMAIL.COM',
										@pvPhoneNumber		= '5512864744',
										@pvContact			= 'NINGUNO',
										@pbStatus = 0, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'
			

*/
CREATE PROCEDURE [dbo].spCat_Customers_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = 'ANG',
@piIdCustomer		Int			= 0,
@pvIdCountry		Varchar(10) = 'ALL',
@pvIdCustomerType	Varchar(10) = 'ALL',
@pvName				Varchar(255)= '',
@pnNumberJDE		Numeric		= 0,
@pvAddressStreet	Varchar(100)= '',
@pvAddressInt		Varchar(30) = '',
@pvAddressExt		Varchar(30) = '',
@pvAddressState		Varchar(50) = '',
@pvAddressZipCode	Varchar(12) = '',
@pvAddressCity		Varchar(50) = '',
@pvAddressCounty	Varchar(50)	= '',
@pvEmail			Varchar(50)	= '',
@pvPhoneNumber		Varchar(30) = '',
@pvContact			Varchar(100)= '',
@pbStatus			Bit			= '',
@pvUser				Varchar(50),
@pvIP				Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vSQL Varchar(MAX)
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Cat_Customers - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Customers_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', 
																				@pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', 
																				@piIdCustomer = '" + ISNULL(CAST(@piIdCustomer AS VARCHAR),'NULL') + "', 
																				@pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL') + "', 
																				@pvIdCustomerType = '" + ISNULL(@pvIdCustomerType,'NULL') + "', 
																				@pvName = '" + ISNULL(@pvName,'NULL') + "', 
																				@pnNumberJDE = '" + ISNULL(CAST(@pnNumberJDE AS VARCHAR),'NULL') + "', 
																				@pvAddressStreet = '" + ISNULL(@pvAddressStreet,'NULL') + "', 
																				@pvAddressInt = '" + ISNULL(@pvAddressInt,'NULL') + "', 
																				@pvAddressExt = '" + ISNULL(@pvAddressExt,'NULL') + "', 
																				@pvAddressState = '" + ISNULL(@pvAddressState,'NULL') + "', 
																				@pvAddressZipCode = '" + ISNULL(CAST(@pvAddressZipCode AS VARCHAR),'NULL') + "', 
																				@pvAddressCity = '" + ISNULL(@pvAddressCity,'NULL') + "', 
																				@pvAddressCounty = '" + ISNULL(@pvAddressCounty,'NULL') + "', 
																				@pvEmail = '" + ISNULL(@pvEmail,'NULL') + "', 
																				@pvPhoneNumber = '" + ISNULL(@pvPhoneNumber,'NULL') + "', 
																				@pvContact = '" + ISNULL(@pvContact,'NULL') + "', 
																				@pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Customers WHERE Id_Customer = @piIdCustomer AND Id_Customer_Type = @pvIdCountry AND Id_Country = @pvIdCustomerType )
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
		SET @piIdCustomer = (SELECT ISNULL(MAX(Id_Customer),0) + 1 FROM Cat_Customers )
			INSERT INTO Cat_Customers (
				Id_Customer,
				Id_Country,
				Id_Customer_Type,
				[Name],
				Number_JDE,
				Address_Street,
				Address_Int,
				Address_Ext,
				Address_State,
				Address_ZipCode,
				Address_City,
				Address_County,
				Email,
				Phone_Number,
				Contact,
				[Status],
				Modify_By,
				Modify_Date,
				Modify_IP)
			VALUES (
				@piIdCustomer,
				@pvIdCountry,
				@pvIdCustomerType,
				@pvName,
				@pnNumberJDE,
				@pvAddressStreet,
				@pvAddressInt,
				@pvAddressExt,
				@pvAddressState,
				@pvAddressZipCode,
				@pvAddressCity,
				@pvAddressCounty,
				@pvEmail,
				@pvPhoneNumber,
				@pvContact,
				@pbStatus,
				@pvUser,
				GETDATE(),
				@pvIP)
		END
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
	SET @vSQL = "SELECT 
		CU.Id_Customer,
		CU.Id_Country,
		Country_Desc = CO.Short_Desc,
		CU.Id_Customer_Type,
		Customer_Type_Desc = CUT.Short_Desc,
		CU.[Name],
		CU.Number_JDE,
		CU.Address_Street,
		CU.Address_Int,
		CU.Address_Ext,
		CU.Address_State,
		CU.Address_ZipCode,
		CU.Address_City,
		CU.Address_County,
		CU.Email,
		CU.Phone_Number,
		CU.Contact,
		CU.[Status],
		CU.Modify_Date,
		CU.Modify_By,
		CU.Modify_IP
		FROM Cat_Customers CU
		
		INNER JOIN Cat_Countries CO ON 
		CU.Id_Country = CO.Id_Country

		INNER JOIN Cat_Customers_Type CUT ON 
		CU.Id_Customer_Type = CUT.Id_Customer_Type AND
		CUT.Id_Language =  '" + @pvIdLanguageUser + "'

		WHERE CU.Id_Country IN (SELECT ZC.Id_Country 
								FROM Cat_Zones_Countries ZC
								INNER JOIN Security_Users U ON 
								ZC.Id_Zone = U.Id_Zone
								WHERE U.[User] = '" + @pvUser + "') "

		IF @piIdCustomer <> 0 
		SET @vSQL += "AND CU.Id_Customer = " + CAST(@piIdCustomer AS VARCHAR) + " "

		IF @pvIdCountry <> 'ALL' AND @pvIdCountry <> ''
		SET @vSQL += "AND CU.Id_Country = '" + @pvIdCountry + "' "
		
		IF @pvIdCustomerType <> 'ALL' AND @pvIdCustomerType <> ''
		SET @vSQL += "AND CU.Id_Customer_Type = '" + @pvIdCustomerType + "' "

		IF @pvIdCustomerType <> 'ALL' AND @pvIdCustomerType <> ''
		SET @vSQL += "AND CU.Id_Customer_Type = '" + @pvIdCustomerType + "' "

		IF @pnNumberJDE <> 0
		SET @vSQL += "AND CU.Number_JDE LIKE '%" + CAST(@pnNumberJDE AS VARCHAR) + "%' "

		IF @pvName <> ''
		SET @vSQL += "AND CU.[Name] LIKE '%" + @pvName + "%' "

		SET @vSQL += "ORDER BY  CU.Id_Country,CU.Id_Customer_Type, CU.[Name] "
		
		PRINT(@vSQL)
		EXEC(@vSQL)
		 
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Customers 
		SET [Name]			= @pvName,
			Number_JDE		= @pnNumberJDE,		
			Address_Street	= @pvAddressStreet,
			Address_Int		= @pvAddressInt,
			Address_Ext		= @pvAddressExt,
			Address_State	= @pvAddressState,
			Address_ZipCode	= @pvAddressZipCode,
			Address_City	= @pvAddressCity,
			Address_County	= @pvAddressCounty,
			Phone_Number	= @pvPhoneNumber,
			Email			= @pvEmail,
			Contact			= @pvContact,
			[Status]		= @pbStatus,
			Modify_Date		= GETDATE(),
			Modify_By		= @pvUser,
			Modify_IP		= @pvIP
		WHERE Id_Customer = @piIdCustomer AND Id_Country = @pvIdCountry AND Id_Customer_Type = @pvIdCustomerType
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
	SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog, IdCustomer = @piIdCustomer

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
		SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog, IdCustomer = @piIdCustomer
		
END CATCH
