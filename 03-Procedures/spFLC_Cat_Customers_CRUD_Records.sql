USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spFLC_Cat_Customers_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spFLC_Cat_Customers_CRUD_Records'

IF OBJECT_ID('[dbo].[spFLC_Cat_Customers_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spFLC_Cat_Customers_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		FLC_Cat_Customers | Create - Read - Upadate - Delete 
Date:		22/01/2021
Example:
			spFLC_Cat_Customers_CRUD_Records @pvOptionCRUD		= 'C', 
										@piIdCustomer		= 0, --automatic assignment
										@pvIdCountry		= 'MX',
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
										@pvAccountNumber	= '114',
										@pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

			spFLC_Cat_Customers_CRUD_Records @pvOptionCRUD = 'R', @piIdCustomer	= 1
			spFLC_Cat_Customers_CRUD_Records @pvOptionCRUD = 'R', @pvName = 'Aleja'
			spFLC_Cat_Customers_CRUD_Records @pvOptionCRUD = 'R', @piIdCustomer	= 1, @pvName = 'Ale'
			spFLC_Cat_Customers_CRUD_Records @pvOptionCRUD = 'R',@pvIdLanguageUser='ANG',@piIdCustomer=0,@pvName='',@pvIdCountry='MX'

			spFLC_Cat_Customers_CRUD_Records @pvOptionCRUD = 'U', 
										@piIdCustomer		= 8, 
										@pvIdCountry		= 'MX',
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
										@pvAccountNumber	= '114',
										@pbStatus = 1, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'
			

*/
CREATE PROCEDURE [dbo].spFLC_Cat_Customers_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = 'ANG',
@piIdCustomer		Int			= 0,
@pvIdCountry		Varchar(10) = '',
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
@pvAccountNumber	Varchar(100)= '',
@pbStatus			Bit			= '',
@pvUser				Varchar(50)= '',
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
	DECLARE @vDescription	Varchar(255)	= 'FLC_Cat_Customers - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spFLC_Cat_Customers_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', 
																				@pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', 
																				@piIdCustomer = '" + ISNULL(CAST(@piIdCustomer AS VARCHAR),'NULL') + "', 
																				@pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL') + "', 
																				@pvName = '" + ISNULL(@pvName,'NULL') + "', 
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
																				@pvAccountNumber = '" + ISNULL(@pvAccountNumber,'NULL') + "', 
																				@pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM FLC_Cat_Customers WHERE Id_Customer = @piIdCustomer)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
		SET @piIdCustomer = (SELECT ISNULL(MAX(Id_Customer),0) + 1 FROM FLC_Cat_Customers )
			INSERT INTO FLC_Cat_Customers (
				Id_Customer,
				Id_Country,
				[Name],
				Address_Street,
				Address_Ext,
				Address_Int,
				Address_State,
				Address_ZipCode,
				Address_City,
				Address_County,
				Email,
				Contact,
				Phone_Number,
				Account_Number,
				[Status],
				Modify_By,
				Modify_Date,
				Modify_IP)
			VALUES (
				@piIdCustomer,
				@pvIdCountry,
				@pvName,
				@pvAddressStreet,
				@pvAddressExt,
				@pvAddressInt,
				@pvAddressState,
				@pvAddressZipCode,
				@pvAddressCity,
				@pvAddressCounty,
				@pvEmail,
				@pvContact,
				@pvPhoneNumber,		
				@pvAccountNumber,
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
		SELECT 
			CU.Id_Customer,
			CU.Id_Country,
			CU.[Name],
			CU.Address_Street,
			CU.Address_Ext,
			CU.Address_Int,
			CU.Address_State,
			CU.Address_ZipCode,
			CU.Address_City,
			CU.Address_County,
			CU.Email,
			CU.Contact,
			CU.Phone_Number,
			CU.Account_Number,
			CU.[Status],
			CU.Modify_By,
			CU.Modify_Date,
			CU.Modify_IP
		FROM FLC_Cat_Customers CU
		
		INNER JOIN Cat_Countries CO ON
		CU.Id_Country = CO.Id_Country
		
		WHERE (@piIdCustomer = 0 OR CU.Id_Customer = @piIdCustomer) AND
		(@pvIdCountry = '' OR CU.Id_Country = @pvIdCountry) AND
		(@pvName = '' OR Name LIKE '%' + @pvName + '%')

		ORDER BY CU.[Name] --- Modificación Ángel Gutiérrez 12/12/23

		 
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE FLC_Cat_Customers 
		SET [Name]			= @pvName,
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
			Account_Number	= @pvAccountNumber,
			[Status]		= @pbStatus,
			Modify_Date		= GETDATE(),
			Modify_By		= @pvUser,
			Modify_IP		= @pvIP
		WHERE Id_Customer = @piIdCustomer 
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