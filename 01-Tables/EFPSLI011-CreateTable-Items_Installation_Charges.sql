USE DBQS
GO

/*==============================================================*/
/* Table: Items_Installation_Charges                            */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Items_Installation_Charges') and o.name = 'FK_Contries_Items_Install_Chargers')
alter table Items_Installation_Charges
   drop constraint FK_Contries_Items_Install_Chargers
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Items_Installation_Charges') and o.name = 'FK_Item_Items_Install_Chargers')
alter table Items_Installation_Charges
   drop constraint FK_Item_Items_Install_Chargers
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Items_Installation_Charges')
            and   name  = 'FK_ITEM_ITEMS_INSTALL_CHARGERS_FK'
            and   indid > 0
            and   indid < 255)
   drop index Items_Installation_Charges.FK_ITEM_ITEMS_INSTALL_CHARGERS_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Items_Installation_Charges')
            and   name  = 'FK_CONTRIES_ITEMS_INSTALL_CHARGERS_FK'
            and   indid > 0
            and   indid < 255)
   drop index Items_Installation_Charges.FK_CONTRIES_ITEMS_INSTALL_CHARGERS_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Items_Installation_Charges')
            and   type = 'U')
   drop table Items_Installation_Charges
go

/*==============================================================*/
/* CreateTable:												     */
/*==============================================================*/
create table Items_Installation_Charges (
   Id_Country           varchar(10)          not null,
   Id_Item              varchar(50)          not null,
   Id_Installation_Charge varchar(10)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Price                float                not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_ITEMS_INSTALLATION_CHARGES primary key (Id_Country, Id_Item)
)
go

/*==============================================================*/
/* Index: FK_CONTRIES_ITEMS_INSTALL_CHARGERS_FK                 */
/*==============================================================*/
create index FK_CONTRIES_ITEMS_INSTALL_CHARGERS_FK on Items_Installation_Charges (
Id_Country ASC
)
go

/*==============================================================*/
/* Index: FK_ITEM_ITEMS_INSTALL_CHARGERS_FK                     */
/*==============================================================*/
create index FK_ITEM_ITEMS_INSTALL_CHARGERS_FK on Items_Installation_Charges (
Id_Item ASC
)
go

alter table Items_Installation_Charges
   add constraint FK_Contries_Items_Install_Chargers foreign key (Id_Country)
      references Cat_Countries (Id_Country)
go

alter table Items_Installation_Charges
   add constraint FK_Item_Items_Install_Chargers foreign key (Id_Item)
      references Cat_Item (Id_Item)
go
