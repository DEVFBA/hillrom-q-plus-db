USE DBQS
GO

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('GSS_Operation_Cost') and o.name = 'FK_Countries_GSSOperationCost')
alter table GSS_Operation_Cost
   drop constraint FK_Countries_GSSOperationCost
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('GSS_Operation_Cost') and o.name = 'FK_GSSItem_GSSOperationCost')
alter table GSS_Operation_Cost
   drop constraint FK_GSSItem_GSSOperationCost
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('GSS_Operation_Cost')
            and   name  = 'IDX_COUNTRIES_GSSOPERATIONCOST_FK'
            and   indid > 0
            and   indid < 255)
   drop index GSS_Operation_Cost.IDX_COUNTRIES_GSSOPERATIONCOST_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('GSS_Operation_Cost')
            and   name  = 'IDX_GSSITEM_GSSOPERATIONCOST_FK'
            and   indid > 0
            and   indid < 255)
   drop index GSS_Operation_Cost.IDX_GSSITEM_GSSOPERATIONCOST_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('GSS_Operation_Cost')
            and   type = 'U')
   drop table GSS_Operation_Cost
go

/*==============================================================*/
/* Table: GSS_Operation_Cost                                    */
/*==============================================================*/
create table GSS_Operation_Cost (
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
   Modify_IP            varchar(20)          not null,
   constraint PK_GSS_OPERATION_COST primary key (Id_Item, Id_Country)
)
go

/*==============================================================*/
/* Index: IDX_GSSITEM_GSSOPERATIONCOST_FK                       */
/*==============================================================*/
create index IDX_GSSITEM_GSSOPERATIONCOST_FK on GSS_Operation_Cost (
Id_Item ASC
)
go

/*==============================================================*/
/* Index: IDX_COUNTRIES_GSSOPERATIONCOST_FK                     */
/*==============================================================*/
create index IDX_COUNTRIES_GSSOPERATIONCOST_FK on GSS_Operation_Cost (
Id_Country ASC
)
go

alter table GSS_Operation_Cost
   add constraint FK_Countries_GSSOperationCost foreign key (Id_Country)
      references Cat_Countries (Id_Country)
go

alter table GSS_Operation_Cost
   add constraint FK_GSSItem_GSSOperationCost foreign key (Id_Item)
      references GSS_Cat_Item (Id_Item)
go
