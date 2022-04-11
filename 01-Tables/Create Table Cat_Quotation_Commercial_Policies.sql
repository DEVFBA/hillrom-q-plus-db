
/*==============================================================*/
/* Table: Cat_Quotation_Commercial_Policies                     */
/*==============================================================*/

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_Quotation_Commercial_Policies') and o.name = 'FK_Countries_ContrIesSalesType')
alter table Cat_Quotation_Commercial_Policies
   drop constraint FK_Countries_ContrIesSalesType
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Cat_Quotation_Commercial_Policies')
            and   name  = 'FK_INCOTERM_QCOMMERCIALPOLICES_FK'
            and   indid > 0
            and   indid < 255)
   drop index Cat_Quotation_Commercial_Policies.FK_INCOTERM_QCOMMERCIALPOLICES_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Cat_Quotation_Commercial_Policies')
            and   name  = 'FK_CURRENCIES_QCOMMERCIALPOLICES_FK'
            and   indid > 0
            and   indid < 255)
   drop index Cat_Quotation_Commercial_Policies.FK_CURRENCIES_QCOMMERCIALPOLICES_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Cat_Quotation_Commercial_Policies')
            and   name  = 'FK_COUNTRIES_CONTRIESSALESTYPE_FK'
            and   indid > 0
            and   indid < 255)
   drop index Cat_Quotation_Commercial_Policies.FK_COUNTRIES_CONTRIESSALESTYPE_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Cat_Quotation_Commercial_Policies')
            and   name  = 'FK_SALESTYPE_CONTRIESSALESTYPE_FK'
            and   indid > 0
            and   indid < 255)
   drop index Cat_Quotation_Commercial_Policies.FK_SALESTYPE_CONTRIESSALESTYPE_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_Quotation_Commercial_Policies')
            and   type = 'U')
   drop table Cat_Quotation_Commercial_Policies
go

/*==============================================================*/
/* Table: Cat_Quotation_Commercial_Policies                     */
/*==============================================================*/
create table Cat_Quotation_Commercial_Policies (
   Id_Country           varchar(10)          not null,
   Id_Sales_Type        varchar(10)          not null,
   Id_Incoterm          varchar(10)          not null,
   Id_Currency          varchar(10)          not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_QUOTATION_COMMERCIAL_PO primary key nonclustered (Id_Currency, Id_Sales_Type, Id_Incoterm, Id_Country)
)
go

/*==============================================================*/
/* Index: FK_SALESTYPE_CONTRIESSALESTYPE_FK                     */
/*==============================================================*/
create index FK_SALESTYPE_CONTRIESSALESTYPE_FK on Cat_Quotation_Commercial_Policies (
Id_Sales_Type ASC
)
go

/*==============================================================*/
/* Index: FK_COUNTRIES_CONTRIESSALESTYPE_FK                     */
/*==============================================================*/
create index FK_COUNTRIES_CONTRIESSALESTYPE_FK on Cat_Quotation_Commercial_Policies (
Id_Country ASC
)
go

/*==============================================================*/
/* Index: FK_CURRENCIES_QCOMMERCIALPOLICES_FK                   */
/*==============================================================*/
create index FK_CURRENCIES_QCOMMERCIALPOLICES_FK on Cat_Quotation_Commercial_Policies (
Id_Currency ASC
)
go

/*==============================================================*/
/* Index: FK_INCOTERM_QCOMMERCIALPOLICES_FK                     */
/*==============================================================*/
create index FK_INCOTERM_QCOMMERCIALPOLICES_FK on Cat_Quotation_Commercial_Policies (
Id_Incoterm ASC
)
go

alter table Cat_Quotation_Commercial_Policies
   add constraint FK_Countries_ContrIesSalesType foreign key (Id_Country)
      references Cat_Countries (Id_Country)
go

/*
alter table Cat_Quotation_Commercial_Policies
   add constraint FK_Currencies_QCommercialPolices foreign key (Cat_Id_Language2, Id_Currency)
      references Cat_Currencies (Id_Language, Id_Currency)
go

alter table Cat_Quotation_Commercial_Policies
   add constraint FK_Incoterm_QCommercialPolices foreign key (Cat_Id_Language, Id_Incoterm)
      references Cat_Incoterm (Id_Language, Id_Incoterm)
go

alter table Cat_Quotation_Commercial_Policies
   add constraint FK_SalesType_ContrIesSalesType foreign key (Id_Language, Id_Sales_Type)
      references Cat_Sales_Types (Id_Language, Id_Sales_Type)
go
*/