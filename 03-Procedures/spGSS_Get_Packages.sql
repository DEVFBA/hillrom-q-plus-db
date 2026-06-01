USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_Get_Packages]    Script Date: 6/1/2026 1:03:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autor:		Angel Gutierrez
Desc:		GSS Packages | Get Packages
Date:		05/31/2026
Example:
			
			EXEC spGSS_Get_Packages @piMode = 1, @pvIdCountry = 'MX', @pvPackageLine = 'SPINE';

			EXEC spGSS_Get_Packages @piMode = 2, @pvIdPackage = 'TST-PCK-26052501';

*/
CREATE PROCEDURE [dbo].[spGSS_Get_Packages]
@piMode				Int,
@pvIdLanguageUser	Varchar(10) = '',
@pvUser				Varchar(50) = '',
@pvIP				Varchar(20) = '',
@pvIdCountry		Varchar(10) = '',
@pvIdPackage		Varchar(50)	= '',
@pvPackageLine		Varchar(10)	= ''
AS

	
														
	--------------------------------------------------------------------
	--Get Packages by Country - Mode 1 
	--------------------------------------------------------------------
	IF @piMode = 1
	BEGIN
		
		PRINT 'Mode 1 - Get Packages by Country';	

		SELECT
			GCI.Id_Item,
			GCI.Short_Desc,
			GCI.Id_Item_Class,
			GCI.Id_Item_SubClass,
			GCI.Long_Desc,
			GCI.Id_Package_Line,
			GCI.Item_SPR,
			GCI.Price,
			GCI.Standard_Cost,
			GCI.Package_Category,
			GCI.[Status]
		FROM GSS_Cat_Item AS GCI
		WHERE
				GCI.Id_Item_Class = 'GSSPACKD'
			AND(@pvIdCountry = '' OR GCI.Id_Country_Package = @pvIdCountry)
			AND (@pvPackageLine = '' OR GCI.Id_Package_Line = @pvPackageLine);

	END
	--------------------------------------------------------------------
	--Get Package Template - Mode 2 
	--------------------------------------------------------------------
	IF @piMode = 2
	BEGIN
		
		PRINT 'Mode 2 - Get Package Template';	

		SELECT
			GCI.Id_Item AS Id_Package,
			GCI.Id_Item_Class,
			GCI.Id_Item_SubClass,
			GCI.Short_Desc AS Package_Short_Desc,
			GCI.Long_Desc AS Package_Long_Desc,
			GCI.Id_Package_Line,
			GCI.Item_SPR,
			GCI.Price,
			GCI.Standard_Cost,
			GCI.Package_Category,
			GPT.Id_Item,
			PackItems.Short_Desc AS Item_Short_Desc,
			PackItems.Long_Desc AS Item_Long_Desc
		FROM GSS_Cat_Item AS GCI INNER JOIN GSS_Packages_Templates AS GPT ON
												GCI.Id_Item = GPT.Id_Package
								 INNER JOIN GSS_Cat_Item AS PackItems ON
												GPT.Id_Item = PackItems.Id_Item
		WHERE 
				GCI.Id_Item_Class = 'GSSPACKD'
			AND (@pvIdPackage = '' OR GCI.Id_Item = @pvIdPackage)
		ORDER BY
				GCI.Id_Item ASC,
				GPT.Id_Item ASC;

	END


