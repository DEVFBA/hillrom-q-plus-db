USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spOperation_Cost_CRUD_Records]    Script Date: 01/05/2024 10:12:12 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Autor:		Alejandro Zepeda
Desc:		Operation_Cost | Create - Read - Upadate - Delete 
Date:		29/01/2021
Example:

			DECLARE  @udtOperationCost  UDT_Operation_Cost 

			INSERT INTO @udtOperationCost
			SELECT	*
			FROM Operation_Cost  
			WHERE Id_Item = 'X3' 

			EXEC spOperation_Cost_CRUD_Records @pvOptionCRUD = 'C', @pvIdItem = 'X3', @pudtOperationCost = @udtOperationCost , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'			
			EXEC spOperation_Cost_CRUD_Records @pvOptionCRUD = 'R', @pvIdItem = 'X3' 
			EXEC spOperation_Cost_CRUD_Records @pvOptionCRUD = 'U', @pvIdItem = 'X3', @pudtOperationCost = @udtOperationCost , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spOperation_Cost_CRUD_Records @pvOptionCRUD = 'D', @pvIdItem = 'X3' 
			EXEC spOperation_Cost_CRUD_Records @pvOptionCRUD = 'W'
 
*/
ALTER PROCEDURE [dbo].[spOperation_Cost_CRUD_Records]
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10) = '',
@pvIdItem						Varchar(50) = '', -- 01/05/24 AEGH, VRC -- Correction from 10 to 50
@pudtOperationCost				UDT_Operation_Cost Readonly,
@pvUser							Varchar(50) = '',
@pvIP							Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD		Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @iNumRegistros			Int			= (SELECT COUNT(*) FROM @pudtOperationCost)
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Operation_Cost - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spOperation_Cost_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdItem = '" + ISNULL(@pvIdItem,'NULL') + "', @pudtOperationCost = '" + ISNULL(CAST(@iNumRegistros AS VARCHAR),'NULL') + " rows affected', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		DELETE Operation_Cost WHERE Id_Item = @pvIdItem

		INSERT INTO Operation_Cost(
			Id_Item,
			Id_Country,
			Allocation,
			Transport_Cost,
			Taxes,
			Warehousing,
			Local_Transport,
			[Services],
			Modify_By,
			Modify_Date,
			Modify_IP)

		SELECT 
			Id_Item,
			Id_Country,
			Allocation,
			Transport_Cost,
			Taxes,
			Warehousing,
			Local_Transport,
			[Services],
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtOperationCost

		
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT
		Id_Item							= @pvIdItem,--@pvIdItem,
		Id_Country						= C.Id_Country,
		Country_Desc					= C.Short_Desc,
		Allocation						= ISNULL(OC.Allocation,0),
		Transport_Cost					= ISNULL(OC.Transport_Cost,0),
		Taxes							= ISNULL(OC.Taxes,0),
		Warehousing						= ISNULL(OC.Warehousing,0),
		Local_Transport					= ISNULL(OC.Local_Transport,0),
		[Services]						= ISNULL(OC.[Services],0),
		Modify_By						= ISNULL(OC.Modify_By,''),
		Modify_Date						= ISNULL(OC.Modify_Date,''),
		Modify_IP						= ISNULL(OC.Modify_IP,'')

		FROM Cat_Countries C  WITH(NOLOCK)
		
		LEFT OUTER JOIN  Operation_Cost OC WITH(NOLOCK) ON
		C.Id_Country = OC.Id_Country AND
		OC.Id_Item = @pvIdItem

		ORDER BY C.Id_Country
		
	END


	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		DELETE Operation_Cost WHERE Id_Item = @pvIdItem

		INSERT INTO Operation_Cost(
			Id_Item,
			Id_Country,
			Allocation,
			Transport_Cost,
			Taxes,
			Warehousing,
			Local_Transport,
			[Services],
			Modify_By,
			Modify_Date,
			Modify_IP)

		SELECT 
			Id_Item,
			Id_Country,
			Allocation,
			Transport_Cost,
			Taxes,
			Warehousing,
			Local_Transport,
			[Services],
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtOperationCost
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
	--Download Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'W'
	BEGIN
		SELECT
		Id_Item							= OC.Id_Item,
		Id_Country						= C.Id_Country,
		Country_Desc					= C.Short_Desc,
		Allocation						= ISNULL(OC.Allocation,0),
		Transport_Cost					= ISNULL(OC.Transport_Cost,0),
		Taxes							= ISNULL(OC.Taxes,0),
		Warehousing						= ISNULL(OC.Warehousing,0),
		Local_Transport					= ISNULL(OC.Local_Transport,0),
		[Services]						= ISNULL(OC.[Services],0),
		Modify_By						= ISNULL(OC.Modify_By,''),
		Modify_Date						= ISNULL(OC.Modify_Date,''),
		Modify_IP						= ISNULL(OC.Modify_IP,'')

		FROM Operation_Cost OC    WITH(NOLOCK)
		
		INNER JOIN  Cat_Countries C WITH(NOLOCK) ON
		OC.Id_Country = C.Id_Country 

		ORDER BY C.Id_Country
		RETURN
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
