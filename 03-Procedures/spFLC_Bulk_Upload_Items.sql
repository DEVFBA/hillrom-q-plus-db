USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spFLC_Bulk_Upload_Items
/* ==================================================================================*/	
PRINT 'Crea Procedure: spFLC_Bulk_Upload_Items'

IF OBJECT_ID('[dbo].[spFLC_Bulk_Upload_Items]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spFLC_Bulk_Upload_Items
GO

/*
Autor:		Alejandro Zepeda
Desc:		FLC Obsolescence Process | Job
Date:		28/10/2023
Example:
			EXEC spFLC_Bulk_Upload_Items @pvOptionCRUD		=  'L', -- Load Records
										 @pvIdLanguageUser	= 'ANG', 
										 @pvFileName		= 'Ejemplo_Layout.csv',
										 @pvLoadNewItems	= 0, -- | 0 =  Actualización  | 1 = Inserta nuevos items
										 @pvUser			= 'AZEPEDA',
										 @pvIP				= '1.1.1.1'

			EXEC spFLC_Bulk_Upload_Items @pvOptionCRUD		=  'L', -- Load Records
										 @pvIdLanguageUser	= 'ANG', 
										 @pvFileName		= 'Ejemplo_Layout_News.csv',
										 @pvLoadNewItems	= 1, -- | 0 =  Actualización  | 1 = Inserta nuevos items
										 @pvUser			= 'AZEPEDA',
										 @pvIP				= '1.1.1.1'

										 

			EXEC spFLC_Bulk_Upload_Items @pvOptionCRUD		=  'W', -- Download Records
										 @pvIdLanguageUser	= 'ANG', 
										 @pvUser			= 'AZEPEDA',
										 @pvIP				= '1.1.1.1'

INSERT Cat_General_Parameters
VALUES(58, 'Bulk_Upload_Items Path', 'C:\Processes\Bulk_Upload_Items\', 'Internal', 'String', 1, 'AZEPEDA', '20231029', '0.0.0.0')
*/
CREATE PROCEDURE [dbo].[spFLC_Bulk_Upload_Items]
@pvOptionCRUD			Varchar(1)  = 'W',
@pvIdLanguageUser		Varchar(10) = 'ANG',
@pvFileName				Varchar(255)= '',
@pvLoadNewItems			Bit			= 0,
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
	DECLARE @vDescription	Varchar(255)	= 'Bulk Upload Items  - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= 'Executed Successfully '
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spFLC_Bulk_Upload_Items @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvFileName = '" + ISNULL(@pvFileName,'NULL') + "', @pvLoadNewItems = " + ISNULL(CAST(@pvLoadNewItems AS VARCHAR),'NULL') + ", @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	
	--------------------------------------------------------------------
	--Download Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'W'
	BEGIN
		SELECT 
		
			Item_Id				= I.Id_Item,
			Short_Description	= I.Short_Desc,
			Long_Description	= I.Long_Desc,
			Category_Id			= IC.Id_FLC_Category,
			Category			= C.Short_Desc,
			Group_Id			= IC.Id_FLC_Group,
			[Group]				= G.Short_Desc,
			Family_Id			= IC.Id_FLC_Family,
			Family				= F.Short_Desc,
			Comment				= I.Comment,
			Price				= I.Price,
			Standard_Cost		= I.Standard_Cost,
			Discontinue			= I.Obsolescence,
			Substitute_Item		= I.Substitute_Item,
			[Current]			= I.[Status]

		FROM FLC_Items_Configuration IC

			INNER JOIN FLC_Cat_Categories C ON 
			IC.Id_FLC_Category = C.Id_FLC_Category
			--AND C.[Status] = 1

			INNER JOIN FLC_Cat_Families F ON 
			IC.Id_FLC_Family = F.Id_FLC_Family
			--AND F.[Status] = 1

			INNER JOIN FLC_Cat_Groups G ON 
			IC.Id_FLC_Group = G.Id_FLC_Group
			--AND G.[Status] = 1

			INNER JOIN FLC_Cat_Item I ON
			IC.Id_Item = I.Id_Item
			--AND I.[Status] = 1

		ORDER BY I.Id_Item
	END

	--------------------------------------------------------------------
	--Load Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'L'
	BEGIN
		TRUNCATE TABLE FLC_Temp_Bulk_Upload_Items
		--TRUNCATE TABLE Ztemp_xlsx

		SET @vSQL = "
		BULK INSERT FLC_Temp_Bulk_Upload_Items
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

		SET @vMessage = @vMessage +  (SELECT '('  + CAST(COUNT(*) AS VARCHAR) + ' rows affected)' FROM FLC_Temp_Bulk_Upload_Items )
		
		-----------------------------------------------------------------
		-- Botón “Load New Items”
		IF @pvLoadNewItems = 1 
		BEGIN 
			BEGIN TRANSACTION;  
			-------------------------
			--Insert Items
			-------------------------
			INSERT INTO FLC_Cat_Item (
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
				Modify_By,
				Modify_Date,
				Modify_IP)
			SELECT DISTINCT 
				Item_Id,
				Short_Description,
				Long_Description,
				Comment,
				Price,
				Standard_Cost,
				Discontinue,				
				Obsolescence_Date = (CASE WHEN [Current] = 0 THEN  GETDATE() ELSE  NULL END),
				Image_Path = '',
				Substitute_Item,
				[Current],
				@pvUser,
				GETDATE(),
				@pvIP
			FROM FLC_Temp_Bulk_Upload_Items

			-------------------------
			--Insert Items Configuration
			-------------------------
			INSERT INTO FLC_Items_Configuration (
				Id_FLC_Category,
				Id_FLC_Family,
				Id_FLC_Group,
				Id_Item,
				[Status],
				Modify_By,
				Modify_Date,
				Modify_IP)
			SELECT DISTINCT
				Category_Id,
				Family_Id,
				Group_Id,				
				Item_Id,
				[Current],
				@pvUser,
				GETDATE(),
				@pvIP
			FROM FLC_Temp_Bulk_Upload_Items

			-------------------------
			--Insert Items Configuration
			-------------------------
			INSERT INTO FLC_Commercial_Release (
				Id_Item,
				Id_Country,
				Id_Language,
				Id_Status_Commercial_Release,
				Final_Effective_Date,
				Modify_By,
				Modify_Date,
				Modify_IP)
			SELECT DISTINCT 
				T.Item_Id,
				Id_Country = C.Id_Country,
				Id_Language = 'ANG',
				Id_Status_Commercial_Release = 1,
				Final_Effective_Date = NULL,
				@pvUser,
				GETDATE(),
				@pvIP
			FROM FLC_Temp_Bulk_Upload_Items T
			INNER JOIN Cat_Countries C ON 
			C.[Status] = 1

			IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION;  

		END
		-----------------------------------------------------------------
		-- Botón “Load Changes"
		ELSE
		BEGIN 
			UPDATE I
			SET  
				I.Short_Desc		= T.Short_Description,
				I.Long_Desc			= T.Long_Description,
				I.Comment			= T.Comment,
				I.Price				= T.Price,
				I.Standard_Cost		= T.Standard_Cost,
				I.Obsolescence		= T.Discontinue,
				I.Obsolescence_Date	= (CASE WHEN T.[Current] = 0 THEN(CASE WHEN I.Obsolescence_Date IS NULL THEN GETDATE() ELSE  I.Obsolescence_Date END) END),
				I.Substitute_Item	= T.Substitute_Item,
				I.[Status]			= T.[Current],
				I.Modify_By			= @pvUser,
				I.Modify_Date		= GETDATE(),
				I.Modify_IP			= @pvIP

			FROM FLC_Cat_Item I
			INNER JOIN FLC_Temp_Bulk_Upload_Items T ON 
			I.Id_Item = T.Item_Id
		END

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
