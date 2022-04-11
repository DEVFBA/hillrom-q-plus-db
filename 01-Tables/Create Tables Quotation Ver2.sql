/***************************************************/
-- DELETE TABLES
/***************************************************/
DROP TABLE Approval_Workflow
DROP TABLE Quotation_Detail
DROP TABLE Quotation_Header
DROP TABLE Quotation

/*==============================================================*/
/* Table: Quotation                                             */
/*==============================================================*/
		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation') and o.name = 'FK_QUOTATIO_FK_CATCUS_CAT_CUST')
		alter table Quotation
		   drop constraint FK_QUOTATIO_FK_CATCUS_CAT_CUST
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation') and o.name = 'FK_QUOTATIO_FK_CATCUS_CAT_CUST2')
		alter table Quotation
		   drop constraint FK_QUOTATIO_FK_CATCUS_CAT_CUST2
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation') and o.name = 'FK_QUOTATIO_FK_CATEXC_CAT_EXCH')
		alter table Quotation
		   drop constraint FK_QUOTATIO_FK_CATEXC_CAT_EXCH
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation') and o.name = 'FK_QUOTATIO_FK_CATINC_CAT_INCO')
		alter table Quotation
		   drop constraint FK_QUOTATIO_FK_CATINC_CAT_INCO
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation') and o.name = 'FK_QUOTATIO_FK_CATLAN_CAT_LANG')
		alter table Quotation
		   drop constraint FK_QUOTATIO_FK_CATLAN_CAT_LANG
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation') and o.name = 'FK_QUOTATIO_FK_CATPLU_CAT_PLUG')
		alter table Quotation
		   drop constraint FK_QUOTATIO_FK_CATPLU_CAT_PLUG
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation') and o.name = 'FK_QUOTATIO_FK_CATPRI_CAT_PRIC')
		alter table Quotation
		   drop constraint FK_QUOTATIO_FK_CATPRI_CAT_PRIC
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation') and o.name = 'FK_QUOTATIO_FK_CATQUO_CAT_QUOT')
		alter table Quotation
		   drop constraint FK_QUOTATIO_FK_CATQUO_CAT_QUOT
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation') and o.name = 'FK_QUOTATIO_FK_CATSAL_CAT_SALE')
		alter table Quotation
		   drop constraint FK_QUOTATIO_FK_CATSAL_CAT_SALE
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation') and o.name = 'FK_QUOTATIO_FK_CATVAL_CAT_VALI')
		alter table Quotation
		   drop constraint FK_QUOTATIO_FK_CATVAL_CAT_VALI
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation') and o.name = 'FK_QUOTATIO_FK_CATVOL_CAT_VOLT')
		alter table Quotation
		   drop constraint FK_QUOTATIO_FK_CATVOL_CAT_VOLT
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation') and o.name = 'FK_QUOTATIO_FK_USERSA_SECURITY')
		alter table Quotation
		   drop constraint FK_QUOTATIO_FK_USERSA_SECURITY
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation_Header') and o.name = 'FK_QUOTATIO_FK_QUOTAT_QUOTATIO2')
		alter table Quotation_Header
		   drop constraint FK_QUOTATIO_FK_QUOTAT_QUOTATIO2
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation_Log') and o.name = 'FK_QUOTATIO_FK_QUOTAT_QUOTATIO')
		alter table Quotation_Log
		   drop constraint FK_QUOTATIO_FK_QUOTAT_QUOTATIO
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation_Questionnaire') and o.name = 'FK_QUOTATIO_FK_QUOTAT_QUOTATIO4')
		alter table Quotation_Questionnaire
		   drop constraint FK_QUOTATIO_FK_QUOTAT_QUOTATIO4
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Quotation')
					and   name  = 'FK_CATVALIDITYPRICE_QUOTATION_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Quotation.FK_CATVALIDITYPRICE_QUOTATION_FK
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Quotation')
					and   name  = 'FK_CATINCOTERM_QUOTATION_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Quotation.FK_CATINCOTERM_QUOTATION_FK
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Quotation')
					and   name  = 'FK_USERSALEEXECUTIVE_QUOTATION_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Quotation.FK_USERSALEEXECUTIVE_QUOTATION_FK
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Quotation')
					and   name  = 'FK_CATCUSTOMERFINAL_QUOTATION_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Quotation.FK_CATCUSTOMERFINAL_QUOTATION_FK
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Quotation')
					and   name  = 'FK_CATQUOTATIONSTATUS_QUOTATION_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Quotation.FK_CATQUOTATIONSTATUS_QUOTATION_FK
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Quotation')
					and   name  = 'FK_CATEXCHANGERATE_QUOTATION_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Quotation.FK_CATEXCHANGERATE_QUOTATION_FK
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Quotation')
					and   name  = 'FK_CATPRICELIST_QUOTATION_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Quotation.FK_CATPRICELIST_QUOTATION_FK
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Quotation')
					and   name  = 'FK_CATVOLTAGE_QUOTATION_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Quotation.FK_CATVOLTAGE_QUOTATION_FK
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Quotation')
					and   name  = 'FK_CATPLUG_QUOTATION_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Quotation.FK_CATPLUG_QUOTATION_FK
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Quotation')
					and   name  = 'FK_CATLANGUAJE_QUOTATION_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Quotation.FK_CATLANGUAJE_QUOTATION_FK
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Quotation')
					and   name  = 'FK_CATCUSTOMER_QUOTATION_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Quotation.FK_CATCUSTOMER_QUOTATION_FK
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Quotation')
					and   name  = 'FK_CATSALESTYPE_QUOTATION_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Quotation.FK_CATSALESTYPE_QUOTATION_FK
		go

		if exists (select 1
					from  sysobjects
				   where  id = object_id('Quotation')
					and   type = 'U')
		   drop table Quotation
		go

		/*==============================================================*/
		/* Table: Quotation                                             */
		/*==============================================================*/
		create table Quotation (
		   Folio                int                  not null,
		   Version              smallint             not null,
		   Id_Customer_Bill_To  int                  not null,
		   Id_Customer_Type_Bill_To varchar(10)          not null,
		   Id_Country_Bill_To   varchar(10)          not null,
		   Id_Customer_Final    int                  not null,
		   Id_Customer_Type_Final varchar(10)          not null,
		   Id_Country_Final     varchar(10)          not null,
		   Id_Voltage           varchar(10)          not null,
		   Id_Language          varchar(10)          not null,
		   Id_Plug              varchar(10)          not null,
		   Id_Incoterm          varchar(10)          not null,
		   Id_Currency          varchar(10)          not null,
		   Id_Exchange_Rate     smallint             not null,
		   Id_Sales_Type        varchar(10)          not null,
		   Id_Price_List        varchar(10)          not null,
		   Id_Validity_Price    varchar(10)          not null,
		   Id_Quotation_Status  varchar(10)          not null,
		   Sales_Executive      varchar(20)          not null,
		   Creation_Date        datetime             not null,
		   SPR_Number           varchar(50)          null,
		   Purchase_Order       int                  null,
		   Comments             varchar(1000)        null,
		   Modify_By            varchar(50)          not null,
		   Modify_Date          datetime             not null,
		   Modify_IP            varchar(20)          not null,
		   constraint PK_QUOTATION primary key nonclustered (Folio, Version)
		)
		go

		/*==============================================================*/
		/* Index: FK_CATSALESTYPE_QUOTATION_FK                          */
		/*==============================================================*/
		create index FK_CATSALESTYPE_QUOTATION_FK on Quotation (
		Id_Sales_Type ASC
		)
		go

		/*==============================================================*/
		/* Index: FK_CATCUSTOMER_QUOTATION_FK                           */
		/*==============================================================*/
		create index FK_CATCUSTOMER_QUOTATION_FK on Quotation (
		Id_Customer_Type_Final ASC,
		Id_Country_Final ASC,
		Id_Customer_Final ASC
		)
		go

		/*==============================================================*/
		/* Index: FK_CATLANGUAJE_QUOTATION_FK                           */
		/*==============================================================*/
		create index FK_CATLANGUAJE_QUOTATION_FK on Quotation (
		Id_Language ASC
		)
		go

		/*==============================================================*/
		/* Index: FK_CATPLUG_QUOTATION_FK                               */
		/*==============================================================*/
		create index FK_CATPLUG_QUOTATION_FK on Quotation (
		Id_Plug ASC
		)
		go

		/*==============================================================*/
		/* Index: FK_CATVOLTAGE_QUOTATION_FK                            */
		/*==============================================================*/
		create index FK_CATVOLTAGE_QUOTATION_FK on Quotation (
		Id_Voltage ASC
		)
		go

		/*==============================================================*/
		/* Index: FK_CATPRICELIST_QUOTATION_FK                          */
		/*==============================================================*/
		create index FK_CATPRICELIST_QUOTATION_FK on Quotation (
		Id_Price_List ASC
		)
		go

		/*==============================================================*/
		/* Index: FK_CATEXCHANGERATE_QUOTATION_FK                       */
		/*==============================================================*/
		create index FK_CATEXCHANGERATE_QUOTATION_FK on Quotation (
		Id_Currency ASC,
		Id_Exchange_Rate ASC
		)
		go

		/*==============================================================*/
		/* Index: FK_CATQUOTATIONSTATUS_QUOTATION_FK                    */
		/*==============================================================*/
		create index FK_CATQUOTATIONSTATUS_QUOTATION_FK on Quotation (
		Id_Quotation_Status ASC
		)
		go

		/*==============================================================*/
		/* Index: FK_CATCUSTOMERFINAL_QUOTATION_FK                      */
		/*==============================================================*/
		create index FK_CATCUSTOMERFINAL_QUOTATION_FK on Quotation (
		Id_Customer_Type_Bill_To ASC,
		Id_Country_Bill_To ASC,
		Id_Customer_Bill_To ASC
		)
		go

		/*==============================================================*/
		/* Index: FK_USERSALEEXECUTIVE_QUOTATION_FK                     */
		/*==============================================================*/
		create index FK_USERSALEEXECUTIVE_QUOTATION_FK on Quotation (
		Sales_Executive ASC
		)
		go

		/*==============================================================*/
		/* Index: FK_CATINCOTERM_QUOTATION_FK                           */
		/*==============================================================*/
		create index FK_CATINCOTERM_QUOTATION_FK on Quotation (
		Id_Incoterm ASC
		)
		go

		/*==============================================================*/
		/* Index: FK_CATVALIDITYPRICE_QUOTATION_FK                      */
		/*==============================================================*/
		create index FK_CATVALIDITYPRICE_QUOTATION_FK on Quotation (
		Id_Validity_Price ASC
		)
		go

		alter table Quotation
		   add constraint FK_QUOTATIO_FK_CATCUS_CAT_CUST foreign key (Id_Customer_Type_Bill_To, Id_Country_Bill_To, Id_Customer_Bill_To)
			  references Cat_Customers (Id_Customer_Type, Id_Country, Id_Customer)
		go

		alter table Quotation
		   add constraint FK_QUOTATIO_FK_CATCUS_CAT_CUST2 foreign key (Id_Customer_Type_Final, Id_Country_Final, Id_Customer_Final)
			  references Cat_Customers (Id_Customer_Type, Id_Country, Id_Customer)
		go

		alter table Quotation
		   add constraint FK_QUOTATIO_FK_CATEXC_CAT_EXCH foreign key (Id_Currency, Id_Exchange_Rate)
			  references Cat_Exchange_Rates (Id_Currency, Id_Exchange_Rate)
		go

		alter table Quotation
		   add constraint FK_QUOTATIO_FK_CATINC_CAT_INCO foreign key (Id_Incoterm)
			  references Cat_Incoterm (Id_Incoterm)
		go

		alter table Quotation
		   add constraint FK_QUOTATIO_FK_CATLAN_CAT_LANG foreign key (Id_Language)
			  references Cat_Languages (Id_Language)
		go

		alter table Quotation
		   add constraint FK_QUOTATIO_FK_CATPLU_CAT_PLUG foreign key (Id_Plug)
			  references Cat_Plugs (Id_Plug)
		go

		alter table Quotation
		   add constraint FK_QUOTATIO_FK_CATPRI_CAT_PRIC foreign key (Id_Price_List)
			  references Cat_Prices_Lists (Id_Price_List)
		go

		alter table Quotation
		   add constraint FK_QUOTATIO_FK_CATQUO_CAT_QUOT foreign key (Id_Quotation_Status)
			  references Cat_Quotation_Status (Id_Quotation_Status)
		go

		alter table Quotation
		   add constraint FK_QUOTATIO_FK_CATSAL_CAT_SALE foreign key (Id_Sales_Type)
			  references Cat_Sales_Types (Id_Sales_Type)
		go

		alter table Quotation
		   add constraint FK_QUOTATIO_FK_CATVAL_CAT_VALI foreign key (Id_Validity_Price)
			  references Cat_Validity_Prices (Id_Validity_Price)
		go

		alter table Quotation
		   add constraint FK_QUOTATIO_FK_CATVOL_CAT_VOLT foreign key (Id_Voltage)
			  references Cat_Voltages (Id_Voltage)
		go

		alter table Quotation
		   add constraint FK_QUOTATIO_FK_USERSA_SECURITY foreign key (Sales_Executive)
			  references Security_Users ("User")
		go


/*==============================================================*/
/* Table: Quotation_Header                                      */
/*==============================================================*/

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Approval_Workflow') and o.name = 'FK_APPROVAL_FK_QHEADE_QUOTATIO')
		alter table Approval_Workflow
		   drop constraint FK_APPROVAL_FK_QHEADE_QUOTATIO
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation_Detail') and o.name = 'FK_QUOTATIO_FK_QHEADE_QUOTATIO')
		alter table Quotation_Detail
		   drop constraint FK_QUOTATIO_FK_QHEADE_QUOTATIO
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation_Header') and o.name = 'FK_QUOTATIO_FK_CATITE_CAT_ITEM2')
		alter table Quotation_Header
		   drop constraint FK_QUOTATIO_FK_CATITE_CAT_ITEM2
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation_Header') and o.name = 'FK_QUOTATIO_FK_QUOTAT_QUOTATIO2')
		alter table Quotation_Header
		   drop constraint FK_QUOTATIO_FK_QUOTAT_QUOTATIO2
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Quotation_Header')
					and   name  = 'FK_CATITEM_QHEADER_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Quotation_Header.FK_CATITEM_QHEADER_FK
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Quotation_Header')
					and   name  = 'FK_QUOTATION_QHEADER_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Quotation_Header.FK_QUOTATION_QHEADER_FK
		go

		if exists (select 1
					from  sysobjects
				   where  id = object_id('Quotation_Header')
					and   type = 'U')
		   drop table Quotation_Header
		go

		/*==============================================================*/
		/* Table: Quotation_Header                                      */
		/*==============================================================*/
		create table Quotation_Header (
		   Folio                int                  not null,
		   Version              smallint             not null,
		   Id_Header            smallint             not null,
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
		   Modify_By            varchar(50)          not null,
		   Modify_Date          datetime             not null,
		   Modify_IP            varchar(20)          not null,
		   constraint PK_QUOTATION_HEADER primary key (Folio, Version, Item_Template, Id_Header)
		)
		go

		/*==============================================================*/
		/* Index: FK_QUOTATION_QHEADER_FK                               */
		/*==============================================================*/
		create index FK_QUOTATION_QHEADER_FK on Quotation_Header (
		Folio ASC,
		Version ASC
		)
		go

		/*==============================================================*/
		/* Index: FK_CATITEM_QHEADER_FK                                 */
		/*==============================================================*/
		create index FK_CATITEM_QHEADER_FK on Quotation_Header (
		Item_Template ASC
		)
		go

		alter table Quotation_Header
		   add constraint FK_QUOTATIO_FK_CATITE_CAT_ITEM2 foreign key (Item_Template)
			  references Cat_Item (Id_Item)
		go

		alter table Quotation_Header
		   add constraint FK_QUOTATIO_FK_QUOTAT_QUOTATIO2 foreign key (Folio, Version)
			  references Quotation (Folio, Version)
		go


/*==============================================================*/
/* Table: Quotation_Detail                                      */
/*==============================================================*/

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation_Detail') and o.name = 'FK_QUOTATIO_FK_CATITE_CAT_ITEM')
		alter table Quotation_Detail
		   drop constraint FK_QUOTATIO_FK_CATITE_CAT_ITEM
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Quotation_Detail') and o.name = 'FK_QUOTATIO_FK_QHEADE_QUOTATIO')
		alter table Quotation_Detail
		   drop constraint FK_QUOTATIO_FK_QHEADE_QUOTATIO
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Quotation_Detail')
					and   name  = 'FK_QHEADER_QDETAIL_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Quotation_Detail.FK_QHEADER_QDETAIL_FK
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Quotation_Detail')
					and   name  = 'FK_CATITEM_QDETAIL_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Quotation_Detail.FK_CATITEM_QDETAIL_FK
		go

		if exists (select 1
					from  sysobjects
				   where  id = object_id('Quotation_Detail')
					and   type = 'U')
		   drop table Quotation_Detail
		go

		/*==============================================================*/
		/* Table: Quotation_Detail                                      */
		/*==============================================================*/
		create table Quotation_Detail (
		   Folio                int                  not null,
		   Version              smallint             not null,
		   Id_Header            smallint             not null,
		   Item_Template        varchar(50)          not null,
		   Id_Detail            smallint             not null,
		   Id_Item              varchar(50)          not null,
		   Quantity             smallint             not null,
		   Price                float                not null,
		   Standard_Cost        float                not null,
		   Kit_Items_Desc       varchar(255)         null,
		   Kit_Price            float                null,
		   Kit_Standard_Cost    float                null,
		   Modify_By            varchar(50)          not null,
		   Modify_Date          datetime             not null,
		   Modify_IP            varchar(20)          not null,
		   constraint PK_QUOTATION_DETAIL primary key nonclustered (Folio, Version, Item_Template, Id_Header, Id_Detail)
		)
		go

		/*==============================================================*/
		/* Index: FK_CATITEM_QDETAIL_FK                                 */
		/*==============================================================*/
		create index FK_CATITEM_QDETAIL_FK on Quotation_Detail (
		Id_Item ASC
		)
		go

		/*==============================================================*/
		/* Index: FK_QHEADER_QDETAIL_FK                                 */
		/*==============================================================*/
		create index FK_QHEADER_QDETAIL_FK on Quotation_Detail (
		Folio ASC,
		Version ASC,
		Item_Template ASC,
		Id_Header ASC
		)
		go

		alter table Quotation_Detail
		   add constraint FK_QUOTATIO_FK_CATITE_CAT_ITEM foreign key (Id_Item)
			  references Cat_Item (Id_Item)
		go

		alter table Quotation_Detail
		   add constraint FK_QUOTATIO_FK_QHEADE_QUOTATIO foreign key (Folio, Version, Item_Template, Id_Header)
			  references Quotation_Header (Folio, Version, Item_Template, Id_Header)
		go


/*==============================================================*/
/* Table: Approval_Workflow                                     */
/*==============================================================*/
		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Approval_Workflow') and o.name = 'FK_APPROVAL_FK_APPROV_APPROVAL')
		alter table Approval_Workflow
		   drop constraint FK_APPROVAL_FK_APPROV_APPROVAL
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Approval_Workflow') and o.name = 'FK_APPROVAL_FK_CATAPP_CAT_APPR')
		alter table Approval_Workflow
		   drop constraint FK_APPROVAL_FK_CATAPP_CAT_APPR
		go

		if exists (select 1
		   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
		   where r.fkeyid = object_id('Approval_Workflow') and o.name = 'FK_APPROVAL_FK_QHEADE_QUOTATIO')
		alter table Approval_Workflow
		   drop constraint FK_APPROVAL_FK_QHEADE_QUOTATIO
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Approval_Workflow')
					and   name  = 'FK_QHEADER_APPROVALWORKFLOW_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Approval_Workflow.FK_QHEADER_APPROVALWORKFLOW_FK
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Approval_Workflow')
					and   name  = 'FK_APPROVALTRACKER_WORKFLOW_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Approval_Workflow.FK_APPROVALTRACKER_WORKFLOW_FK
		go

		if exists (select 1
					from  sysindexes
				   where  id    = object_id('Approval_Workflow')
					and   name  = 'FK_CATAPPROVALSTATUS_WORKFLOW_FK'
					and   indid > 0
					and   indid < 255)
		   drop index Approval_Workflow.FK_CATAPPROVALSTATUS_WORKFLOW_FK
		go

		if exists (select 1
					from  sysobjects
				   where  id = object_id('Approval_Workflow')
					and   type = 'U')
		   drop table Approval_Workflow
		go

		/*==============================================================*/
		/* Table: Approval_Workflow                                     */
		/*==============================================================*/
		create table Approval_Workflow (
		   Id_Approval_Workflow numeric              identity,
		   Folio                int                  not null,
		   Version              smallint             not null,
		   Id_Header            smallint             not null,
		   Item_Template        varchar(50)          not null,
		   Id_Approval_Flow     smallint             not null,
		   Id_Role              varchar(10)          not null,
		   Id_Approval_Status   varchar(10)          not null,
		   Approval_Flow_Sequence smallint             null,
		   Comments             varchar(1000)        null,
		   Modify_By            varchar(50)          not null,
		   Modify_Date          datetime             not null,
		   Modify_IP            varchar(20)          not null,
		   constraint PK_APPROVAL_WORKFLOW primary key nonclustered (Folio, Version, Item_Template, Id_Header, Id_Approval_Workflow)
		)
		go

		/*==============================================================*/
		/* Index: FK_CATAPPROVALSTATUS_WORKFLOW_FK                      */
		/*==============================================================*/
		create index FK_CATAPPROVALSTATUS_WORKFLOW_FK on Approval_Workflow (
		Id_Approval_Status ASC
		)
		go

		/*==============================================================*/
		/* Index: FK_APPROVALTRACKER_WORKFLOW_FK                        */
		/*==============================================================*/
		create index FK_APPROVALTRACKER_WORKFLOW_FK on Approval_Workflow (
		Id_Role ASC,
		Id_Approval_Flow ASC
		)
		go

		/*==============================================================*/
		/* Index: FK_QHEADER_APPROVALWORKFLOW_FK                        */
		/*==============================================================*/
		create index FK_QHEADER_APPROVALWORKFLOW_FK on Approval_Workflow (
		Folio ASC,
		Version ASC,
		Item_Template ASC,
		Id_Header ASC
		)
		go

		alter table Approval_Workflow
		   add constraint FK_APPROVAL_FK_APPROV_APPROVAL foreign key (Id_Role, Id_Approval_Flow)
			  references Approval_Tracker (Id_Role, Id_Approval_Flow)
		go

		alter table Approval_Workflow
		   add constraint FK_APPROVAL_FK_CATAPP_CAT_APPR foreign key (Id_Approval_Status)
			  references Cat_Approval_Status (Id_Approval_Status)
		go

		alter table Approval_Workflow
		   add constraint FK_APPROVAL_FK_QHEADE_QUOTATIO foreign key (Folio, Version, Item_Template, Id_Header)
			  references Quotation_Header (Folio, Version, Item_Template, Id_Header)
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
	   [Version]            smallint             not null,
	   Id_Header			Bigint				 not null,
	   Item_Template        varchar(50)          not null,
	   Discount             float                not null,
	   Quantity             smallint             not null,
	   Allocation           float                not null,
	   Transfer_Price       float                not null,
	   Transport_Cost       float                not null,
	   Taxes                float                not null,
	   Landed_Cost          float                not null,
	   Local_Transport      float                not null,
	   [Services]           float                not null,
	   Warehousing          float                not null,
	   Local_Cost           float                not null,
	   Final_Price          float                not null,
	   Total                float                not null,
	   Margin               float                not null,
	   Modify_By            varchar(50)          null,
	   Modify_Date          datetime             null,
	   Modify_IP            varchar(20)          null)
	GO




/* ==================================================================================*/
-- 10 UDT_Quotation_Detail
/* ==================================================================================*/
	PRINT 'Crea 10  UDT_Quotation_Detail' 
	IF type_id('[dbo].[UDT_Quotation_Detail]') IS NOT NULL
			DROP PROCEDURE spQuotation_Detail_CRUD_Records
			DROP PROCEDURE spQuotation_Integration_Ins_Records
			DROP TYPE  [dbo].[UDT_Quotation_Detail]

	GO

	CREATE TYPE [dbo].[UDT_Quotation_Detail]AS TABLE
	 (
	   Folio                int                  not null,
	   [Version]            smallint             not null,
	   Id_Header			Bigint			 not null,
	   Item_Template        varchar(50)          not null,
	   Id_Detail            smallint             not null,
	   Id_Item              varchar(50)          not null,
	   Quantity             smallint             not null,
	   Price                float                not null,
	   Standard_Cost        float                not null,
	   Kit_Items_Desc       varchar(255)		 null,
	   Kit_Price            float                null,
	   Kit_Standard_Cost    float                null,
	   Modify_By            varchar(50)          null,
	   Modify_Date          datetime             null,
	   Modify_IP            varchar(20)          null)
	GO
