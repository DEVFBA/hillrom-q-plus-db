USE DBQS
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- vwWorkflows
/* ==================================================================================*/	
PRINT 'Crea View: vwPackage_Costs'

IF OBJECT_ID('vwPackage_Costs','V') IS NOT NULL
       DROP VIEW [dbo].vwPackage_Costs
GO



/*
Autor:		Angel Gutierrez
Desc:		Items_Templates con Commercial Release Disponibles
Date:		06/08/25
Example:
		SELECT * FROM vwPackage_Costs
*/

CREATE VIEW dbo.vwPackage_Costs 
AS

SELECT
	CI.Id_Country_Package [Country_Package]
	,IT.Item_Template [Package_ID]
	,CI.Short_Desc [Package_Description]
	,CI.Id_Item_Related [Related_Item]
	,IT.Quantity [Qty]
	,IT.Id_Item [Acc_Comp_ID]
	,CICA.Id_Item_Class [Item_Class]
	,CICA.Short_Desc [Item_Desc]
	,IT.Standard_Cost [Package_Cost]
	,ITPR.Standard_Cost [Product_Cost]
	,ITCA.Standard_Cost [Acc_Comp_Cost]
FROM Items_Templates AS IT INNER JOIN Cat_Item AS CI ON
									IT.Item_Template = CI.Id_Item
								AND CI.Id_Item_Class IN ('PACK', 'PACKD')
						   INNER JOIN Cat_Item AS CICA ON
									IT.Id_Item = CICA.Id_Item
						   INNER JOIN Items_Templates AS ITCA ON
									IT.Id_Item = ITCA.Id_Item
								AND CI.Id_Item_Related = ITCA.Item_Template
						   INNER JOIN Items_Templates AS ITPR ON
									CI.Id_Item_Related = ITPR.Id_Item
UNION
SELECT
	CI.Id_Country_Package [Country_Package]
	,IT.Item_Template [Package_ID]
	,CI.Short_Desc [Package_Description]
	,CI.Id_Item_Related [Related_Item]
	,IT.Quantity [Qty]
	,IT.Id_Item [Acc_Comp_ID]
	,CICA.Id_Item_Class [Item_Class]
	,CICA.Short_Desc [Item_Desc]
	,IT.Standard_Cost [Package_Cost]
	,ITPR.Standard_Cost [Product_Cost]
	,ITCA.Standard_Cost [Acc_Comp_Cost]
FROM Items_Templates AS IT INNER JOIN Cat_Item AS CI ON
									IT.Item_Template = CI.Id_Item
								AND CI.Id_Item_Class IN ('PACK', 'PACKD')
						   INNER JOIN Cat_Item AS CICA ON
									IT.Id_Item = CICA.Id_Item
						   INNER JOIN Items_Templates AS ITCA ON
									IT.Id_Item = ITCA.Id_Item
						   INNER JOIN Items_Templates AS ITPR ON
									CI.Id_Item_Related = ITPR.Id_Item
WHERE 
	CICA.Id_Item_Class IN ('PACK', 'PACKD')
