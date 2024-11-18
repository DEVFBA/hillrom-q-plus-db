use DBQS
GO
/*==============================================================*/
/* Table: FLC_Cat_Item                                          */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Commercial_Release') and o.name = 'FK_CatItem_FLC_CommercialRelease')
alter table FLC_Commercial_Release
   drop constraint FK_CatItem_FLC_CommercialRelease
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Items_Configuration') and o.name = 'FK_FCLCatItem_ItemsConfiguration')
alter table FLC_Items_Configuration
   drop constraint FK_FCLCatItem_ItemsConfiguration
go

if exists (select 1
            from  sysobjects
           where  id = object_id('FLC_Cat_Item')
            and   type = 'U')
   drop table FLC_Cat_Item
go


create table FLC_Cat_Item (
   Id_Item              varchar(50)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         null,
   Comment              varchar(500)         null,
   Price                float                not null,
   Standard_Cost        float                not null,
   Obsolescence         bit                  not null,
   Obsolescence_Date    datetime             null,
   Image_Path           varchar(255)         null,
   Substitute_Item      varchar(50)          null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_FLC_CAT_ITEM primary key nonclustered (Id_Item)
)
go


/*==============================================================*/
/* Table: FLC_Items_Configuration                               */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Items_Configuration') and o.name = 'FK_FCLCatItem_ItemsConfiguration')
alter table FLC_Items_Configuration
   drop constraint FK_FCLCatItem_ItemsConfiguration
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Items_Configuration') and o.name = 'FK_FCLCategoriesFamilies_ItemsConfiguration')
alter table FLC_Items_Configuration
   drop constraint FK_FCLCategoriesFamilies_ItemsConfiguration
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('FLC_Items_Configuration')
            and   name  = 'FCL_CATITEM_ITEMSCONFIGURATION_FK'
            and   indid > 0
            and   indid < 255)
   drop index FLC_Items_Configuration.FCL_CATITEM_ITEMSCONFIGURATION_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('FLC_Items_Configuration')
            and   name  = 'FCL_CATEGORIESFAMILIES_ITEMSCONFIGURATION_FK'
            and   indid > 0
            and   indid < 255)
   drop index FLC_Items_Configuration.FCL_CATEGORIESFAMILIES_ITEMSCONFIGURATION_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('FLC_Items_Configuration')
            and   type = 'U')
   drop table FLC_Items_Configuration
go


create table FLC_Items_Configuration (
   Id_FLC_Category      varchar(10)          not null,
   Id_FLC_Family        varchar(10)          not null,
   Id_FLC_Group         varchar(10)          not null,
   Id_Item              varchar(50)          not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_FLC_ITEMS_CONFIGURATION primary key (Id_FLC_Category, Id_FLC_Family, Id_FLC_Group, Id_Item)
)
go

create index FCL_CATEGORIESFAMILIES_ITEMSCONFIGURATION_FK on FLC_Items_Configuration (
Id_FLC_Category ASC,
Id_FLC_Family ASC,
Id_FLC_Group ASC
)
go

create index FCL_CATITEM_ITEMSCONFIGURATION_FK on FLC_Items_Configuration (
Id_Item ASC
)
go

alter table FLC_Items_Configuration
   add constraint FK_FCLCatItem_ItemsConfiguration foreign key (Id_Item)
      references FLC_Cat_Item (Id_Item)
go

alter table FLC_Items_Configuration
   add constraint FK_FCLCategoriesFamilies_ItemsConfiguration foreign key (Id_FLC_Category, Id_FLC_Family, Id_FLC_Group)
      references FLC_Cat_Categories_Families (Id_FLC_Category, Id_FLC_Family, Id_FLC_Group)
go


/*==============================================================*/
/* Table: FLC_Commercial_Release                                */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Commercial_Release') and o.name = 'FK_CatItem_FLC_CommercialRelease')
alter table FLC_Commercial_Release
   drop constraint FK_CatItem_FLC_CommercialRelease
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Commercial_Release') and o.name = 'FK_Countries_CommercialRelease')
alter table FLC_Commercial_Release
   drop constraint FK_Countries_CommercialRelease
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Commercial_Release') and o.name = 'FK_StatusCommercialRelease_FLC_CommercialRelease')
alter table FLC_Commercial_Release
   drop constraint FK_StatusCommercialRelease_FLC_CommercialRelease
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('FLC_Commercial_Release')
            and   name  = 'FK_STATUSCOMMERCIALRELEASE_FLC_COMMERCIALRELEASE_FK'
            and   indid > 0
            and   indid < 255)
   drop index FLC_Commercial_Release.FK_STATUSCOMMERCIALRELEASE_FLC_COMMERCIALRELEASE_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('FLC_Commercial_Release')
            and   name  = 'FK_COUNTRIES_COMMERCIALRELEASE_FK'
            and   indid > 0
            and   indid < 255)
   drop index FLC_Commercial_Release.FK_COUNTRIES_COMMERCIALRELEASE_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('FLC_Commercial_Release')
            and   name  = 'FK_CATITEM_FLC_COMMERCIALRELEASE_FK'
            and   indid > 0
            and   indid < 255)
   drop index FLC_Commercial_Release.FK_CATITEM_FLC_COMMERCIALRELEASE_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('FLC_Commercial_Release')
            and   type = 'U')
   drop table FLC_Commercial_Release
go


create table FLC_Commercial_Release (
   Id_Item              varchar(50)          not null,
   Id_Country           varchar(10)          not null,
   Id_Language          varchar(10)          not null,
   Id_Status_Commercial_Release smallint     not null,
   Final_Effective_Date datetime             null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_FLC_COMMERCIAL_RELEASE primary key (Id_Item, Id_Country)
)
go


create index FK_CATITEM_FLC_COMMERCIALRELEASE_FK on FLC_Commercial_Release (
Id_Item ASC
)
go


create index FK_COUNTRIES_COMMERCIALRELEASE_FK on FLC_Commercial_Release (
Id_Country ASC
)
go


create index FK_STATUSCOMMERCIALRELEASE_FLC_COMMERCIALRELEASE_FK on FLC_Commercial_Release (
Id_Language ASC,
Id_Status_Commercial_Release ASC
)
go

alter table FLC_Commercial_Release
   add constraint FK_CatItem_FLC_CommercialRelease foreign key (Id_Item)
      references FLC_Cat_Item (Id_Item)
go

alter table FLC_Commercial_Release
   add constraint FK_Countries_CommercialRelease foreign key (Id_Country)
      references Cat_Countries (Id_Country)
go

alter table FLC_Commercial_Release
   add constraint FK_StatusCommercialRelease_FLC_CommercialRelease foreign key (Id_Status_Commercial_Release, Id_Language)
      references Cat_Status_Commercial_Release (Id_Status_Commercial_Release, Id_Language)
go
