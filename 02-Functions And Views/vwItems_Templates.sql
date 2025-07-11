USE DBQS
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- vwWorkflows
/* ==================================================================================*/	
PRINT 'Crea View: vwItems_Templates'

IF OBJECT_ID('vwItems_Templates','V') IS NOT NULL
       DROP VIEW [dbo].vwItems_Templates
GO



/*
Autor:		Alejandro Zepeda
Desc:		Items_Templates
Date:		14/12/2021
Example:
		SELECT * FROM vwItems_Templates where id_item ='P50A7F'
*/

CREATE VIEW dbo.vwItems_Templates
AS

SELECT
--Template Info
---------------------------------------------------
Id_Item_Template		= Template.Item_Template,
Id_ItemTemplate_Class	= ItemTemplate.Id_Item_Class, 
Id_ItemTemplate_SubClass= ItemTemplate.Id_Item_SubClass, 
Item_Template			= ItemTemplate.Short_Desc,
Id_Family				= Template.Id_Family,
Family					= Family.Short_Desc,
Id_Category				= Template.Id_Category,
Category				= Category.Short_Desc,
Id_Line					= Template.Id_Line,
Line					= Line.Short_Desc,
--Item Info
---------------------------------------------------
Id_Item_Class			= Item.Id_Item_Class, 
Item_Class				= Class.Short_Desc,
Id_Item_SubClass		= Item.Id_Item_SubClass, 
Item_SubClass			= SubClass.Short_Desc,
Id_Item					= Item.Id_Item,
Item					= Item.Short_Desc ,
Item_Long_Desc			= Item.Long_Desc ,
Item_Model				= Item.Model,
[Required]				= Template.[Required],
[Default]				= Template.[Default],
Price					= Template.Price,
Standard_Cost			= Template.Standard_Cost,
Measurements			= Item.Measurements,
Specifications			= Item.Specifications 

FROM Items_Templates AS Template 

INNER JOIN Cat_Item AS ItemTemplate ON 
Template.Item_Template = ItemTemplate.Id_Item AND 
ItemTemplate.[Status] = 1

INNER JOIN Cat_Item AS Item ON 
Template.Id_Item = Item.Id_Item AND
Item.[Status] = 1

INNER JOIN Cat_Families AS Family ON 
Template.Id_Family = Family.Id_Family AND
Family.[Status] = 1


INNER JOIN Cat_Categories AS Category ON 
Template.Id_Category = Category.Id_Category AND
Category.[Status] = 1

INNER JOIN Cat_Lines AS Line ON 
Template.Id_Line = Line.Id_Line AND
Line.[Status] = 1

INNER JOIN Cat_Item_Classes AS Class ON 
Item.Id_Item_Class = Class.Id_Item_Class AND
Class.[Status] = 1

INNER JOIN Cat_Item_SubClasses AS SubClass ON 
Item.Id_Item_Class = SubClass.Id_Item_Class AND
Item.Id_Item_SubClass = SubClass.Id_Item_SubClass AND
SubClass.[Status] = 1

WHERE (Template.DynamicField_IsDynamic = 0 OR Template.DynamicField_IsDynamic IS NULL) -- 20240310 -- DynamicFields

