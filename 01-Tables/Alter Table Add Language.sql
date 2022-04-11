USE DBQS


/*==============================================================*/
/* Table: Cat_Customers_Type                                    */
/*==============================================================*/
ALTER TABLE Cat_Customers_Type ADD Id_Language          varchar(10)
GO

CREATE INDEX FK_LANGUANGE_CUSTOMERTYPES_FK on Cat_Customers_Type (Id_Language ASC)
GO

ALTER TABLE Cat_Customers_Type
   add constraint FK_CAT_CUST_FK_LANGUA_CAT_LANG foreign key (Id_Language)
      references Cat_Languages (Id_Language)
GO

UPDATE Cat_Customers_Type
SET Id_Language = 'ANG'
GO

/*==============================================================*/
/* Table: Cat_Prices_Lists                                      */
/*==============================================================*/
ALTER TABLE  Cat_Prices_Lists ADD Id_Language          varchar(10)
GO 

CREATE INDEX FK_LANGUANGE_PRICESLIST_FK on Cat_Prices_Lists (Id_Language ASC)
GO

ALTER TABLE Cat_Prices_Lists
   add constraint FK_CAT_PRIC_FK_LANGUA_CAT_LANG foreign key (Id_Language)
      references Cat_Languages (Id_Language)
GO

UPDATE Cat_Prices_Lists
SET Id_Language = 'ANG'
GO

/*==============================================================*/
/* Table: Cat_Currencies                                        */
/*==============================================================*/
ALTER TABLE  Cat_Currencies ADD Id_Language          varchar(10)
GO

CREATE INDEX FK_LANGUANGE_CURRENCIES_FK on Cat_Currencies (Id_Language ASC)
GO

ALTER TABLE Cat_Currencies
   add constraint FK_CAT_CURR_FK_LANGUA_CAT_LANG foreign key (Id_Language)
      references Cat_Languages (Id_Language)
GO

UPDATE Cat_Currencies
SET Id_Language = 'ANG'
GO

/*==============================================================*/
/* Table: Cat_Quotation_Status                                  */
/*==============================================================*/
ALTER TABLE Cat_Quotation_Status ADD Id_Language          varchar(10)
GO

CREATE INDEX FK_LANGUANGE_QUOTATIONSTS_FK on Cat_Quotation_Status (Id_Language ASC)
GO

ALTER TABLE Cat_Quotation_Status
   add constraint FK_CAT_QUOT_FK_LANGUA_CAT_LANG foreign key (Id_Language)
      references Cat_Languages (Id_Language)
GO

UPDATE Cat_Quotation_Status
SET Id_Language = 'ANG'
GO

/*==============================================================*/
/* Table: Cat_Incoterm                                          */
/*==============================================================*/
ALTER TABLE  Cat_Incoterm ADD Id_Language          varchar(10)
GO

CREATE INDEX FK_LANGUANGE_INCOTERM_FK on Cat_Incoterm (Id_Language ASC)
GO

ALTER TABLE Cat_Incoterm
   add constraint FK_CAT_INCO_FK_LANGUA_CAT_LANG foreign key (Id_Language)
      references Cat_Languages (Id_Language)
GO

UPDATE Cat_Incoterm
SET Id_Language = 'ANG'
GO

/*==============================================================*/
/* Table: Cat_Years_Warranty                                    */
/*==============================================================*/
ALTER TABLE Cat_Years_Warranty ADD Id_Language    varchar(10)    
GO

CREATE INDEX FK_LANGUANGE_YEARWARRANTIES_FK on Cat_Years_Warranty (Id_Language ASC)
GO

ALTER TABLE Cat_Years_Warranty
   add constraint FK_CAT_YEAR_FK_LANGUA_CAT_LANG foreign key (Id_Language)
      references Cat_Languages (Id_Language)
GO

UPDATE Cat_Years_Warranty
SET Id_Language = 'ANG'
GO

/*==============================================================*/
/* Table: Cat_Sales_Types                                       */
/*==============================================================*/
ALTER TABLE Cat_Sales_Types ADD Id_Language          varchar(10)      
GO

CREATE INDEX FK_LANGUANGE_SALESTYPES_FK on Cat_Sales_Types (Id_Language ASC)
GO

ALTER TABLE Cat_Sales_Types
   add constraint FK_CAT_SALE_FK_LANGUA_CAT_LANG foreign key (Id_Language)
      references Cat_Languages (Id_Language)
GO

UPDATE Cat_Sales_Types
SET Id_Language = 'ANG'
GO


/*==============================================================*/
/* Table: Cat_Validity_Prices                                   */
/*==============================================================*/
ALTER TABLE  Cat_Validity_Prices ADD Id_Language          varchar(10)         
GO

CREATE INDEX FK_LANGUANGE_VALIDITYPRICES_FK on Cat_Validity_Prices (Id_Language ASC)
GO

ALTER TABLE Cat_Validity_Prices
   add constraint FK_CAT_VALI_FK_LANGUA_CAT_LANG foreign key (Id_Language)
      references Cat_Languages (Id_Language)
GO

UPDATE Cat_Validity_Prices
SET Id_Language = 'ANG'
GO

/*==============================================================*/
/* Table: Cat_Status_Commercial_Release                         */
/*==============================================================*/
ALTER TABLE Cat_Status_Commercial_Release ADD Id_Language          varchar(10)         
GO

CREATE INDEX FK_LANGUANGE_STSCOMERCIALRELEASE_FK on Cat_Status_Commercial_Release (Id_Language ASC)
GO

ALTER TABLE Cat_Status_Commercial_Release
   add constraint FK_CAT_STAT_FK_LANGUA_CAT_LANG foreign key (Id_Language)
      references Cat_Languages (Id_Language)
GO

UPDATE Cat_Status_Commercial_Release
SET Id_Language = 'ANG'
GO


/*==============================================================*/
/* Table: Cat_Languages                                    */
/*==============================================================*/
ALTER TABLE Cat_Languages ADD Id_Lenguage_Translation          varchar(10)
GO

UPDATE Cat_Languages
SET Id_Language_Translation = 'ANG'
GO
