USE DBQS
GO

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('GSS_Items_Configuration') and o.name = 'FK_CategoryHierarchy_GSSItemConfig')
alter table GSS_Items_Configuration
   drop constraint FK_CategoryHierarchy_GSSItemConfig
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('GSS_Items_Configuration') and o.name = 'FK_GSSItem_GSSItemConfig')
alter table GSS_Items_Configuration
   drop constraint FK_GSSItem_GSSItemConfig
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('GSS_Items_Configuration')
            and   name  = 'IDX_CATEGORYHIERARCHY_GSSITEMCONFIG_FK'
            and   indid > 0
            and   indid < 255)
   drop index GSS_Items_Configuration.IDX_CATEGORYHIERARCHY_GSSITEMCONFIG_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('GSS_Items_Configuration')
            and   name  = 'IDX_GSSITEM_GSSITEMCONFIG_FK'
            and   indid > 0
            and   indid < 255)
   drop index GSS_Items_Configuration.IDX_GSSITEM_GSSITEMCONFIG_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('GSS_Items_Configuration')
            and   type = 'U')
   drop table GSS_Items_Configuration
go

/*==============================================================*/
/* Table: GSS_Items_Configuration                               */
/*==============================================================*/
create table GSS_Items_Configuration (
   Id_Item              varchar(50)          not null,
   Id_Category_Hierarchy int                  not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_GSS_ITEMS_CONFIGURATION primary key (Id_Item, Id_Category_Hierarchy)
)
go

/*==============================================================*/
/* Index: IDX_GSSITEM_GSSITEMCONFIG_FK                          */
/*==============================================================*/
create index IDX_GSSITEM_GSSITEMCONFIG_FK on GSS_Items_Configuration (
Id_Item ASC
)
go

/*==============================================================*/
/* Index: IDX_CATEGORYHIERARCHY_GSSITEMCONFIG_FK                */
/*==============================================================*/
create index IDX_CATEGORYHIERARCHY_GSSITEMCONFIG_FK on GSS_Items_Configuration (
Id_Category_Hierarchy ASC
)
go

alter table GSS_Items_Configuration
   add constraint FK_CategoryHierarchy_GSSItemConfig foreign key (Id_Category_Hierarchy)
      references GSS_Categories_Hierarchies (Id_Category_Hierarchy)
go

alter table GSS_Items_Configuration
   add constraint FK_GSSItem_GSSItemConfig foreign key (Id_Item)
      references GSS_Cat_Item (Id_Item)
go
