USE DBQS
GO

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('GSS_Categories_Hierarchies') and o.name = 'FK_Category_CategoryHierarchy')
alter table GSS_Categories_Hierarchies
   drop constraint FK_Category_CategoryHierarchy
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('GSS_Categories_Hierarchies')
            and   name  = 'FK_CATEGORY_CATEGORYHIERARCHY_FK'
            and   indid > 0
            and   indid < 255)
   drop index GSS_Categories_Hierarchies.FK_CATEGORY_CATEGORYHIERARCHY_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('GSS_Categories_Hierarchies')
            and   type = 'U')
   drop table GSS_Categories_Hierarchies
go

/*==============================================================*/
/* Table: GSS_Categories_Hierarchies                            */
/*==============================================================*/
create table GSS_Categories_Hierarchies (
   Id_Category_Hierarchy numeric              identity,
   Id_Category          varchar(10)          not null,
   Parent               varchar(5)           not null,
   Level                int                  not null,
   Path                 varchar(1000)        null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_GSS_CATEGORIES_HIERARCHIES primary key nonclustered (Id_Category_Hierarchy)
)
go

/*==============================================================*/
/* Index: FK_CATEGORY_CATEGORYHIERARCHY_FK                      */
/*==============================================================*/
create index FK_CATEGORY_CATEGORYHIERARCHY_FK on GSS_Categories_Hierarchies (
Id_Category ASC
)
go

alter table GSS_Categories_Hierarchies
   add constraint FK_Category_CategoryHierarchy foreign key (Id_Category)
      references GSS_Cat_Categories (Id_Category)
go
