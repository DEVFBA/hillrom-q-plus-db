
/*==============================================================*/
/* Table: Cat_Years_Warranty                                    */
/*==============================================================*/

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_Extended_Warranties') and o.name = 'FK_CAT_EXTE_KF_CATYEA_CAT_YEAR')
alter table Cat_Extended_Warranties
   drop constraint FK_CAT_EXTE_KF_CATYEA_CAT_YEAR
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_Years_Warranty')
            and   type = 'U')
   drop table Cat_Years_Warranty
go

create table Cat_Years_Warranty (
   Id_Year_Warranty     smallint             not null,
   Short_Desc           varchar(50)          not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_YEARS_WARRANTY primary key nonclustered (Id_Year_Warranty)
)
go

/*==============================================================*/
/* Table: Cat_Extended_Warranties                               */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_Extended_Warranties') and o.name = 'FK_CAT_EXTE_FK_CATLIN_CAT_LINE')
alter table Cat_Extended_Warranties
   drop constraint FK_CAT_EXTE_FK_CATLIN_CAT_LINE
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_Extended_Warranties') and o.name = 'FK_CAT_EXTE_KF_CATYEA_CAT_YEAR')
alter table Cat_Extended_Warranties
   drop constraint FK_CAT_EXTE_KF_CATYEA_CAT_YEAR
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Cat_Extended_Warranties')
            and   name  = 'FK_CATLINES_CATEXTWARRANTY_FK'
            and   indid > 0
            and   indid < 255)
   drop index Cat_Extended_Warranties.FK_CATLINES_CATEXTWARRANTY_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Cat_Extended_Warranties')
            and   name  = 'KF_CATYEARWARRANTY__CATEXTWARRANTIES_FK'
            and   indid > 0
            and   indid < 255)
   drop index Cat_Extended_Warranties.KF_CATYEARWARRANTY__CATEXTWARRANTIES_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_Extended_Warranties')
            and   type = 'U')
   drop table Cat_Extended_Warranties
go

/*==============================================================*/
/* Table: Cat_Extended_Warranties                               */
/*==============================================================*/
create table Cat_Extended_Warranties (
   Id_Line              varchar(10)          not null,
   Id_Year_Warranty     smallint             not null,
   Percentage_Warranty  float                not null,
   Status               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_EXTENDED_WARRANTIES primary key (Id_Year_Warranty, Id_Line)
)
go

	/*==============================================================*/
	/* Index: KF_CATYEARWARRANTY__CATEXTWARRANTIES_FK               */
	/*==============================================================*/
	create index KF_CATYEARWARRANTY__CATEXTWARRANTIES_FK on Cat_Extended_Warranties (
	Id_Year_Warranty ASC
	)
	go

	/*==============================================================*/
	/* Index: FK_CATLINES_CATEXTWARRANTY_FK                         */
	/*==============================================================*/
	create index FK_CATLINES_CATEXTWARRANTY_FK on Cat_Extended_Warranties (
	Id_Line ASC
	)
	go

	alter table Cat_Extended_Warranties
	   add constraint FK_CAT_EXTE_FK_CATLIN_CAT_LINE foreign key (Id_Line)
		  references Cat_Lines (Id_Line)
	go

	alter table Cat_Extended_Warranties
	   add constraint FK_CAT_EXTE_KF_CATYEA_CAT_YEAR foreign key (Id_Year_Warranty)
		  references Cat_Years_Warranty (Id_Year_Warranty)
	go


/*==============================================================*/
/* Table: Quotation_Header                                      */
/*==============================================================*/
ALTER TABLE Quotation_Header ADD Amount_Warranty      float                null
ALTER TABLE Quotation_Header ADD Id_Year_Warranty     smallint             null
ALTER TABLE Quotation_Header ADD Percentage_Warranty  float                null
ALTER TABLE Quotation_Header ADD Grand_Total          float                null
   
go

	/*==============================================================*/
	/* Index: FK_CATYEARWARRANTY_QUOTATAIONHEADER_FK                */
	/*==============================================================*/
	create index FK_CATYEARWARRANTY_QUOTATAIONHEADER_FK on Quotation_Header (
	Id_Year_Warranty ASC
	)
	go

	alter table Quotation_Header
	   add constraint FK_QUOTATIO_FK_CATYEA_CAT_YEAR foreign key (Id_Year_Warranty)
		  references Cat_Years_Warranty (Id_Year_Warranty)
	go


/* ==================================================================================*/
-- 9 UDT_Quotation_Header
/* ==================================================================================*/
PRINT 'Crea 9  UDT_Quotation_Header' 
IF type_id('[dbo].[UDT_Quotation_Header]') IS NOT NULL
		DROP PROCEDURE spQuotation_Header_CRUD_Records
		DROP PROCEDURE spQuotation_Integration_Ins_Records
		DROP TYPE  [dbo].[UDT_Quotation_Header]
GO

CREATE TYPE [dbo].[UDT_Quotation_Header]AS TABLE
	(
	Folio                int                  not null,
	Version              smallint             not null,
	Id_Header            BigInt				  not null,
	Item_Template        varchar(50)          not null,
	Discount             float                not null,
	Quantity             smallint             not null,
	Allocation           float                not null,
	Transfer_Price       float                not null,
	Transport_Cost       float                not null,
	Taxes                float                not null,
	Landed_Cost          float                not null,
	Local_Transport      float                not null,
	Services             float                not null,
	Warehousing          float                not null,
	Local_Cost           float                not null,
	Final_Price          float                not null,
	Total                float                not null,
	Margin               float                not null,
	Amount_Warranty      float                not null,
	Id_Year_Warranty     smallint             null,
	Percentage_Warranty  float                null,
	Grand_Total          float                not null,
	Item_SPR             varchar(50)          null,
	Modify_By            varchar(50)          not null,
	Modify_Date          datetime             not null,
	Modify_IP            varchar(20)          not null
	)
GO
	