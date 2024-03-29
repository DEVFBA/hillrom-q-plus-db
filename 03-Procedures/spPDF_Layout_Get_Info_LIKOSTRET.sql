USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spPDF_Layout_Get_Info_LIKOSTRET]    Script Date: 10/06/2022 01:12:33 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_LIKOSTRET
Date:		12/01/2022
Example:

	EXEC spPDF_Layout_Get_Info_LIKOSTRET @pvIdZone = 'LIKALL'


*/
ALTER PROCEDURE [dbo].[spPDF_Layout_Get_Info_LIKOSTRET]
@pvIdZone	Varchar(10)
AS

/*****************************************************************************/
-- QUERY 1 - Accesorios �Liko OctoStretch� - OctoStretch with Stretch Leveller�.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'ACCE'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass IN ('LIKOSTEACC')
	AND Item_Long_Desc LIKE 'Octo Stretch W Leveller%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 2 - Accesorios �Liko OctoStretch� - LiftSheet Octo�.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'ACCE'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass IN ('LIKOSTEACC')
	AND Item_Long_Desc LIKE 'LiftSheet Octo%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 3 - Accesorios �Liko OctoStretch� - Solo Octo LiftSheet�.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'ACCE'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass IN ('LIKOSTEACC')
	AND Item_Long_Desc LIKE 'Solo Octo LiftSheet%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 4 - Accesorios �Liko OctoStretch� - Plastic Reinforcement�.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'ACCE'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass IN ('LIKOSTEACC')
	AND Item_Long_Desc LIKE 'EXTRA PLASTIC REINFORCEM%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 5 - Accesorios �LIKOSTRETCH MOD 600 IC� - LikoStretch mod 600 IC�.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	--AND Id_ItemTemplate_Class = 'PROD' 
	AND Id_ItemTemplate_Class = 'ACCE' --AZR 20220920 - Ajuste a solicitud de Alexis
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass IN ('LIKOSTEACC')
	--AND Item_Long_Desc LIKE 'LIKOSTRETCH 600 IC%' 
	AND Item_Long_Desc LIKE 'LIKOSTRETCH mod 600 IC%' --AZR 20220920 - Ajuste a solicitud de Alexis
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 6 - Accesorios �LIKOSTRETCH MOD 600 IC� - Strap mod 600 IC�.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass IN ('LIKOSTEACC')
	--AND Item_Long_Desc LIKE 'STRAP MOD 600 IC 8PCS%' 
	AND Item_Long_Desc LIKE 'STRAP MOD 600 IC, 8 PCS%' --AZR 20220920 - Ajuste a solicitud de Alexis
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC;

/*****************************************************************************/
-- QUERY 7 - Accesorios �LIKOSTRETCH MOD 600 IC� - Spatula mod 600 IC�.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass IN ('LIKOSTEACC')
	--AND Item_Long_Desc LIKE 'SPATULA (MOD 600IC)%'
	AND Item_Long_Desc LIKE 'Spatula mod 600 IC%' --AZR 20220920 - Ajuste a solicitud de Alexis
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 8 - Accesorios �LIKOSTRETCH MOD 600 IC� - SideRails 600 IC�.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'ACCE'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass IN ('LIKOSTEACC')
	AND Item_Long_Desc LIKE 'SIDERAILS 600%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 9 - Accesorios �LIKO FLEXOSTRETCH�, LIKO ULTRASTRETCH� - FlexoStretch��.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass IN ('LIKOSTEACC')
	--AND Item_Long_Desc LIKE 'LIKO FLEXO STRETCH%'
	AND Item_Long_Desc LIKE 'FLEXOSTRETCH%' -- 20220922 Ajuste a solicitud de Alexis
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC;

/*****************************************************************************/
-- QUERY 10 - Accesorios �LIKO FLEXOSTRETCH�, LIKO ULTRASTRETCH� - UltraStretch��.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass IN ('LIKOSTEACC')
	AND Item_Long_Desc LIKE 'ULTRASTRETCH%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 11 - Accesorios �LIKO FLEXOSTRETCH�, LIKO ULTRASTRETCH� - LiftSheet�.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass IN ('LIKOSTEACC')
	AND Item_Long_Desc LIKE 'LiftSheet%'
	AND Item_Long_Desc NOT LIKE '%Octo%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC

/*****************************************************************************/
-- QUERY 12 - Accesorios �LIKO STRETCHERS � MISCELLANEOUS - Stretch Leveller��.
/*****************************************************************************/
SELECT DISTINCT
	Part = Id_Item,
	Item_Long_Desc = Item_Long_Desc,
	Specifications = Specifications,
	Price = Price
FROM vwItems_Templates_Commercial_Release
WHERE Id_Item_Class = 'ACCE'
	AND Id_ItemTemplate_Class = 'PROD'
	AND Id_Line IN ('OVERLFT')
	AND Id_Item_SubClass IN ('LIKOSTEACC')
	AND Item_Long_Desc LIKE 'Stretch Leveller%'
	AND Id_Zone = @pvIdZone
ORDER BY Id_Item ASC;