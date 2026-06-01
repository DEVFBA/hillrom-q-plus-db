/*==============================================================*/
/* Currency FK support                                           */
/*==============================================================*/

-- Remove leftover index/statistics name collisions
IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('GSS_Cat_Item')
      AND name = 'FK_CATCURRENCIES_GSSCATITEM_FK'
)
    DROP INDEX FK_CATCURRENCIES_GSSCATITEM_FK ON GSS_Cat_Item;
GO

IF EXISTS (
    SELECT 1
    FROM sys.stats
    WHERE object_id = OBJECT_ID('GSS_Cat_Item')
      AND name = 'FK_CATCURRENCIES_GSSCATITEM_FK'
)
    DROP STATISTICS GSS_Cat_Item.FK_CATCURRENCIES_GSSCATITEM_FK;
GO

-- Case 1: parent key is (Id_Language, Id_Currency)
IF EXISTS (
    SELECT 1
    FROM sys.indexes i
    JOIN sys.index_columns ic1 ON ic1.object_id = i.object_id AND ic1.index_id = i.index_id AND ic1.key_ordinal = 1
    JOIN sys.columns c1 ON c1.object_id = ic1.object_id AND c1.column_id = ic1.column_id
    JOIN sys.index_columns ic2 ON ic2.object_id = i.object_id AND ic2.index_id = i.index_id AND ic2.key_ordinal = 2
    JOIN sys.columns c2 ON c2.object_id = ic2.object_id AND c2.column_id = ic2.column_id
    WHERE i.object_id = OBJECT_ID('Cat_Currencies')
      AND i.is_unique = 1
      AND c1.name = 'Id_Language'
      AND c2.name = 'Id_Currency'
)
BEGIN
    CREATE INDEX FK_CATCURRENCIES_GSSCATITEM_FK ON GSS_Cat_Item (Id_Language ASC, Id_Currency ASC);

    ALTER TABLE GSS_Cat_Item
      ADD CONSTRAINT FK_CatCurrencies_GSSCatItem
      FOREIGN KEY (Id_Language, Id_Currency)
      REFERENCES Cat_Currencies (Id_Language, Id_Currency);
END
ELSE
-- Case 2: parent key is (Id_Currency, Id_Language)
IF EXISTS (
    SELECT 1
    FROM sys.indexes i
    JOIN sys.index_columns ic1 ON ic1.object_id = i.object_id AND ic1.index_id = i.index_id AND ic1.key_ordinal = 1
    JOIN sys.columns c1 ON c1.object_id = ic1.object_id AND c1.column_id = ic1.column_id
    JOIN sys.index_columns ic2 ON ic2.object_id = i.object_id AND ic2.index_id = i.index_id AND ic2.key_ordinal = 2
    JOIN sys.columns c2 ON c2.object_id = ic2.object_id AND c2.column_id = ic2.column_id
    WHERE i.object_id = OBJECT_ID('Cat_Currencies')
      AND i.is_unique = 1
      AND c1.name = 'Id_Currency'
      AND c2.name = 'Id_Language'
)
BEGIN
    CREATE INDEX FK_CATCURRENCIES_GSSCATITEM_FK ON GSS_Cat_Item (Id_Currency ASC, Id_Language ASC);

    ALTER TABLE GSS_Cat_Item
      ADD CONSTRAINT FK_CatCurrencies_GSSCatItem
      FOREIGN KEY (Id_Currency, Id_Language)
      REFERENCES Cat_Currencies (Id_Currency, Id_Language);
END
ELSE
BEGIN
    RAISERROR('Cat_Currencies must have a UNIQUE/PK key on (Id_Language, Id_Currency) or (Id_Currency, Id_Language).', 16, 1);
END
GO