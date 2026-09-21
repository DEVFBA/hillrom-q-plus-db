USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spCat_General_Parameters_CRUD_Records]    Script Date: 8/18/2026 12:47:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_General_Parameters | Create - Read - Upadate - Delete 
Date:		01/01/2021
Example:
			spCat_General_Parameters_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @piIdParameter = 1 , @pvLongDesc = 'Allow Cost / Margin View', @pvValue = '0', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_General_Parameters_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvType ='User'
			spCat_General_Parameters_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piIdParameter = 1

			--------- UPDATE ---------

			DECLARE @pudtCat_General_Parameters UDT_Cat_General_Parameters

			INSERT INTO @pudtCat_General_Parameters ([Id_Parameter],[Value]) VALUES ('47','C:\QPlus\Approval_Routes\ABAC\'),
			('48','2'),
			('41','202608'),
			('43','#1d00db'),
			('42','#ff0000');

			EXEC spCat_General_Parameters_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pudtCat_General_Parameters = @pudtCat_General_Parameters;

			--------- UPDATE ---------

			spCat_General_Parameters_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @piIdParameter = 1
			
*/
CREATE PROCEDURE [dbo].[spCat_General_Parameters_CRUD_Records]
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10) = '',
@piIdParameter					INT = 0,
@pvLongDesc						Varchar(255)= '',
@pvValue						Varchar(MAX)= '',
@pvType							Varchar(50) = '',
@pvUser							Varchar(50) = '',
@pvIP							Varchar(20) = '',
@pudtCat_General_Parameters		UDT_Cat_General_Parameters Readonly
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_General_Parameters - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_General_Parameters_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') 
												+ "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') 
												+ "', @piIdParameter = '" + ISNULL(CAST(@piIdParameter AS varchar),'NULL') 
												+ "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') 
												+ "', @pvValue = '" + ISNULL(CAST(@pvValue AS VARCHAR),'NULL') 
												+ "', @pvUser = '" + ISNULL(@pvUser,'NULL') 
												+ "', @pvIP = '" + ISNULL(@pvIP,'NULL') 
												+ "', @pvType = '" + ISNULL(@pvType,'NULL') 
												+ "'"
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
		SELECT 
		Id_Catalog = CGP.Id_Parameter,
		CGP.Long_Desc,
		CGP.[Value],
		CGP.[Type],
		[Type_Desc] = CPT.Short_Desc,
		CGP.Data_Type,
		CGP.[Status],
		CGP.Modify_By,
		CGP.Modify_Date,
		CGP.Modify_IP
		FROM Cat_General_Parameters AS CGP INNER JOIN Cat_Parameter_Types AS CPT ON
												CGP.[Type] = CPT.Id_Type
		WHERE (@piIdParameter = 0 OR Id_Parameter = @piIdParameter) AND 
			  (@pvType = '' OR [Type] = @pvType)

		ORDER BY 
				--Id_Catalog
				[Type] ASC,
				Long_Desc ASC;

	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		/*UPDATE Cat_General_Parameters 
		SET 
			Long_Desc	= @pvLongDesc,
			[Value]		= @pvValue,
			Modify_Date	= GETDATE(),
			Modify_By	= @pvUser,
			Modify_IP	= @pvIP
		WHERE  Id_Parameter = @piIdParameter*/

		DECLARE @cvIdParameter		SMALLINT;
		DECLARE @cvValue			VARCHAR(MAX);

		DECLARE curGeneralParameters CURSOR FOR
			SELECT
				Id_Parameter,
				[Value]
			FROM @pudtCat_General_Parameters;

		OPEN curGeneralParameters;

		FETCH NEXT FROM curGeneralParameters INTO @cvIdParameter, @cvValue;

		WHILE @@FETCH_STATUS = 0
		BEGIN

			UPDATE Cat_General_Parameters SET [Value] = @cvValue
			WHERE Id_Parameter = @cvIdParameter;

			FETCH NEXT FROM curGeneralParameters INTO @cvIdParameter, @cvValue;

		END

		CLOSE curGeneralParameters;

		DEALLOCATE curGeneralParameters;

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
