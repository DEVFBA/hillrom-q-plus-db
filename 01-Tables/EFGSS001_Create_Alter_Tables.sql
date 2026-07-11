
/*==============================================================*/
/* Table: Cat_Role_Types                                        */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Security_Roles') and o.name = 'FK_Role_Types_Roles')
alter table Security_Roles
   drop constraint FK_Role_Types_Roles
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_Role_Types')
            and   type = 'U')
   drop table Cat_Role_Types
go


--Table
create table Cat_Role_Types (
   Id_Role_Type         varchar(10)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_ROLE_TYPES primary key nonclustered (Id_Role_Type)
)
go


/*==============================================================*/
/* Table: Security_Roles                                        */
/*==============================================================*/



/* DROP constraint and  Index: FK_Role_Types_Roles */

	if exists (select 1
	   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
	   where r.fkeyid = object_id('Security_Roles') and o.name = 'FK_Role_Types_Roles')
	alter table Security_Roles
	   drop constraint FK_Role_Types_Roles
	go

	if exists (select 1
				from  sysindexes
			   where  id    = object_id('Security_Roles')
				and   name  = 'FK_ROLE_TYPES_ROLES_FK'
				and   indid > 0
				and   indid < 255)
	   drop index Security_Roles.FK_ROLE_TYPES_ROLES_FK
	go


	IF EXISTS (
		SELECT 1 
		FROM sys.columns 
		WHERE Name = 'Id_Role_Type' AND Object_ID = OBJECT_ID('dbo.Security_Roles')
	)
		ALTER TABLE dbo.Security_Roles DROP COLUMN Id_Role_Type


                              
/* Alter Tables: NOT NULL			                             */
	ALTER TABLE Security_Roles ADD Id_Role_Type		VARCHAR(10)          NULL

--ALTER TABLE Security_Roles ALTER COLUMN DynamicField_DefaultValue		VARCHAR(25) NOT NULL;


/* CREATE constraint and  Index: FK_Role_Types_Roles  */

	create index FK_ROLE_TYPES_ROLES_FK on Security_Roles (
	Id_Role_Type ASC
	)
	go

	alter table Security_Roles
	   add constraint FK_Role_Types_Roles foreign key (Id_Role_Type)
		  references Cat_Role_Types (Id_Role_Type)
	go




