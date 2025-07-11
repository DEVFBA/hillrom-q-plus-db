USE DBQS
GO

/*==============================================================*/
/* Table: FLC_Temp_Bulk_Upload_Items                             */
/*==============================================================*/
if exists (select 1
            from  sysobjects
           where  id = object_id('FLC_Temp_Bulk_Upload_Items')
            and   type = 'U')
   drop table FLC_Temp_Bulk_Upload_Items
go
CREATE TABLE [dbo].[FLC_Temp_Bulk_Upload_Items](
	[Item_Id] [varchar](50) NOT NULL,
	[Short_Description] [varchar](50) NOT NULL,
	[Long_Description] [varchar](255) NULL,
	[Category_Id] [varchar](10) NOT NULL,
	[Category] [varchar](50) NOT NULL,
	[Group_Id] [varchar](10) NOT NULL,
	[Group] [varchar](50) NOT NULL,
	[Family_Id] [varchar](10) NOT NULL,
	[Family] [varchar](50) NOT NULL,
	[Comment] [varchar](500) NULL,
	[Price] [float] NOT NULL,
	[Standard_Cost] [float] NOT NULL,
	[Discontinue] [bit] NOT NULL,
	[Substitute_Item] [varchar](50) NULL,
	[Current] [bit] NOT NULL
) ON [PRIMARY]
GO
