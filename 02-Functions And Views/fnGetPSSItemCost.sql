USE [DBQS]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetPSSItemCost]    Script Date: 9/13/2026 12:14:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

IF OBJECT_ID(N'[dbo].[fnGetPSSItemCost]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fnGetPSSItemCost]
GO

/*
Author:		Angel Gutierrez
Desc:		Gets the PSS Item Cost 
Creation:	09/13/2026  
Return 
			@PSSItemCost FLOAT
Example:	
			

			SET @PSSItemCost = dbo.fnGetPSSItemCost(@pvIdCurrency, @pvIdIncoterm, @pvIdItem, @pvIdItemTemplate)
            
			SELECT @PSSItemCost
*/
CREATE FUNCTION [dbo].[fnGetPSSItemCost](@pvIdCurrency VARCHAR(10), @pvIdIncoterm VARCHAR(10), @pvIdItem VARCHAR(50), @pvIdItemTemplate VARCHAR(50))
RETURNS FLOAT
AS
BEGIN

	DECLARE @transferPricePerc FLOAT;
	DECLARE @exchangeRate FLOAT;
	DECLARE @itemStandardCost FLOAT;
	DECLARE @transferPrice FLOAT;
	DECLARE @importCostPerc FLOAT;
	DECLARE @importCost FLOAT;
	DECLARE @PSSItemCost FLOAT;

	SET @transferPricePerc = (SELECT CAST([Value] AS FLOAT) / 100 FROM Cat_General_Parameters WHERE Id_Parameter = 72);
	SET @importCostPerc = (SELECT CAST([Value] AS FLOAT) / 100 FROM Cat_General_Parameters WHERE Id_Parameter = 73);

	SET @exchangeRate = (SELECT Exchange_Rate FROM Cat_Exchange_Rates WHERE Id_Currency = @pvIdCurrency AND [Status] = 1);

	SET @itemStandardCost = (SELECT 
									Standard_Cost * @exchangeRate
							 FROM Items_Templates
							 WHERE 
							 		Id_Item = @pvIdItem 
							 	AND Item_Template = @pvIdItemTemplate);
	
	SET @transferPrice = @itemStandardCost * @transferPricePerc;

	SET @importCost = @itemStandardCost * @importCostPerc;

	IF @pvIdIncoterm = 'Local' AND @pvIdCurrency = 'BRL'
	BEGIN
		SET @PSSItemCost = @transferPrice + @importCost;
	END
	ELSE
	BEGIN
		SET @PSSItemCost = @itemStandardCost;
	END

	RETURN ROUND(@PSSItemCost, 2);

END

