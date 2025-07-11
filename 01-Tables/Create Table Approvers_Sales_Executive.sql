USE DBQS

if exists (select 1
            from  sysindexes
           where  id    = object_id('Approvers_Sales_Executive')
            and   name  = 'FK_USER_APROVERS_FK'
            and   indid > 0
            and   indid < 255)
   drop index Approvers_Sales_Executive.FK_USER_APROVERS_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Approvers_Sales_Executive')
            and   type = 'U')
   drop table Approvers_Sales_Executive
go

/*==============================================================*/
/* Table: Approvers_Sales_Executive                             */
/*==============================================================*/
create table Approvers_Sales_Executive (
   "User"               varchar(20)          not null,
   Sales_Executive      varchar(20)          not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_APPROVERS_SALES_EXECUTIVE primary key nonclustered ("User", Sales_Executive)
)
go

/*==============================================================*/
/* Index: FK_USER_APROVERS_FK                                   */
/*==============================================================*/
create index FK_USER_APROVERS_FK on Approvers_Sales_Executive (
"User" ASC
)
go
