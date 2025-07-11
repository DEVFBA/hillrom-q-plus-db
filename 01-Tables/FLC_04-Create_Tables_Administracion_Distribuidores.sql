USE DBQS
GO

/*==============================================================*/
/* Table: FLC_Cat_Customers                                    */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Cat_Customers') and o.name = 'FLC_Country_Customers')
alter table FLC_Cat_Customers
   drop constraint FLC_Country_Customers
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Customer_Categories') and o.name = 'FK_FLC_Customers_CustomersCategories')
alter table FLC_Customer_Categories
   drop constraint FK_FLC_Customers_CustomersCategories
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Customer_Zones') and o.name = 'FK_FLC_Customers_CustomerZones')
alter table FLC_Customer_Zones
   drop constraint FK_FLC_Customers_CustomerZones
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('FLC_Cat_Customers')
            and   name  = 'FLC_COUNTRY_CUSTOMERS_FK'
            and   indid > 0
            and   indid < 255)
   drop index FLC_Cat_Customers.FLC_COUNTRY_CUSTOMERS_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('FLC_Cat_Customers')
            and   type = 'U')
   drop table FLC_Cat_Customers
go


create table FLC_Cat_Customers (
   Id_Customer          int                  not null,
   Id_Country           varchar(10)          not null,
   Name                 varchar(255)         not null,
   Address_Street       varchar(100)         null,
   Address_Ext          varchar(30)          null,
   Address_Int          varchar(30)          null,
   Address_State        varchar(50)          null,
   Address_ZipCode      varchar(12)          null,
   Address_City         varchar(50)          null,
   Address_County       varchar(50)          null,
   Email                varchar(60)          null,
   Contact              varchar(100)         null,
   Phone_Number         varchar(30)          null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_FLC_CAT_CUSTOMERS primary key nonclustered (Id_Customer)
)
go

create index FLC_COUNTRY_CUSTOMERS_FK on FLC_Cat_Customers (
Id_Country ASC
)
go

alter table FLC_Cat_Customers
   add constraint FLC_Country_Customers foreign key (Id_Country)
      references Cat_Countries (Id_Country)
go


/*==============================================================*/
/* Table: FLC_Customer_Categories                              */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Customer_Categories') and o.name = 'FK_FLC_Categories_CustomersCategories')
alter table FLC_Customer_Categories
   drop constraint FK_FLC_Categories_CustomersCategories
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Customer_Categories') and o.name = 'FK_FLC_Customers_CustomersCategories')
alter table FLC_Customer_Categories
   drop constraint FK_FLC_Customers_CustomersCategories
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('FLC_Customer_Categories')
            and   name  = 'FK_CATEGORIESFAMILIES_CUSTOMERSCATEGORIES_FK'
            and   indid > 0
            and   indid < 255)
   drop index FLC_Customer_Categories.FK_CATEGORIESFAMILIES_CUSTOMERSCATEGORIES_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('FLC_Customer_Categories')
            and   name  = 'FK_CUSTOMERS_CUSTOMERSCATEGORIES_FK'
            and   indid > 0
            and   indid < 255)
   drop index FLC_Customer_Categories.FK_CUSTOMERS_CUSTOMERSCATEGORIES_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('FLC_Customer_Categories')
            and   type = 'U')
   drop table FLC_Customer_Categories
go

create table FLC_Customer_Categories (
   Id_Customer          int                  not null,
   Id_FLC_Category      varchar(10)          not null,
   Category_Discount    varchar(50)          null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_FLC_CUSTOMER_CATEGORIES primary key (Id_Customer, Id_FLC_Category)
)
go

create index FK_CUSTOMERS_CUSTOMERSCATEGORIES_FK on FLC_Customer_Categories (
Id_Customer ASC
)
go

create index FK_CATEGORIESFAMILIES_CUSTOMERSCATEGORIES_FK on FLC_Customer_Categories (
Id_FLC_Category ASC
)
go

alter table FLC_Customer_Categories
   add constraint FK_FLC_Categories_CustomersCategories foreign key (Id_FLC_Category)
      references FLC_Cat_Categories (Id_FLC_Category)
go

alter table FLC_Customer_Categories
   add constraint FK_FLC_Customers_CustomersCategories foreign key (Id_Customer)
      references FLC_Cat_Customers (Id_Customer)
go


/*==============================================================*/
/* Table: FLC_Customer_Zones                                    */
/*==============================================================*/

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Customer_Zones') and o.name = 'FK_FLC_Customers_CustomerZones')
alter table FLC_Customer_Zones
   drop constraint FK_FLC_Customers_CustomerZones
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Customer_Zones') and o.name = 'FK_FLC_RegionZone_CustomerZone')
alter table FLC_Customer_Zones
   drop constraint FK_FLC_RegionZone_CustomerZone
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('FLC_Customer_Zones')
            and   name  = 'RELATIONSHIP_138_FK'
            and   indid > 0
            and   indid < 255)
   drop index FLC_Customer_Zones.RELATIONSHIP_138_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('FLC_Customer_Zones')
            and   name  = 'FK_CUSTOMERS_CUSTOMERZONES_FK'
            and   indid > 0
            and   indid < 255)
   drop index FLC_Customer_Zones.FK_CUSTOMERS_CUSTOMERZONES_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('FLC_Customer_Zones')
            and   type = 'U')
   drop table FLC_Customer_Zones
go


create table FLC_Customer_Zones (
   Id_Customer          int                  not null,
   Id_Region            varchar(10)          not null,
   Id_Zone              varchar(10)          not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_FLC_CUSTOMER_ZONES primary key (Id_Region, Id_Zone, Id_Customer)
)
go

create index FK_CUSTOMERS_CUSTOMERZONES_FK on FLC_Customer_Zones (
Id_Customer ASC
)
go

create index RELATIONSHIP_138_FK on FLC_Customer_Zones (
Id_Region ASC,
Id_Zone ASC
)
go

alter table FLC_Customer_Zones
   add constraint FK_FLC_Customers_CustomerZones foreign key (Id_Customer)
      references FLC_Cat_Customers (Id_Customer)
go

alter table FLC_Customer_Zones
   add constraint FK_FLC_RegionZone_CustomerZone foreign key (Id_Region, Id_Zone)
      references Cat_Region_Zones (Id_Region, Id_Zone)
go
