USE DBQS
GO

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Users_Sale_Types') and o.name = 'FK_SalesType_UserSalesType')
alter table Users_Sale_Types
   drop constraint FK_SalesType_UserSalesType
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Users_Sale_Types') and o.name = 'FK_Users_UserSalesType')
alter table Users_Sale_Types
   drop constraint FK_Users_UserSalesType
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Users_Sale_Types')
            and   name  = 'FK_USER_USERSALESTYPE_FK'
            and   indid > 0
            and   indid < 255)
   drop index Users_Sale_Types.FK_USER_USERSALESTYPE_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Users_Sale_Types')
            and   name  = 'FK_SALESTYPE_USERSALESTYPE_FK'
            and   indid > 0
            and   indid < 255)
   drop index Users_Sale_Types.FK_SALESTYPE_USERSALESTYPE_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Users_Sale_Types')
            and   type = 'U')
   drop table Users_Sale_Types
go

/*==============================================================*/
/* Table: Users_Sale_Types                                      */
/*==============================================================*/
create table Users_Sale_Types (
   "User"               varchar(20)          not null,
   Id_Sales_Type        varchar(10)          not null,
   Id_Language          varchar(10)          not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_USERS_SALE_TYPES primary key ("User", Id_Sales_Type, Id_Language)
)
go

/*==============================================================*/
/* Index: FK_SALESTYPE_USERSALESTYPE_FK                         */
/*==============================================================*/
create index FK_SALESTYPE_USERSALESTYPE_FK on Users_Sale_Types (
Id_Language ASC,
Id_Sales_Type ASC
)
go

/*==============================================================*/
/* Index: FK_USER_USERSALESTYPE_FK                              */
/*==============================================================*/
create index FK_USER_USERSALESTYPE_FK on Users_Sale_Types (
"User" ASC
)
go

alter table Users_Sale_Types
   add constraint FK_SalesType_UserSalesType foreign key (Id_Sales_Type, Id_Language )
      references Cat_Sales_Types (Id_Sales_Type, Id_Language )
go

alter table Users_Sale_Types
   add constraint FK_Users_UserSalesType foreign key ("User")
      references Security_Users ("User")
go
