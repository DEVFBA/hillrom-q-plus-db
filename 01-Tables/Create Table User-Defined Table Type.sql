USE DBQS
/***********************************************************************/
--Create Table User-Defined Table Type
/***********************************************************************/

/* ==================================================================================*/
-- 1. UDT_Security_Access
/* ==================================================================================*/
PRINT 'Crea 1.  UDT_Security_Access' 
IF type_id('[dbo].[UDT_Security_Access]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Security_Access]
GO

CREATE TYPE [dbo].[UDT_Security_Access]AS TABLE
(
	[Id_Role] [varchar](10) NOT NULL,
	[Id_Module] [smallint] NOT NULL,
	[Id_SubModule] [smallint] NOT NULL,
	[Id_SubModuleOption] [smallint] NOT NULL,
	[Url] [varchar](255) NOT NULL,
	[Status] [bit] NOT NULL,
	[Modify_By] [varchar](50) NOT NULL,
	[Modify_Date] [datetime] NOT NULL,
	[Modify_IP] [varchar](20) NOT NULL
)
GO

/* ==================================================================================*/
-- 2. UDT_Items_Configuration
/* ==================================================================================*/
PRINT 'Crea 1.  UDT_Items_Configuration' 
IF type_id('[dbo].[UDT_Items_Configuration]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Items_Configuration]
GO

CREATE TYPE [dbo].[UDT_Items_Configuration]AS TABLE
(
   Id_Family            varchar(10)          not null,
   Id_Category          varchar(10)          not null,
   Id_Line              varchar(10)          not null,
   Id_Item              varchar(50)          not null,
   [Status]             bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null
)
GO


/* ==================================================================================*/
-- 3. UDT_Items_Templates
/* ==================================================================================*/
PRINT 'Crea 3.  UDT_Items_Templates' 
IF type_id('[dbo].[UDT_Items_Templates]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Items_Templates]
GO

CREATE TYPE [dbo].[UDT_Items_Templates]AS TABLE
(
   Item_Template        varchar(50)          not null,
   Id_Family            varchar(10)          not null,
   Id_Category          varchar(10)          not null,
   Id_Line              varchar(10)          not null,
   Id_Item              varchar(50)          not null,
   Id_Price_List        varchar(10)          not null,
   [Required]           bit                  not null,
   [Default]            bit                  not null,
   Price                float                not null,
   Standard_Cost        float                not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null
)
GO

/* ==================================================================================*/
-- 4. UDT_Items_Template_Exceptions
/* ==================================================================================*/
PRINT 'Crea 4.  UDT_Items_Template_Exceptions' 
IF type_id('[dbo].[UDT_Items_Template_Exceptions]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Items_Template_Exceptions]
GO

CREATE TYPE [dbo].[UDT_Items_Template_Exceptions]AS TABLE
(
  -- Id_Template_Exception	numeric             identity,
   Item_Template			varchar(50)         not null,
   Id_Exception				varchar(10)         not null,
   Id_Item_Exception		varchar(50)         not null,
   Id_Item_Trigger			varchar(50)         not null,
   [Message]				varchar(255)		not null,
   Message_Background_Color varchar(30)			not null,
   Message_Font_Color		varchar(30)         not null,
   [Status]					bit                 not null,
   Modify_By				varchar(50)         not null,
   Modify_Date				datetime            not null,
   Modify_IP				varchar(20)         not null
)
GO

/* ==================================================================================*/
-- 5. UDT_Items_Template_Kits
/* ==================================================================================*/
IF OBJECT_ID('[dbo].[spItems_Template_Kits_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spItems_Template_Kits_CRUD_Records
GO

PRINT 'Crea 5.  UDT_Items_Template_Kits' 
IF type_id('[dbo].[UDT_Items_Template_Kits]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Items_Template_Kits]
GO

CREATE TYPE [dbo].[UDT_Items_Template_Kits]AS TABLE
(
   Item_Template        varchar(50)          not null,
   Id_Template_Kit      Bigint                  not null,
   Id_Price_List        varchar(10)          not null,
   Price                float                not null,
   [Status]             bit                  not null
)
GO


/* ==================================================================================*/
-- 5.1 UDT_Items_Template_Kits_Detail
/* ==================================================================================*/
PRINT 'Crea 5.1  UDT_Items_Template_Kits_Detail' 
IF type_id('[dbo].[UDT_Items_Template_Kits_Detail]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Items_Template_Kits_Detail]
GO

CREATE TYPE [dbo].[UDT_Items_Template_Kits_Detail]AS TABLE
(
   Item_Template        varchar(50)          not null,
   Id_Template_Kit      Bigint               not null,
   Id_Item              varchar(50)          not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null
)
GO

/* ==================================================================================*/
-- 6 UDT_Commercial_Release
/* ==================================================================================*/
IF OBJECT_ID('[dbo].[spCommercial_Release_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCommercial_Release_CRUD_Records
GO
IF OBJECT_ID('[dbo].[spItems_Item_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spItems_Item_CRUD_Records
GO


PRINT 'Crea 6  UDT_Commercial_Release' 
IF type_id('[dbo].[UDT_Commercial_Release]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Commercial_Release]
GO

CREATE TYPE [dbo].[UDT_Commercial_Release]AS TABLE
(
   Id_Item              varchar(50)          not null,
   Id_Country           varchar(10)          not null,
   Id_Status_Commercial_Release smallint     not null,
   Final_Effective_Date Varchar(8)             null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null
)
GO

/* ==================================================================================*/
-- 7 UDT_Operation_Cost
/* ==================================================================================*/
PRINT 'Crea 7  UDT_Operation_Cost' 
IF type_id('[dbo].[UDT_Operation_Cost]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Operation_Cost]
GO

CREATE TYPE [dbo].[UDT_Operation_Cost]AS TABLE
 (
   Id_Item              varchar(50)          not null,
   Id_Country           varchar(10)          not null,
   Allocation           float                not null,
   Transport_Cost       float                not null,
   Taxes                float                not null,
   Warehousing          float                not null,
   Local_Transport      float                not null,
   Services             float                not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null
)
GO


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


/* ==================================================================================*/
-- 9 UDT_Quotation_Header
/* ==================================================================================*/
PRINT 'Crea 9  UDT_Quotation_Header' 
IF type_id('[dbo].[UDT_Quotation_Header]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Quotation_Header]
GO

CREATE TYPE [dbo].[UDT_Quotation_Header]AS TABLE
 (
   Folio                int                  not null,
   [Version]            smallint             not null,
   Id_Header			smallint			 not null,
   Item_Template        varchar(50)          not null,
   Discount             float                not null,
   Quantity             smallint             not null,
   Allocation           float                not null,
   Transfer_Price       float                not null,
   Transport_Cost       float                not null,
   Taxes                float                not null,
   Landed_Cost          float                not null,
   Local_Transport      float                not null,
   [Services]           float                not null,
   Warehousing          float                not null,
   Local_Cost           float                not null,
   Final_Price          float                not null,
   Total                float                not null,
   Margin               float                not null,
   Modify_By            varchar(50)          null,
   Modify_Date          datetime             null,
   Modify_IP            varchar(20)          null)
GO




/* ==================================================================================*/
-- 10 UDT_Quotation_Detail
/* ==================================================================================*/
PRINT 'Crea 10  UDT_Quotation_Detail' 
IF type_id('[dbo].[UDT_Quotation_Detail]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Quotation_Detail]
GO

CREATE TYPE [dbo].[UDT_Quotation_Detail]AS TABLE
 (
   Folio                int                  not null,
   [Version]            smallint             not null,
   Id_Header			smallint			 not null,
   Item_Template        varchar(50)          not null,
   Id_Detail            smallint             not null,
   Id_Item              varchar(50)          not null,
   Quantity             smallint             not null,
   Price                float                not null,
   Standard_Cost        float                not null,
   Kit_Items_Desc       varchar(255)		 null,
   Kit_Price            float                null,
   Kit_Standard_Cost    float                null,
   Modify_By            varchar(50)          null,
   Modify_Date          datetime             null,
   Modify_IP            varchar(20)          null)
GO


/* ==================================================================================*/
-- 11 UDT_Quotation_Questionnaire
/* ==================================================================================*/
PRINT 'Crea 11  UDT_Quotation_Questionnaire' 
IF type_id('[dbo].[UDT_Quotation_Questionnaire]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Quotation_Questionnaire]
GO

CREATE TYPE [dbo].[UDT_Quotation_Questionnaire]AS TABLE
 (
   [Folio]              int                  not null,
   [Version]            smallint             not null,
   Question_Number      smallint             not null,
   Question             varchar(100)         not null,
   Answer_Value         varchar(500)         not null)
GO


/* ==================================================================================*/
-- 12 UDT_Approval_Workflow
/* ==================================================================================*/
PRINT 'Crea 12  UDT_Approval_Workflow' 
IF type_id('[dbo].[UDT_Approval_Workflow]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Approval_Workflow]
GO

CREATE TYPE [dbo].[UDT_Approval_Workflow]AS TABLE
 (
   Id_Approval_Workflow Numeric              not null,
   Comments             Varchar(1000)        null
  )
GO