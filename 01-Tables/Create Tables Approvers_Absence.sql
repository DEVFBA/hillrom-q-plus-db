
/*==============================================================*/
/* Table: Cat_Absence_Reasons                                   */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Approvers_Absence') and o.name = 'FK_APPROVER_FK_CATABS_CAT_ABSE')
alter table Approvers_Absence
   drop constraint FK_APPROVER_FK_CATABS_CAT_ABSE
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_Absence_Reasons')
            and   type = 'U')
   drop table Cat_Absence_Reasons
go

create table Cat_Absence_Reasons (
   Id_Absence_Reasons   smallint             not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_ABSENCE_REASONS primary key nonclustered (Id_Absence_Reasons)
)
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Approvers_Absence') and o.name = 'FK_APPROVER_FK_CATABS_CAT_ABSE')
alter table Approvers_Absence
   drop constraint FK_APPROVER_FK_CATABS_CAT_ABSE
go


/*==============================================================*/
/* Table: Approvers_Absence                                     */
/*==============================================================*/
if exists (select 1
            from  sysindexes
           where  id    = object_id('Approvers_Absence')
            and   name  = 'FK_CATABSENCEREASONS_APPROVERS_ABSENCES_FK'
            and   indid > 0
            and   indid < 255)
   drop index Approvers_Absence.FK_CATABSENCEREASONS_APPROVERS_ABSENCES_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Approvers_Absence')
            and   type = 'U')
   drop table Approvers_Absence
go


create table Approvers_Absence (
   Id_Approvers_Absence numeric              identity,
   Id_Absence_Reasons   smallint             not null,
   Absence_User         varchar(20)          not null,
   Backup_User          varchar(20)          not null,
   Initial_Effective_Date datetime           not null,
   Final_Effective_Date datetime             not null,
   Explanation			varchar(1000)		 null,
   Register_Date        datetime             not null,
 
   constraint PK_APPROVERS_ABSENCE primary key nonclustered (Id_Approvers_Absence)
)
go

/*==============================================================*/
/* Index: FK_CATABSENCEREASONS_APPROVERS_ABSENCES_FK            */
/*==============================================================*/
create index FK_CATABSENCEREASONS_APPROVERS_ABSENCES_FK on Approvers_Absence (
Id_Absence_Reasons ASC
)
go

alter table Approvers_Absence
   add constraint FK_APPROVER_FK_CATABS_CAT_ABSE foreign key (Id_Absence_Reasons)
      references Cat_Absence_Reasons (Id_Absence_Reasons)
go
