
/* ==================================================================================*/
-- 8 UDT_Quotation_Discounts
/* ==================================================================================*/
PRINT 'Crea 8  UDT_Quotation_Discounts' 
IF type_id('[dbo].[UDT_Quotation_Discounts]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Quotation_Discounts]
GO

CREATE TYPE [dbo].[UDT_Quotation_Discounts]AS TABLE
 (
   Id_Item            varchar(50)          not null,
   Discount           float                not null,
   Id_Country		  Varchar(10)	       not null
)
GO

