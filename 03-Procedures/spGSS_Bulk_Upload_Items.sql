USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_Bulk_Upload_Items]    Script Date: 5/24/2026 8:23:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Autor:		Angel Gutierrez
Desc:		GSS Commercial Release Process | Job
Date:		05/24/2026
Example:
			EXEC spGSS_Bulk_Upload_Items @pvOptionCRUD		=  'L', -- Load Records
										 @pvIdLanguageUser	= 'ANG', 
										 @pvFileName		= 'GSSCommercialReleaseLoads\Commercial_Load.csv',
										 --@pvLoadNewItems	= 0, -- | 0 =  Actualización  | 1 = Inserta nuevos items
										 @pvUser			= 'ANGUTIERRE',
										 @pvIP				= 'Test Bulk Load';

*/
CREATE PROCEDURE [dbo].[spGSS_Bulk_Upload_Items]
@pvOptionCRUD			Varchar(1)  = 'L',
@pvIdLanguageUser		Varchar(10) = 'ANG',
@pvFileName				Varchar(255)= '',
@pvUser					Varchar(50)	= '',
@pvIP					Varchar(20)	= ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @iLoadRecord	INT				= 0 
	DECLARE @vSQL			VARCHAR(1000)	= ''
	DECLARE @PathFile		VARCHAR(255)	= (SELECT [Value] + @pvFileName FROM Cat_General_Parameters WHERE Id_Parameter = 58)
	DECLARE @piFirstrow		INT				= 2

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription	Varchar(255)	= 'Bulk Upload GSS Commercial Release  - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= 'Executed Successfully '
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spGSS_Bulk_Upload_Items @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') 
													+ "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') 
													+ "', @pvFileName = '" + ISNULL(@pvFileName,'NULL') 
													+ ", @pvUser = '" + ISNULL(@pvUser,'NULL') 
													+ "', @pvIP = '" + ISNULL(@pvIP,'NULL') 
													+ "'";

	--------------------------------------------------------------------
	--Variables for cursor
	--------------------------------------------------------------------
	DECLARE @cvIdItem AS VARCHAR(50)
	DECLARE @cvIdCountry AS VARCHAR(10)
	DECLARE @cvIdStatusCommercialRelease BIT
	DECLARE @cvItemExists BIT
	DECLARE @cvCountryExists BIT
	
	--------------------------------------------------------------------
	--Load Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'L'
	BEGIN

		CREATE TABLE #stagingCSV (
			Id_Item VARCHAR(50),
			Id_Country VARCHAR(10),
			ID_Status_Commercial_Release BIT
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
		EXEC (@vSQL)

		SET @vMessage = @vMessage +  (SELECT '('  + CAST(COUNT(*) AS VARCHAR) + ' rows affected)' FROM #stagingCSV )

		DELETE FROM #stagingCSV
		WHERE
				Id_Item NOT IN (SELECT
									Id_Item
								FROM GSS_Cat_Item)
			AND Id_Country NOT IN (SELECT
										Id_Country
								   FROM Cat_Countries);

		SELECT
			*
		FROM #stagingCSV;

		DELETE FROM GSS_Commercial_Release
		WHERE
				Id_Item IN (SELECT
								Id_Item
							FROM #stagingCSV)
			AND Id_Country IN (SELECT
									Id_Country
							   FROM #stagingCSV);

		DECLARE curGSSCommercialRelease CURSOR FOR
			SELECT
				Id_Item,
				Id_Country,
				Id_Status_Commercial_Release
			FROM #stagingCSV
			WHERE
					Id_Item IN (SELECT
									Id_Item 
								FROM GSS_Cat_Item)
				AND Id_Country IN (SELECT
										Id_Country
								   FROM Cat_Countries);

		OPEN curGSSCommercialRelease

		FETCH NEXT FROM curGSSCommercialRelease INTO @cvIdItem, @cvIdCountry, @cvIdStatusCommercialRelease

		WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @cvItemExists = (SELECT COUNT(*) FROM GSS_Cat_Item WHERE Id_Item = @cvIdItem);
			SET @cvCountryExists = (SELECT COUNT(*) FROM Cat_Countries WHERE Id_Country = @cvIdCountry);

			IF @cvItemExists = 1 AND @cvCountryExists = 1 
			BEGIN

				INSERT INTO GSS_Commercial_Release (
					Id_Item,
					Id_Country,
					Final_Effective_Date,
					Id_Status_Commercial_Release,
					Modify_By,
					Modify_Date,
					Modify_IP
				)
				VALUES (
					@cvIdItem,
					@cvIdCountry,
					NULL,
					@cvIdStatusCommercialRelease,
					@pvUser,
					GETDATE(),
					@pvIP
				)

			END

			FETCH NEXT FROM curGSSCommercialRelease INTO @cvIdItem, @cvIdCountry, @cvIdStatusCommercialRelease

		END

		CLOSE curGSSCommercialRelease
		DEALLOCATE curGSSCommercialRelease

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
	IF  @pvOptionCRUD = 'L' 
	SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog

END TRY
BEGIN CATCH
	 IF @@TRANCOUNT > 0  
        ROLLBACK TRANSACTION; 

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
