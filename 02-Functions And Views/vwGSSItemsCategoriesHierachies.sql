USE DBQS
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- vwGSSItemsCategoriesHierachies
/* ==================================================================================*/	
PRINT 'Crea View: vwGSSItemsCategoriesHierachies'

IF OBJECT_ID('vwGSSItemsCategoriesHierachies','V') IS NOT NULL
       DROP VIEW [dbo].vwGSSItemsCategoriesHierachies
GO



/*
Autor:		Angel Gutierrez
Desc:		GSS Items Categories Hierarchies  View
Date:		04/16/2026
Example:
		SELECT * FROM vwGSSItemsCategoriesHierachies
		ORDER BY SortKey;
		
*/

CREATE VIEW dbo.vwGSSItemsCategoriesHierachies
AS
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
				GCI.Id_Currency,
				--GCI.Standard_Cost,
				GCI.Modify_By,
				GCI.Modify_Date,
				GCI.Modify_IP,
				GCC.PDF_Layout
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
				ON GIC.Id_Item = GCI.Id_Item;