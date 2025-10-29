USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spGSS_Categories_Hierarchies
/* ==================================================================================*/	
PRINT 'Crea Procedure: spGSS_Categories_Hierarchies'

IF OBJECT_ID('[dbo].[spGSS_Categories_Hierarchies]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spGSS_Categories_Hierarchies
GO
/*
Autor:		Alejandro Zepeda
Desc:		spGSS_Categories_Hierarchies| Create - Read - Upadate - Delete 
Date:		08/10/2023
Example:
			DECLARE  @pudtGSS_Categories_Hierarchies  UDT_GSS_Categories_Hierarchies

			INSERT INTO @pudtGSS_Categories_Hierarchies
			SELECT 1, 'ORLIGHTS'  , '#', 0,	'path',	0 UNION ALL
			SELECT 2, 'HELUXPRO25',	'1', 1,	'path',	1 UNION ALL
			SELECT 3, 'HELPRMOBLI',	'2', 2,	'path',	1 UNION ALL
			SELECT 4, 'HELPRPENVE',	'2', 2,	'path',	1 UNION ALL
			SELECT 5, 'HELPRCEIVE',	'2', 2,	'path',	0  

			--SELECT * FROM @pudtGSS_Categories_Hierarchies
			
			EXEC spGSS_Categories_Hierarchies @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pudtGSS_Categories_Hierarchies = @pudtGSS_Categories_Hierarchies,  @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'			

			EXEC spGSS_Categories_Hierarchies @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pudtGSS_Categories_Hierarchies = @pudtGSS_Categories_Hierarchies,  @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'			

			spGSS_Categories_Hierarchies @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piIdCategoryHierarchy = 1
			spGSS_Categories_Hierarchies @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdCategory = 'ORLIGHTS'
			spGSS_Categories_Hierarchies @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdFLCCategory = 'ABPMSY' , @pvIdFLCFamily = 'ABPM6100AC', @pvIdFLCGroup = 'ABPACC', @pvIdItem= 'Id Item'			
			spGSS_Categories_Hierarchies @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvParent = '#'			
			spGSS_Categories_Hierarchies @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @piLevel = 2


			SELECT * FROM GSS_Categories_Hierarchies

			EXEC spGSS_Categories_Hierarchies @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pudtGSS_Categories_Hierarchies = @pudtGSS_Categories_Hierarchies,  @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'			
			
			spGSS_Categories_Hierarchies @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvIdFLCCategory = 'Id' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spGSS_Categories_Hierarchies @pvOptionCRUD = 'X', @pvIdLanguageUser = 'ANG', @pvIdFLCCategory = 'Id' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254''
*/
CREATE PROCEDURE [dbo].spGSS_Categories_Hierarchies
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10) = 'ANG',
@piIdCategoryHierarchy			Numeric		= 0,
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
			Id_Category,
			Parent,
			[Level],
			[Path],
			[Status],
			Modify_By,
			Modify_Date,
			Modify_IP)
		SELECT 
			Id_Category,
			Parent,
			[Level],
			[Path],
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
		SELECT 
			CH.Id_Category_Hierarchy,
			CH.Id_Category,
			Category = C.Short_Desc,
			CH.Parent,
			CH.[Level],
			CH.[Path],
			CH.[Status],
			CH.Modify_Date,
			CH.Modify_By,
			CH.Modify_IP
		FROM GSS_Categories_Hierarchies CH
		INNER JOIN GSS_Cat_Categories C ON 
		CH.Id_Category = C.Id_Category

		WHERE (@piIdCategoryHierarchy = 0 OR CH.Id_Category_Hierarchy = @piIdCategoryHierarchy)
		AND (@pvIdCategory = '' OR CH.Id_Category = @pvIdCategory )
		AND (@pvParent = '' OR CH.Parent = @pvParent )
		AND (@piLevel IS NULL OR CH.[Level] = @piLevel)
		AND (@pbStatus IS NULL OR CH.[Status] = @pbStatus)

		ORDER BY CH.Id_Category_Hierarchy,CH.Id_Category,CH.Parent
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
