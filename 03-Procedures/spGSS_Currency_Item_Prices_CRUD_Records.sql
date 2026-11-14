USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_Currency_Item_Prices_CRUD_Records]    Script Date: 4/16/2026 9:01:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Autor:		Angel Gutierrez
Desc:		GSS_Currency_Item_Prices | Create - Read - Upadate - Delete || EFEFBRA009
Date:		22/08/2026
Example:
			
			EXEC spGSS_Currency_Item_Prices_CRUD_Records @pvOptionCRUD = 'R',  
				@pvIdCurrency = 'BRL',
				@pvUser = 'ANGUTIERRE', 
				@pvIdLanguageUser = 'ANG',
				@pvIP = 'TST';

            EXEC spGSS_Currency_Item_Prices_CRUD_Records @pvOptionCRUD = 'R',  
				@pbStatus = 0, 
				@pvIdCurrency = 'BRL',
				@pvUser = 'ANGUTIERRE', 
				@pvIdLanguageUser = 'ANG',
				@pvIP = 'TST';

            EXEC spGSS_Currency_Item_Prices_CRUD_Records @pvOptionCRUD = 'U',
                @pvFileName = 'Example.csv';
			
*/
IF OBJECT_ID('[dbo].[spGSS_Currency_Item_Prices_CRUD_Records]', 'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spGSS_Currency_Item_Prices_CRUD_Records]
GO

CREATE PROCEDURE [dbo].[spGSS_Currency_Item_Prices_CRUD_Records]
@pvOptionCRUD		Varchar(1),
@pvIdItem           Varchar(50)		= '',
@pbStatus			Bit				= NULL,
@pvUser				Varchar(50)		= '',
@pvIP				Varchar(20)		= '',
@pvIdLanguageUser   Varchar(10)		= 'ANG',
@pvIdCurrency		Varchar(10)		= '',
@pvFileName				Varchar(255)= ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	Declare @vDescOperationCRUD     Varchar(50)     = dbo.fnGetOperationCRUD(@pvOptionCRUD)
    DECLARE @PathFile		        VARCHAR(255)	= (SELECT [Value] + @pvFileName FROM Cat_General_Parameters WHERE Id_Parameter = 58)
	DECLARE @piFirstrow				INT				= 2
	DECLARE @vSQL					VARCHAR(1000)	= ''

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'GSS_Currency_Item_Prices - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spGSS_Currency_Item_Prices_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') 
                                                + "', @pvIdItem = '" + ISNULL(@pvIdItem,'NULL') 
												+ "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') 
												+ "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') 
												+ "', @pvUser = '" + ISNULL(@pvUser,'NULL') 
												+ "', @pvIP = '" + ISNULL(@pvIP,'NULL') 
												+ "', @pvIdCurrency = '" + ISNULL(@pvIdCurrency,'NULL')
												+ "', @pvFileName = '" + ISNULL(@pvFileName,'NULL')
												+ "'"
	--------------------------------------------------------------------
	--Variables for cursor
	--------------------------------------------------------------------
	DECLARE @cvRecordExists		BIT
    DECLARE @cvIdItem			VARCHAR(50)
	DECLARE @cvPrice			FLOAT
	DECLARE @cvIdCurrency		VARCHAR(10)
	DECLARE @cbStatus			BIT

    --------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		SET @bSuccessful	= 0
		SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
		SET @vMessage		= dbo.fnGetTransacMessages('N/A',@pvIdLanguageUser)
	END

	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN

		IF @pbStatus = '0' 
		BEGIN

			SET @pbStatus = NULL;

		END

        SELECT
            GCIPC.Id_Item,
            CI.Short_Desc AS Item_Desc,
            GCIPC.Id_Currency,
            CC.Short_Desc AS Currency_Desc,
            GCIPC.Price,
            GCIPC.[Status],
            GCIPC.Modify_By,
            GCIPC.Modify_Date,  
            GCIPC.Modify_IP,
            GCIPC.Id_Language
        FROM GSS_Currency_Item_Prices AS GCIPC INNER JOIN Cat_Currencies AS CC ON 
                                                                GCIPC.Id_Currency = CC.Id_Currency
                                                            AND CC.Id_Language = @pvIdLanguageUser
                                                     INNER JOIN GSS_Cat_Item AS CI ON
                                                                GCIPC.Id_Item = CI.Id_Item
                                                     INNER JOIN Cat_Languages AS CL ON
                                                                GCIPC.Id_Language = CL.Id_Language
                                                            AND CL.Id_Language_Translation = @pvIdLanguageUser
        WHERE 
                (@pvIdItem = '' OR GCIPC.Id_Item = @pvIdItem)
            AND (@pvIdCurrency = '' OR GCIPC.Id_Currency = @pvIdCurrency) 
            AND (@pbStatus IS NULL OR GCIPC.[Status] = @pbStatus)

	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		
        PRINT 'Update Records';

        CREATE TABLE #stagingCSV (
			Id_Item VARCHAR(50),
            Item_Desc VARCHAR(50),
			Id_Currency VARCHAR(10),
            Currency_Desc VARCHAR(10),
            Price FLOAT,
			[Status] BIT
		)

		SET @vSQL = "
		BULK INSERT #StagingCSV
		FROM '" + @PathFile + "' 
		WITH
		(	CODEPAGE = '65001',
			FIRSTROW = " + CAST(@piFirstrow AS VARCHAR) + ", 
			FIELDTERMINATOR =  ',',  --CSV field delimiter
			ROWTERMINATOR = '\n',   --Use to shift the control to next row 0X0a \n
			TABLOCK
		)"
		--PRINT @vSQL
		EXEC (@vSQL);

		SET @vMessage = @vMessage +  (SELECT '('  + CAST(COUNT(*) AS VARCHAR) + ' rows affected)' FROM #stagingCSV );

        DECLARE curGSSCurrencyPrices CURSOR FOR
			SELECT
				Id_Item,
				Id_Currency,
				Price,
                [Status]
			FROM #stagingCSV;

		OPEN curGSSCurrencyPrices

		FETCH NEXT FROM curGSSCurrencyPrices INTO @cvIdItem, @cvIdCurrency, @cvPrice, @cbStatus

		WHILE @@FETCH_STATUS = 0
		BEGIN

            SET @cvRecordExists = (SELECT COUNT(*) FROM GSS_Currency_Item_Prices WHERE Id_Item = @cvIdItem AND Id_Currency = @cvIdCurrency);

            IF @cvRecordExists = 0
            BEGIN

				INSERT INTO GSS_Currency_Item_Prices (
					Id_Item,
					Id_Currency,
					Id_Language,
					Price,
                    [Status],
					Modify_By,
					Modify_Date,
					Modify_IP
				)
				VALUES (
					@cvIdItem,
					@cvIdCurrency,
					'ANG',
					@cvPrice,
					@cbStatus,
					@pvUser,
					GETDATE(),
					@pvIP
				)

		    END
            ELSE IF @cvRecordExists = 1
            BEGIN

                UPDATE GSS_Currency_Item_Prices SET   Price = @cvPrice,
                                                            [Status] = @cbStatus,
                                                            Modify_By = @pvUser,
                                                            Modify_Date = GETDATE(),
                                                            Modify_IP = @pvIP
                WHERE 
                        Id_Item = @cvIdItem 
                    AND Id_Currency = @cvIdCurrency;

            END

			FETCH NEXT FROM curGSSCurrencyPrices INTO @cvIdItem, @cvIdCurrency, @cvPrice, @cbStatus

		END

		CLOSE curGSSCurrencyPrices
		DEALLOCATE curGSSCurrencyPrices

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

	IF @pvOptionCRUD NOT IN ('R')
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