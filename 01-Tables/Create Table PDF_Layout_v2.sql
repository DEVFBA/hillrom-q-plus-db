use DBQS
go

/* Table: Cat_PDF_Layout_Types                                  */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_PDF_Layout_Types') and o.name = 'FK_CAT_PDF__FK_ZONETY_CAT_ZONE')
alter table Cat_PDF_Layout_Types
   drop constraint FK_CAT_PDF__FK_ZONETY_CAT_ZONE
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_PDF_Layouts') and o.name = 'FK_CAT_PDF__FK_LAYOUT_CAT_PDF_')
alter table Cat_PDF_Layouts
   drop constraint FK_CAT_PDF__FK_LAYOUT_CAT_PDF_
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Cat_PDF_Layout_Types')
            and   name  = 'FK_ZONETYPE_TYPESLAYOUT_FK'
            and   indid > 0
            and   indid < 255)
   drop index Cat_PDF_Layout_Types.FK_ZONETYPE_TYPESLAYOUT_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_PDF_Layout_Types')
            and   type = 'U')
   drop table Cat_PDF_Layout_Types
go


create table Cat_PDF_Layout_Types (
   Id_Layout_Type       varchar(10)          not null,
   Id_Zone_Type         varchar(10)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_PDF_LAYOUT_TYPES primary key nonclustered (Id_Layout_Type)
)
go

/* Index: FK_ZONETYPE_TYPESLAYOUT_FK                            */

create index FK_ZONETYPE_TYPESLAYOUT_FK on Cat_PDF_Layout_Types (
Id_Zone_Type ASC
)
go

alter table Cat_PDF_Layout_Types
   add constraint FK_CAT_PDF__FK_ZONETY_CAT_ZONE foreign key (Id_Zone_Type)
      references Cat_Zone_Types (Id_Zone_Type)
go



/*==============================================================*/
/* Table: Cat_PDF_Layouts                                       */
/*==============================================================*/

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_Item') and o.name = 'FK_CAT_ITEM_FK_PDFLAY_CAT_PDF_')
alter table Cat_Item
   drop constraint FK_CAT_ITEM_FK_PDFLAY_CAT_PDF_
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_PDF_Layouts') and o.name = 'FK_CAT_PDF__FK_LAYOUT_CAT_PDF_')
alter table Cat_PDF_Layouts
   drop constraint FK_CAT_PDF__FK_LAYOUT_CAT_PDF_
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Cat_PDF_Layouts')
            and   name  = 'FK_LAYOUTTYPE_LAYOUT_FK'
            and   indid > 0
            and   indid < 255)
   drop index Cat_PDF_Layouts.FK_LAYOUTTYPE_LAYOUT_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_PDF_Layouts')
            and   type = 'U')
   drop table Cat_PDF_Layouts
go


create table Cat_PDF_Layouts (
   Id_Layout            varchar(50)          not null,
   Id_Layout_Type       varchar(10)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Layout_Path          varchar(255)         null,
   Layout_Ref			varchar(50)          not null,
   "Order"              smallint             not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_PDF_LAYOUTS primary key nonclustered (Id_Layout)
)
go


/* Index: FK_LAYOUTTYPE_LAYOUT_FK                               */
create index FK_LAYOUTTYPE_LAYOUT_FK on Cat_PDF_Layouts (
Id_Layout_Type ASC
)
go

alter table Cat_PDF_Layouts
   add constraint FK_CAT_PDF__FK_LAYOUT_CAT_PDF_ foreign key (Id_Layout_Type)
      references Cat_PDF_Layout_Types (Id_Layout_Type)
go




/*==============================================================*/
/* Table: Cat_Item                                          */
/*==============================================================*/
IF NOT EXISTS(SELECT *
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'Cat_Item'
                 AND COLUMN_NAME = 'Id_Layout') 

	ALTER TABLE Cat_Item ADD Id_Layout         varchar(50)          null
GO

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_Item') and o.name = 'FK_CAT_ITEM_FK_PDFLAY_CAT_PDF_')
alter table Cat_Item
   drop constraint FK_CAT_ITEM_FK_PDFLAY_CAT_PDF_
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Cat_Item')
            and   name  = 'FK_PDFLAYOUT_ITEM_FK'
            and   indid > 0
            and   indid < 255)
   drop index Cat_Item.FK_PDFLAYOUT_ITEM_FK
go

/*==============================================================*/
/* Index: FK_PDFLAYOUT_ITEM_FK                                  */

create index FK_PDFLAYOUT_ITEM_FK on Cat_Item (
Id_Layout ASC
)
go

alter table Cat_Item
   add constraint FK_CAT_ITEM_FK_PDFLAY_CAT_PDF_ foreign key (Id_Layout)
      references Cat_PDF_Layouts (Id_Layout)
go

/*==============================================================*/
/* Alter  coluk   */

select * from Cat_PDF_Layouts where Layout_Ref is null

ALTER TABLE Cat_PDF_Layouts
ALTER COLUMN Layout_Ref varchar(50)  NOT NULL
