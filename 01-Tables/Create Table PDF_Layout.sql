use DBQS
go

/*==============================================================*/
/* Table: Cat_Families                                          */
/*==============================================================*/
IF NOT EXISTS(SELECT *
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'Cat_Families'
                 AND COLUMN_NAME = 'Id_Zone_Type') 

	ALTER TABLE Cat_Families ADD Id_Zone_Type         varchar(10)          null
GO

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_Families') and o.name = 'FK_CAT_FAMI_FK_ZONETY_CAT_ZONE')
alter table Cat_Families
   drop constraint FK_CAT_FAMI_FK_ZONETY_CAT_ZONE
go


if exists (select 1
            from  sysindexes
           where  id    = object_id('Cat_Families')
            and   name  = 'FK_ZONETYPE_FAMILIES_FK'
            and   indid > 0
            and   indid < 255)
   drop index Cat_Families.FK_ZONETYPE_FAMILIES_FK
go

/* Index: FK_ZONETYPE_FAMILIES_FK                               */

create index FK_ZONETYPE_FAMILIES_FK on Cat_Families (
Id_Zone_Type ASC
)
go

alter table Cat_Families
   add constraint FK_CAT_FAMI_FK_ZONETY_CAT_ZONE foreign key (Id_Zone_Type)
      references Cat_Zone_Types (Id_Zone_Type)
go


/*==============================================================*/
/* Table: Cat_PDF_Layouts                                       */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_PDF_Lines_Layouts') and o.name = 'FK_CAT_PDF__CATLAYOUT_CAT_PDF_')
alter table Cat_PDF_Lines_Layouts
   drop constraint FK_CAT_PDF__CATLAYOUT_CAT_PDF_
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_PDF_Layouts')
            and   type = 'U')
   drop table Cat_PDF_Layouts
go


create table Cat_PDF_Layouts (
   Id_Layout            varchar(10)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Layout_Path          varchar(255)         null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_PDF_LAYOUTS primary key nonclustered (Id_Layout)
)
go


/*==============================================================*/
/* Table: Cat_PDF_Lines_Layouts                                 */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_PDF_Lines_Layouts') and o.name = 'FK_CAT_PDF__CATLAYOUT_CAT_PDF_')
alter table Cat_PDF_Lines_Layouts
   drop constraint FK_CAT_PDF__CATLAYOUT_CAT_PDF_
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_PDF_Lines_Layouts') and o.name = 'FK_CAT_PDF__CATLINE_P_CAT_LINE')
alter table Cat_PDF_Lines_Layouts
   drop constraint FK_CAT_PDF__CATLINE_P_CAT_LINE
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Cat_PDF_Lines_Layouts')
            and   name  = 'CATLAYOUTS_PDFLINES_FK'
            and   indid > 0
            and   indid < 255)
   drop index Cat_PDF_Lines_Layouts.CATLAYOUTS_PDFLINES_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Cat_PDF_Lines_Layouts')
            and   name  = 'CATLINE_PDFLINE_LAYOUTS_FK'
            and   indid > 0
            and   indid < 255)
   drop index Cat_PDF_Lines_Layouts.CATLINE_PDFLINE_LAYOUTS_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_PDF_Lines_Layouts')
            and   type = 'U')
   drop table Cat_PDF_Lines_Layouts
go

create table Cat_PDF_Lines_Layouts (
   Id_Line              varchar(10)          not null,
   Id_Layout            varchar(10)          not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_PDF_LINES_LAYOUTS primary key (Id_Line, Id_Layout)
)
go

/* Index: CATLINE_PDFLINE_LAYOUTS_FK                            */

create index CATLINE_PDFLINE_LAYOUTS_FK on Cat_PDF_Lines_Layouts (
Id_Line ASC
)
go

/* Index: CATLAYOUTS_PDFLINES_FK                                */

create index CATLAYOUTS_PDFLINES_FK on Cat_PDF_Lines_Layouts (
Id_Layout ASC
)
go

alter table Cat_PDF_Lines_Layouts
   add constraint FK_CAT_PDF__CATLAYOUT_CAT_PDF_ foreign key (Id_Layout)
      references Cat_PDF_Layouts (Id_Layout)
go

alter table Cat_PDF_Lines_Layouts
   add constraint FK_CAT_PDF__CATLINE_P_CAT_LINE foreign key (Id_Line)
      references Cat_Lines (Id_Line)
go
