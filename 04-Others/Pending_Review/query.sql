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
					--HWI.Id_Category_Hierarchy,
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
					GCC.Image_Path,
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
					HWI.Additional_Desc
				FROM HierarchyWithIndex AS HWI INNER JOIN GSS_Cat_Categories AS GCC ON
												HWI.Id_Category = GCC.Id_Category
				/*WHERE 
						HWI.[Status] = 1
					AND (@pvLineId = '' OR HWI.Parent_Level_2 = @pvLineId)*/
				ORDER BY 
					RootParent,    -- Group by root parent first
					SortKey;       -- Then order hierarchically within each group