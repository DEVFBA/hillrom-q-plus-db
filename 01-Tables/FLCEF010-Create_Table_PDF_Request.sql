use DBQS
if exists (select 1
            from  sysobjects
           where  id = object_id('FLC_PDF_Requests')
            and   type = 'U')
   drop table FLC_PDF_Requests
go

/*==============================================================*/
/* Table: FLC_PDF_Requests                                      */
/*==============================================================*/
create table FLC_PDF_Requests (
   Folio                int                  not null,
   Modality             varchar(50)          not null,
   Cluster              varchar(100)         null,
   Distributor          varchar(100)         null,
   Initial_Date         datetime             not null,
   Final_Date           datetime             null,
   [Path]               varchar(1000)             null,
   [Status]               bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_FLC_PDF_REQUESTS primary key nonclustered (Folio)
)
go
