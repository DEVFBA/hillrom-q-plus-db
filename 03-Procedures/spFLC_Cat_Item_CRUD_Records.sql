USE DBQS
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spFLC_Cat_Item_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spFLC_Cat_Item_CRUD_Records'

IF OBJECT_ID('[dbo].[spFLC_Cat_Item_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spFLC_Cat_Item_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		FLC_Cat_Item | Create - Read - Upadate - Delete 
Date:		01/17/2021
Example:
			spFLC_Cat_Item_CRUD_Records @pvOptionCRUD	= 'C',
									@pvIdLanguageUser	= 'ANG', 
									@pvIdItem			= 'Id Item4', 
									@pvShortDesc		= 'Item', 
									@pvLongDesc			= 'Long Item', 
									@pvComment			= 'ninguno',
									@pfPrice			= 10.5,
									@pfStandardCost		= 13.5,
									@pbObsolescence		= 0,
									@pvObsolescenceDate	= '', --YYYYMMDD
									@pvImagePath		= 'c:\',
									@pvSubstituteItem	= 'sibitem',
									@pbStatus			= 0,
									@pvUser				= 'AZEPEDA', 
									@pvIP				='192.168.1.254'

			EXEC spFLC_Cat_Item_CRUD_Records @pvOptionCRUD		= 'R'

			EXEC spFLC_Cat_Item_CRUD_Records @pvOptionCRUD		= 'R', 
									@pvIdLanguageUser	= 'ANG', 
									@pvIdItem			= 'Id Item3'

			spFLC_Cat_Item_CRUD_Records @pvOptionCRUD		= 'U', 
									@pvIdLanguageUser	= 'ANG', 
									@pvIdItem			= 'Id Item', 
									@pvShortDesc		= 'Item', 
									@pvLongDesc			= 'Long Item', 
									@pvComment			= 'ninguno',
									@pfPrice			= 20.5,
									@pfStandardCost		= 23.5,
									@pbObsolescence		= 0,
									@pvObsolescenceDate	= '', --YYYYMMDD
									@pvImagePath		= 'c:\',
									@pvSubstituteItem	= 'sibitem',
									@pbStatus			= 0,
									@pvUser				= 'AZEPEDA', 
									@pvIP				='192.168.1.254'

*/
CREATE PROCEDURE [dbo].[spFLC_Cat_Item_CRUD_Records]
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10)		= 'ANG',
@pvIdItem						Varchar(50)		= '',
@pvShortDesc					Varchar(50)		= '',
@pvLongDesc						Varchar(255)	= '',
@pvComment						Varchar(500)	= '',
@pfPrice						Float			= 0,
@pfStandardCost					Float			= 0,
@pbObsolescence					Bit				= 0,
@pvObsolescenceDate				Varchar(8)		= '', --YYYYMMDD
@pvImagePath					Varchar(255)	= '',
@pvSubstituteItem				Varchar(50)		= '',
@pbStatus						Bit				= 0,
@pvUser							Varchar(50)		= '',
@pvIP							Varchar(20)		= ''
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
	DECLARE @vDescription	Varchar(255)	= 'FLC_Cat_Item - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spFLC_Cat_Item_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdItem = '" + ISNULL(@pvIdItem,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pvComment = '" + ISNULL(@pvComment,'NULL') + "', @pfPrice = '" + ISNULL(CAST(@pfPrice AS VARCHAR),'NULL') + "', @pfStandardCost = '" + ISNULL(CAST(@pfStandardCost AS VARCHAR),'NULL') + "', @pbObsolescence = '" + ISNULL(CAST(@pbObsolescence AS VARCHAR),'NULL') + "',  @pvObsolescenceDate = '" + ISNULL(@pvObsolescenceDate,'NULL') + "',  @pvImagePath = '" + ISNULL(@pvImagePath,'NULL') + "',  @pvSubstituteItem = '" + ISNULL(@pvSubstituteItem,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM FLC_Cat_Item WHERE  Id_Item = @pvIdItem)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO FLC_Cat_Item(
				Id_Item,
				Short_Desc,
				Long_Desc,
				Comment,
				Price,
				Standard_Cost,
				Obsolescence,
				Obsolescence_Date,
				Image_Path,
				Substitute_Item,
				[Status],
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdItem,
				@pvShortDesc,
				@pvLongDesc,
				@pvComment,
				@pfPrice,
				@pfStandardCost,
				@pbObsolescence,
				@pvObsolescenceDate,
				@pvImagePath,
				@pvSubstituteItem,
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
			Id_Item,
			Short_Desc,
			Long_Desc,
			Comment,
			Price,
			Standard_Cost,
			Obsolescence,
			Obsolescence_Date,
			Image_Path,
			Substitute_Item,
			[Status],
			Modify_Date,
			Modify_By,
			Modify_IP
		FROM FLC_Cat_Item 

		WHERE (@pvIdItem = '' OR Id_Item = @pvIdItem )
		ORDER BY Id_Item
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE FLC_Cat_Item 
		SET 
			Short_Desc			= @pvShortDesc,
			Long_Desc			= @pvLongDesc,
			Comment				= @pvComment,
			Price				= @pfPrice,
			Standard_Cost		= @pfStandardCost,
			Obsolescence		= @pbObsolescence,
			Obsolescence_Date	= @pvObsolescenceDate,
			Image_Path			= @pvImagePath,
			Substitute_Item		= @pvSubstituteItem,
			[Status]			= @pbStatus,
			Modify_Date			= GETDATE(),
			Modify_By			= @pvUser,
			Modify_IP			= @pvIP
		WHERE Id_Item = @pvIdItem

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
