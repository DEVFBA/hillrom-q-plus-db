
/*==============================================================*/
/* Table: Cat_Payment_Terms                                     */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_Payment_Terms') and o.name = 'FK_AppFlow_PaymentTerm')
alter table Cat_Payment_Terms
   drop constraint FK_AppFlow_PaymentTerm
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_Payment_Terms') and o.name = 'FK_Language_PaymTerms')
alter table Cat_Payment_Terms
   drop constraint FK_Language_PaymTerms
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Quotation') and o.name = 'FK_PaymentTer_Quotation')
alter table Quotation
   drop constraint FK_PaymentTer_Quotation
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Cat_Payment_Terms')
            and   name  = 'FK_APPFLOW_PAYMENTTERM_FK'
            and   indid > 0
            and   indid < 255)
   drop index Cat_Payment_Terms.FK_APPFLOW_PAYMENTTERM_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Cat_Payment_Terms')
            and   name  = 'FK_LANGUAGE_PAYMTERMS_FK'
            and   indid > 0
            and   indid < 255)
   drop index Cat_Payment_Terms.FK_LANGUAGE_PAYMTERMS_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_Payment_Terms')
            and   type = 'U')
   drop table Cat_Payment_Terms
go

create table Cat_Payment_Terms (
   Id_Language          varchar(10)          not null,
   Id_Payment_Term      varchar(10)          not null,
   Id_Approval_Flow     smallint             null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_PAYMENT_TERMS primary key nonclustered (Id_Language, Id_Payment_Term)
)
go

/* Index: FK_LANGUAGE_PAYMTERMS_FK                              */
create index FK_LANGUAGE_PAYMTERMS_FK on Cat_Payment_Terms (
Id_Language ASC
)
go

/* Index: FK_APPFLOW_PAYMENTTERM_FK                             */
create index FK_APPFLOW_PAYMENTTERM_FK on Cat_Payment_Terms (
Id_Approval_Flow ASC
)
go

alter table Cat_Payment_Terms
   add constraint FK_AppFlow_PaymentTerm foreign key (Id_Approval_Flow)
      references Cat_Approvals_Flows (Id_Approval_Flow)
go

/* PK Correcta (Id_Language, Id_Language_Translation)
alter table Cat_Payment_Terms
   add constraint FK_Language_PaymTerms foreign key (Id_Language)
      references Cat_Languages (Id_Language)
go
*/



/*==============================================================*/
/* Table: Quotation                                             */
/*==============================================================*/

IF NOT EXISTS(SELECT *
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'Quotation'
                 AND COLUMN_NAME = 'Id_Payment_Term') 

	ALTER TABLE Quotation ADD Id_Payment_Term      varchar(10)          null
GO
