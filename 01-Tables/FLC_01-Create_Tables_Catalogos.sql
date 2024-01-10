USE DBQS
GO

/*==============================================================*/
/* Table: FLC_Cat_Categories                                    */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Cat__Categories_Families') and o.name = 'FK_FLC_Categories_CategFamilies')
alter table FLC_Cat__Categories_Families
   drop constraint FK_FLC_Categories_CategFamilies
go

if exists (select 1
            from  sysobjects
           where  id = object_id('FLC_Cat_Categories')
            and   type = 'U')
   drop table FLC_Cat_Categories
go


create table FLC_Cat_Categories (
   Id_FLC_Category      varchar(10)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Master_Discount      varchar(50)          null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_FLC_CAT_CATEGORIES primary key nonclustered (Id_FLC_Category)
)
go

/*==============================================================*/
/* Table: FLC_Cat_Families                                      */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Cat__Categories_Families') and o.name = 'FK_FLC_Families_CategFamilies')
alter table FLC_Cat__Categories_Families
   drop constraint FK_FLC_Families_CategFamilies
go

if exists (select 1
            from  sysobjects
           where  id = object_id('FLC_Cat_Families')
            and   type = 'U')
   drop table FLC_Cat_Families
go


create table FLC_Cat_Families (
   Id_FLC_Family        varchar(10)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_FLC_CAT_FAMILIES primary key nonclustered (Id_FLC_Family)
)
go

/*==============================================================*/
/* Table: FLC_Cat_Groups                                        */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Cat__Categories_Families') and o.name = 'FK_FLC_Groups_CategFamilies')
alter table FLC_Cat__Categories_Families
   drop constraint FK_FLC_Groups_CategFamilies
go

if exists (select 1
            from  sysobjects
           where  id = object_id('FLC_Cat_Groups')
            and   type = 'U')
   drop table FLC_Cat_Groups
go


create table FLC_Cat_Groups (
   Id_FLC_Group         varchar(10)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_FLC_CAT_GROUPS primary key nonclustered (Id_FLC_Group)
)
go


/*==============================================================*/
/* Table: FLC_Cat__Categories_Families                          */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Cat_Categories_Families') and o.name = 'FK_FLC_Categories_CategFamilies')
alter table FLC_Cat_Categories_Families
   drop constraint FK_FLC_Categories_CategFamilies
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Cat_Categories_Families') and o.name = 'FK_FLC_Families_CategFamilies')
alter table FLC_Cat_Categories_Families
   drop constraint FK_FLC_Families_CategFamilies
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('FLC_Cat_Categories_Families') and o.name = 'FK_FLC_Groups_CategFamilies')
alter table FLC_Cat_Categories_Families
   drop constraint FK_FLC_Groups_CategFamilies
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('FLC_Cat_Categories_Families')
            and   name  = 'FK_FLC_GROUPS_CATEGFAMILIES_FK'
            and   indid > 0
            and   indid < 255)
   drop index FLC_Cat_Categories_Families.FK_FLC_GROUPS_CATEGFAMILIES_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('FLC_Cat_Categories_Families')
            and   name  = 'FK_FLC_FAMILIES_CATEGFAMILIES_FK'
            and   indid > 0
            and   indid < 255)
   drop index FLC_Cat_Categories_Families.FK_FLC_FAMILIES_CATEGFAMILIES_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('FLC_Cat_Categories_Families')
            and   name  = 'FK_FLC_CATEGORIES_CATEGFAMILIES_FK'
            and   indid > 0
            and   indid < 255)
   drop index FLC_Cat_Categories_Families.FK_FLC_CATEGORIES_CATEGFAMILIES_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('FLC_Cat_Categories_Families')
            and   type = 'U')
   drop table FLC_Cat_Categories_Families
go

/*==============================================================*/
/* Table: FLC_Cat_Categories_Families                           */
/*==============================================================*/
create table FLC_Cat_Categories_Families (
   Id_FLC_Category      varchar(10)          not null,
   Id_FLC_Family        varchar(10)          not null,
   Id_FLC_Group         varchar(10)          not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_FLC_CAT_CATEGORIES_FAMILIES primary key (Id_FLC_Category, Id_FLC_Family, Id_FLC_Group)
)
go

/*==============================================================*/
/* Index: FK_FLC_CATEGORIES_CATEGFAMILIES_FK                    */
/*==============================================================*/
create index FK_FLC_CATEGORIES_CATEGFAMILIES_FK on FLC_Cat_Categories_Families (
Id_FLC_Category ASC
)
go

/*==============================================================*/
/* Index: FK_FLC_FAMILIES_CATEGFAMILIES_FK                      */
/*==============================================================*/
create index FK_FLC_FAMILIES_CATEGFAMILIES_FK on FLC_Cat_Categories_Families (
Id_FLC_Family ASC
)
go

/*==============================================================*/
/* Index: FK_FLC_GROUPS_CATEGFAMILIES_FK                        */
/*==============================================================*/
create index FK_FLC_GROUPS_CATEGFAMILIES_FK on FLC_Cat_Categories_Families (
Id_FLC_Group ASC
)
go

alter table FLC_Cat_Categories_Families
   add constraint FK_FLC_Categories_CategFamilies foreign key (Id_FLC_Category)
      references FLC_Cat_Categories (Id_FLC_Category)
go

alter table FLC_Cat_Categories_Families
   add constraint FK_FLC_Families_CategFamilies foreign key (Id_FLC_Family)
      references FLC_Cat_Families (Id_FLC_Family)
go

alter table FLC_Cat_Categories_Families
   add constraint FK_FLC_Groups_CategFamilies foreign key (Id_FLC_Group)
      references FLC_Cat_Groups (Id_FLC_Group)
go
