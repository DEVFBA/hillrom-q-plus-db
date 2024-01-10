USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spFLC_Customer_Zones_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spFLC_Customer_Zones_CRUD_Records'

IF OBJECT_ID('[dbo].[spFLC_Customer_Zones_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spFLC_Customer_Zones_CRUD_Records
GO
/*
Autor:		Alejandro Zepeda
Desc:		FLC_Customer_Zones | Create - Read - Upadate - Delete 
Date:		24/09/2023
Example:
	
			spFLC_Customer_Zones_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @piIdCustomer = 1, @pvIdRegion = 'BRAZIL', @pvIdZone = 'BRA', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spFLC_Customer_Zones_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piIdCustomer = 1 
			spFLC_Customer_Zones_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piIdCustomer = 1, @pvIdRegion = 'BRAZIL', @pvIdZone = 'BRA'
			spFLC_Customer_Zones_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @piIdCustomer = 1, @pvIdRegion = 'BRAZIL', @pvIdZone = 'BRA', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spFLC_Customer_Zones_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @piIdCustomer = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spFLC_Customer_Zones_CRUD_Records @pvOptionCRUD = 'X', @pvIdLanguageUser = 'ANG', @piIdCustomer = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254''
*/
CREATE PROCEDURE [dbo].spFLC_Customer_Zones_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@piIdCustomer		Int			= 0,
@pvIdRegion			Varchar(10) = '',
@pvIdZone			Varchar(10) = '',
@pbStatus			Bit			= '',
@pvUser				Varchar(50) = '',
@pvIP				Varchar(20) = ''
AS
SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'FLC_Customer_Zones - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spFLC_Customer_Zones_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piIdCustomer = '" + ISNULL(CAST(@piIdCustomer AS VARCHAR),'NULL') + "', @pvIdRegion = '" + ISNULL(@pvIdRegion,'NULL') + "', @pvIdZone = '" + ISNULL(@pvIdZone,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM FLC_Customer_Zones WHERE Id_Customer = @piIdCustomer AND Id_Region = @pvIdRegion AND Id_Zone = @pvIdZone)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO FLC_Customer_Zones(
				Id_Customer,
				Id_Region,
				Id_Zone,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@piIdCustomer,
				@pvIdRegion,
				@pvIdZone,
				@pbStatus,
				GETDATE(),
				@pvUser,
				@pvIP)
		END
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
			CZ.Id_Customer,
			Customer = C.[Name],
			CZ.Id_Region,
			Region = R.Short_Desc,
			CZ.Id_Zone,
			[Zone] = Z.Short_Desc, 
			CZ.[Status],
			CZ.Modify_Date,
			CZ.Modify_By,
			CZ.Modify_IP
		FROM FLC_Customer_Zones CZ

		INNER JOIN FLC_Cat_Customers C ON
		CZ.Id_Customer = C.Id_Customer AND
		C.[Status] = 1

		INNER JOIN Cat_Region_Zones RZ ON 
		CZ.Id_Region = RZ.Id_Region AND 
		CZ.Id_Zone = RZ.Id_Zone AND
		RZ.[Status] = 1

		INNER JOIN Cat_Regions R ON 
		CZ.Id_Region = R.Id_Region AND
		R.[Status] = 1

		INNER JOIN Cat_Zones Z ON 
		CZ.Id_Zone = Z.Id_Zone AND
		Z.[Status] = 1

		WHERE (@piIdCustomer = '' OR CZ.Id_Customer = @piIdCustomer)
		AND (@pvIdRegion = '' OR CZ.Id_Region = @pvIdRegion )
		AND (@pvIdZone = '' OR CZ.Id_Zone = @pvIdZone )
		ORDER BY Id_Customer,Id_Region,Id_Zone 
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE FLC_Customer_Zones 
		SET [Status]		= @pbStatus,
			Modify_Date		= GETDATE(),
			Modify_By		= @pvUser,
			Modify_IP		= @pvIP
		WHERE Id_Customer = @piIdCustomer AND Id_Region = @pvIdRegion AND Id_Zone = @pvIdZone

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
