USE DBQS
GO

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('GSS_Cat_Item') and o.name = 'FK_Countries_GSSItem')
alter table GSS_Cat_Item
   drop constraint FK_Countries_GSSItem
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('GSS_Cat_Item') and o.name = 'FK_CountryPackage_GSSItem')
alter table GSS_Cat_Item
   drop constraint FK_CountryPackage_GSSItem
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('GSS_Cat_Item') and o.name = 'FK_DiscountCategory_GSSItem')
alter table GSS_Cat_Item
   drop constraint FK_DiscountCategory_GSSItem
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('GSS_Cat_Item') and o.name = 'FK_ItemSubClass_GSSItem')
alter table GSS_Cat_Item
   drop constraint FK_ItemSubClass_GSSItem
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('GSS_Cat_Item')
            and   name  = 'IDX_COUNTRYPACKAGE_GSSITEM_FK'
            and   indid > 0
            and   indid < 255)
   drop index GSS_Cat_Item.IDX_COUNTRYPACKAGE_GSSITEM_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('GSS_Cat_Item')
            and   name  = 'IDX_DISCOUNTCATEGORY_GSSITEM_FK'
            and   indid > 0
            and   indid < 255)
   drop index GSS_Cat_Item.IDX_DISCOUNTCATEGORY_GSSITEM_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('GSS_Cat_Item')
            and   name  = 'IDX_ITEMSUBCLASS_GSSITEM_FK'
            and   indid > 0
            and   indid < 255)
   drop index GSS_Cat_Item.IDX_ITEMSUBCLASS_GSSITEM_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('GSS_Cat_Item')
            and   name  = 'IDX_COUNTRIES_GSSITEM_FK'
            and   indid > 0
            and   indid < 255)
   drop index GSS_Cat_Item.IDX_COUNTRIES_GSSITEM_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('GSS_Cat_Item')
            and   type = 'U')
   drop table GSS_Cat_Item
go

/*==============================================================*/
/* Table: GSS_Cat_Item                                          */
/*==============================================================*/
create table GSS_Cat_Item (
   Id_Item              varchar(50)          not null,
   Id_Country           varchar(10)          not null,
   Id_Item_Class        varchar(10)          not null,
   Id_Item_SubClass     varchar(10)          not null,
   Id_Discount_Category varchar(10)          not null,
   Id_Country_Package   varchar(10)          null,
   Id_Item_Related      varchar(50)          null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Model                varchar(100)         null,
   Specifications       varchar(1000)        null,
   Weight               varchar(50)          null,
   Measurements         varchar(50)          null,
   Image_Path           varchar(255)         null,
   Status               bit                  not null,
   Item_SPR             varchar(50)          null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
	Price                float                not null,
	Id_Currency          varchar(10)          not null,
	Id_Language          varchar(10)          not null,
	Standard_Cost        float                not null,
	On_Request           bit                  not null,
   constraint PK_GSS_CAT_ITEM primary key nonclustered (Id_Item)
)
go

/*==============================================================*/
/* Index: IDX_COUNTRIES_GSSITEM_FK                              */
/*==============================================================*/
create index IDX_COUNTRIES_GSSITEM_FK on GSS_Cat_Item (
Id_Country ASC
)
go

/*==============================================================*/
/* Index: IDX_ITEMSUBCLASS_GSSITEM_FK                           */
/*==============================================================*/
create index IDX_ITEMSUBCLASS_GSSITEM_FK on GSS_Cat_Item (
Id_Item_Class ASC,
Id_Item_SubClass ASC
)
go

/*==============================================================*/
/* Index: IDX_DISCOUNTCATEGORY_GSSITEM_FK                       */
/*==============================================================*/
create index IDX_DISCOUNTCATEGORY_GSSITEM_FK on GSS_Cat_Item (
Id_Discount_Category ASC
)
go

/*==============================================================*/
/* Index: IDX_COUNTRYPACKAGE_GSSITEM_FK                         */
/*==============================================================*/
create index IDX_COUNTRYPACKAGE_GSSITEM_FK on GSS_Cat_Item (
Id_Country_Package ASC
)
go

alter table GSS_Cat_Item
   add constraint FK_Countries_GSSItem foreign key (Id_Country)
      references Cat_Countries (Id_Country)
go

alter table GSS_Cat_Item
   add constraint FK_CountryPackage_GSSItem foreign key (Id_Country_Package)
      references Cat_Countries (Id_Country)
go

alter table GSS_Cat_Item
   add constraint FK_DiscountCategory_GSSItem foreign key (Id_Discount_Category)
      references Cat_Discount_Categories (Id_Discount_Category)
go

alter table GSS_Cat_Item
   add constraint FK_ItemSubClass_GSSItem foreign key (Id_Item_Class, Id_Item_SubClass)
      references Cat_Item_SubClasses (Id_Item_Class, Id_Item_SubClass)
go
