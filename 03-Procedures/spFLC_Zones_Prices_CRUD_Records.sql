USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spFLC_Zones_Prices_CRUD_Records]    Script Date: 6/9/2026 8:35:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autor:		Angel Gutierrez
Desc:		FLC_Zones_Prices | Create - Read - Upadate - Delete 
Date:		06/09/2026
Example:

			DECLARE  @pudtFLCZonesPrices  UDT_FLC_Zones_Prices 

			INSERT INTO @pudtFLCZonesPrices
			SELECT '7670-12', 'FLCCLSOUCO', 'FLCCOPY', 15 UNION ALL
			SELECT '7670-12', 'FLCCLSOUCO', 'FLCCOUY', 25 '' UNION ALL
			SELECT '7670-12', 'FLCCLCELA', 'FLCCOVE', 35

			SELECT * FROM @pudtFLCZonesPrices

			EXEC spFLC_Zones_Prices_CRUD_Records @pvOptionCRUD = 'C', 
												 @pvIdLanguageUser = 'ANG', 
												 @pudtFLCZonesPrices = @pudtFLCZonesPrices,  
												 @pvUser = 'ANGUTIERRE', 
												 @pvIP ='TEST';			
			
			
			
			EXEC spFLC_Zones_Prices_CRUD_Records @pvOptionCRUD = 'R', 
												 @pvIdLanguageUser = 'ANG', 
												 @pvIdItem = 'Id Item';
			
			-------------------------------------------------------------------------------------------------
			-------------------------------------------------------------------------------------------------

			DECLARE  @pudtFLCZonesPrices  UDT_FLC_Zones_Prices 

			INSERT INTO @pudtFLCZonesPrices
			SELECT '7670-12', 'FLCCLSOUCO', 'FLCCOPY', 15 UNION ALL
			SELECT '7670-12', 'FLCCLSOUCO', 'FLCCOUY', 25 '' UNION ALL
			SELECT '7670-12', 'FLCCLCELA', 'FLCCOVE', 35

			SELECT * FROM @pudtFLCZonesPrices

			EXEC spFLC_Zones_Prices_CRUD_Records @pvOptionCRUD = 'U', 
												 @pvIdLanguageUser = 'ANG', 
												 @pudtFLCZonesPrices = @pudtFLCZonesPrices,  
												 @pvUser = 'ANGUTIERRE', 
												 @pvIP ='TEST';	

			EXEC spFLC_Zones_Prices_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG'
			
			EXEC spFLC_Zones_Prices_CRUD_Records @pvoptioncrud = 'R',@pvIdItem='';


			SELECT * FROM FLC_Zones_Prices
	
*/
CREATE PROCEDURE [dbo].[spFLC_Zones_Prices_CRUD_Records]
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10) = 'ANG',
@pvIdItem				Varchar(50) = '',
@pvIdZone			Varchar(10) = '',
@pvIdLanguage			Varchar(10) = '',
--@pvIdStatusComRelease	Smallint	= 0,
@pudtFLCZonesPrices	UDT_FLC_Zones_Prices Readonly,
@pvUser					Varchar(50) = '',
@pvIP					Varchar(20) = ''
AS
SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vjsonUDT			NVarchar(MAX)	= (SELECT * FROM @pudtFLCZonesPrices FOR JSON AUTO);
	DECLARE @vStsAvailable			Varchar(50)	= (SELECT Short_Desc FROM Cat_Status_Commercial_Release WHERE Id_Status_Commercial_Release = 1 AND Id_Language = @pvIdLanguageUser)
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'FLC_Zones_Prices - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spFLC_Zones_Prices_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') 
													+ "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') 
													+ "', @pvIdItem = '" + ISNULL(@pvIdItem,'NULL')
													+ "', @pvIdZone = '" + ISNULL(@pvIdZone,'NULL') 
													+ "', @pvIdLanguage = '" + ISNULL(@pvIdLanguage,'NULL') 
													+ "',  @pudtFLCZonesPrices = '" + ISNULL(@vjsonUDT,'NULL') 
													+ "', @pvUser = '" + ISNULL(@pvUser,'NULL') 
													+ "', @pvIP = '" + ISNULL(@pvIP,'NULL') 
													+ "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN

		DELETE FLC_Zones_Prices WHERE Id_Item IN (SELECT Id_Item FROM @pudtFLCZonesPrices)

		INSERT INTO FLC_Zones_Prices(
			Id_Item,
			Id_Region,
			Id_Zone,
			Price,
			Modify_By,
			Modify_Date,
			Modify_IP)
		SELECT 
			Id_Item,
			Id_Region,
			Id_Zone,
			Price,
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtFLCZonesPrices

	END
	
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN

		Print 'Read Records';

		SELECT
			Id_Item,
			Id_Region,
			Id_Zone,
			Price,
			Modify_By,
			Modify_Date,
			Modify_IP
		FROM FLC_Zones_Prices
		WHERE
				(@pvIdItem = '' OR Id_Item = @pvIdItem);

	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN

		DELETE FLC_Zones_Prices WHERE Id_Item IN (SELECT Id_Item FROM @pudtFLCZonesPrices)

		INSERT INTO FLC_Zones_Prices(
			Id_Item,
			Id_Region,
			Id_Zone,
			Price,
			Modify_By,
			Modify_Date,
			Modify_IP)
		SELECT 
			Id_Item,
			Id_Region,
			Id_Zone,
			Price,
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtFLCZonesPrices

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
	
	--SET @vMessage		= dbo.fnGetTransacMessages('Generic Error',@pvIdLanguageUser)
	SET @vMessage		= ( SELECT Message FROM Security_Transaction_Log WHERE  Id_Transaction_Log = @nIdTransacLog)
	SET NOCOUNT OFF
	SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog
		
END CATCH
