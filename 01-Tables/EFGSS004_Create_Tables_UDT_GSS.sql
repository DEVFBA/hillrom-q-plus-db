USE DBQS
GO
/* ==================================================================================*/
-- 1. UDT_GSS_Items_Configuration
/* ==================================================================================*/
PRINT 'Crea 1. UDT_GSS_Items_Configuration' 
IF type_id('[dbo].[UDT_GSS_Items_Configuration]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_GSS_Items_Configuration]
GO

CREATE TYPE [dbo].[UDT_GSS_Items_Configuration]AS TABLE
(
   Id_Item                      varchar(50)             not null,
   Id_Category_Hierarchy        int                     not null
)
GO

/* ==================================================================================*/
-- 2 UDT_GSS_Operation_Cost
/* ==================================================================================*/
PRINT 'Crea 2  UDT_GSS_Operation_Cost' 
IF type_id('[dbo].[UDT_GSS_Operation_Cost]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_GSS_Operation_Cost]
GO

CREATE TYPE [dbo].[UDT_GSS_Operation_Cost]AS TABLE
 (
   Id_Item              varchar(50)          not null,
   Id_Country           varchar(10)          not null,
   Allocation           float                not null,
   Transport_Cost       float                not null,
   Taxes                float                not null,
   Warehousing          float                not null,
   Local_Transport      float                not null,
   Services             float                not null
)
GO


/* ==================================================================================*/
-- 3 UDT_GSS_Commercial_Release
/* ==================================================================================*/
PRINT 'Crea 3  UDT_GSS_Commercial_Release' 
IF type_id('[dbo].[UDT_GSS_Commercial_Release]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_GSS_Commercial_Release]
GO

CREATE TYPE [dbo].[UDT_GSS_Commercial_Release]AS TABLE
(
   Id_Item              varchar(50)          not null,
   Id_Country           varchar(10)          not null,
   Id_Status_Commercial_Release smallint     not null,
   Final_Effective_Date Varchar(8)             null
)
GO