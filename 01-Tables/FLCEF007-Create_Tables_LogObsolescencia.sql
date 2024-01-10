USE DBQS
GO

/*==============================================================*/
/* Table: FLC_Log_Item_Obsolescence                             */
/*==============================================================*/
if exists (select 1
            from  sysobjects
           where  id = object_id('FLC_Log_Item_Obsolescence')
            and   type = 'U')
   drop table FLC_Log_Item_Obsolescence
go


create table FLC_Log_Item_Obsolescence (
   Id_Transaction_Log   numeric              NOT NULL,
   Id_Item              varchar(50)          not null
)
go
