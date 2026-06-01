USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_PDF_Price_Lists]    Script Date: 5/24/2026 8:16:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Autor:		Angel Gutierrez
Desc:		PDF_Price_Lists | Create - Read - Upadate - Delete || 
Date:		12/28/25
Example:
			
			EXEC spGSS_PDF_Price_Lists @pvOptionCRUD = 'R', @piMode = 1, @pvLineId = 'HELUXPRO25', @pvUser = 'ANGUTIERRE', @pvIP = '0.0.0.0', @pvIdLanguageUser = 'ANG';
			EXEC spGSS_PDF_Price_Lists @pvOptionCRUD = 'R', @piMode = 2, @pvLineId = 'HELUXPRO25', @pvUser = 'ANGUTIERRE', @pvIP = '0.0.0.0', @pvIdLanguageUser = 'ANG';
			EXEC spGSS_PDF_Price_Lists @pvOptionCRUD = 'R', @piMode = 3, @pvLineId = 'HELUXPRO25', @pvUser = 'ANGUTIERRE', @pvIP = '0.0.0.0', @pvIdLanguageUser = 'ANG';

			EXEC spGSS_PDF_Price_Lists @pvOptionCRUD = 'R', @piMode = 1, @pvLineId = 'HELUXPRO25', @pvUser = 'ANGUTIERRE', @pvIP = '0.0.0.0', @pvIdLanguageUser = 'ANG';
			EXEC spGSS_PDF_Price_Lists @pvOptionCRUD = 'R', @piMode = 2, @pvLineId = 'HELUXPRO25', @pvUser = 'ANGUTIERRE', @pvIP = '0.0.0.0', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX';
			EXEC spGSS_PDF_Price_Lists @pvOptionCRUD = 'R', @piMode = 3, @pvLineId = 'HELUXPRO25', @pvUser = 'ANGUTIERRE', @pvIP = '0.0.0.0', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX';

*/
CREATE PROCEDURE [dbo].[spGSS_PDF_Price_Lists]
@pvOptionCRUD		Varchar(1),
@piMode             Int				= 0, -- 0: All ; 1: Only Index ; 2: Only Items
@pvLineId           Varchar(10)     = '',
@pvUser				Varchar(50)		= '',
@pvIP				Varchar(20)		= '',
@pvIdLanguageUser   Varchar(10)		= 'ANG',
@pvIdCountry		Varchar(10)		
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
	DECLARE @vDescription	Varchar(255)	= 'GSS_PDF_Price_Lists - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spGSS_PDF_Price_Lists @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piMode = " + ISNULL(CAST(@piMode AS VARCHAR(1)),'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "'"
	PRINT 'Exec_Command: ' + @vExecCommand;
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
		
        IF @piMode = 0
        BEGIN

            PRINT 'Mode 0: All'

        END

        ELSE IF @piMode = 1 -- Get Only Index
        BEGIN
     
			WITH HierarchyWithIndex AS (
					-- Base case: Level 3 (start of our hierarchy)
					SELECT 
						h.Id_Category_Hierarchy,
						h.Id_Category,
						h.Parent,
						h.[Level],
						h.[Order],
						h.[Path],
						h.[Status],
						c.Short_Desc,
						c.Additional_Desc,
						-- Create index for level 3: just the order number
						CAST(h.[Order] AS VARCHAR(100)) AS HierarchyIndex,
						-- Create sort key for proper hierarchical ordering (parent comes before children)
						CAST(FORMAT(h.[Order], '000') AS VARCHAR(1000)) AS SortKey,
						-- Track the root parent for grouping
						h.Id_Category_Hierarchy AS RootParent,
						-- Parent hierarchy resolution for Level 3
						p2.Id_Category AS Parent_Level_1,
						p1.Id_Category AS Parent_Level_2,
						h.Id_Category AS Parent_Level_3,
						CAST(NULL AS VARCHAR(10)) AS Parent_Level_4,
						CAST(NULL AS VARCHAR(10)) AS Parent_Level_5
					FROM GSS_Categories_Hierarchies h
					INNER JOIN GSS_Cat_Categories c ON h.Id_Category = c.Id_Category
					-- Find Level 2 parent
					LEFT JOIN GSS_Categories_Hierarchies p1 ON h.Parent = CAST(p1.Id_Category_Hierarchy AS VARCHAR(5)) AND p1.[Level] = 2
					-- Find Level 1 parent (parent of Level 2)
					LEFT JOIN GSS_Categories_Hierarchies p2 ON p1.Parent = CAST(p2.Id_Category_Hierarchy AS VARCHAR(5)) AND p2.[Level] = 1
					WHERE h.[Level] = 3 
					AND h.[Status] = 1

					UNION ALL

					-- Recursive case: Level 4 and 5
					SELECT 
						ch.Id_Category_Hierarchy,
						ch.Id_Category,
						ch.Parent,
						ch.[Level],
						ch.[Order],
						ch.[Path],
						ch.[Status],
						cc.Short_Desc,
						cc.Additional_Desc,
						-- Build hierarchical index: parent index + '.' + current order
						CASE 
							WHEN ch.[Level] = 4 THEN CAST(p.HierarchyIndex + '.' + CAST(ch.[Order] AS VARCHAR) AS VARCHAR(100))
							WHEN ch.[Level] = 5 THEN CAST(p.HierarchyIndex + '.' + CAST(ch.[Order] AS VARCHAR) AS VARCHAR(100))
							ELSE CAST(p.HierarchyIndex AS VARCHAR(100))
						END AS HierarchyIndex,
						-- Build sort key to keep children immediately after their parent
						CAST(p.SortKey + '.' + FORMAT(ch.[Order], '000') AS VARCHAR(1000)) AS SortKey,
						-- Keep track of root parent for grouping
						p.RootParent,
						-- Inherit parent hierarchy and add current level
						p.Parent_Level_1,
						p.Parent_Level_2,
						p.Parent_Level_3,
						CASE 
							WHEN ch.[Level] = 4 THEN CAST(ch.Id_Category AS VARCHAR(10))  -- Level 4 stores its own Id_Category
							WHEN ch.[Level] = 5 THEN CAST((
								SELECT h_parent.Id_Category 
								FROM GSS_Categories_Hierarchies h_parent 
								WHERE h_parent.Id_Category_Hierarchy = CAST(ch.Parent AS INT) 
								AND h_parent.[Level] = 4
							) AS VARCHAR(10))  -- Level 5's Level 4 parent
							ELSE CAST(NULL AS VARCHAR(10))
						END AS Parent_Level_4,
						CASE 
							WHEN ch.[Level] = 5 THEN CAST(ch.Id_Category AS VARCHAR(10))  -- Level 5 record stores its own Id_Category
							ELSE CAST(NULL AS VARCHAR(10))
						END AS Parent_Level_5
						/*CASE 
							WHEN ch.[Level] = 5 THEN CAST(NULL AS VARCHAR(10))  -- Level 5 has no Level 5 parent
							ELSE CAST(NULL AS VARCHAR(10))
						END AS Parent_Level_5*/
					FROM GSS_Categories_Hierarchies ch
					INNER JOIN GSS_Cat_Categories cc ON ch.Id_Category = cc.Id_Category
					INNER JOIN HierarchyWithIndex p ON ch.Parent = CAST(p.Id_Category_Hierarchy AS VARCHAR(5))
					WHERE ch.[Level] IN (4, 5) 
					AND ch.[Status] = 1
				)

				SELECT 
					HWI.Id_Category_Hierarchy,
					--HWI.Id_Category,
					--HWI.Short_Desc AS Category_Name,
					HWI.Parent,
					HWI.[Level],
					HWI.[Order] AS Order_Within_Parent,
					HWI.HierarchyIndex,
					-- Parent hierarchy columns
					HWI.Parent_Level_1,
					HWI.Parent_Level_2,
					HWI.Parent_Level_3,
					HWI.Parent_Level_4,
					HWI.Parent_Level_5,
					-- Show visual indentation for hierarchy
					REPLICATE('    ', HWI.[Level] - 3) + HWI.HierarchyIndex + ' - ' + HWI.Short_Desc AS Tree_View,
					--HWI.[Path],
					--HWI.[Status],
					--HWI.SortKey,
					--HWI.RootParent
					--GCC.Image_Path,
					HWI.[Path] as Image_Path,
					(SELECT
							Image_Path
					 FROM GSS_Cat_Categories
					 WHERE 
							Id_Category = HWI.Parent_Level_2) AS Portrait_Image,
					(SELECT
							PDF_Layout
					 FROM GSS_Cat_Categories
					 WHERE 
							Id_Category = HWI.Parent_Level_2) AS Second_Portrait,
					HWI.Additional_Desc,
					GCCPDF.Long_Desc AS PDF_Title
				FROM HierarchyWithIndex AS HWI INNER JOIN GSS_Cat_Categories AS GCC ON
												HWI.Id_Category = GCC.Id_Category
											   INNER JOIN GSS_Cat_Categories AS GCCPDF ON
												HWI.Parent_Level_2 = GCCPDF.Id_Category

				WHERE 
						HWI.[Status] = 1
					AND (@pvLineId = '' OR HWI.Parent_Level_2 = @pvLineId)
				ORDER BY 
					RootParent,    -- Group by root parent first
					SortKey;       -- Then order hierarchically within each group

        END

        ELSE IF @piMode = 2 -- Get Only Items

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
				-- Anchor
				SELECT
					b.Id_Category_Hierarchy,
					b.Id_Category,
					b.Parent,
					b.[Level],
					b.[Order],
					CAST(b.Id_Category AS VARCHAR(MAX)) AS Path,   -- 👈 Path inicial con Id_Category
					b.[Status],
					b.SiblingSeq,
					b.Short_Desc,
					CAST(b.Short_Desc AS VARCHAR(MAX)) AS Path_Desc,
					CAST(RIGHT('000000' + CAST(b.SiblingSeq AS VARCHAR(10)), 6) AS VARCHAR(1000)) AS SortKey
				FROM Base b
				WHERE b.Parent = 0

				UNION ALL

				-- Recursivo
				SELECT
					ch.Id_Category_Hierarchy,
					ch.Id_Category,
					ch.Parent,
					ch.[Level],
					ch.[Order],
					CAST(t.Path + '|' + CAST(ch.Id_Category AS VARCHAR(50)) AS VARCHAR(MAX)) AS Path,   -- 👈 concatenamos Id_Category
					ch.[Status],
					ROW_NUMBER() OVER (
						PARTITION BY ch.Parent 
						ORDER BY ch.[Order], ch.Id_Category_Hierarchy
					) AS SiblingSeq,
					ch.Short_Desc,
					CAST(t.Path_Desc + '|' + ch.Short_Desc AS VARCHAR(MAX)) AS Path_Desc,                         -- 👈 concatenamos Short_Desc
					CAST(t.SortKey + '.' + RIGHT('000000' + CAST(ROW_NUMBER() OVER (
						PARTITION BY ch.Parent 
						ORDER BY ch.[Order], ch.Id_Category_Hierarchy
					) AS VARCHAR(10)), 6) AS VARCHAR(1000)) AS SortKey
				FROM Base ch
				INNER JOIN Tree t
					ON ch.Parent = t.Id_Category_Hierarchy
			)
			SELECT DISTINCT
				--REPLICATE('   ', T.[Level]-1) + CAST(T.Id_Category AS VARCHAR(50)) AS TreeView,
				--T.Id_Category_Hierarchy,
				--T.Id_Category,
				--REPLICATE('   ', T.[Level]-1) + CAST(T.Short_Desc AS VARCHAR(50)) AS CategoryTreeView,
				T.Short_Desc AS Category,
				T.Parent AS Parent_Id,
				T.[Level],
				--T.[Path],
				--T.Path_Desc,

				-- Parents parsed with STRING_SPLIT (names)
				--P.Parent1,
				--P.Parent2,
				--P.Parent3,
				--P.Parent4,
				--P.Parent5,

				-- Parents parsed with STRING_SPLIT (Hierarchy IDs)
				PI.ParentId1,
				PI.ParentId2,
				PI.ParentId3,
				PI.ParentId4,
				PI.ParentId5,

				-- Orders from GSS_Categories_Hierarchies
				--GCHP1.[Order] AS ParentOrder1,
				--GCHP2.[Order] AS ParentOrder2,
				--GCHP3.[Order] AS ParentOrder3,
				--GCHP4.[Order] AS ParentOrder4,
				--GCHP5.[Order] AS ParentOrder5,

				--T.[Status] AS Hierarchy_Status,
				--T.[Order] AS CurrentOrder,
				T.SortKey,
				--GCI.Id_Item_Class,
				--GCI.Id_Item_SubClass,
				GCI.Id_Item,
				--GCI.Short_Desc,
				GCI.Long_Desc,
				--GCI.Id_Currency,
				GCI.Specifications,
				GCI.On_Request,
				GCI.Price,
				--GCI.Standard_Cost,
				GCI.Modify_By,
				GCI.Modify_Date,
				GCI.Modify_IP,
				GCC.PDF_Layout,
				GCR.Id_Status_Commercial_Release
			FROM Tree T
			OUTER APPLY (
				SELECT
					MAX(CASE WHEN rn = 1 THEN token END) AS Parent1,
					MAX(CASE WHEN rn = 2 THEN token END) AS Parent2,
					MAX(CASE WHEN rn = 3 THEN token END) AS Parent3,
					MAX(CASE WHEN rn = 4 THEN token END) AS Parent4,
					MAX(CASE WHEN rn = 5 THEN token END) AS Parent5
				FROM (
					SELECT 
						ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn,
						value AS token
					FROM STRING_SPLIT(T.Path_Desc, '|')
				) s
			) P
			OUTER APPLY (
				SELECT
					MAX(CASE WHEN rn = 1 THEN token END) AS ParentId1,
					MAX(CASE WHEN rn = 2 THEN token END) AS ParentId2,
					MAX(CASE WHEN rn = 3 THEN token END) AS ParentId3,
					MAX(CASE WHEN rn = 4 THEN token END) AS ParentId4,
					MAX(CASE WHEN rn = 5 THEN token END) AS ParentId5
				FROM (
					SELECT 
						ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn,
						value AS token
					FROM STRING_SPLIT(T.Path, '|')
				) s
			) PI
			LEFT JOIN GSS_Cat_Categories AS GCC 
				ON T.Id_Category = GCC.Id_Category
			LEFT JOIN GSS_Categories_Hierarchies AS GCHP1 ON GCHP1.Id_Category = PI.ParentId1
			LEFT JOIN GSS_Categories_Hierarchies AS GCHP2 ON GCHP2.Id_Category = PI.ParentId2
			LEFT JOIN GSS_Categories_Hierarchies AS GCHP3 ON GCHP3.Id_Category = PI.ParentId3
			LEFT JOIN GSS_Categories_Hierarchies AS GCHP4 ON GCHP4.Id_Category = PI.ParentId4
			LEFT JOIN GSS_Categories_Hierarchies AS GCHP5 ON GCHP5.Id_Category = PI.ParentId5
			LEFT JOIN GSS_Items_Configuration AS GIC
				ON T.Id_Category_Hierarchy = GIC.Id_Category_Hierarchy
			LEFT JOIN GSS_Cat_Item AS GCI
				ON GIC.Id_Item = GCI.Id_Item
			--------------------------------------------------------------------------------------
			-- BEGIN Commercial Release JOIN
			--------------------------------------------------------------------------------------
			LEFT JOIN GSS_Commercial_Release AS GCR ON 
							GCR.Id_Item = GCI.Id_Item
						AND (@pvIdCountry = '' OR GCR.Id_Country = @pvIdCountry)
						--AND GCR.Id_Country = @pvIdCountry
						--AND GCR.Id_Status_Commercial_Release = 1
			--------------------------------------------------------------------------------------
			-- END Commercial Release JOIN
			--------------------------------------------------------------------------------------
			WHERE
					GCI.Id_Item IS NOT NULL
				AND (@pvLineId = '' OR PI.ParentId2 = @pvLineId)
			--------------------------------------------------------------------------------------
			-- START Commercial Release Select
			--------------------------------------------------------------------------------------
				AND (GCR.Id_Status_Commercial_Release = 1 OR GCR.Id_Status_Commercial_Release = NULL)
			--------------------------------------------------------------------------------------
			-- END Commercial Release JOIN
			--------------------------------------------------------------------------------------
			ORDER BY T.SortKey;

        END

		ELSE IF @piMode = 3 -- Get All
		BEGIN

			EXEC spGSS_PDF_Price_Lists @pvOptionCRUD = 'R', 
									   @piMode = 1, 
									   @pvLineId = @pvLineId, 
									   @pvUser = @pvUser, 
									   @pvIP = @pvIP, 
									   @pvIdLanguageUser = @pvIdLanguageUser,
									   @pvIdCountry = @pvIdCountry;

			EXEC spGSS_PDF_Price_Lists @pvOptionCRUD = 'R', 
									   @piMode = 2, 
									   @pvLineId = @pvLineId, 
									   @pvUser = @pvUser, 
									   @pvIP = @pvIP, 
									   @pvIdLanguageUser = @pvIdLanguageUser, 
									   @pvIdCountry = @pvIdCountry;

		END
        
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------

	IF @pvOptionCRUD = 'U' 
	BEGIN
		SET @bSuccessful	= 0
		SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
		SET @vMessage		= dbo.fnGetTransacMessages('N/A',@pvIdLanguageUser)
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