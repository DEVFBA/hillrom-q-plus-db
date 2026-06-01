USE DBQS;

/*==============================================================*/
/* Drop existing constraints and tables if they exist          */
/*==============================================================*/
-- Drop foreign key constraints first
IF EXISTS (
    SELECT
        1
    FROM
        sys.sysreferences r
        JOIN sys.sysobjects o ON (
            o.id = r.constid
            AND o.type = 'F'
        )
    WHERE
        r.fkeyid = OBJECT_ID ('GSS_Quotation_Detail')
        AND o.name = 'FK_GSSQuotationDetail_GSSQuotation'
)
ALTER TABLE GSS_Quotation_Detail
DROP CONSTRAINT FK_GSSQuotationDetail_GSSQuotation;

IF EXISTS (
    SELECT
        1
    FROM
        sys.sysreferences r
        JOIN sys.sysobjects o ON (
            o.id = r.constid
            AND o.type = 'F'
        )
    WHERE
        r.fkeyid = OBJECT_ID ('GSS_Quotation_Detail')
        AND o.name = 'FK_GSSQuotationDetail_Parent'
)
ALTER TABLE GSS_Quotation_Detail
DROP CONSTRAINT FK_GSSQuotationDetail_Parent;

IF EXISTS (
    SELECT
        1
    FROM
        sys.sysreferences r
        JOIN sys.sysobjects o ON (
            o.id = r.constid
            AND o.type = 'F'
        )
    WHERE
        r.fkeyid = OBJECT_ID ('GSS_Quotation_Detail')
        AND o.name = 'FK_GSSQuotationDetail_GSSCatItem'
)
ALTER TABLE GSS_Quotation_Detail
DROP CONSTRAINT FK_GSSQuotationDetail_GSSCatItem;

-- Drop tables
IF EXISTS (
    SELECT
        1
    FROM
        sysobjects
    WHERE
        id = OBJECT_ID ('GSS_Quotation_Detail')
        AND type = 'U'
)
DROP TABLE GSS_Quotation_Detail;

IF EXISTS (
    SELECT
        1
    FROM
        sysobjects
    WHERE
        id = OBJECT_ID ('GSS_Quotation')
        AND type = 'U'
)
DROP TABLE GSS_Quotation;

/*==============================================================*/
/* Table: GSS_Quotation                                        */
/*==============================================================*/
CREATE TABLE
    GSS_Quotation (
        Folio INT NOT NULL,
        Version SMALLINT NOT NULL,
        Id_Customer_Bill_To INT NULL,
        Id_Customer_Type_Bill_To VARCHAR(10) NULL,
        Id_Country_Bill_To VARCHAR(10) NULL,
        Id_Customer_Final INT NULL,
        Id_Customer_Type_Final VARCHAR(10) NULL,
        Id_Country_Final VARCHAR(10) NULL,
        Id_Incoterm VARCHAR(10) NULL,
        Id_Currency VARCHAR(10) NOT NULL,
        Id_Exchange_Rate SMALLINT NOT NULL,
        Id_Sales_Type VARCHAR(10) NOT NULL,
        Id_Price_List VARCHAR(10) NULL,
        Id_Validity_Price VARCHAR(10) NULL,
        Id_Quotation_Status VARCHAR(10) NOT NULL,
        Sales_Executive VARCHAR(20) NOT NULL,
        Creation_Date DATETIME NOT NULL,
        SPR_Number VARCHAR(50) NULL,
        Purchase_Order INT NULL,
        TTQ_Quote_Number VARCHAR(50),
        Comments VARCHAR(1000) NULL,
        --Id_Language				VARCHAR(10)			NOT NULL,
        Modify_By VARCHAR(50) NOT NULL,
        Modify_Date DATETIME NOT NULL,
        Modify_IP VARCHAR(20) NOT NULL,
        CONSTRAINT PK_GSS_Quotation PRIMARY KEY NONCLUSTERED (Folio, Version)
    );

/*==============================================================*/
/* Table: GSS_Quotation_Detail                                 */
/*==============================================================*/
CREATE TABLE
    GSS_Quotation_Detail (
        Id_Detail BIGINT NOT NULL,
        Folio INT NOT NULL,
        Version SMALLINT NOT NULL,
        Level_Number TINYINT NOT NULL, -- 1, 2, 3, or 4
        Position_Display VARCHAR(50) NOT NULL, -- 1, 1.1, 1.1.1, 1.1.1.1
        Position_Sort VARCHAR(100) NOT NULL, -- For proper sorting: 001.001.001.001
        Id_Parent BIGINT NULL, -- Reference to parent detail record
        Quantity FLOAT NOT NULL,
        Description VARCHAR(500) NOT NULL,
        Unit_Price FLOAT NOT NULL,
        Discount FLOAT NOT NULL,
        Net_Price FLOAT NOT NULL,
        Total_Price FLOAT NOT NULL,
        -- Level 4 specific fields (GSS_Cat_Item integration)
        Id_Item VARCHAR(50) NULL, -- Foreign key to GSS_Cat_Item
        Item_Short_Desc VARCHAR(50) NULL, -- Retrieved from GSS_Cat_Item
        Item_Standard_Cost FLOAT NULL, -- Retrieved from GSS_Cat_Item
        Generic_Item BIT NULL, -- Retrieved from GSS_Cat_Item
        On_Request BIT NULL, -- Retrieved from GSS_Cat_Item
        -- Additional fields
        Notes VARCHAR(500) NULL,
        Modify_By VARCHAR(50) NULL,
        Modify_Date DATETIME NULL,
        Modify_IP VARCHAR(20) NULL,
        CONSTRAINT PK_GSS_Quotation_Detail PRIMARY KEY (Id_Detail)
    );

/*==============================================================*/
/* Indexes                                                      */
/*==============================================================*/
CREATE INDEX IX_GSSQuotationDetail_Header ON GSS_Quotation_Detail (Folio, Version);

CREATE INDEX IX_GSSQuotationDetail_Parent ON GSS_Quotation_Detail (Id_Parent);

CREATE INDEX IX_GSSQuotationDetail_Position ON GSS_Quotation_Detail (Folio, Version, Position_Sort);

CREATE INDEX IX_GSSQuotationDetail_Level ON GSS_Quotation_Detail (Level_Number);

CREATE INDEX IX_GSSQuotationDetail_Item ON GSS_Quotation_Detail (Id_Item);

/*==============================================================*/
/* Foreign Key Constraints                                      */
/*==============================================================*/
ALTER TABLE GSS_Quotation_Detail ADD CONSTRAINT FK_GSSQuotationDetail_GSSQuotation FOREIGN KEY (Folio, Version) REFERENCES GSS_Quotation (Folio, Version);

ALTER TABLE GSS_Quotation_Detail ADD CONSTRAINT FK_GSSQuotationDetail_GSSCatItem FOREIGN KEY (Id_Item) REFERENCES GSS_Cat_Item (Id_Item);

-- GSS_Quotation Foreign Keys
ALTER TABLE GSS_Quotation ADD CONSTRAINT FK_GSSQuotation_CustomerBillTo FOREIGN KEY (
    Id_Customer_Type_Bill_To,
    Id_Country_Bill_To,
    Id_Customer_Bill_To
) REFERENCES GSS_Cat_Customers (Id_Customer_Type, Id_Country, Id_Customer);

ALTER TABLE GSS_Quotation ADD CONSTRAINT FK_GSSQuotation_CustomerFinal FOREIGN KEY (
    Id_Customer_Type_Final,
    Id_Country_Final,
    Id_Customer_Final
) REFERENCES GSS_Cat_Customers (Id_Customer_Type, Id_Country, Id_Customer);

ALTER TABLE GSS_Quotation ADD CONSTRAINT FK_GSSQuotation_ExchangeRate FOREIGN KEY (Id_Currency, Id_Exchange_Rate) REFERENCES Cat_Exchange_Rates (Id_Currency, Id_Exchange_Rate);

ALTER TABLE GSS_Quotation ADD CONSTRAINT FK_GSSQuotation_SalesExecutive FOREIGN KEY (Sales_Executive) REFERENCES Security_Users ("User");