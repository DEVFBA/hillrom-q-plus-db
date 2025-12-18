USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_Items_Configuration_CRUD_Records]    Script Date: 12/16/2025 6:55:32 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Autor:		Angel Gutierrez
Desc:		GSS_Items_Configuration | Create - Read - Upadate - Delete 
Date:		11/27/25
Example:
			spGSS_Items_Configuration_CRUD_Records @pvOptionCRUD		= 'C',
									@pudtGSSItemsConfiguration = @udtGSSItemsConfiguration,
                                    @pvUser = 'ANGUTIERRE',
                                    @pvIP = '0.0.0.0'

			EXEC spGSS_Items_Configuration_CRUD_Records @pvOptionCRUD		= 'R', 
									@pvIdItem = 'IDItem',
                                    @piIdCategoryHierarchy = 1
 
			EXEC spGSS_Items_Configuration_CRUD_Records @pvOptionCRUD		= 'D', 
									@pvIdItem = 'IDItem',
                                    @piIdCategoryHierarchy = 1

*/
CREATE PROCEDURE [dbo].[spGSS_Items_Configuration_CRUD_Records]
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10)		= 'ANG',
@pvIdItem						Varchar(50)		= '',
@pvUser							Varchar(50)		= '',
@pvIP							Varchar(20)		= '',
@pudtGSSItemsConfiguration		UDT_GSS_Items_Configuration Readonly ,
@piIdCategoryHierarchy          Int             = 0
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------

	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
    DECLARE @iNumRegistros		Int = (SELECT COUNT(*) FROM @pudtGSSItemsConfiguration)
	DECLARE @vjsonUDTGSSConfiguration		NVarchar(MAX)	= (SELECT * FROM @pudtGSSItemsConfiguration FOR JSON AUTO);

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------

	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'GSS_Items_Configuration - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spGSS_Items_Configuration_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pudtGSSItemsConfiguration = '" + ISNULL(CAST(@iNumRegistros AS VARCHAR),'NULL') + " rows affected', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--DECLARE @vExecCommand	Varchar(Max)	= "TEST"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		
		PRINT @vjsonUDTGSSConfiguration
		
		PRINT 'Borra Registros'

		DELETE GSS_Items_Configuration 
		--WHERE Id_Item = @pvIdItem;
		WHERE Id_Item IN (SELECT
								Id_Item
						  FROM @pudtGSSItemsConfiguration);

		PRINT 'Inserta Registros'

		-- Declarar variables
		--DECLARE @Id INT, @Nombre NVARCHAR(100);

		-- Declarar cursor
		DECLARE curGSSItemsConfiguration CURSOR FOR
		SELECT Id_Item, Id_Category_Hierarchy
		FROM @pudtGSSItemsConfiguration;

		-- Abrir cursor
		OPEN curGSSItemsConfiguration;

		-- Obtener primera fila
		FETCH NEXT FROM curGSSItemsConfiguration INTO @pvIdItem, @piIdCategoryHierarchy;

		-- Recorrer filas
		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT 'Id_Item: ' + CAST(@pvIdItem AS NVARCHAR) + ' - Id_Category_Hierarchy: ' + CAST(@piIdCategoryHierarchy AS NVARCHAR);

				INSERT INTO GSS_Items_Configuration (
					Id_Item,
					Id_Category_Hierarchy,
					Modify_By,
					Modify_Date,
					Modify_IP
				) VALUES (
					@pvIdItem,
					@piIdCategoryHierarchy,
					@pvUser,
					GETDATE(),
					@pvIP
				)

			FETCH NEXT FROM curGSSItemsConfiguration INTO @pvIdItem, @piIdCategoryHierarchy;
		END;

		-- Cerrar y liberar
		CLOSE curGSSItemsConfiguration;
		DEALLOCATE curGSSItemsConfiguration;

		/*
		INSERT INTO GSS_Items_Configuration(
			Id_Item,
            Id_Category_Hierarchy,
			Modify_By,
			Modify_Date,
			Modify_IP)
		SELECT 
			Id_Item,
            Id_Category_Hierarchy,
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtGSSItemsConfiguration;
		*/

		PRINT 'Finaliza'
		
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		WITH OrderedTree AS (
			-- Raíces
			SELECT 
				h.Id_Category_Hierarchy,
				h.Id_Category,
				h.Parent,
				h.[Level],
				h.[Order],
				h.[Path],
				h.[Status],
				h.Modify_By,
				h.Modify_Date,
				h.Modify_IP
			FROM GSS_Categories_Hierarchies h
			WHERE h.Parent = 0

			UNION ALL

			-- Hijos recursivos
			SELECT 
				ch.Id_Category_Hierarchy,
				ch.Id_Category,
				ch.Parent,
				ch.[Level],
				ch.[Order],
				ch.[Path],
				ch.[Status],
				ch.Modify_By,
				ch.Modify_Date,
				ch.Modify_IP
			FROM GSS_Categories_Hierarchies ch
			INNER JOIN OrderedTree ot 
				ON ch.Parent = ot.Id_Category_Hierarchy
		)
		SELECT 
			REPLICATE('   ', OT.[Level]-1) + CAST(OT.Id_Category AS VARCHAR(100)) AS TreeView,
			OT.Id_Category_Hierarchy,
			OT.Id_Category,
			OT.Parent,
			OT.[Level],
			OT.[Path],
			OT.[Order],
			OT.[Status],
			OT.Modify_By,
			OT.Modify_Date,
			OT.Modify_IP,
			IC.Id_Category_Hierarchy AS Item_Category_Hierarchy,   
			IC.Id_Item,
			GCC.Short_Desc AS Category
		FROM OrderedTree OT
		INNER JOIN GSS_Cat_Categories AS GCC 
			ON OT.Id_Category = GCC.Id_Category
		LEFT JOIN GSS_Items_Configuration IC
			ON OT.Id_Category_Hierarchy = IC.Id_Category_Hierarchy
			AND (@pvIdItem = '' OR IC.Id_Item = @pvIdItem)
		WHERE OT.[Status] = 1
       -- AND (@piIdCategoryHierarchy = 0 OR OT.Id_Category_Hierarchy = @piIdCategoryHierarchy)
		ORDER BY OT.[Path], OT.[Order];

	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN

		DELETE GSS_Items_Configuration 
		WHERE Id_Item IN (SELECT
								Id_Item
						  FROM @pudtGSSItemsConfiguration);

		INSERT INTO GSS_Items_Configuration(
			Id_Item,
            Id_Category_Hierarchy,
			Modify_By,
			Modify_Date,
			Modify_IP)

		SELECT 
			Id_Item,
            Id_Category_Hierarchy,
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtGSSItemsConfiguration

	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D' OR @vDescOperationCRUD = 'N/A'
	BEGIN
		IF (@pvIdItem <> '' AND @pvIdItem IS NOT NULL AND @piIdCategoryHierarchy <> 0 AND @piIdCategoryHierarchy IS NOT NULL)
        BEGIN
            DELETE GSS_Items_Configuration 
            WHERE Id_Item = @pvIdItem
            AND Id_Category_Hierarchy = @piIdCategoryHierarchy
        END
	END

	--------------------------------------------------------------------
	--Register Transaction Log
	--------------------------------------------------------------------
	EXEC spSecurity_Transaction_Log_Ins_Record	@pvDescription	= @vDescription, 
												@pvExecCommand	= @vExecCommand,
												--@pvExecCommand	= 'TEST',
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
												--@pvExecCommand	= 'TEST',
												@pbSuccessful	= @bSuccessful, 
												@pvMessagetType = @vMessageType,
												@pvMessage		= @vMessage, 
												@pvUser			= @pvUser, 
												@pnIdTransacLog	= @nIdTransacLog OUTPUT
	
	SET @vMessage		= dbo.fnGetTransacMessages('Generic Error',@pvIdLanguageUser)
	SET NOCOUNT OFF
		SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog
		
END CATCH



