USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spUpdate_Package_Costs]    Script Date: 3/23/2026 8:50:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autor:		Angel Gutiérrez
Desc:		Update Package Costs | 
Date:		06/12/25
Example:
		
		EXEC spUpdate_Package_Costs 
            @pvOptionCRUD = 'E', 
            @pvIdLanguageUser = 'ANG',
            @pvUser = 'ANGUTIERRE',
			@pvPackageId = 'PACK-0001';	
*/

CREATE PROCEDURE [dbo].[spUpdate_Package_Costs]
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10)		= '',
@pvUser					Varchar(50)		= '',
@pvPackageId			Varchar(50)		= ''

AS
SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD			Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vPackageId					Varchar(50)
	DECLARE @pvRelatedItem				Varchar(50)
	DECLARE @piQty						Smallint
	DECLARE @pvItemClass				Varchar(10)
	DECLARE @pfPackageCost				Float
	DECLARE @pfProductCost				Float
	DECLARE @pfAccCompCost				Float

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Update Package Costs - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
    DECLARE @vExecCommand	Varchar(Max)	= "EXEC spUpdate_Package_Costs @pvOptionCRUD =  'E', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL')
	--------------------------------------------------------------------
	--Update Package Costs
	--------------------------------------------------------------------

	DECLARE curPackageCosts CURSOR FOR
	SELECT
		Package_ID
	FROM vwPackage_Costs
	WHERE
			(@pvPackageId = '' OR Package_ID = @pvPackageId)
	GROUP BY Package_ID

	OPEN curPackageCosts

	FETCH NEXT FROM curPackageCosts
	INTO
		@vPackageId

	WHILE @@FETCH_STATUS = 0
	BEGIN

		DECLARE @pfPackageTotalCost			Float
		DECLARE @pfComponentsTotalCost		Float
		DECLARE @pfAccessoriesTotalCost		Float
		DECLARE @pfProductRelatedTotalCost	Float

		SET @pfAccessoriesTotalCost = 0

		PRINT 'Package ' + @vPackageId

		SET @pfComponentsTotalCost = ISNULL((SELECT
													SUM(Acc_Comp_Cost)
											 FROM vwPackage_Costs 
											 WHERE 
													Package_ID = @vPackageId
												AND Item_Class = 'COMP'),0)

		PRINT 'Components Cost ' + CAST(@pfComponentsTotalCost AS VARCHAR(50))

		SET @pfProductCost = ISNULL((SELECT
											SUM(Product_Cost)
									 FROM vwPackage_Costs 
									 WHERE 
												Package_ID = @vPackageId
											AND Item_Class IN ('PACK', 'PACKD')),0)

		PRINT 'Product Cost ' + CAST(@pfProductCost AS VARCHAR(50))

		DECLARE curPackageAccessories CURSOR FOR
		SELECT
			Qty,
			Acc_Comp_Cost
		FROM vwPackage_Costs
		WHERE
				Package_ID = @vPackageId
			AND Item_Class = 'ACCE'

		OPEN curPackageAccessories

		FETCH NEXT FROM curPackageAccessories
		INTO
			@piQty,
			@pfAccCompCost

		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			PRINT 'Accessories Cost Begin ' + CAST(@pfAccessoriesTotalCost AS VARCHAR(50))
			
			SET @pfAccessoriesTotalCost = (@pfAccessoriesTotalCost + (@piQty * @pfAccCompCost))

			PRINT 'Accessories Cost After ' + CAST(@pfAccessoriesTotalCost AS VARCHAR(50))

			FETCH NEXT FROM curPackageAccessories
			INTO
				@piQty,
				@pfAccCompCost

		END

		CLOSE curPackageAccessories;
		DEALLOCATE curPackageAccessories;

		PRINT 'Accessories Cost Total ' + CAST(@pfAccessoriesTotalCost AS VARCHAR(50))

		SET @pfPackageTotalCost = (@pfAccessoriesTotalCost + @pfComponentsTotalCost + @pfProductCost)

		PRINT 'Total Cost ' + CAST(@pfPackageTotalCost AS VARCHAR(50))

		UPDATE Items_Templates SET Standard_Cost = @pfPackageTotalCost 
		WHERE
				Item_Template = @vPackageId
			AND Id_Item = @vPackageId

		SET @pfAccessoriesTotalCost = 0
		
		FETCH NEXT FROM curPackageCosts
		INTO
			@vPackageId
	END
	
	CLOSE curPackageCosts;
	DEALLOCATE curPackageCosts;

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
