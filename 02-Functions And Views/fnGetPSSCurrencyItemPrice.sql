USE [DBQS]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetPSSCurrencyItemPrice]    Script Date: 9/13/2026 12:14:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

IF OBJECT_ID(N'[dbo].[fnGetPSSCurrencyItemPrice]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fnGetPSSCurrencyItemPrice]
GO

/*
Author:		Angel Gutierrez
Desc:		Gets the PSS Item Price based on Currency
Creation:	09/13/2026  
Return 
			@PSSItemPrice FLOAT
Example:	
			Declare @PSSItemPrice FLOAT
            Declare @pvIdItem VARCHAR(10)
            Declare @pvIdCurrency VARCHAR(10)
            Declare @pfPrice FLOAT

            SET @pvIdItem = 'ItemID'
            SET @pvIdCurrency = 'CurrencyID'
            SET @pfPrice = 100.0

			SET @PSSItemPrice = dbo.fnGetPSSCurrencyItemPrice(@pvIdItem, @pvIdCurrency, @pfPrice)
            
			SELECT @PSSItemPrice
*/
CREATE FUNCTION [dbo].[fnGetPSSCurrencyItemPrice](@pvIdItem VARCHAR(10), @pvIdCurrency VARCHAR(10), @pfPrice FLOAT)
RETURNS FLOAT
AS
BEGIN

	DECLARE @PSSItemPrice FLOAT;
    DECLARE @fvCurrencyPrice FLOAT;
    DECLARE @currencyConvertedPrice FLOAT;
    DECLARE @pfExchangeRate FLOAT;

    SET @pfExchangeRate = (SELECT
                                Exchange_Rate
                           FROM Cat_Exchange_Rates
                           WHERE 
                                    Id_Currency = @pvIdCurrency
                                AND [Status] = 1);

    SET @currencyConvertedPrice = @pfPrice * @pfExchangeRate;

    IF @pvIdCurrency = 'USD'
    BEGIN

        SET @PSSItemPrice = @currencyConvertedPrice;

    END
    ELSE 
    BEGIN

        SET @fvCurrencyPrice = (SELECT 
                                    Price 
                                FROM PSS_Currency_Item_Prices
                                WHERE 
                                        Id_Item = @pvIdItem
                                    AND Id_Currency = @pvIdCurrency);

        IF @fvCurrencyPrice IS NOT NULL
        BEGIN

            SET @PSSItemPrice = @fvCurrencyPrice;

        END
        ELSE
        BEGIN

            SET @PSSItemPrice = @currencyConvertedPrice;

        END

    END

	RETURN @PSSItemPrice;

END

