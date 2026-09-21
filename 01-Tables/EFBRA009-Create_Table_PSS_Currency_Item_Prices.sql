USE DBQS
GO

/*==============================================================*/
/* Table: PSS_Currency_Item_Prices                        */
/*==============================================================*/

IF EXISTS (
    SELECT 1
    FROM sysobjects
    WHERE id = OBJECT_ID('PSS_Currency_Item_Prices')
      AND type = 'U'
)
    DROP TABLE PSS_Currency_Item_Prices
GO

CREATE TABLE PSS_Currency_Item_Prices (
   Id_Item              varchar(50)          not null,
   Id_Currency          varchar(10)          not null,
   Id_Language          varchar(10)          not null,
   Price                float                not null,
   [Status]             bit                  not null,
   Modify_By            varchar(50)          not null,
   Modify_IP            varchar(20)          not null,
   Modify_Date          datetime             not null,
   CONSTRAINT PK_PSS_Currency_Item_Prices PRIMARY KEY CLUSTERED (Id_Item, Id_Currency, Id_Language)
)
GO

ALTER TABLE PSS_Currency_Item_Prices
   ADD CONSTRAINT FK_PSSCURRIT_CAT_ITEM FOREIGN KEY (Id_Item)
      REFERENCES Cat_Item (Id_Item)
GO

ALTER TABLE PSS_Currency_Item_Prices
   ADD CONSTRAINT FK_PSSCURRIT_CAT_CURRENCIES FOREIGN KEY (Id_Currency, Id_Language)
      REFERENCES Cat_Currencies (Id_Currency, Id_Language)
GO
