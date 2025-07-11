USE PortalGTC
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCustomers_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCustomers_CRUD_Records'

IF OBJECT_ID('[dbo].[spCustomers_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCustomers_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Customers | Create - Read - Upadate - Delete 
Date:		29/08/2021
Example:


			EXEC spCustomers_CRUD_Records	@pvOptionCRUD		= 'C', 
											@pvIdCountry		= 'MEX',
											@pvIdTaxRegimen		= '605',
											@pvName				= 'Cliente SA de CV',
											@pvTaxId			= 'RFCCLIENTE12',
											@pvStreet			= 'AV. Reforma',
											@pvExtNumber		= '222',
											@pvIntNumber		= 'piso 4',											
											@pvCity				= 'MEXICO',
											@pvZipCode			= '68600',
											@pvContactPerson	= 'Contacto',
											@pvPhone1			= '555500000',
											@pvPhone2			= '555500001',
											@pvWebPage			= 'Empresa.com',
											@pvLogo				= 'C:\Logos',	
											@pbStampingMaster	= 0,
											@pbStatus			= 1,
											@pvUser				= 'AZEPEDA', 
											@pvIP				= '192.168.1.254'
			
			EXEC spCustomers_CRUD_Records @pvOptionCRUD = 'R', @piIdCustomer = 20
			
			EXEC spCustomers_CRUD_Records @pvOptionCRUD = 'R', @pvName = 'Cliente'
			
			EXEC spCustomers_CRUD_Records	@pvOptionCRUD = 'U', 
											@piIdCustomer = 20, 	
											@pvIdCountry		= 'USA',
											@pvIdTaxRegimen		= '605',
											@pvName				= 'Empresa SA de CV',
											@pvTaxId			= 'RFCCLIENTE12',
											@pvStreet			= 'AV. Reforma',
											@pvExtNumber		= '222',
											@pvIntNumber		= 'piso 4',
											@pvCity				= 'MEXICO',
											@pvZipCode			= '68600',
											@pvContactPerson	= 'Contacto',
											@pvPhone1			= '555500000',
											@pvPhone2			= '555500001',
											@pvWebPage			= 'Empresa.com',
											@pvLogo				= 'C:\Logos',	
											@pbStatus			= 1,
											@pbStampingMaster	= 0,
											@pvUser				= 'AZEPEDA', 
											@pvIP				= '192.168.1.254'

			EXEC spCustomers_CRUD_Records @pvOptionCRUD = 'D' 


*/
CREATE PROCEDURE [dbo].spCustomers_CRUD_Records
@pvOptionCRUD		Varchar(1),
@piIdCustomer		Int			 = 0,
@pvIdCountry		Varchar(50) = '',	
@pvIdTaxRegimen		Varchar(50) = '',	
@pvName				Varchar(255) = '',
@pvTaxId			Varchar(20)  = '',
@pvStreet			Varchar(100) = '',
@pvExtNumber		Varchar(20)  = '',
@pvIntNumber		Varchar(20)  = '',
@pvCity				Varchar(50)  = '',
@pvZipCode			Varchar(10)  = '',
@pvContactPerson	Varchar(255) = '',
@pvPhone1			Varchar(20)  = '',
@pvPhone2			Varchar(20)  = '',
@pvWebPage			Varchar(255) = '',
@pvLogo				Varchar(255) = '',
@pbStampingMaster	Bit			 = 0,
@pbStatus			Bit			 = 1,
@pvUser				Varchar(50)  = '',
@pvIP				Varchar(20)  = ''
AS

SET NOCOUNT ON
BEGIN TRY
	
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	Declare @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Customers - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spCustomers_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @piIdCustomer = '" + ISNULL(CAST(@piIdCustomer AS VARCHAR),'NULL') + "', @pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL') + "', @pvName = '" + ISNULL(@pvName,'NULL') + "', @pvTaxId = '" + ISNULL(@pvTaxId,'NULL') + "', @pvStreet = '" + ISNULL(@pvStreet,'NULL') + "', @pvExtNumber = '" + ISNULL(@pvExtNumber,'NULL') + "', @pvIntNumber = '" + ISNULL(@pvIntNumber,'NULL') + "', @pvCity = '" + ISNULL(@pvCity,'NULL') + "', @pvZipCode = '" + ISNULL(@pvZipCode,'NULL') + "', @pvContactPerson = '" + ISNULL(@pvContactPerson,'NULL') + "', @pvPhone1 = '" + ISNULL(@pvPhone1,'NULL') + "', @pvPhone2 = '" + ISNULL(@pvPhone2,'NULL') + "', @pvWebPage = '" + ISNULL(@pvWebPage,'NULL') + "', @pvLogo = '" + ISNULL(@pvLogo,'NULL') + "', @pbStampingMaster = '" + ISNULL(CAST(@pbStampingMaster AS VARCHAR),'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
			-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Customers WHERE Id_Country = @pvIdCountry AND Tax_Id = @pvTaxId)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don´t Exists
		BEGIN
		SET @piIdCustomer = (SELECT MAX(Id_Customer) + 1 FROM Customers)

			--Insert Application Settings
			INSERT INTO Customers (
					Id_Customer,
					Id_Country,
					Id_Tax_Regimen,
					[Name],
					Tax_Id,
					Street,
					Ext_Number,
					Int_Number,
					City,
					Zip_Code,
					Contact_Person,
					Phone_1,
					Phone_2,
					Web_Page,
					Logo,
					Stamping_Master,
					[Status],
					Modify_By,
					Modify_Date,
					Modify_IP)

			VALUES (@piIdCustomer,
					@pvIdCountry,
					@pvIdTaxRegimen,
					@pvName,
					@pvTaxId,
					@pvStreet,
					@pvExtNumber,
					@pvIntNumber,
					@pvCity,
					@pvZipCode,
					@pvContactPerson,
					@pvPhone1,
					@pvPhone2,
					@pvWebPage,
					@pvLogo,
					@pbStampingMaster,
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
		SELECT  Customers.Id_Customer,
				Customers.[Name],
				Country.Id_Country,
				Country_Desc = Country.Short_Desc,
				Customers.Id_Tax_Regimen,
				Tax_Regimen = Tax_Regimens.Short_Desc,
				Customers.Tax_Id,
				Customers.Street,
				Customers.Ext_Number,
				Customers.Int_Number,
				Customers.City,
				Customers.Zip_Code,
				Customers.Contact_Person,
				Customers.Phone_1,
				Customers.Phone_2,
				Customers.Web_Page,
				Customers.Logo,
				Customers.Stamping_Master,
				Customers.[Status],
				Customers.Modify_By,
				Customers.Modify_Date,
				Customers.Modify_IP
		FROM Customers
		
		INNER JOIN SAT_Cat_Countries Country ON 
		Customers.Id_Country = Country.Id_Country

		LEFT OUTER JOIN SAT_Cat_Tax_Regimens Tax_Regimens ON 
		Customers.Id_Tax_Regimen = Tax_Regimens.Id_Tax_Regimen

		WHERE 
		(@piIdCustomer	= 0	 OR Id_Customer = @piIdCustomer) AND 
		(@pvName		= '' OR Name LIKE '%' + @pvName + '%')
		
		ORDER BY  Id_Customer
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
	
		UPDATE Customers
		SET 	Id_Country		= @pvIdCountry,
				Id_Tax_Regimen	= @pvIdTaxRegimen,
				[Name]			= @pvName,
				Tax_Id			= @pvTaxId,
				Street			= @pvStreet,
				Ext_Number		= @pvExtNumber,
				Int_Number		= @pvIntNumber,
				City			= @pvCity,
				Zip_Code		= @pvZipCode,
				Contact_Person	= @pvContactPerson, 
				Phone_1			= @pvPhone1,
				Phone_2			= @pvPhone2,
				Web_Page		= @pvWebPage,
				Logo			= (CASE WHEN @pvLogo = '' THEN Logo ELSE @pvLogo END),
				Stamping_Master = @pbStampingMaster,
				[Status]		= @pbStatus,
				Modify_By		= @pvUser,
				Modify_Date		= GETDATE(),
				Modify_IP		= @pvIP
		WHERE 
		Id_Customer		= @piIdCustomer
		
	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D' OR @vDescOperationCRUD = 'N/A'
	BEGIN
		SET @iCode	= dbo.fnGetCodes('Invalid Option')	
	END

	--------------------------------------------------------------------
	--Register Transaction Log
	--------------------------------------------------------------------
	EXEC spSecurity_Transaction_Log_Ins_Record	@pvDescription		= @vDescription, 
												@pvExecCommand		= @vExecCommand,
												@piCode				= @iCode, 
												@pvExceptionMessage = @vExceptionMessage,
												@pvUser				= @pvUser, 
												@pnIdTransacLog		= @nIdTransacLog OUTPUT
	
	SET NOCOUNT OFF
	
	IF @pvOptionCRUD <> 'R'
	SELECT Code, Code_Classification, Code_Type , Code_Message_User, Code_Successful,  IdTransacLog = @nIdTransacLog FROM vwSecurityCodes WHERE Code = @iCode

END TRY
BEGIN CATCH
	--------------------------------------------------------------------
	-- Exception Handling
	--------------------------------------------------------------------
	SET @iCode					= dbo.fnGetCodes('Generic Error')
	SET @vExceptionMessage		= dbo.fnGetTransacErrorBD()

	EXEC spSecurity_Transaction_Log_Ins_Record	@pvDescription		= @vDescription, 
												@pvExecCommand		= @vExecCommand,
												@piCode				= @iCode, 
												@pvExceptionMessage = @vExceptionMessage,
												@pvUser				= @pvUser, 
												@pnIdTransacLog		= @nIdTransacLog OUTPUT
	
	SET NOCOUNT OFF
	SELECT Code, Code_Classification, Code_Type , Code_Message_User, Code_Successful,  IdTransacLog = @nIdTransacLog FROM vwSecurityCodes WHERE Code = @iCode
		
END CATCH