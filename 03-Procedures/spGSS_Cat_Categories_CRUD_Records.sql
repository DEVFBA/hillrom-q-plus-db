USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_Cat_Categories_CRUD_Records]    Script Date: 12/9/2025 5:16:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Autor:		Angel Gutierrez
Desc:		GSS_Cat_Categories | Create - Read - Upadate - Delete || EFGSS002
Date:		16/09/2025
Example:
			EXEC spGSS_Cat_Categories_CRUD_Records @pvOptionCRUD = 'C', @pvIdCategory = 'AEGHTEST01', @pvShortDesc = 'AEGH Test Short', @pvLongDesc = 'AEGH Test Long Desc', @pbStatus = 1, @pvPDFLayout = 'Test', @pvHierarchyLevel = 'LINE', @pvUser = 'ANGUTIERRE', @pvIP = 'TST';
			EXEC spGSS_Cat_Categories_CRUD_Records @pvOptionCRUD = 'R', @pvIdCategory = '', @pvShortDesc = '', @pvPDFLayout = '', @pvHierarchyLevel = 'FAMILY';
			EXEC spGSS_Cat_Categories_CRUD_Records @pvOptionCRUD = 'R', @pvIdCategory = '', @pvShortDesc = 'Accessories', @pvPDFLayout = '', @pvHierarchyLevel = '';
			EXEC spGSS_Cat_Categories_CRUD_Records @pvOptionCRUD = 'R', @piLevel = 2;
			EXEC spGSS_Cat_Categories_CRUD_Records @pvOptionCRUD = 'U', @pvIdCategory = 'AEGHTEST01', @pvShortDesc = 'AEGH Update S', @pvLongDesc = 'AEGH Test Long Desc Updated', @pbStatus = 0, @pvPDFLayout = 'Test UPD', @pvHierarchyLevel = 'GROUP', @pvUser = 'ANGUTIERRE', @pvIP = 'TST';
			
*/
CREATE PROCEDURE [dbo].[spGSS_Cat_Categories_CRUD_Records]
@pvOptionCRUD		Varchar(1),
@pvIdCategory		Varchar(10)		= '',
@pvShortDesc		Varchar(50)		= '',
@pvLongDesc			Varchar(255)	= '',
@pvHierarchyLevel	Varchar(10)		= '',
@pvPDFLayout		Varchar(255)	= '',
@pbStatus			Bit				= '',
@pvUser				Varchar(50)		= '',
@pvIP				Varchar(20)		= '',
@pvIdLanguageUser   Varchar(10)		= 'ANG',
@piLevel			Int				= 0,
@piIdParent			Int				= 0
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
	DECLARE @vDescription	Varchar(255)	= 'Cat_Families - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spGSSCat_Categories_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdCategory = '" + ISNULL(@pvIdCategory,'NULL') + "', @pvPDFLayout = '" + ISNULL(@pvPDFLayout,'NULL') + "', @pvHierarchyLevel = '" + ISNULL(@pvHierarchyLevel,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM GSS_Cat_Categories WHERE Id_Category = @pvIdCategory)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don�t Exists
		BEGIN
			INSERT INTO GSS_Cat_Categories(
				Id_Category,
				Short_Desc,
				Long_Desc,
				[Status],
				Id_Hierarchy_Level,
                PDF_Layout,
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdCategory,
				@pvShortDesc,
				@pvLongDesc,
				@pbStatus,
				@pvHierarchyLevel,
                @pvPDFLayout,
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
		IF @piLevel = 0
		BEGIN
			SELECT 
			Id_Catalog = GCC.Id_Category,
			GCC.Short_Desc,
			GCC.Long_Desc,
			Id_Hierarchy_Level = GCC.Id_Hierarchy_Level,
			GCC.PDF_Layout,
			GCC.[Status],
			GCC.Modify_Date,
			GCC.Modify_By,
			GCC.Modify_IP
			FROM GSS_Cat_Categories AS GCC INNER JOIN GSS_Cat_Hierarchy_Levels AS GCHL ON
														GCC.Id_Hierarchy_Level = GCHL.Id_Hierarchy_Level
			WHERE (@pvIdCategory = '' OR GCC.Id_Category = @pvIdCategory) AND
				  (@pvShortDesc = '' OR GCC.Short_Desc LIKE '%' + @pvShortDesc + '%') AND
				  (@pvPDFLayout = '' OR GCC.PDF_Layout LIKE '%' + @pvPDFLayout + '%') AND
				  (@pvHierarchyLevel = '' OR GCHL.Id_Hierarchy_Level = @pvHierarchyLevel) 
			ORDER BY GCC.Short_Desc

		END
		IF @piLevel > 0
		BEGIN
			SELECT 
				Id_Catalog = GCC.Id_Category,
				GCC.Short_Desc,
				GCC.Long_Desc,
				Id_Hierarchy_Level = GCC.Id_Hierarchy_Level,
				GCC.PDF_Layout,
				GCC.[Status],
				GCC.Modify_Date,
				GCC.Modify_By,
				GCC.Modify_IP
			FROM GSS_Cat_Categories AS GCC INNER JOIN GSS_Cat_Hierarchy_Levels AS GCHL ON
															GCC.Id_Hierarchy_Level = GCHL.Id_Hierarchy_Level
			WHERE GCHL.Id_Hierarchy_Level = (SELECT TOP 1 Id_Hierarchy_Level
											 FROM GSS_Cat_Hierarchy_Levels
											 WHERE [Level] <= @piLevel
											 ORDER BY [Level] DESC)
		END
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE GSS_Cat_Categories 
		SET Short_Desc			= @pvShortDesc,
			Long_Desc			= @pvLongDesc,
			[Status]			= @pbStatus,
			Id_Hierarchy_Level	= @pvHierarchyLevel,
            PDF_Layout          = @pvPDFLayout,
			Modify_Date			= GETDATE(),
			Modify_By			= @pvUser,
			Modify_IP			= @pvIP
		WHERE Id_Category		= @pvIdCategory
 
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
	--Validate Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'V'
	BEGIN
		
		SELECT 
			Id_Catalog = GCC.Id_Category,
			GCC.Short_Desc,
			GCC.Long_Desc,
			Id_Hierarchy_Level = GCC.Id_Hierarchy_Level,
			GCC.PDF_Layout,
			GCC.[Status],
			GCC.Modify_Date,
			GCC.Modify_By,
			GCC.Modify_IP,
			GCH.Id_Category_Hierarchy,
			GCH.[Level],
			GCH.[Parent],
			GCH.[Status]
		FROM GSS_Cat_Categories AS GCC INNER JOIN GSS_Cat_Hierarchy_Levels AS GCHL ON
														GCC.Id_Hierarchy_Level = GCHL.Id_Hierarchy_Level
									   LEFT JOIN GSS_Categories_Hierarchies AS GCH ON
														GCC.Id_Category = GCH.Id_Category
													AND GCH.[Parent] = @piIdParent
		WHERE 
				GCHL.Id_Hierarchy_Level = (SELECT TOP 1 Id_Hierarchy_Level
												FROM GSS_Cat_Hierarchy_Levels
												WHERE [Level] <= @piLevel
												ORDER BY [Level] DESC)
			AND GCH.Id_Category_Hierarchy IS NULL;
		
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

	IF @pvOptionCRUD NOT IN ('R', 'V')
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