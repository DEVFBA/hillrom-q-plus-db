use DBQS
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spItems_Installation_Charges_CRUD_Records 
/* ==================================================================================*/	
PRINT 'Crea Procedure: spItems_Installation_Charges_CRUD_Records'

IF OBJECT_ID('[dbo].[spItems_Installation_Charges_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spItems_Installation_Charges_CRUD_Records
GO


/*
Autor:		Alejandro Zepeda
Desc:		Items_Installation_Charges | Create - Read - Upadate - Delete 
Date:		20/06/2025
Example:

			EXEC spItems_Installation_Charges_CRUD_Records @pvOptionCRUD = 'C', 
			EXEC spItems_Installation_Charges_CRUD_Records @pvOptionCRUD = 'R', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spItems_Installation_Charges_CRUD_Records @pvOptionCRUD = 'R', @pvIdCountry ='PR', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spItems_Installation_Charges_CRUD_Records @pvOptionCRUD = 'R', @pvIdItem = 'AF750', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spItems_Installation_Charges_CRUD_Records @pvOptionCRUD = 'R', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spItems_Installation_Charges_CRUD_Records @pvOptionCRUD = 'R', @pvIdCountry ='PR', @pvIdItem = 'AF750', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spItems_Installation_Charges_CRUD_Records @pvOptionCRUD = 'U', 
			EXEC spItems_Installation_Charges_CRUD_Records @pvOptionCRUD = 'D', 
			EXEC spItems_Installation_Charges_CRUD_Records @pvOptionCRUD = 'W'
 
SELECT * FROM Items_Installation_Charges
*/
CREATE PROCEDURE [dbo].[spItems_Installation_Charges_CRUD_Records]
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10) = 'ANG',
@pvIdCountry					Varchar(10) = '',
@pvIdItem						Varchar(50) = '',
@pbStatus						Bit			= NULL,
@pvUser							Varchar(50) = '',
@pvIP							Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD		Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Items_Installation_Charges - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spItems_Installation_Charges_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL') + "', @pvIdItem = '" + ISNULL(@pvIdItem,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT
			IIC.Id_Country,
			Country = C.Short_Desc,
			IIC.Id_Item,
			Item = I.Short_Desc,
			IIC.Id_Installation_Charge,
			IIC.Short_Desc,
			IIC.Long_Desc,
			IIC.Price,
			IIC.[Status],
			IIC.Modify_By,
			IIC.Modify_Date,
			IIC.Modify_IP

		FROM Items_Installation_Charges IIC  WITH(NOLOCK)
		
		INNER JOIN  Cat_Countries  C WITH(NOLOCK) ON
		IIC.Id_Country = C.Id_Country 

		INNER JOIN  Cat_Item I WITH(NOLOCK) ON
		IIC.Id_Item = I.Id_Item 

		WHERE 
		(@pvIdCountry	= '' OR IIC.Id_Country	= @pvIdCountry) AND 
		(@pvIdItem		= '' OR IIC.Id_Item		= @pvIdItem)  AND
		(@pbStatus IS NULL OR IIC.[Status]	= @pbStatus)  


		ORDER BY IIC.Id_Country, IIC.Id_Item
		
	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C' OR @pvOptionCRUD = 'U' OR @pvOptionCRUD = 'D' OR @vDescOperationCRUD = 'N/A'
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
