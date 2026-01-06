USE DBQS
GO

/*==============================================================*/
/* Example Quotation Data Structure                            */
/* Based on EFGSS006_Create_Tables.sql exact structure        */
/*==============================================================*/

PRINT '/*==============================================================*/'
PRINT '/* GSS QUOTATION SYSTEM - DATA STRUCTURE REFERENCE          */'
PRINT '/*==============================================================*/'
PRINT ''

PRINT '-- GSS_Quotation Table Structure:'
PRINT 'Folio: INT - Primary key (quotation number)'
PRINT 'Version: SMALLINT - Primary key (version control)'
PRINT 'Id_Customer_Bill_To: INT - Bill-to customer ID'
PRINT 'Id_Customer_Type_Bill_To: VARCHAR(10) - Bill-to customer type'
PRINT 'Id_Country_Bill_To: VARCHAR(10) - Bill-to country'
PRINT 'Id_Customer_Final: INT - Final customer ID'
PRINT 'Id_Customer_Type_Final: VARCHAR(10) - Final customer type'
PRINT 'Id_Country_Final: VARCHAR(10) - Final country'
PRINT 'Id_Incoterm: VARCHAR(10) - Incoterm code'
PRINT 'Id_Currency: VARCHAR(10) - Currency code'
PRINT 'Id_Exchange_Rate: SMALLINT - Exchange rate reference'
PRINT 'Id_Sales_Type: VARCHAR(10) - Sales type'
PRINT 'Id_Price_List: VARCHAR(10) - Price list reference'
PRINT 'Id_Validity_Price: VARCHAR(10) - Price validity'
PRINT 'Id_Quotation_Status: VARCHAR(10) - Status code'
PRINT 'Sales_Executive: VARCHAR(20) - Sales person'
PRINT 'Creation_Date: DATETIME - Creation timestamp'
PRINT 'SPR_Number: VARCHAR(50) - SPR reference (nullable)'
PRINT 'Purchase_Order: INT - PO number (nullable)'
PRINT 'Comments: VARCHAR(1000) - Additional comments (nullable)'
PRINT '--Id_Language: VARCHAR(10) - Language (commented out)'
PRINT 'Modify_By: VARCHAR(50) - Last modifier'
PRINT 'Modify_Date: DATETIME - Last modification date'
PRINT 'Modify_IP: VARCHAR(20) - Modification IP address'
PRINT ''

PRINT '-- GSS_Quotation_Detail Table Structure:'
PRINT 'Id_Detail: BIGINT - Primary key (FRONTEND CONTROLLED - NOT IDENTITY)'
PRINT 'Folio: INT - Foreign key to GSS_Quotation'
PRINT 'Version: SMALLINT - Foreign key to GSS_Quotation'
PRINT 'Level_Number: TINYINT - Hierarchy level (1-4)'
PRINT 'Position_Display: VARCHAR(50) - Display position (1, 1.1, 1.1.1, 1.1.1.1)'
PRINT 'Position_Sort: VARCHAR(100) - Sort key (001.001.001.001)'
PRINT 'Id_Parent: BIGINT - Parent detail reference (nullable)'
PRINT 'Quantity: FLOAT - Item quantity'
PRINT 'Description: VARCHAR(500) - Item description'
PRINT 'Unit_Price: FLOAT - Unit price'
PRINT 'Discount: FLOAT - Discount amount'
PRINT 'Net_Price: FLOAT - Net price after discount'
PRINT 'Total_Price: FLOAT - Total line price'
PRINT 'Id_Item: VARCHAR(50) - GSS_Cat_Item reference (Level 4 only)'
PRINT 'Item_Short_Desc: VARCHAR(50) - Item short description'
PRINT 'Item_Standard_Cost: FLOAT - Standard cost from catalog'
PRINT 'Generic_Item: BIT - Generic item flag'
PRINT 'On_Request: BIT - On request pricing flag'
PRINT 'Notes: VARCHAR(500) - Additional notes'
PRINT 'Modify_By: VARCHAR(50) - Last modifier'
PRINT 'Modify_Date: DATETIME - Last modification'
PRINT 'Modify_IP: VARCHAR(20) - Modification IP'
PRINT ''

PRINT '-- Hierarchical Structure Example:'
PRINT 'Level 1 (Main Categories):'
PRINT '  1 - Medical Equipment'
PRINT '  2 - Services'
PRINT '  3 - Accessories'
PRINT ''
PRINT 'Level 2 (Sub Categories):'
PRINT '  1.1 - Patient Care Equipment'
PRINT '  1.2 - Diagnostic Equipment'
PRINT '  2.1 - Installation Services'
PRINT '  2.2 - Training Services'
PRINT ''
PRINT 'Level 3 (Item Groups):'
PRINT '  1.1.1 - Hospital Beds'
PRINT '  1.1.2 - Patient Monitors'
PRINT '  1.2.1 - Ultrasound Systems'
PRINT ''
PRINT 'Level 4 (Catalog Items):'
PRINT '  1.1.1.1 - Hospital Bed Model ABC-100'
PRINT '  1.1.1.2 - Hospital Bed Model DEF-200'
PRINT '  1.1.2.1 - Patient Monitor XYZ-300'
PRINT ''

PRINT '-- Foreign Key Relationships:'
PRINT 'GSS_Quotation_Detail -> GSS_Quotation (Folio, Version)'
PRINT 'GSS_Quotation_Detail -> GSS_Quotation_Detail (Id_Parent)'
PRINT 'GSS_Quotation_Detail -> GSS_Cat_Item (Id_Item)'
PRINT 'GSS_Quotation -> GSS_Cat_Customers (Customer references)'
PRINT 'GSS_Quotation -> Cat_Exchange_Rates (Currency, Exchange Rate)'
PRINT 'GSS_Quotation -> Security_Users (Sales_Executive)'
PRINT ''
PRINT '-- IMPORTANT: Id_Detail values must be provided by frontend application'
PRINT '-- No automatic ID generation - full control from client application'
PRINT ''

PRINT '-- Sample Data Structure:'
PRINT '/*'
PRINT 'GSS_Quotation:'
PRINT 'Folio=1, Version=1, Customer_Bill_To=100, Sales_Executive=ADMIN'
PRINT ''
PRINT 'GSS_Quotation_Detail:'
PRINT 'Id=1, Level=1, Position="1", Description="Medical Equipment", Parent=NULL'
PRINT 'Id=2, Level=2, Position="1.1", Description="Patient Care", Parent=1'
PRINT 'Id=3, Level=3, Position="1.1.1", Description="Hospital Beds", Parent=2'
PRINT 'Id=4, Level=4, Position="1.1.1.1", Description="Bed Model X", Parent=3, Id_Item="BED001"'
PRINT '*/'
PRINT ''

PRINT '-- Example Query to View Hierarchy:'
PRINT 'SELECT Level_Number, Position_Display, Position_Sort,'
PRINT '       Description, Quantity, Unit_Price, Discount,'
PRINT '       Net_Price, Total_Price, Id_Item, Id_Parent'
PRINT 'FROM GSS_Quotation_Detail'
PRINT 'WHERE Folio = 1 AND Version = 1'
PRINT 'ORDER BY Position_Sort'
├─────────┼─────────────────────────────────────┼─────────────┼─────────────┼─────────────┼─────────────┤
│ 1       │ Equipos de Cuidados Intensivos     │ 9950.00     │ 9950.00     │ 9950.00     │ NULL        │
│ 1       │ Monitores de Paciente               │ 6300.00     │ 6300.00     │ 6300.00     │ NULL        │
│ 2       │ Monitor Básico                      │ 1500.00     │ 3000.00     │ 3000.00     │ NULL        │
│ 1       │ Monitor de Signos Vitales           │ 1200.00     │ 1200.00     │ 1200.00     │ MON001      │
│ 1       │ Sensor de Presión                   │ 300.00      │ 300.00      │ 300.00      │ SEN002      │
│ 1       │ Monitor Avanzado                    │ 3300.00     │ 3300.00     │ 3300.00     │ NULL        │
│ 1       │ Monitor Multiparámetro Premium      │ 3300.00     │ 3300.00     │ 3300.00     │ MON005      │
│ 2       │ Ventiladores Mecánicos              │ 3650.00     │ 7300.00     │ 7300.00     │ NULL        │
│ 1       │ Ventilador Básico                   │ 3650.00     │ 3650.00     │ 3650.00     │ NULL        │
│ 1       │ Ventilador Neonatal VN-2000        │ 3650.00     │ 3650.00     │ 3650.00     │ VENT003     │
│ 1       │ Accesorios y Repuestos              │ 2900.00     │ 2900.00     │ 2900.00     │ NULL        │
│ 3       │ Filtros de Aire                     │ 2900.00     │ 8700.00     │ 8700.00     │ NULL        │
│ 1       │ Set de Filtros Respiratorios        │ 2900.00     │ 2900.00     │ 2900.00     │ NULL        │
│ 50      │ Filtro HEPA Individual              │ 58.00       │ 2900.00     │ 2900.00     │ FILT001     │
└─────────┴─────────────────────────────────────┴─────────────┴─────────────┴─────────────┴─────────────┘

Key Points About This Structure:
- Level 1 (Pos: 1, 2): Main categories with calculated prices from children
- Level 2 (Pos: 1.1, 1.2, 2.1): Sub-categories with quantities and calculated prices  
- Level 3 (Pos: 1.1.1, 1.1.2, etc.): Item groups with quantities and calculated prices
- Level 4 (Pos: 1.1.1.1, 1.1.1.2, etc.): Actual catalog items with Id_Item from GSS_Cat_Item

Price Flow Example for Position 1.1.1:
- Level 4 items (1.1.1.1 + 1.1.1.2): $1200 + $300 = $1500
- Level 3 (1.1.1): Unit Price = $1500, Quantity = 2, Total = $3000
- This $3000 flows up to Level 2 (1.1) calculation
*/

PRINT ''
PRINT 'STORED PROCEDURE OUTPUT EXAMPLES:'
PRINT ''
PRINT '1. spQuotation_Hierarchical_Header_CRUD @Operation=''READ'', @Folio=1, @Version=1'
PRINT 'Output:'
/*
┌─────────┬─────────┬─────────────────────┬─────────────────────┬─────────────────────────┐
│ Folio   │ Version │ Creation_Date       │ Id_Customer_Bill_To │ Id_Customer_Type_Bill_To│
├─────────┼─────────┼─────────────────────┼─────────────────────┼─────────────────────────┤
│ 1       │ 1       │ 2025-12-19 10:30:00│ 1                   │ HOSP                    │
└─────────┴─────────┴─────────────────────┴─────────────────────┴─────────────────────────┘
│ Id_Currency │ Sales_Executive │ Id_Quotation_Status │ Comments      │ Modify_By │
├─────────────┼─────────────────┼─────────────────────┼───────────────┼───────────┤
│ USD         │ JPEREZ          │ DRAFT               │ Medical Equip │ JPEREZ    │
└─────────────┴─────────────────┴─────────────────────┴───────────────┴───────────┘
*/

PRINT ''
PRINT '2. spQuotation_Hierarchical_Detail_CRUD @Operation=''READ'', @Folio=1, @Version=1'
PRINT 'Output (Hierarchical order):'
/*
┌────────────┬──────────────┬──────────────────┬─────────┬─────────────────────────────────────┐
│ Id_Detail  │ Level_Number │ Position_Display │Quantity │ Description                         │
├────────────┼──────────────┼──────────────────┼─────────┼─────────────────────────────────────┤
│ 1          │ 1            │ 1                │ 1       │ Equipos de Cuidados Intensivos     │
│ 2          │ 2            │ 1.1              │ 1       │ Monitores de Paciente               │
│ 3          │ 3            │ 1.1.1            │ 2       │ Monitor Básico                      │
│ 4          │ 4            │ 1.1.1.1          │ 1       │ Monitor de Signos Vitales           │
│ 5          │ 4            │ 1.1.1.2          │ 1       │ Sensor de Presión                   │
│ 6          │ 3            │ 1.1.2            │ 1       │ Monitor Avanzado                    │
│ 7          │ 4            │ 1.1.2.1          │ 1       │ Monitor Multiparámetro Premium      │
│ 8          │ 2            │ 1.2              │ 2       │ Ventiladores Mecánicos              │
│ 9          │ 3            │ 1.2.1            │ 1       │ Ventilador Básico                   │
│ 10         │ 4            │ 1.2.1.1          │ 1       │ Ventilador Neonatal VN-2000        │
│ 11         │ 1            │ 2                │ 1       │ Accesorios y Repuestos              │
│ 12         │ 2            │ 2.1              │ 3       │ Filtros de Aire                     │
│ 13         │ 3            │ 2.1.1            │ 1       │ Set de Filtros Respiratorios        │
│ 14         │ 4            │ 2.1.1.1          │ 50      │ Filtro HEPA Individual              │
└────────────┴──────────────┴──────────────────┴─────────┴─────────────────────────────────────┘

┌─────────────┬─────────────┬─────────────┬─────────────┬──────────────────────┐
│ Unit_Price  │ Total_Price │ Net_Price   │ Id_Item     │ Item_On_Request      │
├─────────────┼─────────────┼─────────────┼─────────────┼──────────────────────┤
│ 9950.00     │ 9950.00     │ 9950.00     │ NULL        │ NULL                 │
│ 6300.00     │ 6300.00     │ 6300.00     │ NULL        │ NULL                 │
│ 1500.00     │ 3000.00     │ 3000.00     │ NULL        │ NULL                 │
│ 1200.00     │ 1200.00     │ 1200.00     │ MON001      │ 0                    │
│ 300.00      │ 300.00      │ 300.00      │ SEN002      │ 0                    │
│ 3300.00     │ 3300.00     │ 3300.00     │ NULL        │ NULL                 │
│ 3300.00     │ 3300.00     │ 3300.00     │ MON005      │ 1                    │
│ 3650.00     │ 7300.00     │ 7300.00     │ NULL        │ NULL                 │
│ 3650.00     │ 3650.00     │ 3650.00     │ NULL        │ NULL                 │
│ 3650.00     │ 3650.00     │ 3650.00     │ VENT003     │ 0                    │
│ 2900.00     │ 2900.00     │ 2900.00     │ NULL        │ NULL                 │
│ 2900.00     │ 8700.00     │ 8700.00     │ NULL        │ NULL                 │
│ 2900.00     │ 2900.00     │ 2900.00     │ NULL        │ NULL                 │
│ 58.00       │ 2900.00     │ 2900.00     │ FILT001     │ 0                    │
└─────────────┴─────────────┴─────────────┴─────────────┴──────────────────────┘
*/

PRINT ''
PRINT '3. spQuotation_Get_Full_Structure @Folio=1, @Version=1'
PRINT 'Output (Enhanced with item details):'
/*
First ResultSet - HEADER:
┌─────────────┬─────────┬─────────┬─────────────────────┬─────────────────────┬─────────────────────┐
│ RecordType  │ Folio   │ Version │ Creation_Date       │ Id_Customer_Bill_To │ Sales_Executive     │
├─────────────┼─────────┼─────────┼─────────────────────┼─────────────────────┼─────────────────────┤
│ HEADER      │ 1       │ 1       │ 2025-12-19 10:30:00│ 1                   │ JPEREZ              │
└─────────────┴─────────┴─────────┴─────────────────────┴─────────────────────┴─────────────────────┘
│ Id_Quotation_Status │ Comments              │ Id_Currency │ Id_Incoterm │
├─────────────────────┼───────────────────────┼─────────────┼─────────────┤
│ DRAFT               │ Medical Equipment     │ USD         │ FOB         │
└─────────────────────┴───────────────────────┴─────────────┴─────────────┘

Second ResultSet - DETAIL:
┌─────────────┬────────────┬──────────────┬──────────────────┬──────────────────┬─────────────────────────────────────┐
│ RecordType  │ Id_Detail  │ Level_Number │ Position_Display │ Level_Description│ Description                         │
├─────────────┼────────────┼──────────────┼──────────────────┼──────────────────┼─────────────────────────────────────┤
│ DETAIL      │ 1          │ 1            │ 1                │ Main Category    │ Equipos de Cuidados Intensivos     │
│ DETAIL      │ 2          │ 2            │ 1.1              │ Sub Category     │ Monitores de Paciente               │
│ DETAIL      │ 3          │ 3            │ 1.1.1            │ Item Group       │ Monitor Básico                      │
│ DETAIL      │ 4          │ 4            │ 1.1.1.1          │ Catalog Item     │ Monitor de Signos Vitales           │
│ DETAIL      │ 5          │ 4            │ 1.1.1.2          │ Catalog Item     │ Sensor de Presión                   │
│ DETAIL      │ 6          │ 3            │ 1.1.2            │ Item Group       │ Monitor Avanzado                    │
│ DETAIL      │ 7          │ 4            │ 1.1.2.1          │ Catalog Item     │ Monitor Multiparámetro Premium      │
└─────────────┴────────────┴──────────────┴──────────────────┴──────────────────┴─────────────────────────────────────┘

┌─────────────┬─────────────┬─────────────┬─────────────┬──────────────┬─────────────────┐
│ Unit_Price  │ Total_Price │ Id_Item     │ Item_Model  │ Children_Count│ Item_On_Request │
├─────────────┼─────────────┼─────────────┼─────────────┼──────────────┼─────────────────┤
│ 9950.00     │ 9950.00     │ NULL        │ NULL        │ 2            │ NULL            │
│ 6300.00     │ 6300.00     │ NULL        │ NULL        │ 2            │ NULL            │
│ 1500.00     │ 3000.00     │ NULL        │ NULL        │ 2            │ NULL            │
│ 1200.00     │ 1200.00     │ MON001      │ VS-2000     │ 0            │ 0               │
│ 300.00      │ 300.00      │ SEN002      │ PS-100      │ 0            │ 0               │
│ 3300.00     │ 3300.00     │ NULL        │ NULL        │ 1            │ NULL            │
│ 3300.00     │ 3300.00     │ MON005      │ MP-5000     │ 0            │ 1               │
└─────────────┴─────────────┴─────────────┴─────────────┴──────────────┴─────────────────┘
*/

PRINT ''
PRINT 'PRICE CALCULATION FLOW:'
PRINT '1. Level 4 items calculate their Total_Price = Quantity * Unit_Price'
PRINT '2. Level 3 Unit_Price = SUM of all its Level 4 children Total_Price'
PRINT '3. Level 3 Total_Price = Level 3 Quantity * Level 3 Unit_Price'  
PRINT '4. Level 2 Unit_Price = SUM of all its Level 3 children Total_Price'
PRINT '5. Level 2 Total_Price = Level 2 Quantity * Level 2 Unit_Price'
PRINT '6. Level 1 Unit_Price = SUM of all its Level 2 children Total_Price'
PRINT '7. Header Total_Amount = SUM of all Level 1 Net_Price'
PRINT ''
PRINT 'Example Calculation for Position 1.1.1:'
PRINT '- Position 1.1.1.1: Qty=1 * Price=$1200 = $1200'
PRINT '- Position 1.1.1.2: Qty=1 * Price=$300 = $300'
PRINT '- Position 1.1.1: Unit_Price = $1200 + $300 = $1500'
PRINT '- Position 1.1.1: Total_Price = Qty=2 * $1500 = $3000'