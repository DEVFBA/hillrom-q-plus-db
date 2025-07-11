USE DBQS
GO

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Approved_Discounts') and o.name = 'FK_SalesType_ApprovedDiscounts')
alter table Approved_Discounts
   drop constraint FK_SalesType_ApprovedDiscounts
go


if exists (select 1
            from  sysindexes
           where  id    = object_id('Approved_Discounts')
            and   name  = 'FK_SALESTYPE_APPROVALDISCOUNTS_FK'
            and   indid > 0
            and   indid < 255)
   drop index Approved_Discounts.FK_SALESTYPE_APPROVALDISCOUNTS_FK
go

/*==============================================================*/
/* Alter Table: Approved_Discounts                                    */
/*==============================================================*/

IF EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE Name = 'Id_Language' AND Object_ID = OBJECT_ID('dbo.Approved_Discounts')
)
BEGIN
    ALTER TABLE dbo.Approved_Discounts DROP COLUMN Id_Language;
END

IF EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE Name = 'Id_Sales_Type' AND Object_ID = OBJECT_ID('dbo.Approved_Discounts')
)
BEGIN
    ALTER TABLE dbo.Approved_Discounts DROP COLUMN Id_Sales_Type;
END

ALTER TABLE Approved_Discounts ADD Id_Language varchar(10);
ALTER TABLE Approved_Discounts ADD Id_Sales_Type varchar(10);

/*==============================================================*/
/* Index: FK_SALESTYPE_APPROVALDISCOUNTS_FK                     */
/*==============================================================*/
create index FK_SALESTYPE_APPROVALDISCOUNTS_FK on Approved_Discounts (
Id_Language ASC,
Id_Sales_Type ASC
)
go


alter table Approved_Discounts
   add constraint FK_SalesType_ApprovedDiscounts foreign key (Id_Sales_Type,Id_Language)
      references Cat_Sales_Types (Id_Sales_Type,Id_Language)
go

/* ACTIVAR NULOS

ALTER TABLE Approved_Discounts 
ALTER COLUMN Id_Sales_Type varchar(10) NOT NULL;

ALTER TABLE Approved_Discounts 
ALTER COLUMN Id_Language varchar(10) NOT NULL;

*/