USE DBQS
/***********************************************************************/
--Create Table User-Defined Table Type
/***********************************************************************/

/* ==================================================================================*/
-- 1. UDT_FLC_Customer_Categories
/* ==================================================================================*/
PRINT 'Crea 1.  UDT_FLC_Customer_Categories' 
IF type_id('[dbo].[UDT_FLC_Customer_Categories]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_FLC_Customer_Categories]
GO

CREATE TYPE [dbo].[UDT_FLC_Customer_Categories] AS TABLE
(
   Id_Customer          int                  not null,
   Id_FLC_Category      varchar(10)          not null,
   Category_Discount    varchar(50)          null,
   Status               bit                  not null
)
GO

/* ==================================================================================*/
-- 2. UDT_FLC_Items_Configuration
/* ==================================================================================*/
PRINT 'Crea 1.  UDT_FLC_Items_Configuration' 
IF type_id('[dbo].[UDT_FLC_Items_Configuration]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_FLC_Items_Configuration]
GO

CREATE TYPE [dbo].[UDT_FLC_Items_Configuration] AS TABLE
(
   Id_FLC_Category      varchar(10)          not null,
   Id_FLC_Family        varchar(10)          not null,
   Id_FLC_Group         varchar(10)          not null,
   Id_Item              varchar(50)          not null,
   Status               bit                  not null
)
GO

/* ==================================================================================*/
-- 3. UDT_FLC_Commercial_Release
/* ==================================================================================*/
PRINT 'Crea 1.  UDT_FLC_Commercial_Release' 
IF type_id('[dbo].[UDT_FLC_Commercial_Release]') IS NOT NULL
		DROP PROCEDURE [dbo].spFLC_Commercial_Release_CRUD_Records
        DROP TYPE  [dbo].[UDT_FLC_Commercial_Release]
GO

CREATE TYPE [dbo].[UDT_FLC_Commercial_Release]AS TABLE
(
   Id_Item						varchar(50)          not null,
   Id_Country					varchar(10)          not null,
   Id_Language					varchar(10)          not null,
   Id_Status_Commercial_Release smallint             not null,
   Final_Effective_Date			varchar(8)             null
)
GO