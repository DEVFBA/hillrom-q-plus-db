
/* ==================================================================================*/
-- 12 UDT_Approval_Workflow
/* ==================================================================================*/

IF OBJECT_ID('[dbo].[spQuotation_ApprovalRoutes_Upd_Workflow]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_ApprovalRoutes_Upd_Workflow
GO


IF type_id('[dbo].[UDT_Approval_Workflow]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Approval_Workflow]
GO

CREATE TYPE [dbo].[UDT_Approval_Workflow]AS TABLE
 (
   Id_Approval_Section  smallint		null,
   Id_Approval_Workflow Numeric			not null,
   Comments             Varchar(1000)   null
  )
GO

/*==============================================================*/
/* Table: Cat_Approval_Country_Incoterms                        */
/*==============================================================*/
	------------------------------------------------------------------
	/* DROP OBJECTS                       */
	if exists (select 1
	   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
	   where r.fkeyid = object_id('Cat_Approval_Country_Incoterms') and o.name = 'FK_CAT_APPR_FK_APPFLO_CAT_APPR')
	alter table Cat_Approval_Country_Incoterms
	   drop constraint FK_CAT_APPR_FK_APPFLO_CAT_APPR
	go

	if exists (select 1
	   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
	   where r.fkeyid = object_id('Cat_Approval_Country_Incoterms') and o.name = 'FK_CAT_APPR_FK_CATINC_CAT_INCO')
	alter table Cat_Approval_Country_Incoterms
	   drop constraint FK_CAT_APPR_FK_CATINC_CAT_INCO
	go

	if exists (select 1
	   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
	   where r.fkeyid = object_id('Cat_Approval_Country_Incoterms') and o.name = 'FK_CAT_APPR_FK_COUNTR_CAT_COUN')
	alter table Cat_Approval_Country_Incoterms
	   drop constraint FK_CAT_APPR_FK_COUNTR_CAT_COUN
	go

	if exists (select 1
				from  sysindexes
			   where  id    = object_id('Cat_Approval_Country_Incoterms')
				and   name  = 'FK_APPFLOWS__APPROVALINCOTERM_FK'
				and   indid > 0
				and   indid < 255)
	   drop index Cat_Approval_Country_Incoterms.FK_APPFLOWS__APPROVALINCOTERM_FK
	go

	if exists (select 1
				from  sysindexes
			   where  id    = object_id('Cat_Approval_Country_Incoterms')
				and   name  = 'FK_COUNTRY_APPROVALINCOTERM_FK'
				and   indid > 0
				and   indid < 255)
	   drop index Cat_Approval_Country_Incoterms.FK_COUNTRY_APPROVALINCOTERM_FK
	go

	if exists (select 1
				from  sysindexes
			   where  id    = object_id('Cat_Approval_Country_Incoterms')
				and   name  = 'FK_CATINCOTERM_APPROVALINCOTERM_FK'
				and   indid > 0
				and   indid < 255)
	   drop index Cat_Approval_Country_Incoterms.FK_CATINCOTERM_APPROVALINCOTERM_FK
	go

	if exists (select 1
				from  sysobjects
			   where  id = object_id('Cat_Approval_Country_Incoterms')
				and   type = 'U')
	   drop table Cat_Approval_Country_Incoterms
	go

	------------------------------------------------------------------
	/* CREATE TABLE                        */
	create table Cat_Approval_Country_Incoterms (
	   Id_Country           varchar(10)          not null,
	   Id_Incoterm          varchar(10)          not null,
	   Id_Approval_Flow     smallint             not null,
	   Status               bit                  not null,
	   Modify_By            varchar(50)          not null,
	   Modify_Date          datetime             not null,
	   Modify_IP            varchar(20)          not null,
	   constraint PK_CAT_APPROVAL_COUNTRY_INCOTE primary key (Id_Incoterm, Id_Country, Id_Approval_Flow)
	)
	go

	------------------------------------------------------------------
	/* CREATE INDEXS                    */
	create index FK_CATINCOTERM_APPROVALINCOTERM_FK on Cat_Approval_Country_Incoterms (Id_Incoterm ASC
	)
	go

	create index FK_COUNTRY_APPROVALINCOTERM_FK on Cat_Approval_Country_Incoterms (Id_Country ASC
	)
	go

	create index FK_APPFLOWS__APPROVALINCOTERM_FK on Cat_Approval_Country_Incoterms (
	Id_Approval_Flow ASC
	)
	go

	------------------------------------------------------------------
	/* CREATE REFERENCES                    */
	alter table Cat_Approval_Country_Incoterms
	   add constraint FK_CAT_APPR_FK_APPFLO_CAT_APPR foreign key (Id_Approval_Flow)
		  references Cat_Approvals_Flows (Id_Approval_Flow)
	go

	alter table Cat_Approval_Country_Incoterms
	   add constraint FK_CAT_APPR_FK_COUNTR_CAT_COUN foreign key (Id_Country)
		  references Cat_Countries (Id_Country)
	go

	/*****
	-- No aplica ya que la PK de Cat_Incoterm es (Id_Language, Id_Incoterm)

	alter table Cat_Approval_Country_Incoterms
	   add constraint FK_CAT_APPR_FK_CATINC_CAT_INCO foreign key (Id_Language, Id_Incoterm)
		  references Cat_Incoterm (Id_Language, Id_Incoterm)
	go
	**/


/*==============================================================*/
/* Table: Cat_Approval_Sections                                 */
/*==============================================================*/
	------------------------------------------------------------------
	/* DROP OBJECTS                       */
	if exists (select 1
	   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
	   where r.fkeyid = object_id('Cat_Approval_Types') and o.name = 'FK_CAT_APPR_FK_APPSEC_CAT_APPR')
	alter table Cat_Approval_Types
	   drop constraint FK_CAT_APPR_FK_APPSEC_CAT_APPR
	go

	if exists (select 1
				from  sysobjects
			   where  id = object_id('Cat_Approval_Sections')
				and   type = 'U')
	   drop table Cat_Approval_Sections
	go

	------------------------------------------------------------------
	/* CREATE TABLE                        */
	create table Cat_Approval_Sections (
	   Id_Approval_Section  smallint             not null,
	   Short_Desc           varchar(50)          not null,
	   Long_Desc            varchar(255)         not null,
	   Workflow_Table       varchar(255)         not null,
	   Status               bit                  not null,
	   Modify_By            varchar(50)          not null,
	   Modify_Date          datetime             not null,
	   Modify_IP            varchar(20)          not null,
	   constraint PK_CAT_APPROVAL_SECTIONS primary key nonclustered (Id_Approval_Section)
	)
	go


/*==============================================================*/
/* Table: Cat_Approval_Types                                    */
/*==============================================================*/
	------------------------------------------------------------------
	/* DROP OBJECTS                       */
	if exists (select 1
	   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
	   where r.fkeyid = object_id('Approval_Workflow_Quotation') and o.name = 'FK_APPROVAL_FK_APPSEC_CAT_APPR')
	alter table Approval_Workflow_Quotation
	   drop constraint FK_APPROVAL_FK_APPSEC_CAT_APPR
	go

	if exists (select 1
	   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
	   where r.fkeyid = object_id('Cat_Approval_Types') and o.name = 'FK_CAT_APPR_FK_APPSEC_CAT_APPR')
	alter table Cat_Approval_Types
	   drop constraint FK_CAT_APPR_FK_APPSEC_CAT_APPR
	go

	if exists (select 1
				from  sysindexes
			   where  id    = object_id('Cat_Approval_Types')
				and   name  = 'FK_APPSECCTIOS_APPTYPES_FK'
				and   indid > 0
				and   indid < 255)
	   drop index Cat_Approval_Types.FK_APPSECCTIOS_APPTYPES_FK
	go

	if exists (select 1
				from  sysobjects
			   where  id = object_id('Cat_Approval_Types')
				and   type = 'U')
	   drop table Cat_Approval_Types
	go

	------------------------------------------------------------------
	/* CREATE TABLE                        */
	create table Cat_Approval_Types (
	   Id_Approval_Section  smallint             not null,
	   Id_Approval_Type     smallint             not null,
	   Short_Desc           varchar(50)          not null,
	   Long_Desc            varchar(255)         not null,
	   Status               bit                  not null,
	   Modify_By            varchar(50)          not null,
	   Modify_Date          datetime             not null,
	   Modify_IP            varchar(20)          not null,
	   constraint PK_CAT_APPROVAL_TYPES primary key nonclustered (Id_Approval_Section, Id_Approval_Type)
	)
	go

	------------------------------------------------------------------
	/* CREATE INDESXS                        */
	create index FK_APPSECCTIOS_APPTYPES_FK on Cat_Approval_Types (
	Id_Approval_Section ASC
	)
	go

	------------------------------------------------------------------
	/* CREATE CONSTRAINTS                        */
	alter table Cat_Approval_Types
	   add constraint FK_CAT_APPR_FK_APPSEC_CAT_APPR foreign key (Id_Approval_Section)
		  references Cat_Approval_Sections (Id_Approval_Section)
	go




/*==============================================================*/
/* Table: Approval_Workflow_Quotation                           */
/*==============================================================*/
	------------------------------------------------------------------
	/* DROP OBJECTS                       */
	if exists (select 1
	   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
	   where r.fkeyid = object_id('Approval_Workflow_Quotation') and o.name = 'FK_APPROVAL_FK_APPSEC_CAT_APPR')
	alter table Approval_Workflow_Quotation
	   drop constraint FK_APPROVAL_FK_APPSEC_CAT_APPR
	go

	if exists (select 1
	   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
	   where r.fkeyid = object_id('Approval_Workflow_Quotation') and o.name = 'FK_APPROVAL_FK_APPSTA_CAT_APPR')
	alter table Approval_Workflow_Quotation
	   drop constraint FK_APPROVAL_FK_APPSTA_CAT_APPR
	go

	if exists (select 1
	   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
	   where r.fkeyid = object_id('Approval_Workflow_Quotation') and o.name = 'FK_APPROVAL_FK_APPTRA_APPROVAL')
	alter table Approval_Workflow_Quotation
	   drop constraint FK_APPROVAL_FK_APPTRA_APPROVAL
	go

	if exists (select 1
	   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
	   where r.fkeyid = object_id('Approval_Workflow_Quotation') and o.name = 'FK_APPROVAL_FK_QUOTAT_QUOTATIO')
	alter table Approval_Workflow_Quotation
	   drop constraint FK_APPROVAL_FK_QUOTAT_QUOTATIO
	go

	if exists (select 1
				from  sysindexes
			   where  id    = object_id('Approval_Workflow_Quotation')
				and   name  = 'FK_APPSTATUS_APPWFQUOTATION_FK'
				and   indid > 0
				and   indid < 255)
	   drop index Approval_Workflow_Quotation.FK_APPSTATUS_APPWFQUOTATION_FK
	go

	if exists (select 1
				from  sysindexes
			   where  id    = object_id('Approval_Workflow_Quotation')
				and   name  = 'FK_APPTRACKER_APPWFQUOTATION_FK'
				and   indid > 0
				and   indid < 255)
	   drop index Approval_Workflow_Quotation.FK_APPTRACKER_APPWFQUOTATION_FK
	go

	if exists (select 1
				from  sysindexes
			   where  id    = object_id('Approval_Workflow_Quotation')
				and   name  = 'FK_QUOTATION_APPWFQUOTATION_FK'
				and   indid > 0
				and   indid < 255)
	   drop index Approval_Workflow_Quotation.FK_QUOTATION_APPWFQUOTATION_FK
	go

	if exists (select 1
				from  sysindexes
			   where  id    = object_id('Approval_Workflow_Quotation')
				and   name  = 'FK_APPSECTIOSTYPES_WFQUOTATION_FK'
				and   indid > 0
				and   indid < 255)
	   drop index Approval_Workflow_Quotation.FK_APPSECTIOSTYPES_WFQUOTATION_FK
	go

	if exists (select 1
				from  sysobjects
			   where  id = object_id('Approval_Workflow_Quotation')
				and   type = 'U')
	   drop table Approval_Workflow_Quotation
	go

	------------------------------------------------------------------
	/* CREATE TABLE                      */
	create table Approval_Workflow_Quotation (
	   Id_Approval_WF_Quotation numeric              identity,
	   Folio                int                  not null,
	   Version              smallint             not null,
	   Id_Approval_Section  smallint             not null,
	   Id_Approval_Type     smallint             not null,
	   Id_Approval_Status   varchar(10)          not null,
	   Id_Approval_Flow     smallint             not null,
	   Id_Role              varchar(10)          not null,
	   Approval_Information varchar(255)         not null,
	   Approval_Flow_Sequence smallint             not null,
	   Comments             varchar(1000)        null,
	   Modify_By            varchar(50)          not null,
	   Modify_Date          datetime             not null,
	   Modify_IP            varchar(20)          not null,
	   constraint PK_APPROVAL_WORKFLOW_QUOTATION primary key nonclustered (Id_Approval_WF_Quotation)
	)
	go

	------------------------------------------------------------------
	/* CREATE INDEXS                      */
	create index FK_APPSECTIOSTYPES_WFQUOTATION_FK on Approval_Workflow_Quotation (
	Id_Approval_Section ASC,
	Id_Approval_Type ASC
	)
	go

	create index FK_QUOTATION_APPWFQUOTATION_FK on Approval_Workflow_Quotation (
	Folio ASC,
	Version ASC
	)
	go

	create index FK_APPTRACKER_APPWFQUOTATION_FK on Approval_Workflow_Quotation (
	Id_Role ASC,
	Id_Approval_Flow ASC
	)
	go

	create index FK_APPSTATUS_APPWFQUOTATION_FK on Approval_Workflow_Quotation (
	Id_Approval_Status ASC
	)
	go


	------------------------------------------------------------------
	/* CREATE INDEXS                      */
	alter table Approval_Workflow_Quotation
	   add constraint FK_APPROVAL_FK_APPSEC_CAT_APPR foreign key (Id_Approval_Section, Id_Approval_Type)
		  references Cat_Approval_Types (Id_Approval_Section, Id_Approval_Type)
	go

	alter table Approval_Workflow_Quotation
	   add constraint FK_APPROVAL_FK_APPSTA_CAT_APPR foreign key (Id_Approval_Status)
		  references Cat_Approval_Status (Id_Approval_Status)
	go

	alter table Approval_Workflow_Quotation
	   add constraint FK_APPROVAL_FK_APPTRA_APPROVAL foreign key (Id_Role, Id_Approval_Flow)
		  references Approval_Tracker (Id_Role, Id_Approval_Flow)
	go

	alter table Approval_Workflow_Quotation
	   add constraint FK_APPROVAL_FK_QUOTAT_QUOTATIO foreign key (Folio, Version)
		  references Quotation (Folio, Version)
	go


/*==============================================================*/
/* INSERTS:									                    */
/*==============================================================*/

--Cat_Approval_Sections
INSERT INTO Cat_Approval_Sections (Id_Approval_Section,Short_Desc,Long_Desc,Workflow_Table,Status,Modify_By,Modify_Date,Modify_IP)
SELECT 1,'Discount','Discount', 'Approval_Workflow',1,'ALZEPEDA',GETDATE(), '0.0.0.0' UNION 
SELECT 2,'Quotation','Quotation', 'Approval_Workflow_Quotation',1,'ALZEPEDA',GETDATE(), '0.0.0.0' 

--Cat_Approval_Types
INSERT INTO Cat_Approval_Types (Id_Approval_Section,Id_Approval_Type,Short_Desc,Long_Desc,Status,Modify_By,Modify_Date,Modify_IP)
SELECT 2,1,'Incoterm', 'Incoterm',1,'ALZEPEDA',GETDATE(), '0.0.0.0'  

SELECT * FROM Cat_Approval_Sections
SELECT * FROM Cat_Approval_Types