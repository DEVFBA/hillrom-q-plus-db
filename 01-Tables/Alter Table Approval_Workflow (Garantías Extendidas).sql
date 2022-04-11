
/*==============================================================*/
/* Table: Cat_Extended_Warranties                               */
/*==============================================================*/
PRINT 'Modifica Cat_Extended_Warranties'
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_Extended_Warranties') and o.name = 'FK_CAT_EXTE_FK_APPFLO_CAT_APPR')
alter table Cat_Extended_Warranties
   drop constraint FK_CAT_EXTE_FK_APPFLO_CAT_APPR
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Cat_Extended_Warranties')
            and   name  = 'FK_APPFLOWS_EXTENDEDWARRANTY_FK'
            and   indid > 0
            and   indid < 255)
   drop index Cat_Extended_Warranties.FK_APPFLOWS_EXTENDEDWARRANTY_FK
go

IF NOT EXISTS(SELECT *
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'Cat_Extended_Warranties'
                 AND COLUMN_NAME = 'Id_Approval_Flow') 

	ALTER TABLE Cat_Extended_Warranties ADD Id_Approval_Flow smallint null
GO


/* Index: FK_APPFLOWS_EXTENDEDWARRANTY_FK                       */
create index FK_APPFLOWS_EXTENDEDWARRANTY_FK on Cat_Extended_Warranties (
Id_Approval_Flow ASC
)
go

alter table Cat_Extended_Warranties
   add constraint FK_CAT_EXTE_FK_APPFLO_CAT_APPR foreign key (Id_Approval_Flow)
      references Cat_Approvals_Flows (Id_Approval_Flow)
go


PRINT 'Modifica Approval_Workflow'
/*==============================================================*/
/* Table: Approval_Workflow                                     */
/*==============================================================*/

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Approval_Workflow') and o.name = 'FK_APPROVAL_FK_APPTYP_CAT_APPR')
alter table Approval_Workflow
   drop constraint FK_APPROVAL_FK_APPTYP_CAT_APPR
go


if exists (select 1
            from  sysindexes
           where  id    = object_id('Approval_Workflow')
            and   name  = 'FK_APPTYPES_WORKFLOW_FK'
            and   indid > 0
            and   indid < 255)
   drop index Approval_Workflow.FK_APPTYPES_WORKFLOW_FK
go

-- Delete primary key.  
if exists (SELECT *  
FROM sys.key_constraints  
WHERE type = 'PK' AND OBJECT_NAME(parent_object_id) = N'Approval_Workflow')

	-- Delete the primary key constraint.  
	ALTER TABLE Approval_Workflow  DROP CONSTRAINT PK_APPROVAL_WORKFLOW
GO  

--  Add column
IF NOT EXISTS(SELECT *
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'Approval_Workflow'
                 AND COLUMN_NAME = 'Id_Approval_Section') 

	ALTER TABLE Approval_Workflow ADD Id_Approval_Section smallint null
GO

--  Add column
IF NOT EXISTS(SELECT *
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'Approval_Workflow'
                 AND COLUMN_NAME = 'Id_Approval_Type') 

	ALTER TABLE Approval_Workflow ADD Id_Approval_Type smallint null
GO

UPDATE Approval_Workflow
SET Id_Approval_Section = 1,
	Id_Approval_Type  = 1
GO

ALTER TABLE Approval_Workflow alter column Id_Approval_Section smallint NOT NULL
ALTER TABLE Approval_Workflow alter column Id_Approval_Type smallint NOT NULL


/* Index: FK_APPTYPES_WORKFLOW_FK                               */
create index FK_APPTYPES_WORKFLOW_FK on Approval_Workflow (
Id_Approval_Section ASC,
Id_Approval_Type ASC
)
go

alter table Approval_Workflow
   add constraint FK_APPROVAL_FK_APPTYP_CAT_APPR foreign key (Id_Approval_Section, Id_Approval_Type)
      references Cat_Approval_Types (Id_Approval_Section, Id_Approval_Type)
go


ALTER TABLE Approval_Workflow
	ADD CONSTRAINT PK_APPROVAL_WORKFLOW PRIMARY KEY (Id_Approval_Workflow,Folio,Version,Id_Header,Item_Template,Id_Approval_Section,Id_Approval_Type)
go


/* ==================================================================================*/
-- UDT_Quotation_Incoterms
/* ==================================================================================*/
PRINT 'Crea UDT_Quotation_Incoterms' 
IF type_id('[dbo].[UDT_Quotation_Incoterms]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Quotation_Incoterms]
GO

CREATE TYPE [dbo].[UDT_Quotation_Incoterms]AS TABLE
(
	Id_Country	Varchar(10),
	Id_Incoterm	Varchar(10)
)
GO

/* ==================================================================================*/
-- UDT_Quotation_Warranties
/* ==================================================================================*/
PRINT 'Crea UDT_Quotation_Warranties' 
IF type_id('[dbo].[UDT_Quotation_Warranties]') IS NOT NULL
        DROP TYPE  [dbo].UDT_Quotation_Warranties
GO

CREATE TYPE [dbo].[UDT_Quotation_Warranties]AS TABLE
(
	Id_Line				Varchar(10),
	Id_Year_Warranty	Smallint
)
GO

