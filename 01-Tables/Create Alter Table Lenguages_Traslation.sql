
/*==============================================================*/
/* Table: Cat_Countries_Languages                               */
/*==============================================================*/
	ALTER TABLE Cat_Countries_Languages
	   ADD Default_Translation   bit                  null
	go


/*==============================================================*/
/* Table: Quotation                               */
/*==============================================================*/
	ALTER TABLE Quotation
	   ADD Id_Language_Translation varchar(10)          null
	go



	/* Index: FK_LENGUAJETRASLATE_QUOTATION_FK                      */
	if exists (select 1
				from  sysindexes
			   where  id    = object_id('Quotation')
				and   name  = 'FK_LENGUAJETRASLATE_QUOTATION_FK'
				and   indid > 0
				and   indid < 255)
	   drop index Quotation.FK_LENGUAJETRASLATE_QUOTATION_FK
	go

	create index FK_LENGUAJETRASLATE_QUOTATION_FK on Quotation (
	Id_Language_Translation ASC
	)
	go


	/* Constraint: FK_QUOTATIO_FK_LENGUA_CAT_LANG                      */
	if exists (select 1
	   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
	   where r.fkeyid = object_id('Quotation') and o.name = 'FK_QUOTATIO_FK_LENGUA_CAT_LANG')
	alter table Quotation
	  drop constraint FK_QUOTATIO_FK_LENGUA_CAT_LANG
	go

	alter table Quotation
	   add constraint FK_QUOTATIO_FK_LENGUA_CAT_LANG foreign key (Id_Language_Translation)
		  references Cat_Languages (Id_Language)
	go

/*==============================================================*/
/* Table: Cat_Reports_Lenguages                                 */
/*==============================================================*/
	if exists (select 1
	   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
	   where r.fkeyid = object_id('Cat_Reports_Lenguages') and o.name = 'FK_CAT_REPO_FK_CATLAN_CAT_LANG')
	alter table Cat_Reports_Lenguages
	   drop constraint FK_CAT_REPO_FK_CATLAN_CAT_LANG
	go

	if exists (select 1
				from  sysindexes
			   where  id    = object_id('Cat_Reports_Lenguages')
				and   name  = 'FK_CATLANGUAGES_REPORTS_FK'
				and   indid > 0
				and   indid < 255)
	   drop index Cat_Reports_Lenguages.FK_CATLANGUAGES_REPORTS_FK
	go

	if exists (select 1
				from  sysobjects
			   where  id = object_id('Cat_Reports_Lenguages')
				and   type = 'U')
	   drop table Cat_Reports_Lenguages
	go

	/* Table: Cat_Reports_Lenguages                                 */
	create table Cat_Reports_Lenguages (
	   Id_Report            varchar(10)          not null,
	   Id_Language          varchar(10)          not null,
	   Short_Desc           varchar(50)          not null,
	   RptName              varchar(50)          not null,
	   Status               bit                  not null,
	   Modify_By            varchar(50)          not null,
	   Modify_Date          datetime             not null,
	   Modify_IP            varchar(20)          not null,
	   constraint PK_CAT_REPORTS_LENGUAGES primary key nonclustered (Id_Language, Id_Report)
	)
	go

	/* Index: FK_CATLANGUAGES_REPORTS_FK                            */
	create index FK_CATLANGUAGES_REPORTS_FK on Cat_Reports_Lenguages (
	Id_Language ASC
	)
	go

	alter table Cat_Reports_Lenguages
	   add constraint FK_CAT_REPO_FK_CATLAN_CAT_LANG foreign key (Id_Language)
		  references Cat_Languages (Id_Language)
	go

/*==============================================================*/
/* Table: Lenguages_Traslation                                  */
/*==============================================================*/
	if exists (select 1
	   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
	   where r.fkeyid = object_id('Lenguages_Translation') and o.name = 'FK_LENGUAGE_FK_CATLEN_CAT_LANG')
	alter table Lenguages_Translation
	   drop constraint FK_LENGUAGE_FK_CATLEN_CAT_LANG
	go

	if exists (select 1
				from  sysindexes
			   where  id    = object_id('Lenguages_Translation')
				and   name  = 'FK_CATLENGUAGE_TRASLATION_FK'
				and   indid > 0
				and   indid < 255)
	   drop index Lenguages_Translation.FK_CATLENGUAGE_TRASLATION_FK
	go

	if exists (select 1
				from  sysobjects
			   where  id = object_id('Lenguages_Translation')
				and   type = 'U')
	   drop table Lenguages_Translation
	go

	/* Table: Lenguages_Translation                                 */
	create table Lenguages_Translation (
	   Id_Translation       int                  not null,
	   Id_Language          varchar(10)          not null,
	   Interface_Name       varchar(50)          not null,
	   [Object_Name]        varchar(50)          not null,
	   SubObject_Name       varchar(50)          null,
	   Translation          varchar(MAX)         not null,
	   Modify_By            varchar(50)          not null,
	   Modify_Date          datetime             not null,
	   Modify_IP            varchar(20)          not null,
	   constraint PK_LENGUAGES_TRANSLATION primary key nonclustered (Id_Translation)
	)
	go


	/* Index: FK_CATLENGUAGE_TRASLATION_FK                          */

	create index FK_CATLENGUAGE_TRASLATION_FK on Lenguages_Translation (
	Id_Language ASC
	)
	go

	alter table Lenguages_Translation
	   add constraint FK_LENGUAGE_FK_CATLEN_CAT_LANG foreign key (Id_Language)
		  references Cat_Languages (Id_Language)
	go
