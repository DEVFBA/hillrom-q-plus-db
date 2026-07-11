USE DBQS
GO

/*==============================================================*/
/* Table: GSS_Cat_Hierarchy_Levels                              */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('GSS_Cat_Categories') and o.name = 'FKHierarchy_Levels_Category')
alter table GSS_Cat_Categories
   drop constraint FKHierarchy_Levels_Category
go

if exists (select 1
            from  sysobjects
           where  id = object_id('GSS_Cat_Hierarchy_Levels')
            and   type = 'U')
   drop table GSS_Cat_Hierarchy_Levels
go

--Table
create table GSS_Cat_Hierarchy_Levels (
   Id_Hierarchy_Level   varchar(10)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Level                int                  not null,
   constraint PK_GSS_CAT_HIERARCHY_LEVELS primary key nonclustered (Id_Hierarchy_Level)
)
go


/*==============================================================*/
/* Table: GSS_Cat_Categories                                    */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('GSS_Cat_Categories') and o.name = 'FKHierarchy_Levels_Category')
alter table GSS_Cat_Categories
   drop constraint FKHierarchy_Levels_Category
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('GSS_Cat_Categories')
            and   name  = 'FKHIERARCHY_LEVELS_CATEGORY_FK'
            and   indid > 0
            and   indid < 255)
   drop index GSS_Cat_Categories.FKHIERARCHY_LEVELS_CATEGORY_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('GSS_Cat_Categories')
            and   type = 'U')
   drop table GSS_Cat_Categories
go


--Table
create table GSS_Cat_Categories (
   Id_Category          varchar(10)          not null,
   Id_Hierarchy_Level   varchar(10)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   PDF_Layout           varchar(255)         null,
   Image_Path           varchar(255)         null,   
   Additional_Desc      varchar(1000)        null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_GSS_CAT_CATEGORIES primary key nonclustered (Id_Category)
)
go

/*==============================================================*/
/* Index: FKHIERARCHY_LEVELS_CATEGORY_FK                        */
/*==============================================================*/
create index FKHIERARCHY_LEVELS_CATEGORY_FK on GSS_Cat_Categories (
Id_Hierarchy_Level ASC
)
go

alter table GSS_Cat_Categories
   add constraint FKHierarchy_Levels_Category foreign key (Id_Hierarchy_Level)
      references GSS_Cat_Hierarchy_Levels (Id_Hierarchy_Level)
go
