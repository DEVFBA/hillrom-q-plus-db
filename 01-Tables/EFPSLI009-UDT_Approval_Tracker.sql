USE [DBQS]
GO

/* ==================================================================================*/
-- 14 UDT_Approved_Discounts -- EFPSLI009
/* ==================================================================================*/
PRINT 'Crea 14  UDT_Approval_Tracker' 
IF type_id('[dbo].[UDT_Approval_Tracker]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Approval_Tracker]
GO

CREATE TYPE [dbo].[UDT_Approval_Tracker]AS TABLE
 (
   Id_Role                      Varchar(10)          not null 
 )
GO