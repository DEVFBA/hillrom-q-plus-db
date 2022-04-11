/*
NOTA: HACER PRIMARY KEY 
Cat_File_Types 
	   Id_File_Type         varchar(10)          not null,
	   Id_Language			varchar(10)          not null,
*/
/*==============================================================*/
/* Alter Table: Approved_Discounts                                        */
/*==============================================================*/
IF NOT EXISTS(SELECT *
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'Approved_Discounts'
                 AND COLUMN_NAME = 'Approval_Group') 

	ALTER TABLE Approved_Discounts ADD Approval_Group VARCHAR(20)
GO

/*==============================================================*/
/* Alter Table: Cat_File_Types                                        */
/*==============================================================*/
IF NOT EXISTS(SELECT *
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'Approval_Tracker'
                 AND COLUMN_NAME = 'Apply_File') 

	ALTER TABLE Approval_Tracker ADD Apply_File Bit
GO

UPDATE Approval_Tracker SET Apply_File = 0 

UPDATE Approval_Tracker SET Apply_File = 1 WHERE Id_Role = 'SPAPP' AND Id_Approval_Flow IN (7,8,9)


/* ==================================================================================*/
-- UDT_Security_Access
/* ==================================================================================*/
PRINT 'Crea 1.  UDT_Quotation_Files' 
IF type_id('[dbo].[UDT_Quotation_Files]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Quotation_Files]
GO

CREATE TYPE [dbo].[UDT_Quotation_Files]AS TABLE
(
	Folio                int                null,
	[Version]            smallint			null,
	Id_File_Type         varchar(10)        null,
	Id_File              int				null,
	File_Path            varchar(255)       null,
	Comments             varchar(1000)      null,
	[Modify_By]			[varchar](50)		NULL,
	[Modify_Date]		[datetime]			NULL,
	[Modify_IP]			[varchar](20)		NULL
)
GO

/*==============================================================*/
/* Table: Cat_File_Types                                        */
/*==============================================================*/

	if exists (select 1
	   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
	   where r.fkeyid = object_id('Quotation_Files') and o.name = 'FK_QUOTATIO_FK_TYPEFI_CAT_FILE')
	alter table Quotation_Files
	   drop constraint FK_QUOTATIO_FK_TYPEFI_CAT_FILE
	go

	if exists (select 1
				from  sysobjects
			   where  id = object_id('Cat_File_Types')
				and   type = 'U')
	   drop table Cat_File_Types
	go

	create table Cat_File_Types (
	   Id_File_Type         varchar(10)          not null,
	   Id_Language			varchar(10)          not null,
	   Short_Desc           varchar(50)          not null,
	   [Name]                varchar(255)         not null,
	   Extension            varchar(5)           not null,
	   [Use]                varchar(255)         not null,
	   [Status]               bit                  not null,
	   Modify_By            varchar(50)          not null,
	   Modify_Date          datetime             not null,
	   Modify_IP            varchar(20)          not null,
	   constraint PK_CAT_FILE_TYPES primary key nonclustered (Id_File_Type,Id_Language)
	)
	go

/*==============================================================*/
/* Table: Quotation_Files                                       */
/*==============================================================*/

	if exists (select 1
	   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
	   where r.fkeyid = object_id('Quotation_Files') and o.name = 'FK_Quotation_Files')
	alter table Quotation_Files
	   drop constraint FK_Quotation_Files
	go


	if exists (select 1
				from  sysindexes
			   where  id    = object_id('Quotation_Files')
				and   name  = 'FK_TYPEFILE_QUOTATIONFILE_FK'
				and   indid > 0
				and   indid < 255)
	   drop index Quotation_Files.FK_TYPEFILE_QUOTATIONFILE_FK
	go

	if exists (select 1
				from  sysindexes
			   where  id    = object_id('Quotation_Files')
				and   name  = 'FK_QUOTATION_FILES_FK'
				and   indid > 0
				and   indid < 255)
	   drop index Quotation_Files.FK_QUOTATION_FILES_FK
	go

	if exists (select 1
				from  sysobjects
			   where  id = object_id('Quotation_Files')
				and   type = 'U')
	   drop table Quotation_Files
	go


	create table Quotation_Files (
		Folio                int                  null,
		[Version]            smallint             null,
		Id_File_Type         varchar(10)          not null,
		Id_File              numeric              identity,
		File_Path            varchar(255)         not null,
		Comments             varchar(1000)        null,
		[Modify_By]			[varchar](50)		NOT NULL,
		[Modify_Date]		[datetime]			NOT NULL,
		[Modify_IP]			[varchar](20)		NOT NULL
	   constraint PK_QUOTATION_FILES primary key nonclustered (Id_File)
	)
	go

	/*==============================================================*/
	/* Index: FK_QUOTATION_FILES_FK                                 */
	/*==============================================================*/
	create index FK_QUOTATION_FILES_FK on Quotation_Files (
	Folio ASC,
	Version ASC
	)
	go

	/*==============================================================*/
	/* Index: FK_TYPEFILE_QUOTATIONFILE_FK                          */
	/*==============================================================*/
	create index FK_TYPEFILE_QUOTATIONFILE_FK on Quotation_Files (
	Id_File_Type ASC
	)
	go

	alter table Quotation_Files
	   add constraint FK_Quotation_Files foreign key (Folio, Version)
		  references Quotation (Folio, Version)
	go

