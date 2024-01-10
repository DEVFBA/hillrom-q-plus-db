USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spFLC_Generate_Price_List
/* ==================================================================================*/	
PRINT 'Crea Procedure: spFLC_Generate_Price_List'

IF OBJECT_ID('[dbo].[spFLC_Generate_Price_List]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spFLC_Generate_Price_List
GO

/*
Autor:		Alejandro Zepeda
Desc:		FLC OGenerate Price List 
Date:		07/11/2023
Parameters
			@pvModality 
					- Master
					- Cluster
					- Distributor
Example:
			EXEC spFLC_Generate_Price_List	@pvModality			=  'Master', 
											@pvIdLanguageUser	= 'ANG', 
											@pvUser				= 'AZEPEDA',
											@pvIP				= '1.1.1.1'

			EXEC spFLC_Generate_Price_List	@pvModality			=  'Cluster', --154,693
											@pvIdCluster		= 'FLCCLUCOL',
											@pvIdLanguageUser	= 'ANG', 
											@pvUser				= 'AZEPEDA',
											@pvIP				= '1.1.1.1'

			EXEC spFLC_Generate_Price_List	@pvModality			=  'Distributor', --154,693
											@pvIdDistributor	= 1,
											@pvIdLanguageUser	= 'ANG', 
											@pvUser				= 'AZEPEDA',
											@pvIP				= '1.1.1.1'

*/

CREATE PROCEDURE [dbo].[spFLC_Generate_Price_List]
@pvModality				Varchar(20) ,
@pvIdCluster			Varchar(10) = '',
@pvIdDistributor		Int			= 0,
@pvIdLanguageUser		Varchar(10) = 'ANG',
@pvUser					Varchar(50)	= '',
@pvIP					Varchar(20)	= ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------


	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescOperationCRUD Varchar(50) = @pvModality
	DECLARE @vDescription	Varchar(255)	= 'Generate_Price_List  - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= 'Executed Successfully '
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spFLC_Generate_Price_List @pvModality =  '" + ISNULL(@pvModality,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	
	--------------------------------------------------------------------
	--Download Records
	--------------------------------------------------------------------
	IF @pvModality = 'Master'
	BEGIN	
			------------------------------------
			--Los descuentos máster
			------------------------------------
			SELECT
				Product_Category	= CC.Short_Desc,
				Discount			= CC.Master_Discount 
			FROM FLC_Cat_Categories AS CC
			WHERE CC.[Status] = 1
			ORDER BY [Order],Product_Category -- Modificación Ángel Gutiérrez 23/11/23

			------------------------------------
			--La información de los artículos
			------------------------------------
			SELECT
				Category				= CC.Long_Desc,
				[Group]					= CG.Long_Desc,
				Family					= CF.Long_Desc,
				Material				= I.Id_Item,
				[Description]			= I.Long_Desc,
				Suggested_Retail_Price	= I.Price,
				Obsolescence			= I.Obsolescence,
				Substitute_Item			= I.Substitute_Item,
				Comment					=  (CASE WHEN Obsolescence = 1 THEN(--'Discontinued' + ' \n ' +   /// Angel Gutierrez
																			CASE WHEN I.Substitute_Item <> '' THEN  +  I.Substitute_Item + ' \n '
																				 ELSE   ''
																			END) 
												ELSE ''
											END) + REPLACE(I.Comment,'||',' \n '),
				[Order]					= CC.[Order],
				Order_Group				= CG.[Order],
				Order_Family			= CF.[Order]

			FROM FLC_Cat_Item AS I 

			INNER JOIN FLC_Items_Configuration AS IC ON 
			I.Id_Item = IC.Id_Item
			
			INNER JOIN FLC_Cat_Categories AS CC ON 
			IC.Id_FLC_Category = CC.Id_FLC_Category
			
			INNER JOIN FLC_Cat_Groups AS CG ON 
			IC.Id_FLC_Group = CG.Id_FLC_Group
			
			INNER JOIN FLC_Cat_Families AS CF ON 
			IC.Id_FLC_Family = CF.Id_FLC_Family
			
			WHERE IC.[Status] = 1 AND CC.[Status] = 1 AND I.[Status] = 1 -- Modificación Ángel Gutiérrez 06/12/23
			ORDER BY CC.[Order], CG.[Order], CF.[Order], Category, [Group], Family -- Modificación Ángel Gutiérrez 23/11/23

	END

	IF @pvModality = 'Cluster' OR @pvModality = 'Distributor'
	BEGIN	

		SELECT
			Cluster_Id				= FCZ.Id_Zone,
			Cluster					= CZ.Short_Desc,
			Customer_Id				= C.Id_Customer,
			Distributor_Name		= C.[Name],
			Category				= Cat.Long_Desc,
			Discount				= CC.Category_Discount,
			[Group]					= CG.Long_Desc,
			Family					= CF.Long_Desc,
			Material				= FIC.Id_Item,
			[Description]			= I.Long_Desc,
			Suggested_Retail_Price	= I.Price, -- Angel Gutierrez a petición de Alexis
			Obsolescence			= I.Obsolescence,
			Substitute_Item			= I.Substitute_Item ,
			Comment					= I.Comment,
			[Order]					= Cat.[Order],
			Order_Group				= CG.[Order],
			Order_Family			= CF.[Order],
			Id_Country				= CR.Id_Country,
			Id_Status_CR			= CR.Id_Status_Commercial_Release 

		FROM FLC_Cat_Customers AS C 
		
		INNER JOIN FLC_Customer_Categories AS CC
		ON C.Id_Customer = CC.Id_Customer

		INNER JOIN FLC_Cat_Categories AS Cat
		ON CC.Id_FLC_Category = Cat.Id_FLC_Category

		INNER JOIN FLC_Cat_Categories_Families AS CCF
		ON CC.Id_FLC_Category = CCF.Id_FLC_Category
		AND CCF.[Status] = 1

		INNER JOIN FLC_Cat_Groups AS CG
		ON CCF.Id_FLC_Group = CG.Id_FLC_Group

		INNER JOIN FLC_Cat_Families AS CF
		ON CCF.Id_FLC_Family = CF.Id_FLC_Family

		INNER JOIN FLC_Items_Configuration AS FIC
		ON CCF.Id_FLC_Category = FIC.Id_FLC_Category
		AND CCF.Id_FLC_Group = FIC.Id_FLC_Group
		AND CCF.Id_FLC_Family = FIC.Id_FLC_Family
		AND FIC.[Status] = 1

		INNER JOIN FLC_Cat_Item AS I
		ON FIC.Id_Item = I.Id_Item
		AND I.[Status] = 1

		INNER JOIN FLC_Customer_Zones AS FCZ
		ON C.Id_Customer = FCZ.Id_Customer
		AND FCZ.[Status] = 1

		INNER JOIN Cat_Zones AS CZ
		ON FCZ.Id_Zone = CZ.Id_Zone

		INNER JOIN FLC_Commercial_Release AS CR ON
		CR.Id_Item =  I.Id_Item AND
		CR.Id_Country = C.Id_Country AND 
		CR.Id_Language = @pvIdLanguageUser AND
		CR.Id_Status_Commercial_Release = 1

		WHERE
		(@pvIdCluster = '' OR FCZ.Id_Zone = @pvIdCluster) AND
		(@pvIdDistributor = 0 OR C.Id_Customer = @pvIdDistributor) AND
		C.[Status] = 1
		
		ORDER BY
		C.[Name], Cat.[Order],  CG.[Order], CF.[Order], Cat.Long_Desc,CG.Long_Desc,CF.Long_Desc -- Modificación Ángel Gutiérrez 23/11/23

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
