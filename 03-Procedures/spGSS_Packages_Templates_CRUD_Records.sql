USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_Packages_Templates_CRUD_Records]    Script Date: 5/31/2026 9:33:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autor:		Angel Gutierrez
Desc:		GSS_Packages_Templates | Create - Read - Upadate - Delete 
Date:		05/18/2026
Example:


		EXEC spGSS_Packages_Templates_CRUD_Records @pvOptionCRUD		='C',
									@pvIdLanguageUser				= 'ANG', 
									@pvUser							='VIROJAS',
									@pvIP							='127.0.0.1',
									@pudtGSSPackagesTemplates1		= @pudtGSSPackagesTemplates1;

		EXEC spGSS_Packages_Templates_CRUD_Records @pvOptionCRUD		= 'R',
												   @pvIdPackage			= 'TEST001';
			
*/
CREATE PROCEDURE [dbo].[spGSS_Packages_Templates_CRUD_Records]
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10)		= '',
@pvUser							Varchar(50)		= '',
@pvIP							Varchar(20)		= '',
@pudtGSSPackagesTemplates		UDT_GSS_Packages_Templates Readonly,
@pvIdPackage					Varchar(10)		= ''
AS

SET NOCOUNT ON

  
BEGIN TRY  
   
   --------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vSQL Varchar(MAX)

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Packages Templates - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spGSS_Packages_Templates_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL')  
													+ "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') 
													+ "', @pvUser = '" + ISNULL(@pvUser,'NULL') 
													+ "', @pvIdPackage = '" + ISNULL(@pvIdPackage,'NULL') 
													+ "', @pvIP = '" + ISNULL(@pvIP,'NULL') 
													+ "'";

	----------------------------------------------------------------------------------------------------------------------------------
	-- CREATE RECORDS
	----------------------------------------------------------------------------------------------------------------------------------

    IF @pvOptionCRUD = 'C'
    BEGIN
        		
		INSERT INTO GSS_Packages_Templates(
			Id_Package,
			Id_Item,
			Modify_By,
			Modify_Date,
			Modify_IP)

		SELECT 
			Id_Package,
			Id_Item,
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtGSSPackagesTemplates
		
    END

	----------------------------------------------------------------------------------------------------------------------------------
	-- READ RECORDS
	----------------------------------------------------------------------------------------------------------------------------------

    IF @pvOptionCRUD = 'R'
    BEGIN
        
		SELECT
			GPT.Id_Package,
			Packages.Short_Desc AS Package_Description,
			GPT.Id_Item,
			Items.Short_Desc AS Item_Description,
			GPT.Modify_By,
			GPT.Modify_Date,
			GPT.Modify_IP
		FROM GSS_Packages_Templates AS GPT INNER JOIN GSS_Cat_Item AS Packages ON
															GPT.Id_Package = Packages.Id_Item
										   INNER JOIN GSS_Cat_Item AS Items ON
															GPT.Id_Item = Items.Id_Item
		WHERE
				(@pvIdPackage = '' OR Id_Package = @pvIdPackage);

    END

	----------------------------------------------------------------------------------------------------------------------------------
	-- UPDATE RECORDS
	----------------------------------------------------------------------------------------------------------------------------------

    IF @pvOptionCRUD = 'U'
    BEGIN
			
		DELETE GSS_Packages_Templates
		WHERE
				Id_Package IN (SELECT
									Id_Package
							   FROM @pudtGSSPackagesTemplates);
        
		INSERT INTO GSS_Packages_Templates(
			Id_Package,
			Id_Item,
			Modify_By,
			Modify_Date,
			Modify_IP)

		SELECT 
			Id_Package,
			Id_Item,
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtGSSPackagesTemplates

    END 

	----------------------------------------------------------------------------------------------------------------------------------
	-- DELETE RECORDS
	----------------------------------------------------------------------------------------------------------------------------------

    IF @pvOptionCRUD = 'D'
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
												--@pvExecCommand	= 'TEST',
												@pbSuccessful	= @bSuccessful, 
												@pvMessagetType = @vMessageType,
												@pvMessage		= @vMessage, 
												@pvUser			= @pvUser, 
												@pnIdTransacLog	= @nIdTransacLog OUTPUT
	
	SET @vMessage		= dbo.fnGetTransacMessages('Generic Error',@pvIdLanguageUser)
	SET NOCOUNT OFF
		SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog

  
    
END CATCH;  