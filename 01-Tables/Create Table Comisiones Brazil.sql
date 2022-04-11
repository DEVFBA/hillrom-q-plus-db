/* ==================================================================================*/
-- UDT_Quotation_Commissions
/* ==================================================================================*/

IF type_id('[dbo].[UDT_Quotation_Commissions]') IS NOT NULL
        DROP TYPE  [dbo].UDT_Quotation_Commissions
GO

CREATE TYPE [dbo].[UDT_Quotation_Commissions]AS TABLE
 (
   Folio                int                  not null,
   [Version]            smallint             not null,
   [Id_Commission]      smallint             not null,
   Percentage           float                not null,
   Amount               float                not null)
GO

/* ==================================================================================*/
-- 9 UDT_Quotation_Header
/* ==================================================================================*/
IF OBJECT_ID('[dbo].[spQuotation_Integration_INS_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_Integration_INS_Records
GO

IF OBJECT_ID('[dbo].[spQuotation_Header_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_Header_CRUD_Records
GO

IF type_id('[dbo].[UDT_Quotation_Header]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Quotation_Header]
GO

CREATE TYPE [dbo].[UDT_Quotation_Header]AS TABLE
 (
	Folio						int                  not null,
	[Version]					smallint             not null,
	Id_Header					bigInt				 not null,
	Item_Template				varchar(50)          not null,
	Discount					float                not null,
	Quantity					smallint             not null,
	Allocation					float                not null,
	Transfer_Price				float                not null,
	Transport_Cost				float                not null,
	Taxes						float                not null,
	Landed_Cost					float                not null,
	Local_Transport				float                not null,
	[Services]					float                not null,
	Warehousing					float                not null,
	Local_Cost					float                not null,
	Final_Price					float                not null,
	Margin						float                not null,
	Total						float                not null,
	Amount_Warranty				float				 null,
	Id_Year_Warranty			smallint			 null,
	Percentage_Warranty			float				 null,
	General_Taxes_Percentage	float				 null,
	General_Taxes_Total			float				 null,
	General_Taxes_Warranty		float				 null,
	Grand_Total					float				 null,
	Item_SPR					varchar				 null,
	Modify_By					varchar(50)          null,
	Modify_Date					datetime             null,
	Modify_IP					varchar(20)          null)
GO


/*==============================================================*/
/* Table: Cat_Countries_Commissions                             */
/*==============================================================*/
	create table Cat_Countries_Commissions (
	   Id_Country           varchar(10)          not null,
	   Id_Language          varchar(10)          not null,
	   Id_Commission        smallint             not null,
	   Short_Desc           varchar(50)          not null,
	   Long_Desc            varchar(255)         not null,
	   Status               bit                  not null,
	   Modify_Date          datetime             not null,
	   Modify_By            varchar(50)          not null,
	   Modify_IP            varchar(20)          not null,
	   constraint PK_CAT_COUNTRIES_COMMISSIONS primary key nonclustered (Id_Language, Id_Country, Id_Commission)
	)
	go


	/* Index: FK_LANGUAGES_COMMISSIONS_FK                           */
	create index FK_LANGUAGES_COMMISSIONS_FK on Cat_Countries_Commissions (
	Id_Language ASC
	)
	go


	/* Index: FK_COUNTRIES_LANGUANGE_FK                             */
	create index FK_COUNTRIES_LANGUANGE_FK on Cat_Countries_Commissions (
	Id_Country ASC
	)
	go

	alter table Cat_Countries_Commissions
	   add constraint FK_CAT_COUN_FK_COUNTR_CAT_COUN2 foreign key (Id_Country)
		  references Cat_Countries (Id_Country)
	go

	

/*==============================================================*/
/* Table: Cat_Countries_Valid_Commissions                       */
/*==============================================================*/
	create table Cat_Countries_Valid_Commissions (
	   Id_Country           varchar(10)          not null,
	   Id_Valid_Commission  smallint             not null,
	   Valid_Percentage     float                not null,
	   Status               bit                  not null,
	   Modify_Date          datetime             not null,
	   Modify_By            varchar(50)          not null,
	   Modify_IP            varchar(20)          not null,
	   constraint PK_CAT_COUNTRIES_VALID_COMMISS primary key nonclustered (Id_Country, Id_Valid_Commission)
	)
	go

	/* Index: FK_CONTRIES_VALIDCOMMISSIONS_FK                       */
	create index FK_CONTRIES_VALIDCOMMISSIONS_FK on Cat_Countries_Valid_Commissions (
	Id_Country ASC
	)
	go

	alter table Cat_Countries_Valid_Commissions
	   add constraint FK_CAT_COUN_FK_CONTRI_CAT_COUN foreign key (Id_Country)
		  references Cat_Countries (Id_Country)
	go


/*==============================================================*/
/* Table: Cat_Line_Taxes                                        */
/*==============================================================*/
	create table Cat_Line_Taxes (
	   Id_Country           varchar(10)          not null,
	   Id_Line              varchar(10)          not null,
	   Percentage           float                not null,
	   Status               bit                  not null,
	   Modify_Date          datetime             not null,
	   Modify_By            varchar(50)          not null,
	   Modify_IP            varchar(20)          not null,
	   constraint PK_CAT_LINE_TAXES primary key nonclustered (Id_Line, Id_Country)
	)
	go

	/*==============================================================*/
	/* Index: FK_LINES_TAXES_FK                                     */
	/*==============================================================*/
	create index FK_LINES_TAXES_FK on Cat_Line_Taxes (
	Id_Line ASC
	)
	go

	/*==============================================================*/
	/* Index: FK_COUNTRIES_TAXES_FK                                 */
	/*==============================================================*/
	create index FK_COUNTRIES_TAXES_FK on Cat_Line_Taxes (
	Id_Country ASC
	)
	go

	alter table Cat_Line_Taxes
	   add constraint FK_CAT_LINE_FK_COUNTR_CAT_COUN foreign key (Id_Country)
		  references Cat_Countries (Id_Country)
	go

	alter table Cat_Line_Taxes
	   add constraint FK_CAT_LINE_FK_LINES__CAT_LINE foreign key (Id_Line)
		  references Cat_Lines (Id_Line)
	go


/*==============================================================*/
/* Table: Quotation_Commissions                                 */
/*==============================================================*/
	create table Quotation_Commissions (
	   Folio                int                  not null,
	   Version              smallint             not null,
	   Id_Commission        smallint             not null,
	   Percentage           float                not null,
	   Amount               float                not null,
	   constraint PK_QUOTATION_COMMISSIONS primary key (Folio, Version, Id_Commission)
	)
	go

	alter table Quotation_Commissions
	   add constraint FK_QUOTATIO_FK_QUOTAT_QUOTATIO3 foreign key (Folio, Version)
		  references Quotation (Folio, Version)
	go

/*==============================================================*/
/* Table: Quotation_Header                                */
/*==============================================================*/
ALTER TABLE Quotation_Header ADD General_Taxes_Percentage	float	null
ALTER TABLE Quotation_Header ADD General_Taxes_Total		float	null
