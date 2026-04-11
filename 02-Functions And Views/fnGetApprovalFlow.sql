USE [DBQS]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetApprovalFlow]    Script Date: 4/7/2026 9:55:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


/*
Author:		Angel Gutierrez
Desc:		Gets the Approval Flow
Creation:	04/07/2026
Return 
			@ApprovalFlow Smallint
Example:	
			Declare @ApprovalFlow Smallint
			SET @ApprovalFlow = dbo.fnGetApprovalFlow('2078108', 70, 'DCLMEXI', 'DIRSA')
			SELECT @ApprovalFlow
*/
CREATE FUNCTION [dbo].[fnGetApprovalFlow](@pvIdItem Varchar(50), @pfDiscount Float, @pvIdZone Varchar(10), @pvIdSalesType Varchar(10))
RETURNS Smallint
AS
BEGIN
	Declare @ApprovalFlow Smallint
	
	SET @ApprovalFlow		 = (SELECT
									ISNULL(Id_Approval_Flow, 0)
								FROM Approved_Discounts
								WHERE
										Id_Discount_Category = (SELECT
																	Id_Discount_Category
																FROM GSS_Cat_Item
																WHERE
																		Id_Item = @pvIdItem)
									AND Bottom_Limit <= @pfDiscount
									AND Upper_Limit >= @pfDiscount
									AND Id_Sales_Type = @pvIdSalesType
									AND Id_Zone = @pvIdZone);
	
	RETURN @ApprovalFlow
END

GO



