USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_Categories_Hierarchies_CRUD_Records]    Script Date: 12/8/2025 8:15:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autor:		Alejandro Zepeda
Desc:		spGSS_Categories_Hierarchies_CRUD_Records| Create - Read - Upadate - Delete 
Date:		08/10/2023
Example:
			DECLARE  @pudtGSS_Categories_Hierarchies  UDT_GSS_Categories_Hierarchies

			INSERT INTO @pudtGSS_Categories_Hierarchies_CRUD_Records
			SELECT 1, 'ORLIGHTS'  , '#', 0,	'path',	0 UNION ALL
			SELECT 2, 'HELUXPRO25',	'1', 1,	'path',	1 UNION ALL
			SELECT 3, 'HELPRMOBLI',	'2', 2,	'path',	1 UNION ALL
			SELECT 4, 'HELPRPENVE',	'2', 2,	'path',	1 UNION ALL
			SELECT 5, 'HELPRCEIVE',	'2', 2,	'path',	0  

			--SELECT * FROM @pudtGSS_Categories_Hierarchies
			
			EXEC spGSS_Categories_Hierarchies_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pudtGSS_Categories_Hierarchies = @pudtGSS_Categories_Hierarchies,  @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'			

			EXEC spGSS_Categories_Hierarchies_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pudtGSS_Categories_Hierarchies = @pudtGSS_Categories_Hierarchies,  @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'			

			spGSS_Categories_Hierarchies_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piIdCategoryHierarchy = 1
			spGSS_Categories_Hierarchies_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdCategory = 'ORLIGHTS'
			spGSS_Categories_Hierarchies_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdFLCCategory = 'ABPMSY' , @pvIdFLCFamily = 'ABPM6100AC', @pvIdFLCGroup = 'ABPACC', @pvIdItem= 'Id Item'			
			spGSS_Categories_Hierarchies_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvParent = '#'			
			spGSS_Categories_Hierarchies_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piLevel = 2


			SELECT * FROM GSS_Categories_Hierarchies

			EXEC spGSS_Categories_Hierarchies_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pudtGSS_Categories_Hierarchies = @pudtGSS_Categories_Hierarchies,  @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'			
			
			spGSS_Categories_Hierarchies_CRUD_Records @pvOption = 'D', @pvIdLanguageUser = 'ANG', @pvIdFLCCategory = 'Id' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spGSS_Categories_Hierarchies_CRUD_Records @pvOption = 'X', @pvIdLanguageUser = 'ANG', @pvIdFLCCategory = 'Id' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254''
*/
CREATE PROCEDURE [dbo].[spGSS_Categories_Hierarchies_CRUD_Records]
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10) = 'ANG',
@piIdCategoryHierarchy			Int			= 0,
@pvIdCategory					Varchar(10) = '',
@pvParent						Varchar(5)	= '',
@piLevel						Int			= NULL,
@pudtGSS_Categories_Hierarchies	UDT_GSS_Categories_Hierarchies Readonly ,
@pbStatus						Bit				= NULL,
@pvUser							Varchar(50) = '',
@pvIP							Varchar(20) = ''
AS
SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vjsonUDT			NVarchar(MAX)	= (SELECT * FROM @pudtGSS_Categories_Hierarchies FOR JSON AUTO);
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'GSS_Categories_Hierarchies - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spGSS_Categories_Hierarchies @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piIdCategoryHierarchy = '" + ISNULL(CAST(@piIdCategoryHierarchy AS VARCHAR),'NULL') + "', @pvIdCategory = '" + ISNULL(@pvIdCategory,'NULL') + "', @pvParent = '" + ISNULL(@pvParent,'NULL') + "', @piLevel = '" + ISNULL(CAST(@piLevel AS VARCHAR),'NULL') + "', @pudtGSSCategoriesHierarchies = '" + ISNULL(@vjsonUDT,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "',  @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN		
		INSERT INTO GSS_Categories_Hierarchies(
			Id_Category_Hierarchy,
			Id_Category,
			Parent,
			[Level],
			[Path],
			[Order],
			[Status],
			Modify_By,
			Modify_Date,
			Modify_IP)
		SELECT 
			Id_Category_Hierarchy,
			Id_Category,
			Parent,
			[Level],
			[Path],
			[Order],
			[Status],
			@pvUser,
			GETDATE(),
			@pvIP
		FROM @pudtGSS_Categories_Hierarchies
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN	

		WITH Base AS (
						SELECT
							h.Id_Category_Hierarchy,
							h.Id_Category,
							h.Parent,
							h.[Level],
							h.[Order],
							h.[Path],
							h.[Status],
							ROW_NUMBER() OVER (
								PARTITION BY h.Parent
								ORDER BY h.[Order], h.Id_Category_Hierarchy
							) AS SiblingSeq,
							c.Short_Desc
						FROM GSS_Categories_Hierarchies h
						INNER JOIN GSS_Cat_Categories c
							ON h.Id_Category = c.Id_Category
		),
		Tree AS (
				SELECT
					b.Id_Category_Hierarchy,
					b.Id_Category,
					b.Parent,
					b.[Level],
					b.[Order],
					b.[Path],
					b.[Status],
					b.SiblingSeq,
					b.Short_Desc,
					CAST(b.Short_Desc AS VARCHAR(MAX)) AS Path_Desc,
					CAST(RIGHT('000000' + CAST(b.SiblingSeq AS VARCHAR(10)), 6) AS VARCHAR(1000)) AS SortKey
				FROM Base b
				WHERE b.Parent = 0

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
					ch.SiblingSeq,
					ch.Short_Desc,
					CAST(t.Path_Desc + '/' + ch.Short_Desc AS VARCHAR(MAX)) AS Path_Desc,
					CAST(t.SortKey + '.' + RIGHT('000000' + CAST(ch.SiblingSeq AS VARCHAR(10)), 6) AS VARCHAR(1000)) AS SortKey
				FROM Base ch
				INNER JOIN Tree t
					ON ch.Parent = t.Id_Category_Hierarchy
		)
		SELECT
			REPLICATE('   ', T.[Level]-1) + CAST(T.Id_Category AS VARCHAR(50)) AS TreeView,
			T.Id_Category_Hierarchy,
			T.Id_Category,
			REPLICATE('   ', T.[Level]-1) + CAST(T.Short_Desc AS VARCHAR(50)) AS CategoryTreeView,
			T.Short_Desc AS Category,
			T.Parent AS Parent_Id,
			CASE 
						WHEN GCH.Id_Category IS NULL THEN '#'
						ELSE CAST(GCH.Id_Category AS VARCHAR(100))
					END AS Parent,
			T.[Level],
			T.[Path],
			T.Path_Desc,
			T.[Status],
			T.[Order],
			T.SortKey,
			(SELECT MAX(Id_Category_Hierarchy) FROM GSS_Categories_Hierarchies) + 1 AS Next_Number
		FROM Tree T
		INNER JOIN GSS_Cat_Categories AS GCC 
					ON T.Id_Category = GCC.Id_Category
				LEFT JOIN GSS_Categories_Hierarchies AS GCH 
				ON T.Parent = GCH.Id_Category_Hierarchy
		ORDER BY T.SortKey;

	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE A
		SET
			A.Id_Category	= B.Id_Category,
			A.Parent		= B.Parent,
			A.[Level]		= B.[Level],
			A.[Path]		= B.[Path],
			A.[Order]		= B.[Order],
			A.[Status]		= B.[Status],
			A.Modify_Date	= GETDATE(),
			A.Modify_By		= @pvUser,
			A.Modify_IP		= @pvIP
		FROM GSS_Categories_Hierarchies A
		INNER JOIN @pudtGSS_Categories_Hierarchies B ON
		A.Id_Category_Hierarchy = B.Id_Category_Hierarchy

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
