USE [DBQS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*==============================================================*/
/* Table: Security_Role_Functions                               */
/*==============================================================*/

if exists (select 1
            from  sysindexes
           where  id    = object_id('Security_Role_Functions')
            and   name  = 'FK_ROLE_ROLE_FUNCTIONS_FK'
            and   indid > 0
            and   indid < 255)
   drop index Security_Role_Functions.FK_ROLE_ROLE_FUNCTIONS_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Security_Role_Functions')
            and   type = 'U')
   drop table Security_Role_Functions
go


create table Security_Role_Functions (
   Id_Role              varchar(10)          not null,
   Id_Function          int                  not null,
   Interface_Name       varchar(50)          not null,
   Object_Name          varchar(50)          not null,
   SubObject_Name       varchar(50)          null,
   Visibility           bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_SECURITY_ROLE_FUNCTIONS primary key nonclustered (Id_Role, Id_Function)
)
go

/* Index: FK_ROLE_ROLE_FUNCTIONS_FK                             */

create index FK_ROLE_ROLE_FUNCTIONS_FK on Security_Role_Functions (
Id_Role ASC
)
go
