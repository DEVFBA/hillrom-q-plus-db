USE [DBQS]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetFLCItemPrice]    Script Date: 6/10/2026 1:25:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Author:		Angel Gutierrez
Desc:		Gets the FLC Price || Determines if it will be General Price or Zone Price
Creation:	06/10/2026
Return 
			@vfFLCPrice
Example:	
			Declare @vfFLCPrice FLOAT
			SET @vfFLCPrice = dbo.fnGetFLCItemPrice('FLCCOVE', '7670-12')
			SELECT @vfFLCPrice

			Declare @vfFLCPrice FLOAT
			SET @vfFLCPrice = dbo.fnGetFLCItemPrice('FLCCOAR', '7670-12')
			SELECT @vfFLCPrice
*/
CREATE FUNCTION [dbo].[fnGetFLCItemPrice](@pvIdZone Varchar(10), @pvIdItem Varchar(50))
RETURNS FLOAT
AS
BEGIN
	
	DECLARE @vfFLCPrice FLOAT;

	SET @vfFLCPrice = (SELECT
							Price
					   FROM FLC_Zones_Prices 
					   WHERE 
								Id_Zone = @pvIdZone
							AND Id_Item = @pvIdItem);

	SET @vfFLCPrice = ISNULL(@vfFLCPrice, 0);

	IF @vfFLCPrice = 0
	BEGIN

		SET @vfFLCPrice = (SELECT
								Price
						   FROM FLC_Cat_Item
						   WHERE 
									Id_Item = @pvIdItem)

	END

	RETURN @vfFLCPrice
END