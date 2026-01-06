USE DBQS
GO

/*==============================================================*/
/* Generic Inserts and Execution Order                         */
/* Based on EFGSS006_Create_Tables.sql exact structure        */
/*==============================================================*/

PRINT '/*==============================================================*/'
PRINT '/* GSS QUOTATION - GENERIC INSERT EXAMPLES                  */'
PRINT '/*==============================================================*/'
PRINT ''

-- Sample variables
DECLARE @Folio INT = 1
DECLARE @Version SMALLINT = 1
DECLARE @L1_Id BIGINT, @L2_Id BIGINT, @L3_Id BIGINT
DECLARE @CurrentUser VARCHAR(50) = 'ADMIN'
DECLARE @CurrentIP VARCHAR(20) = '192.168.1.100'

PRINT '-- Step 1: Insert GSS_Quotation Header'
PRINT 'INSERT INTO GSS_Quotation ('
PRINT '    Folio, Version, Id_Customer_Bill_To, Id_Customer_Type_Bill_To, Id_Country_Bill_To,'
PRINT '    Id_Customer_Final, Id_Customer_Type_Final, Id_Country_Final, Id_Incoterm,'
PRINT '    Id_Currency, Id_Exchange_Rate, Id_Sales_Type, Id_Price_List, Id_Validity_Price,'
PRINT '    Id_Quotation_Status, Sales_Executive, Creation_Date, SPR_Number, Purchase_Order,'
PRINT '    Comments, Modify_By, Modify_Date, Modify_IP'
PRINT ')'
PRINT 'VALUES ('
PRINT '    1, 1, 100, ''HOSP'', ''CR'', 100, ''HOSP'', ''CR'', ''FOB'','
PRINT '    ''USD'', 1, ''DIRECT'', ''LIST01'', ''30DAYS'', ''DRAFT'','
PRINT '    ''ADMIN'', GETDATE(), ''SPR-2026-001'', 12345,'
PRINT '    ''Sample quotation for testing'', ''ADMIN'', GETDATE(), ''192.168.1.100'''
PRINT ')'
PRINT ''

PRINT '-- Step 2: Insert Level 1 Detail (Main Category)'
PRINT 'INSERT INTO GSS_Quotation_Detail ('
PRINT '    Id_Detail, Folio, Version, Level_Number, Position_Display, Position_Sort, Id_Parent,'
PRINT '    Quantity, Description, Unit_Price, Discount, Net_Price, Total_Price,'
PRINT '    Id_Item, Item_Short_Desc, Item_Standard_Cost, Generic_Item, On_Request,'
PRINT '    Notes, Modify_By, Modify_Date, Modify_IP'
PRINT ')'
PRINT 'VALUES ('
PRINT '    1001, @Folio, @Version, 1, ''1'', ''001.000.000.000'', NULL,'
PRINT '    1, ''Medical Equipment'', 0, 0, 0, 0,'
PRINT '    NULL, NULL, NULL, NULL, NULL,'
PRINT '    ''Main category for medical equipment'', @CurrentUser, GETDATE(), @CurrentIP'
PRINT ')'
PRINT ''

PRINT '-- Capture Level 1 ID for parent reference'
PRINT 'SELECT @L1_Id = Id_Detail FROM GSS_Quotation_Detail '
PRINT 'WHERE Folio = @Folio AND Version = @Version AND Level_Number = 1'
PRINT ''

PRINT '-- Step 3: Insert Level 2 Detail (Sub Category)'
PRINT 'INSERT INTO GSS_Quotation_Detail ('
PRINT '    Id_Detail, Folio, Version, Level_Number, Position_Display, Position_Sort, Id_Parent,'
PRINT '    Quantity, Description, Unit_Price, Discount, Net_Price, Total_Price,'
PRINT '    Id_Item, Item_Short_Desc, Item_Standard_Cost, Generic_Item, On_Request,'
PRINT '    Notes, Modify_By, Modify_Date, Modify_IP'
PRINT ')'
PRINT 'VALUES ('
PRINT '    1002, @Folio, @Version, 2, ''1.1'', ''001.001.000.000'', @L1_Id,'
PRINT '    1, ''Patient Care Equipment'', 0, 0, 0, 0,'
PRINT '    NULL, NULL, NULL, NULL, NULL,'
PRINT '    ''Patient care and monitoring equipment'', @CurrentUser, GETDATE(), @CurrentIP'
PRINT ')'
PRINT ''

PRINT 'SELECT @L2_Id = Id_Detail FROM GSS_Quotation_Detail '
PRINT 'WHERE Id_Parent = @L1_Id AND Level_Number = 2'
PRINT ''

PRINT '-- Step 4: Insert Level 3 Detail (Item Group)'
PRINT 'INSERT INTO GSS_Quotation_Detail ('
PRINT '    Id_Detail, Folio, Version, Level_Number, Position_Display, Position_Sort, Id_Parent,'
PRINT '    Quantity, Description, Unit_Price, Discount, Net_Price, Total_Price,'
PRINT '    Id_Item, Item_Short_Desc, Item_Standard_Cost, Generic_Item, On_Request,'
PRINT '    Notes, Modify_By, Modify_Date, Modify_IP'
PRINT ')'
PRINT 'VALUES ('
PRINT '    1003, @Folio, @Version, 3, ''1.1.1'', ''001.001.001.000'', @L2_Id,'
PRINT '    2, ''Hospital Beds'', 0, 0, 0, 0,'
PRINT '    NULL, NULL, NULL, NULL, NULL,'
PRINT '    ''Hospital bed systems and accessories'', @CurrentUser, GETDATE(), @CurrentIP'
PRINT ')'
PRINT ''

PRINT 'SELECT @L3_Id = Id_Detail FROM GSS_Quotation_Detail '
PRINT 'WHERE Id_Parent = @L2_Id AND Level_Number = 3'
PRINT ''

PRINT '-- Step 5: Insert Level 4 Details (Catalog Items)'
PRINT 'INSERT INTO GSS_Quotation_Detail ('
PRINT '    Id_Detail, Folio, Version, Level_Number, Position_Display, Position_Sort, Id_Parent,'
PRINT '    Quantity, Description, Unit_Price, Discount, Net_Price, Total_Price,'
PRINT '    Id_Item, Item_Short_Desc, Item_Standard_Cost, Generic_Item, On_Request,'
PRINT '    Notes, Modify_By, Modify_Date, Modify_IP'
PRINT ')'
PRINT 'VALUES '
PRINT '    (1004, @Folio, @Version, 4, ''1.1.1.1'', ''001.001.001.001'', @L3_Id,'
PRINT '     1, ''Hospital Bed Advanced Model'', 2500.00, 0, 2500.00, 2500.00,'
PRINT '     ''BED001'', ''Bed-Adv'', 2000.00, 0, 0,'
PRINT '     ''Advanced hospital bed with electronic controls'', @CurrentUser, GETDATE(), @CurrentIP),'
PRINT '    (1005, @Folio, @Version, 4, ''1.1.1.2'', ''001.001.001.002'', @L3_Id,'
PRINT '     1, ''Hospital Bed Standard Model'', 1800.00, 100.00, 1700.00, 1700.00,'
PRINT '     ''BED002'', ''Bed-Std'', 1500.00, 0, 0,'
PRINT '     ''Standard hospital bed with manual controls'', @CurrentUser, GETDATE(), @CurrentIP)'
PRINT ''

PRINT '-- Step 6: Recalculate prices up the hierarchy'
PRINT 'EXEC spRecalculate_Quotation_Prices @Folio, @Version'
PRINT ''

PRINT '-- Verification Query:'
PRINT 'SELECT Level_Number, Position_Display, Position_Sort, Description,'
PRINT '       Quantity, Unit_Price, Discount, Net_Price, Total_Price,'
PRINT '       Id_Item, Id_Parent'
PRINT 'FROM GSS_Quotation_Detail'
PRINT 'WHERE Folio = @Folio AND Version = @Version'
PRINT 'ORDER BY Position_Sort'
PRINT ''

PRINT '-- Header Summary:'
PRINT 'SELECT h.Folio, h.Version, h.Creation_Date, h.Id_Quotation_Status,'
PRINT '       h.Sales_Executive, h.Comments,'
PRINT '       SUM(d.Total_Price) as Quotation_Total'
PRINT 'FROM GSS_Quotation h'
PRINT 'LEFT JOIN GSS_Quotation_Detail d ON h.Folio = d.Folio AND h.Version = d.Version'
PRINT '                                  AND d.Level_Number = 1'
PRINT 'WHERE h.Folio = @Folio AND h.Version = @Version'
PRINT 'GROUP BY h.Folio, h.Version, h.Creation_Date, h.Id_Quotation_Status,'
PRINT '         h.Sales_Executive, h.Comments'
PRINT ''
PRINT ''

PRINT '=============================================================='
PRINT 'GENERIC INSERT STATEMENTS'
PRINT '=============================================================='
PRINT ''

-- =========================================
-- QUOTATION HEADER INSERT EXAMPLES
-- =========================================
PRINT 'QUOTATION HEADER - Manual Insert Example:'
PRINT ''
/*
-- Basic quotation header insert
INSERT INTO Quotation_Header (
    Folio, 
    Version, 
    Id_Customer, 
    Customer_Name, 
    Id_Currency, 
    Id_Language, 
    Id_Country, 
    Exchange_Rate, 
    Validity_Days, 
    Payment_Terms, 
    Delivery_Terms, 
    Special_Conditions, 
    Notes, 
    Status, 
    Created_By, 
    Created_IP
) VALUES (
    'QH000001',                           -- Folio
    1,                                    -- Version  
    'CUST001',                           -- Id_Customer
    'Hospital General de México',         -- Customer_Name
    'USD',                               -- Id_Currency
    'ESP',                               -- Id_Language
    'MX',                                -- Id_Country
    1.0,                                 -- Exchange_Rate
    30,                                  -- Validity_Days
    '30 days net',                       -- Payment_Terms
    'FOB Mexico City',                   -- Delivery_Terms
    'Instalación incluida',              -- Special_Conditions
    'Cotización para equipos médicos',   -- Notes
    'DRAFT',                             -- Status
    'JPEREZ',                            -- Created_By
    '192.168.1.100'                      -- Created_IP
)
*/

PRINT 'QUOTATION HEADER - Using Stored Procedure (RECOMMENDED):'
PRINT ''
/*
EXEC spQuotation_Hierarchical_Header_CRUD 
    @Operation = 'CREATE',
    @Id_Customer_Bill_To = 1,
    @Id_Customer_Type_Bill_To = 'HOSP',
    @Id_Country_Bill_To = 'MX',
    @Id_Customer_Final = 1,
    @Id_Customer_Type_Final = 'HOSP', 
    @Id_Country_Final = 'MX',
    @Id_Incoterm = 'FOB',
    @Id_Currency = 'USD',
    @Id_Exchange_Rate = 1,
    @Id_Sales_Type = 'DIR',
    @Id_Price_List = 'STD',
    @Id_Validity_Price = '30D',
    @Id_Quotation_Status = 'DRAFT',
    @Sales_Executive = 'JPEREZ',
    @SPR_Number = 'SPR-2025-001',
    @Comments = 'Cotización para equipos médicos',
    @User_Name = 'JPEREZ',
    @User_IP = '192.168.1.100'
*/

-- =========================================
-- QUOTATION DETAIL INSERT EXAMPLES
-- =========================================
PRINT ''
PRINT 'QUOTATION DETAIL - Level 1 (Main Category) Insert:'
PRINT ''
/*
-- Manual insert example (NOT RECOMMENDED - use stored procedures instead)
INSERT INTO Quotation_Detail (
    Folio, 
    Version, 
    Level_Number, 
    Position_Display, 
    Position_Sort, 
    Id_Parent,
    Quantity, 
    Description, 
    Unit_Price, 
    Total_Price, 
    Net_Price, 
    Created_By, 
    Created_IP
) VALUES (
    'QH000001',                          -- Folio
    1,                                   -- Version
    1,                                   -- Level_Number
    '1',                                 -- Position_Display
    '001',                               -- Position_Sort
    NULL,                                -- Id_Parent (NULL for Level 1)
    1,                                   -- Quantity
    'Equipos de Monitoreo',              -- Description
    0,                                   -- Unit_Price (will be calculated)
    0,                                   -- Total_Price (will be calculated)
    0,                                   -- Net_Price (will be calculated)
    'JPEREZ',                            -- Created_By
    '192.168.1.100'                      -- Created_IP
)
*/

PRINT 'QUOTATION DETAIL - Using Stored Procedure (RECOMMENDED):'
PRINT ''

-- Level 1 Creation
PRINT '-- Step 1: Create Level 1 (Main Category)'
/*
EXEC spQuotation_Hierarchical_Detail_CRUD 
    @Operation = 'CREATE',
    @Folio = 1,
    @Version = 1,
    @Level_Number = 1,
    @Id_Parent = NULL,
    @Quantity = 1,
    @Description = 'Equipos de Monitoreo',
    @User_Name = 'JPEREZ',
    @User_IP = '192.168.1.100'
-- This will return the new Id_Detail, let's assume it returns 1
*/

PRINT ''
-- Level 2 Creation  
PRINT '-- Step 2: Create Level 2 (Sub Category) - Parent Id_Detail = 1'
/*
EXEC spQuotation_Hierarchical_Detail_CRUD 
    @Operation = 'CREATE',
    @Folio = 1,
    @Version = 1,
    @Level_Number = 2,
    @Id_Parent = 1,                      -- Parent from Level 1
    @Quantity = 2,
    @Description = 'Monitores de Paciente',
    @User_Name = 'JPEREZ',
    @User_IP = '192.168.1.100'
-- This will return the new Id_Detail, let's assume it returns 2
*/

PRINT ''
-- Level 3 Creation
PRINT '-- Step 3: Create Level 3 (Item Group) - Parent Id_Detail = 2'
/*
EXEC spQuotation_Hierarchical_Detail_CRUD 
    @Operation = 'CREATE',
    @Folio = 1,
    @Version = 1,
    @Level_Number = 3,
    @Id_Parent = 2,                      -- Parent from Level 2
    @Quantity = 1,
    @Description = 'Monitor Básico',
    @User_Name = 'JPEREZ',
    @User_IP = '192.168.1.100'
-- This will return the new Id_Detail, let's assume it returns 3
*/

PRINT ''
-- Level 4 Creation (with GSS_Cat_Item)
PRINT '-- Step 4: Create Level 4 (Catalog Item) - Parent Id_Detail = 3'
/*
EXEC spQuotation_Hierarchical_Detail_CRUD 
    @Operation = 'CREATE',
    @Folio = 1,
    @Version = 1,
    @Level_Number = 4,
    @Id_Parent = 3,                      -- Parent from Level 3
    @Quantity = 1,
    @Id_Item = 'MON001',                 -- GSS_Cat_Item reference
    -- Description, Unit_Price will be auto-retrieved from GSS_Cat_Item
    @User_Name = 'JPEREZ',
    @User_IP = '192.168.1.100'
-- Prices will automatically cascade up the hierarchy
*/

PRINT ''
PRINT '=============================================================='
PRINT 'COMPLETE WORKFLOW EXAMPLE'
PRINT '=============================================================='
PRINT ''

-- Complete workflow from scratch
PRINT '-- COMPLETE WORKFLOW: Creating a full quotation from scratch'
PRINT ''

-- Step 1: Create Header
PRINT '-- 1. CREATE QUOTATION HEADER'
PRINT 'DECLARE @Folio VARCHAR(20), @Version INT'
PRINT ''
PRINT 'EXEC spQuotation_Hierarchical_Header_CRUD'
PRINT '    @Operation = ''CREATE'','
PRINT '    @Id_Customer_Bill_To = 1,'
PRINT '    @Id_Customer_Type_Bill_To = ''HOSP'','
PRINT '    @Id_Country_Bill_To = ''CR'','
PRINT '    @Id_Customer_Final = 1,'
PRINT '    @Id_Customer_Type_Final = ''HOSP'','
PRINT '    @Id_Country_Final = ''CR'','
PRINT '    @Id_Incoterm = ''FOB'','
PRINT '    @Id_Currency = ''USD'','
PRINT '    @Id_Exchange_Rate = 1,'
PRINT '    @Id_Sales_Type = ''DIR'','
PRINT '    @Sales_Executive = ''ADMIN'','
PRINT '    @User_Name = ''ADMIN'','
PRINT '    @User_IP = ''127.0.0.1'''
PRINT '-- Note: This will return the new Folio and Version'
PRINT ''

-- Step 2-5: Create hierarchy
PRINT '-- 2. CREATE LEVEL 1 (Main Category)'
PRINT 'DECLARE @Level1_Id BIGINT'
PRINT 'EXEC spQuotation_Hierarchical_Detail_CRUD'
PRINT '    @Operation = ''CREATE'','
PRINT '    @Folio = @Folio,'
PRINT '    @Version = @Version,'
PRINT '    @Level_Number = 1,'
PRINT '    @Description = ''Equipos Médicos'','
PRINT '    @User_Name = ''ADMIN'','
PRINT '    @User_IP = ''127.0.0.1'''
PRINT '-- Save returned Id_Detail as @Level1_Id'
PRINT ''

PRINT '-- 3. CREATE LEVEL 2 (Sub Category)'
PRINT 'DECLARE @Level2_Id BIGINT'
PRINT 'EXEC spQuotation_Hierarchical_Detail_CRUD'
PRINT '    @Operation = ''CREATE'','
PRINT '    @Folio = @Folio,'
PRINT '    @Version = @Version,'
PRINT '    @Level_Number = 2,'
PRINT '    @Id_Parent = @Level1_Id,'
PRINT '    @Quantity = 2,'
PRINT '    @Description = ''Monitores'','
PRINT '    @User_Name = ''ADMIN'','
PRINT '    @User_IP = ''127.0.0.1'''
PRINT ''

PRINT '-- 4. CREATE LEVEL 3 (Item Group)'
PRINT 'DECLARE @Level3_Id BIGINT'
PRINT 'EXEC spQuotation_Hierarchical_Detail_CRUD'
PRINT '    @Operation = ''CREATE'','
PRINT '    @Folio = @Folio,'
PRINT '    @Version = @Version,'
PRINT '    @Level_Number = 3,'
PRINT '    @Id_Parent = @Level2_Id,'
PRINT '    @Quantity = 1,'
PRINT '    @Description = ''Monitor de Signos Vitales'','
PRINT '    @User_Name = ''ADMIN'','
PRINT '    @User_IP = ''127.0.0.1'''
PRINT ''

PRINT '-- 5. CREATE LEVEL 4 (Catalog Items)'
PRINT 'EXEC spQuotation_Hierarchical_Detail_CRUD'
PRINT '    @Operation = ''CREATE'','
PRINT '    @Folio = @Folio,'
PRINT '    @Version = @Version,'
PRINT '    @Level_Number = 4,'
PRINT '    @Id_Parent = @Level3_Id,'
PRINT '    @Quantity = 1,'
PRINT '    @Id_Item = ''MON001'',        -- From GSS_Cat_Item'
PRINT '    @User_Name = ''ADMIN'','
PRINT '    @User_IP = ''127.0.0.1'''
PRINT ''

PRINT '-- 6. VIEW COMPLETE QUOTATION'
PRINT 'EXEC spQuotation_Get_Full_Structure @Folio = @Folio, @Version = @Version'
PRINT ''

PRINT '=============================================================='
PRINT 'IMPORTANT NOTES'
PRINT '=============================================================='
PRINT ''
PRINT '1. ALWAYS use stored procedures instead of direct INSERT statements'
PRINT '2. Position_Display and Position_Sort are automatically generated'
PRINT '3. Prices cascade automatically when Level 4 items are added'
PRINT '4. Level 4 requires valid Id_Item from GSS_Cat_Item table'
PRINT '5. Each procedure call returns the affected records'
PRINT '6. Parent-child relationships are enforced by foreign keys'
PRINT '7. Use READ operation to get Id_Detail values for parent references'
PRINT '8. spRecalculate_Quotation_Prices runs automatically after each detail change'
PRINT ''

PRINT '=============================================================='
PRINT 'VALIDATION QUERIES'
PRINT '=============================================================='
PRINT ''
PRINT '-- Check quotation structure'
PRINT 'SELECT Level_Number, Position_Display, Position_Sort, Description, '
PRINT '       Unit_Price, Total_Price, Id_Item, Id_Parent'
PRINT 'FROM GSS_Quotation_Detail '
PRINT 'WHERE Folio = 1 AND Version = 1'
PRINT 'ORDER BY Position_Sort'
PRINT ''
PRINT '-- Check price calculations'
PRINT 'SELECT h.Folio, h.Version, h.Comments,'
PRINT '       SUM(d.Net_Price) as Calculated_Total'
PRINT 'FROM GSS_Quotation h'
PRINT 'LEFT JOIN GSS_Quotation_Detail d ON h.Folio = d.Folio AND h.Version = d.Version'
PRINT '                              AND d.Level_Number = 1 AND d.Is_Active = 1'
PRINT 'WHERE h.Folio = 1 AND h.Version = 1'
PRINT '=============================================================='  
PRINT 'ADVANCED OPERATIONS EXAMPLES'
PRINT '=============================================================='
PRINT ''
PRINT '-- BULK PRICE UPDATES:'
PRINT 'EXEC spQuotation_Bulk_Update_Items'
PRINT '    @Folio = 1,'
PRINT '    @Version = 1,'
PRINT '    @Price_Adjustment_Pct = 10,      -- 10% increase'
PRINT '    @Update_Mode = ''ON_REQUEST_ONLY'','
PRINT '    @User_Name = ''ADMIN'','
PRINT '    @User_IP = ''127.0.0.1'''
PRINT ''
PRINT '-- CLONE QUOTATION VERSION:'
PRINT 'DECLARE @New_Version SMALLINT'
PRINT 'EXEC spQuotation_Clone_Version'
PRINT '    @Source_Folio = 1,'
PRINT '    @Source_Version = 1,'
PRINT '    @User_Name = ''ADMIN'','
PRINT '    @User_IP = ''127.0.0.1'','
PRINT '    @New_Version = @New_Version OUTPUT'
PRINT 'PRINT ''New version created: '' + CAST(@New_Version AS VARCHAR)'
PRINT ''
PRINT '-- ERROR HANDLING EXAMPLE:'
PRINT 'BEGIN TRY'
PRINT '    EXEC spQuotation_Hierarchical_Detail_CRUD'
PRINT '        @Operation = ''DELETE'','
PRINT '        @Id_Detail = 999999  -- Non-existent ID'
PRINT 'END TRY'
PRINT 'BEGIN CATCH'
PRINT '    SELECT ERROR_MESSAGE() as Error_Message,'
PRINT '           ERROR_SEVERITY() as Error_Severity,'
PRINT '           ERROR_STATE() as Error_State'
PRINT 'END CATCH'
PRINT ''
PRINT ''

PRINT '=============================================================='  
PRINT 'TESTING AND VALIDATION EXAMPLES'
PRINT '=============================================================='
PRINT ''
PRINT '-- EXAMPLE 1: Complete quotation with validation'
PRINT 'DECLARE @Folio INT, @Version SMALLINT = 1'
PRINT 'DECLARE @L1_Id BIGINT, @L2_Id BIGINT, @L3_Id BIGINT, @L4_Id BIGINT'
PRINT ''
PRINT '-- Create header and capture Folio'
PRINT 'EXEC spQuotation_Hierarchical_Header_CRUD @Operation=''CREATE'', @User_Name=''ADMIN'', @User_IP=''127.0.0.1'''
PRINT 'SELECT @Folio = MAX(Folio) FROM GSS_Quotation'
PRINT ''
PRINT '-- Create Level 1 and capture ID'
PRINT 'EXEC spQuotation_Hierarchical_Detail_CRUD @Operation=''CREATE'', @Folio=@Folio, @Version=@Version, @Level_Number=1, @Description=''Medical Equipment'', @User_Name=''ADMIN'', @User_IP=''127.0.0.1'''
PRINT 'SELECT @L1_Id = Id_Detail FROM GSS_Quotation_Detail WHERE Folio=@Folio AND Version=@Version AND Level_Number=1'
PRINT ''
PRINT '-- Validate hierarchy after each step'
PRINT 'EXEC spQuotation_Validate_Hierarchy @Folio=@Folio, @Version=@Version'
PRINT ''
PRINT '-- View complete structure'
PRINT 'EXEC spQuotation_Get_Full_Structure @Folio=@Folio, @Version=@Version'
PRINT ''
PRINT '-- Generate summary report'
PRINT 'EXEC spQuotation_Summary_Report @Folio=@Folio, @Version=@Version'
PRINT ''