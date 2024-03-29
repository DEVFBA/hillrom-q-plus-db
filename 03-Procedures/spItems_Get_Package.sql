
USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spItems_Get_Package
/* ==================================================================================*/	
PRINT 'Crea Procedure: spItems_Get_Package'
IF OBJECT_ID('[dbo].[spItems_Get_Package]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spItems_Get_Package
GO
/*
Autor:		Alejandro Zepeda
Desc:		spDashboard Sales
Date:		18/04/2023

Example:
	EXEC spItems_Get_Package @pvIdItemClass = 'PACK'
	EXEC spItems_Get_Package @pvIdItemClass = 'PACKD'
*/
CREATE PROCEDURE [dbo].spItems_Get_Package
@pvIdItemClass		Varchar(10)		= ''

AS

	SELECT
		Item.Id_Item AS [Id_Item],
		Countries.Short_Desc AS [Package_Country],
		Item.Id_Item_Related AS [Related_Id_Item],
		Rel_Items.Short_Desc AS [Related_Item],
		Item.Short_Desc AS [Package_Description],
		Item.Item_SPR AS [Package_SPR]
	FROM Cat_Item AS Item 
	INNER JOIN Cat_Countries AS Countries ON
	Item.Id_Country_Package = Countries.Id_Country
	INNER JOIN Cat_Item AS Rel_Items ON
	Item.Id_Item_Related = Rel_Items.Id_Item
	WHERE Item.Id_Item_Class = '' OR  Item.Id_Item_Class = @pvIdItemClass 
	AND Item.[Status] = 1