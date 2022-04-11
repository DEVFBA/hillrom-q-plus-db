USE DBQS
GO


/*==============================================================*/
/* Table: Cat_Currencies                                             */
/*==============================================================*/

IF NOT EXISTS(SELECT *
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'Cat_Currencies'
                 AND COLUMN_NAME = 'Symbol') 

	ALTER TABLE Cat_Currencies ADD Symbol Varchar(2) NULL
GO
