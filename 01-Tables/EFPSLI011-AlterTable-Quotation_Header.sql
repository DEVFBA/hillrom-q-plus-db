USE DBQS
GO

IF EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE Name = 'Id_Installation_Charge' AND Object_ID = OBJECT_ID('dbo.Quotation_Header')
)
    ALTER TABLE dbo.Quotation_Header DROP COLUMN Id_Installation_Charge;
go

IF EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE Name = 'Installation_Charges_Price' AND Object_ID = OBJECT_ID('dbo.Quotation_Header')
)
    ALTER TABLE dbo.Quotation_Header DROP COLUMN Installation_Charges_Price;
go


ALTER TABLE Quotation_Header ADD Id_Installation_Charge			VARCHAR(10) NULL
ALTER TABLE Quotation_Header ADD Installation_Charges_Price		FLOAT		NULL
go

SP_HELP Quotation_Header
GO

/* ACTIVAR NULOS

ALTER TABLE Quotation_Header 
ALTER COLUMN Id_Installation_Charge VARCHAR(10) NOT NULL;

ALTER TABLE Quotation_Header 
ALTER COLUMN Installation_Charges_Price FLOAT NOT NULL;

*/
