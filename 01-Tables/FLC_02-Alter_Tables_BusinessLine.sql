USE DBQS
GO

/*==============================================================*/
/* Table: Cat_Business_Line                                     */
/*==============================================================*/

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_Regions') and o.name = 'FK_BusinessLine_Regions')
alter table Cat_Regions
   drop constraint FK_BusinessLine_Regions
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_Zone_Types') and o.name = 'FK_BusinessLine_ZoneType')
alter table Cat_Zone_Types
   drop constraint FK_BusinessLine_ZoneType
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Security_Roles') and o.name = 'FK_BusinessLine_Role')
alter table Security_Roles
   drop constraint FK_BusinessLine_Role
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_Business_Line')
            and   type = 'U')
   drop table Cat_Business_Line
go


create table Cat_Business_Line (
   Id_Business_Line     varchar(10)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_BUSINESS_LINE primary key nonclustered (Id_Business_Line)
)
go

/*==============================================================*/
/* Alter Table: Security_Roles                                  */
/*==============================================================*/

ALTER TABLE Security_Roles ADD Id_Business_Line  varchar(10)   null

------------------
create index FKBUSINESSLINE_ROLE_FK on Security_Roles (
Id_Business_Line ASC
)
go

alter table Security_Roles
   add constraint FK_BusinessLine_Role foreign key (Id_Business_Line)
      references Cat_Business_Line (Id_Business_Line)
go

/*==============================================================*/
/* Alter Table: Cat_Regions                                  */
/*==============================================================*/

ALTER TABLE Cat_Regions ADD Id_Business_Line  varchar(10)   null

------------------
create index FK_BUSINESSLINE_REGIONS_FK on Cat_Regions (
Id_Business_Line ASC
)
go

alter table Cat_Regions
   add constraint FK_BusinessLine_Regions foreign key (Id_Business_Line)
      references Cat_Business_Line (Id_Business_Line)
go

/*==============================================================*/
/* Alter Table: Security_Roles                                  */
/*==============================================================*/

ALTER TABLE Cat_Zone_Types ADD Id_Business_Line  varchar(10)   null

------------------
create index FK_CATBUSINESSLINE_ZONETYPE_FK on Cat_Zone_Types (
Id_Business_Line ASC
)
go

alter table Cat_Zone_Types
   add constraint FK_BusinessLine_ZoneType foreign key (Id_Business_Line)
      references Cat_Business_Line (Id_Business_Line)
go






/*==============================================================*/
/* Alter Tables: NOT NULL			                             */
/*==============================================================*/

/*
ALTER TABLE Security_Roles
ALTER COLUMN Id_Business_Line  varchar(10)   NOT NULL;

ALTER TABLE Cat_Regions
ALTER COLUMN Id_Business_Line  varchar(10)   NOT NULL;

ALTER TABLE Cat_Zone_Types
ALTER COLUMN Id_Business_Line  varchar(10)   NOT NULL;
*/