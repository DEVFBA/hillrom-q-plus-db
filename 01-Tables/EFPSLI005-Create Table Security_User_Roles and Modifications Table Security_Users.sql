USE DBQS
GO

/*==============================================================*/
/* Script for modifications to the table: Security_Users                                        */
/*==============================================================*/

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Security_Users') and o.name = 'FK_SECURITY_FK_CATZON_CAT_ZONE')
alter table Security_Users
   drop constraint FK_SECURITY_FK_CATZON_CAT_ZONE
go


if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Security_Users') and o.name = 'FK_SECURITY_FK_ROLES__SECURITY2')
alter table Security_Users
   drop constraint FK_SECURITY_FK_ROLES__SECURITY2
go


if exists (select 1
            from  sysindexes
           where  id    = object_id('Security_Users')
            and   name  = 'FK_CATZONE_USERS_FK'
            and   indid > 0
            and   indid < 255)
   drop index Security_Users.FK_CATZONE_USERS_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Security_Users')
            and   name  = 'FK_ROLES_USER_FK'
            and   indid > 0
            and   indid < 255)
   drop index Security_Users.FK_ROLES_USER_FK
go

IF EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE Name = 'Id_Role' AND Object_ID = OBJECT_ID('dbo.Security_Users')
)
    ALTER TABLE dbo.Security_Users DROP COLUMN Id_Role;
go

IF EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE Name = 'Id_Zone' AND Object_ID = OBJECT_ID('dbo.Security_Users')
)
    ALTER TABLE dbo.Security_Users DROP COLUMN Id_Zone;
go

sp_help Security_Users
go


/*==============================================================*/
/* Scripts for creating a new table: Security_User_Roles                                   */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Security_User_Roles') and o.name = 'FK_SECURITY_FK_ROLES_USER_ROLES')
alter table Security_User_Roles
   drop constraint FK_SECURITY_FK_ROLES_USER_ROLES
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Security_User_Roles') and o.name = 'FK_SECURITY_FK_USER_USER_ROLES')
alter table Security_User_Roles
   drop constraint FK_SECURITY_FK_USER_USER_ROLES
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Security_User_Roles') and o.name = 'FK_SECURITY_FK_ZONES_USER_ROLES')
alter table Security_User_Roles
   drop constraint FK_SECURITY_FK_ZONES_USER_ROLES
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Security_User_Roles')
            and   name  = 'FK_ZONES_USERROL_FK'
            and   indid > 0
            and   indid < 255)
   drop index Security_User_Roles.FK_ZONES_USERROL_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Security_User_Roles')
            and   name  = 'FK_ROLES_USERROL_FK'
            and   indid > 0
            and   indid < 255)
   drop index Security_User_Roles.FK_ROLES_USERROL_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Security_User_Roles')
            and   name  = 'FK_USER_USERROL_FK'
            and   indid > 0
            and   indid < 255)
   drop index Security_User_Roles.FK_USER_USERROL_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Security_User_Roles')
            and   type = 'U')
   drop table Security_User_Roles
go

/*==============================================================*/
/* Table: Security_User_Roles                                   */
/*==============================================================*/
create table Security_User_Roles (
   "User"               varchar(20)          not null,
   Id_Role              varchar(10)          not null,
   Id_Zone              varchar(10)          not null,
   Principal            bit                  not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_SECURITY_USER_ROLES primary key ("User", Id_Role)
)
go

/*==============================================================*/
/* Index: FK_USER_USERROL_FK                                    */
/*==============================================================*/
create index FK_USER_USERROL_FK on Security_User_Roles (
"User" ASC
)
go

/*==============================================================*/
/* Index: FK_ROLES_USERROL_FK                                   */
/*==============================================================*/
create index FK_ROLES_USERROL_FK on Security_User_Roles (
Id_Role ASC
)
go

/*==============================================================*/
/* Index: FK_ZONES_USERROL_FK                                   */
/*==============================================================*/
create index FK_ZONES_USERROL_FK on Security_User_Roles (
Id_Zone ASC
)
go

alter table Security_User_Roles
   add constraint FK_SECURITY_FK_ROLES_USER_ROLES foreign key (Id_Role)
      references Security_Roles (Id_Role)
go

alter table Security_User_Roles
   add constraint FK_SECURITY_FK_USER_USER_ROLES foreign key ("User")
      references Security_Users ("User")
go

alter table Security_User_Roles
   add constraint FK_SECURITY_FK_ZONES_USER_ROLES foreign key (Id_Zone)
      references Cat_Zones (Id_Zone)
go

sp_help Security_User_Roles
go