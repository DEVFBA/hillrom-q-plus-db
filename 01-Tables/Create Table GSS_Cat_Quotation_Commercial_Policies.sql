/*==============================================================*/
/* Table: GSS_Cat_Quotation_Commercial_Policies                 */
/*==============================================================*/

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('GSS_Cat_Quotation_Commercial_Policies') and o.name = 'FK_GSS_Countries_ContrIesSalesType')
alter table GSS_Cat_Quotation_Commercial_Policies
   drop constraint FK_GSS_Countries_ContrIesSalesType
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('GSS_Cat_Quotation_Commercial_Policies')
            and   name  = 'FK_GSS_INCOTERM_QCOMMERCIALPOLICES_FK'
            and   indid > 0
            and   indid < 255)
   drop index GSS_Cat_Quotation_Commercial_Policies.FK_GSS_INCOTERM_QCOMMERCIALPOLICES_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('GSS_Cat_Quotation_Commercial_Policies')
            and   name  = 'FK_GSS_CURRENCIES_QCOMMERCIALPOLICES_FK'
            and   indid > 0
            and   indid < 255)
   drop index GSS_Cat_Quotation_Commercial_Policies.FK_GSS_CURRENCIES_QCOMMERCIALPOLICES_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('GSS_Cat_Quotation_Commercial_Policies')
            and   name  = 'FK_GSS_COUNTRIES_CONTRIESSALESTYPE_FK'
            and   indid > 0
            and   indid < 255)
   drop index GSS_Cat_Quotation_Commercial_Policies.FK_GSS_COUNTRIES_CONTRIESSALESTYPE_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('GSS_Cat_Quotation_Commercial_Policies')
            and   name  = 'FK_GSS_SALESTYPE_CONTRIESSALESTYPE_FK'
            and   indid > 0
            and   indid < 255)
   drop index GSS_Cat_Quotation_Commercial_Policies.FK_GSS_SALESTYPE_CONTRIESSALESTYPE_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('GSS_Cat_Quotation_Commercial_Policies')
            and   type = 'U')
   drop table GSS_Cat_Quotation_Commercial_Policies
go

/*==============================================================*/
/* Table: GSS_Cat_Quotation_Commercial_Policies                 */
/*==============================================================*/
create table GSS_Cat_Quotation_Commercial_Policies (
   Id_Country           varchar(10)          not null,
   Id_Sales_Type        varchar(10)          not null,
   Id_Incoterm          varchar(10)          not null,
   Id_Currency          varchar(10)          not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_GSS_CAT_QUOTATION_COMMERCIAL_PO primary key nonclustered (Id_Currency, Id_Sales_Type, Id_Incoterm, Id_Country)
)
go

/*==============================================================*/
/* Index: FK_GSS_SALESTYPE_CONTRIESSALESTYPE_FK                 */
/*==============================================================*/
create index FK_GSS_SALESTYPE_CONTRIESSALESTYPE_FK on GSS_Cat_Quotation_Commercial_Policies (
Id_Sales_Type ASC
)
go

/*==============================================================*/
/* Index: FK_GSS_COUNTRIES_CONTRIESSALESTYPE_FK                 */
/*==============================================================*/
create index FK_GSS_COUNTRIES_CONTRIESSALESTYPE_FK on GSS_Cat_Quotation_Commercial_Policies (
Id_Country ASC
)
go

/*==============================================================*/
/* Index: FK_GSS_CURRENCIES_QCOMMERCIALPOLICES_FK               */
/*==============================================================*/
create index FK_GSS_CURRENCIES_QCOMMERCIALPOLICES_FK on GSS_Cat_Quotation_Commercial_Policies (
Id_Currency ASC
)
go

/*==============================================================*/
/* Index: FK_GSS_INCOTERM_QCOMMERCIALPOLICES_FK                 */
/*==============================================================*/
create index FK_GSS_INCOTERM_QCOMMERCIALPOLICES_FK on GSS_Cat_Quotation_Commercial_Policies (
Id_Incoterm ASC
)
go

alter table GSS_Cat_Quotation_Commercial_Policies
   add constraint FK_GSS_Countries_ContrIesSalesType foreign key (Id_Country)
      references Cat_Countries (Id_Country)
go
