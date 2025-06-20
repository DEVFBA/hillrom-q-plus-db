USE [DBQS]
GO

/* ==================================================================================*/
-- 13 UDT_Approved_Discounts -- EFPSLI008
/* ==================================================================================*/
PRINT 'Crea 13  UDT_Approved_Discounts' 
IF type_id('[dbo].[UDT_Approved_Discounts]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Approved_Discounts]
GO

CREATE TYPE [dbo].[UDT_Approved_Discounts]AS TABLE
 (
   Id_Discount                  smallint             not null,
   Id_Discount_Category         Varchar(10)          not null,
   Id_Discount_Type             Varchar(10)          not null,
   Id_Zone                      Varchar(10)          not null,
   Id_Approval_Flow             smallint             not null,
   Bottom_Limit                 float                not null,
   Upper_Limit                  float                not null,
   Apply_Amount                 bit                  not null,
   Approval_Group               Varchar(20)          null,
   Id_Language                  Varchar(10)          null,
   Id_Sales_Type                Varchar(10)          null)
GO