USE DBQS
GO
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('GSS_Commercial_Release') and o.name = 'FK_Countries_GSSComRelease')
alter table GSS_Commercial_Release
   drop constraint FK_Countries_GSSComRelease
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('GSS_Commercial_Release') and o.name = 'FK_GSSItem_GSSComRelease')
alter table GSS_Commercial_Release
   drop constraint FK_GSSItem_GSSComRelease
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('GSS_Commercial_Release') and o.name = 'FK_StatusComRelease_GSSComRelease')
alter table GSS_Commercial_Release
   drop constraint FK_StatusComRelease_GSSComRelease
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('GSS_Commercial_Release')
            and   name  = 'IDX_STATUSCOMRELEASE_GSSCOMRELEASE_FK'
            and   indid > 0
            and   indid < 255)
   drop index GSS_Commercial_Release.IDX_STATUSCOMRELEASE_GSSCOMRELEASE_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('GSS_Commercial_Release')
            and   name  = 'IDX_COUNTRIES_GSSCOMRELEASE_FK'
            and   indid > 0
            and   indid < 255)
   drop index GSS_Commercial_Release.IDX_COUNTRIES_GSSCOMRELEASE_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('GSS_Commercial_Release')
            and   name  = 'IDX_GSSITEM_GSSCOMRELEASE_FK'
            and   indid > 0
            and   indid < 255)
   drop index GSS_Commercial_Release.IDX_GSSITEM_GSSCOMRELEASE_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('GSS_Commercial_Release')
            and   type = 'U')
   drop table GSS_Commercial_Release
go

/*==============================================================*/
/* Table: GSS_Commercial_Release                                */
/*==============================================================*/
create table GSS_Commercial_Release (
   Id_Item              varchar(50)          not null,
   Id_Country           varchar(10)          not null,
   Id_Status_Commercial_Release smallint             not null,
   Final_Effective_Date datetime             null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_GSS_COMMERCIAL_RELEASE primary key (Id_Item, Id_Country)
)
go

/*==============================================================*/
/* Index: IDX_GSSITEM_GSSCOMRELEASE_FK                          */
/*==============================================================*/
create index IDX_GSSITEM_GSSCOMRELEASE_FK on GSS_Commercial_Release (
Id_Item ASC
)
go

/*==============================================================*/
/* Index: IDX_COUNTRIES_GSSCOMRELEASE_FK                        */
/*==============================================================*/
create index IDX_COUNTRIES_GSSCOMRELEASE_FK on GSS_Commercial_Release (
Id_Country ASC
)
go

/*==============================================================*/
/* Index: IDX_STATUSCOMRELEASE_GSSCOMRELEASE_FK                 */
/*==============================================================*/
create index IDX_STATUSCOMRELEASE_GSSCOMRELEASE_FK on GSS_Commercial_Release (
Id_Status_Commercial_Release ASC
)
go

alter table GSS_Commercial_Release
   add constraint FK_Countries_GSSComRelease foreign key (Id_Country)
      references Cat_Countries (Id_Country)
go

alter table GSS_Commercial_Release
   add constraint FK_GSSItem_GSSComRelease foreign key (Id_Item)
      references GSS_Cat_Item (Id_Item)
go
