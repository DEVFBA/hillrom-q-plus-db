
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
	AND Item_Long_Desc LIKE 'LIKOSTRETCH 600 IC%'
	AND Id_Zone = 'LIKALL'
ORDER BY Id_Item ASC



SELECT * FROM CAT_ITEM
WHERE Id_Item IN ('3156065B')

SELECT * FROM vwItems_Templates
WHERE Id_Line IN ('CP7800A') and Item_Long_Desc like '%CONTINU%'
Id_Item IN ('ST867A','ST877A') AND Id_Line IN ('OVERLFT')


SELECT * FROM Items_Templates
WHERE Id_Line IN ('CP7800A')
Id_Item IN ('TURN','FOAM','CLRT') AND 

WHERE Id_Item IN ('3156056', '3683105', '3683106', '3683905-4', '3683906-4', '3683062', '3156065B', '3684001', '3684002', '3166506')

SELECT * FROM Cat_Item_SubClasses
WHERE Id_Item_SubClass LIKE '%OPTIUPGRAD%'
--WHERE Id_Item_Class = 'ACCE'
ORDER BY 2



SELECT
Servidor =  CONVERT(char(20),SERVERPROPERTY('servername')),
BD		 = DB_NAME(),
name,
crdate,*
FROM sysobjects
WHERE CONVERT(varchar(10), crdate,112) >= '20220801' 
ORDER BY xtype,4

/* ==================================================================================*/
--Generar realapdo de BD Y TABLA
/* ==================================================================================*/
SELECT *  INTO Items_Templates_20221001_bkp FROM Items_Templates


/* ==================================================================================*/
-- spPDF_Layout_Get_Info_PRP7500
/* ==================================================================================*/	

-- Inserta nueva SubClass
EXEC spCat_Item_Subclasses_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdItemClass = 'ACCE' , @pvIdItemSubClass = 'ICUACC', @pvShortDesc = 'ICU Accesories' , @pvLongDesc = 'ICU Accesories', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='0.0.0.0'
			
-- Actualiza Item
UPDATE CAT_ITEM
SET Id_Item_SubClass = 'ICUACC'
WHERE ID_ITEM = 'P7529'

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_CP7800A
/* ==================================================================================*/	

-- Actualiza Item
UPDATE CAT_ITEM
SET Id_Item_SubClass = 'MISCACCESO'
WHERE ID_ITEM = 'P7512A'


/* ==================================================================================*/
-- spPDF_Layout_Get_Info_HIRO900
/* ==================================================================================*/	
-- Inserta nueva SubClass
EXEC spCat_Item_Subclasses_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdItemClass = 'COMP' , @pvIdItemSubClass = 'BEDEXITALR', @pvShortDesc = 'Bed Exists Alarm' , @pvLongDesc = 'Bed Exists Alarm', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='0.0.0.0'

-- Actualiza Item
UPDATE CAT_ITEM
SET Id_Item_SubClass = 'BEDEXITALR' --  'ACCEBARHOL'
WHERE ID_ITEM = 'ABF'	

-- Actualiza Item
UPDATE CAT_ITEM
SET Id_Item_SubClass = 'BEDEXITALR' --  'PATSIDECOM'
WHERE ID_ITEM = 'NC'	



 
/* ==================================================================================*/
-- spPDF_Layout_Get_Info_RAILSYSTEM
/* ==================================================================================*/	
--QUERY 10
 UPDATE Cat_Item
SET Short_Desc = '6.4 m Straight Rail H140 (252 in), natural',
	Long_Desc = '6.4 m Straight Rail H140 (252 in), natural'
WHERE Id_Item = '31013464N'



/* ==================================================================================*/
-- UPDATE Items_Configuration -Items_Templates
/* ==================================================================================*/	

--==========================================================================================================================================

select * from Cat_Families_Categories where Id_Family = 'MLS' AND Id_Category in('NA', 'OLS' )
select * from Cat_Item WHERE Id_Item IN ('3156056', '3683105', '3683106', '3683905-4', '3683906-4', '3683062', '3156065B', '3684001', '3684002', '3166506')

SELECT * FROM Items_Templates
WHERE Id_Item IN ('3156056', '3683105', '3683106', '3683905-4', '3683906-4', '3683062', '3156065B', '3684001', '3684002', '3166506')
and Id_Family = 'MLS' AND Id_Line = 'OVERLFT' AND Id_Category = 'OLS' 
and Id_Family = 'MLS' AND Id_Line = 'NA' AND Id_Category = 'NA' 


SELECT * FROM Items_Configuration 
WHERE Id_Item IN ('3156056', '3683105', '3683106', '3683905-4', '3683906-4', '3683062', '3156065B', '3684001', '3684002', '3166506')


INSERT INTO Cat_Families_Categories
SELECT 'MLS','OLS',	'OVERLFT',1,'sa',	GETDATE(),	'0.0.0.0'


INSERT INTO Items_Configuration (
	Id_Family,
	Id_Category,
	Id_Line,
	Id_Item,
	Status,
	Modify_By,
	Modify_Date,
	Modify_IP)

SELECT 
	Id_Family,
	Id_Category ='OLS',
	Id_Line = 'OVERLFT',
	Id_Item,
	Status,
	Modify_By,
	Modify_Date,
	Modify_IP
FROM Items_Configuration 
WHERE Id_Item IN ('3156056', '3683105', '3683106', '3683905-4', '3683906-4', '3683062', '3156065B', '3684001', '3684002', '3166506')




UPDATE Items_Templates 
SET Id_Line = 'OVERLFT', 
	Id_Category = 'OLS' 
WHERE Id_Item IN ('3156056', '3683105', '3683106', '3683905-4', '3683906-4', '3683062', '3156065B', '3684001', '3684002', '3166506')
and Id_Family = 'MLS' AND Id_Line = 'NA' AND Id_Category = 'NA' 



DELETE Items_Configuration 
WHERE Id_Item IN ('3156056', '3683105', '3683106', '3683905-4', '3683906-4', '3683062', '3156065B', '3684001', '3684002', '3166506')
and Id_Family = 'MLS' AND Id_Line = 'NA' AND Id_Category = 'NA' 


/*===========================================================*/
--4 En cotizaciones quitar temporalmente la columna de margen: como no se modificaron los costos el margen es incorrecto
UPDATE Cat_General_Parameters
SET [Value] = 0
WHERE Id_Parameter = 44

SELECT * FROM Cat_General_Parameters
WHERE Id_Parameter = 44
order by 1
/*===========================================================*/
--5 quitar de forma temporal la venta directa para los paises MEXICO, BRASIL Y COLOMBIA: esto tambien debido a que los costos no se incrementaron

select * from Cat_Quotation_Commercial_Policies
where Id_Sales_Type = 'DIRSA' and Id_Country in ('MX','BR','CO')

UPDATE Cat_Quotation_Commercial_Policies
SET Status = 0
where Id_Sales_Type = 'DIRSA' and Id_Country in ('MX','BR','CO')

/*===================================================================*/
/*===================================================================*/
/*===================================================================*/
/*===================================================================*/
--SCRIPTS ALEXIS


--Scripts utilizados en PREPRODUCCION

SELECT  Price , (Price * 1.16), ROUND((Price * 1.16),0) FROM Items_Templates

UPDATE Items_Templates SET Price =  ROUND((Price * 1.16),0)



UPDATE Cat_Item SET Long_Desc = 'Low Air loss Surface with Turn Assist & air supply unit'  WHERE Id_Item = 'P642ACAP.'



UPDATE Items_Templates SET Price = 23760  WHERE Id_Item = 'P642ACAP.' AND Item_Template = 'TURN'



UPDATE Items_Templates SET Price = 15064  WHERE Id_Item = 'P641A.' AND Item_Template = 'FOAM'



UPDATE Items_Templates SET Price = 4831  WHERE Id_Item = 'LAROTTHER' AND Item_Template = 'CLRT'



UPDATE Items_Templates SET Price = 48748 WHERE Id_Item = 'TURN' AND Id_Line IN ('CP7800A')



UPDATE Items_Templates SET Price = 48748 WHERE Id_Item = 'FOAM' AND Id_Line IN ('CP7800A')



UPDATE Cat_Item SET Model = 'AD231A' WHERE Id_Item = 'ASS043'



UPDATE Cat_Item SET Model = 'AD231A' WHERE Id_Item = 'ASS044'



UPDATE Cat_Item SET Model = 'AD231A' WHERE Id_Item = 'ASS077'



UPDATE Cat_Item SET Model = 'AD231A' WHERE Id_Item = 'ASS078'



UPDATE Items_Template_Kits SET Price = 554 WHERE Item_Template = 'HR900 X3' AND Id_Template_Kit = 2



UPDATE Items_Template_Kits SET Price = 2714 WHERE Item_Template = 'HR900 X3' AND Id_Template_Kit = 3



UPDATE Items_Template_Kits SET Price = 383 WHERE Item_Template = 'HR900 X3' AND Id_Template_Kit = 4