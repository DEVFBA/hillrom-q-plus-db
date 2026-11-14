USE [DBQS]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetPSSItemPrice]    Script Date: 9/13/2026 12:14:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

IF OBJECT_ID(N'[dbo].[fnGetPSSItemPrice]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fnGetPSSItemPrice]
GO

/*
Author:		Angel Gutierrez
Desc:		Gets the PSS Item List
Creation:	09/13/2026  
Return 
			@PSSItemListPrice FLOAT
Example:	
			Declare @PSSItemListPrice FLOAT
            Declare @pvIdItem VARCHAR(10)
            Declare @pvIdCountry VARCHAR(10)
            Declare @pvIdIncoterm VARCHAR(10)
            Declare @pfPrice FLOAT
            Declare @pvIdCurrency VARCHAR(10)

            SET @pvIdItem = 'ASS032'
            SET @pvIdCountry = 'BRL'
            SET @pvIdIncoterm = 'EXW'
            SET @pfPrice = 100.0
            SET @pvIdCurrency = 'BRL'

			SET @PSSItemListPrice = dbo.fnGetPSSItemPrice(@pvIdItem, @pvIdCountry, @pvIdIncoterm, @pfPrice, @pvIdCurrency)
            
			SELECT @PSSItemListPrice
*/
CREATE FUNCTION [dbo].[fnGetPSSItemPrice](@pvIdItem VARCHAR(50), @pvIdCountry VARCHAR(10), @pvIdIncoterm VARCHAR(10), @pfPrice FLOAT, @pvIdCurrency VARCHAR(10))
RETURNS FLOAT
AS
BEGIN

	--DECLARE @PSSItemListPrice FLOAT;
	DECLARE @PSSItemListPrice VARCHAR(MAX);

    IF @pvIdCountry = 'BR' -- Brazil specific pricing logic

    /** Start of EXW Calculations */    

    BEGIN

        DECLARE @maxDiscountAllowed FLOAT;
        DECLARE @exwBasePrice FLOAT;
        DECLARE @exwOverpricePerc FLOAT;
        DECLARE @exwPrice FLOAT;
        DECLARE @dapOverpricePerc FLOAT;
        DECLARE @dapPrice FLOAT;

        SET @maxDiscountAllowed = ISNULL((SELECT
												Max_Allowed_Discount / 100
										  FROM Max_Allowed_Discounts
										  WHERE
													Id_Discount_Category = (SELECT
																					Id_Discount_Category
																			FROM Cat_Item 
																			WHERE Id_Item = @pvIdItem)),0);

        SET @exwBasePrice = dbo.fnGetPSSCurrencyItemPrice(@pvIdItem, @pvIdCurrency, @pfPrice) * (1 - @maxDiscountAllowed);
        SET @exwOverpricePerc = (SELECT 
                                        CAST([Value] AS FLOAT) / 100
                                    FROM Cat_General_Parameters
                                    WHERE
                                        Id_Parameter = 74);

        SET @exwPrice = @exwBasePrice * (1 + @exwOverpricePerc);

        /** End of EXW Calculations **/

        /** Start of DAP Calculations **/

        SET @dapOverpricePerc = (SELECT 
                                        CAST([Value] AS FLOAT) / 100
                                    FROM Cat_General_Parameters
                                    WHERE
                                        Id_Parameter = 75);

        SET @dapPrice = @exwPrice * (1 + @dapOverpricePerc);

        /** End of DAP Calculations **/

        IF @pvIdIncoterm = 'EXW'
        BEGIN

            SET @PSSItemListPrice = @exwPrice;

        END
        ELSE IF @pvIdIncoterm = 'DAP'
        BEGIN

            SET @PSSItemListPrice = @dapPrice;

        END
        ELSE
        BEGIN

            SET @PSSItemListPrice = dbo.fnGetPSSCurrencyItemPrice(@pvIdItem, @pvIdCurrency, @pfPrice)

        END

    END
    ELSE -- Rest of countries Not BR
    BEGIN

        SET @PSSItemListPrice = dbo.fnGetPSSCurrencyItemPrice(@pvIdItem, @pvIdCurrency, @pfPrice)

    END
    
	RETURN ROUND(@PSSItemListPrice, 2);

END

