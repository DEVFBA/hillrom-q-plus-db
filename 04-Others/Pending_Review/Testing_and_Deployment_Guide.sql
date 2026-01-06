USE DBQS
GO

/*==============================================================*/
/* TESTING AND DEPLOYMENT GUIDE                               */
/* GSS Quotation System - EFGSS006 Structure                  */
/* Based on EFGSS006_Create_Tables.sql exact structure        */
/* Version: 1.1 - Updated for Frontend-Controlled Id_Detail   */
/*==============================================================*/

PRINT '=============================================================='
PRINT 'GSS QUOTATION SYSTEM - DEPLOYMENT GUIDE (EFGSS006)'
PRINT '=============================================================='
PRINT 'Based on EFGSS006_Create_Tables.sql exact structure'
PRINT 'IMPORTANT: Id_Detail is now FRONTEND-CONTROLLED (NOT IDENTITY)'
PRINT 'Frontend must provide all Id_Detail values for Detail records'
PRINT 'Includes: Generic_Item, On_Request, Discount fields'
PRINT 'No Is_Active field (as per EFGSS006)'
PRINT ''

/*==============================================================*/
/* STEP 1: DEPLOYMENT ORDER (CRITICAL)                        */
/*==============================================================*/

PRINT '1. DEPLOYMENT ORDER'
PRINT '-------------------'
PRINT 'REQUIRED EXECUTION ORDER:'
PRINT '1. 01-Tables/EFGSS006_Create_Tables.sql (FIRST - Creates base tables)'
PRINT '2. spQuotation_Support_Procedures.sql (Support functions)'
PRINT '3. spQuotation_Hierarchical_Header_CRUD.sql (Header operations)'
PRINT '4. spQuotation_Hierarchical_Detail_CRUD.sql (Detail operations)'  
PRINT '5. spQuotation_Advanced_Operations.sql (Advanced features)'
PRINT '6. Testing_and_Deployment_Guide.sql (This file - LAST)'
PRINT ''

/*==============================================================*/
/* STEP 2: TABLE STRUCTURE VALIDATION                         */
/*==============================================================*/

PRINT '2. VALIDATING EFGSS006 TABLE STRUCTURE'
PRINT '---------------------------------------'

-- Verify GSS_Quotation exists with correct structure
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'GSS_Quotation')
BEGIN
    PRINT '❌ ERROR: GSS_Quotation table not found'
    PRINT 'Please execute EFGSS006_Create_Tables.sql first'
    RETURN
END
ELSE
    PRINT '✅ GSS_Quotation table found'

-- Verify GSS_Quotation_Detail exists with EFGSS006 structure
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'GSS_Quotation_Detail')
BEGIN
    PRINT '❌ ERROR: GSS_Quotation_Detail table not found'
    PRINT 'Please execute EFGSS006_Create_Tables.sql first'
    RETURN
END
ELSE
    PRINT '✅ GSS_Quotation_Detail table found'

-- Validate EFGSS006-specific columns in GSS_Quotation_Detail
DECLARE @ValidationResults TABLE (
    FieldName VARCHAR(50),
    IsPresent BIT,
    DataType VARCHAR(50),
    Additional_Info VARCHAR(100)
)

-- Check Id_Detail is BIGINT and NOT IDENTITY (frontend-controlled)
INSERT INTO @ValidationResults (FieldName, IsPresent, DataType, Additional_Info)
SELECT 'Id_Detail', 
       CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
                        WHERE TABLE_NAME = 'GSS_Quotation_Detail' 
                        AND COLUMN_NAME = 'Id_Detail') THEN 1 ELSE 0 END,
       ISNULL((SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'GSS_Quotation_Detail' 
               AND COLUMN_NAME = 'Id_Detail'), 'NOT FOUND'),
       CASE WHEN EXISTS (SELECT 1 FROM sys.columns c 
                        JOIN sys.tables t ON c.object_id = t.object_id 
                        WHERE t.name = 'GSS_Quotation_Detail' 
                        AND c.name = 'Id_Detail' 
                        AND c.is_identity = 1) 
            THEN 'ERROR: Is IDENTITY' 
            ELSE 'OK: Frontend Controlled' 
       END

INSERT INTO @ValidationResults (FieldName, IsPresent, DataType, Additional_Info)
SELECT 'Generic_Item', 
       CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
                        WHERE TABLE_NAME = 'GSS_Quotation_Detail' 
                        AND COLUMN_NAME = 'Generic_Item') THEN 1 ELSE 0 END,
       ISNULL((SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'GSS_Quotation_Detail' 
               AND COLUMN_NAME = 'Generic_Item'), 'NOT FOUND'),
       'EFGSS006 Field'

INSERT INTO @ValidationResults (FieldName, IsPresent, DataType, Additional_Info)
SELECT 'On_Request', 
       CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
                        WHERE TABLE_NAME = 'GSS_Quotation_Detail' 
                        AND COLUMN_NAME = 'On_Request') THEN 1 ELSE 0 END,
       ISNULL((SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'GSS_Quotation_Detail' 
               AND COLUMN_NAME = 'On_Request'), 'NOT FOUND'),
       'EFGSS006 Field'

INSERT INTO @ValidationResults (FieldName, IsPresent, DataType, Additional_Info)
SELECT 'Discount', 
       CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
                        WHERE TABLE_NAME = 'GSS_Quotation_Detail' 
                        AND COLUMN_NAME = 'Discount') THEN 1 ELSE 0 END,
       ISNULL((SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'GSS_Quotation_Detail' 
               AND COLUMN_NAME = 'Discount'), 'NOT FOUND'),
       'EFGSS006 Field'

-- Verify Is_Active field does NOT exist (as per EFGSS006)
INSERT INTO @ValidationResults (FieldName, IsPresent, DataType, Additional_Info)
SELECT 'Is_Active', 
       CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
                        WHERE TABLE_NAME = 'GSS_Quotation_Detail' 
                        AND COLUMN_NAME = 'Is_Active') THEN 1 ELSE 0 END,
       ISNULL((SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'GSS_Quotation_Detail' 
               AND COLUMN_NAME = 'Is_Active'), 'NOT FOUND'),
       'Should NOT exist'

-- Display validation results
SELECT 
    FieldName,
    CASE 
        WHEN FieldName = 'Is_Active' AND IsPresent = 0 THEN '✅ Correctly ABSENT (per EFGSS006)'
        WHEN FieldName = 'Id_Detail' AND IsPresent = 1 AND Additional_Info LIKE 'OK:%' THEN '✅ Present (Frontend Controlled)'
        WHEN FieldName = 'Id_Detail' AND IsPresent = 1 AND Additional_Info LIKE 'ERROR:%' THEN '❌ ' + Additional_Info
        WHEN FieldName != 'Is_Active' AND FieldName != 'Id_Detail' AND IsPresent = 1 THEN '✅ Present'
        WHEN FieldName != 'Is_Active' AND IsPresent = 0 THEN '❌ MISSING'
        WHEN FieldName = 'Is_Active' AND IsPresent = 1 THEN '⚠️  UNEXPECTED (should be absent)'
        ELSE '?'
    END as Status,
    DataType,
    Additional_Info
FROM @ValidationResults

PRINT '✅ EFGSS006 field validation completed'

PRINT 'DEPLOYMENT ORDER (Execute in this exact sequence):'
PRINT '1. Create_Tables_Quotation_Hierarchical_System.sql'
PRINT '2. spQuotation_Support_Procedures.sql'
PRINT '3. spQuotation_Hierarchical_Header_CRUD.sql'
PRINT '4. spQuotation_Hierarchical_Detail_CRUD.sql'
PRINT '5. spQuotation_Advanced_Operations.sql'
PRINT ''

/*==============================================================*/
/* STEP 2: PRE-DEPLOYMENT VALIDATION                          */
/*==============================================================*/

PRINT '=============================================================='
PRINT 'PRE-DEPLOYMENT VALIDATION'
PRINT '=============================================================='

-- Check for required tables
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'GSS_Cat_Item')
BEGIN
    PRINT 'WARNING: GSS_Cat_Item table not found. This is required for Level 4 items.'
END
ELSE
BEGIN
    PRINT '✓ GSS_Cat_Item table exists'
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'GSS_Customers_Table')
BEGIN
    PRINT 'WARNING: GSS_Customers_Table table not found. This is required for customer references.'
END
ELSE
BEGIN
    PRINT '✓ GSS_Customers_Table table exists'
END

-- Check for required catalog tables
DECLARE @MissingTables TABLE (TableName VARCHAR(50))

INSERT INTO @MissingTables
SELECT 'Cat_Exchange_Rates' WHERE NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Cat_Exchange_Rates')
UNION ALL
SELECT 'Cat_Incoterm' WHERE NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Cat_Incoterm')
UNION ALL
SELECT 'Cat_Prices_Lists' WHERE NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Cat_Prices_Lists')
UNION ALL
SELECT 'Cat_Quotation_Status' WHERE NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Cat_Quotation_Status')
UNION ALL
SELECT 'Cat_Sales_Types' WHERE NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Cat_Sales_Types')
UNION ALL
SELECT 'Cat_Validity_Prices' WHERE NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Cat_Validity_Prices')
UNION ALL
SELECT 'Security_Users' WHERE NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Security_Users')

IF EXISTS (SELECT * FROM @MissingTables)
BEGIN
    PRINT 'WARNING: Missing catalog tables:'
    SELECT '  - ' + TableName FROM @MissingTables
END
ELSE
BEGIN
    PRINT '✓ All required catalog tables exist'
END

PRINT ''

/*==============================================================*/
/* STEP 3: TESTING SCRIPTS                                    */
/*==============================================================*/

PRINT '=============================================================='
PRINT 'TESTING SCRIPTS'
PRINT '=============================================================='
PRINT ''

PRINT 'TEST 1: Basic Table Creation Test'
PRINT '----------------------------------'
/*
-- Execute this after running Create_Tables_Quotation_Hierarchical_System.sql

-- Check if tables were created successfully
SELECT 'GSS_Quotation' as TableName, 
       CASE WHEN EXISTS (SELECT * FROM sys.tables WHERE name = 'GSS_Quotation') 
            THEN 'CREATED' ELSE 'MISSING' END as Status
UNION ALL
SELECT 'GSS_Quotation_Detail', 
       CASE WHEN EXISTS (SELECT * FROM sys.tables WHERE name = 'GSS_Quotation_Detail') 
            THEN 'CREATED' ELSE 'MISSING' END

-- Check constraints
SELECT 
    'FK_GSSQuotationDetail_GSSQuotation' as ConstraintName,
    CASE WHEN EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_GSSQuotationDetail_GSSQuotation') 
         THEN 'EXISTS' ELSE 'MISSING' END as Status
UNION ALL
SELECT 
    'CK_GSSQuotationDetail_Level',
    CASE WHEN EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK_GSSQuotationDetail_Level') 
         THEN 'EXISTS' ELSE 'MISSING' END

-- Check indexes
SELECT 
    i.name as IndexName,
    t.name as TableName,
    'EXISTS' as Status
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.name IN ('GSS_Quotation', 'GSS_Quotation_Detail')
  AND i.name IS NOT NULL
ORDER BY t.name, i.name
*/

PRINT ''
PRINT 'TEST 2: Stored Procedures Test'
PRINT '-------------------------------'
/*
-- Execute this after running all procedure scripts

-- Check if procedures were created
SELECT 
    name as ProcedureName,
    create_date as CreatedDate,
    modify_date as ModifiedDate,
    'EXISTS' as Status
FROM sys.procedures 
WHERE name LIKE 'spQuotation%' OR name LIKE '%Quotation%'
ORDER BY name

-- Test spGenerate_Quotation_Position
DECLARE @TestFolio INT = 999999
DECLARE @TestVersion SMALLINT = 1
DECLARE @Position_Display VARCHAR(50)
DECLARE @Position_Sort VARCHAR(100)

EXEC spGenerate_Quotation_Position 
    @Folio = @TestFolio,
    @Version = @TestVersion,
    @Level_Number = 1,
    @Id_Parent = NULL,
    @Position_Display = @Position_Display OUTPUT,
    @Position_Sort = @Position_Sort OUTPUT

SELECT 'Position Generation Test' as Test,
       @Position_Display as Position_Display,
       @Position_Sort as Position_Sort,
       CASE WHEN @Position_Display = '1' AND @Position_Sort = '001' 
            THEN 'PASS' ELSE 'FAIL' END as Result
*/

PRINT ''
PRINT 'TEST 3: Complete Workflow Test (Frontend-Controlled IDs)'
PRINT '-------------------------------'
/*
-- This tests the complete quotation creation workflow with frontend-controlled Id_Detail values
BEGIN TRANSACTION -- Use transaction for testing

DECLARE @TestFolio INT
DECLARE @TestVersion SMALLINT = 1
DECLARE @Level1_Id BIGINT = 5001 -- Frontend assigns unique IDs
DECLARE @Level2_Id BIGINT = 5002
DECLARE @Level3_Id BIGINT = 5003

-- Step 1: Create Header
EXEC spQuotation_Hierarchical_Header_CRUD
    @Operation = 'CREATE',
    @Id_Customer_Bill_To = 1,
    @Id_Customer_Type_Bill_To = 'TEST',
    @Id_Country_Bill_To = 'US',
    @Id_Customer_Final = 1,
    @Id_Customer_Type_Final = 'TEST',
    @Id_Country_Final = 'US',
    @Id_Incoterm = 'FOB',
    @Id_Currency = 'USD',
    @Id_Exchange_Rate = 1,
    @Id_Sales_Type = 'DIR',
    @Id_Price_List = 'STD',
    @Id_Validity_Price = '30D',
    @Id_Quotation_Status = 'DRAFT',
    @Sales_Executive = 'TEST',
    @Comments = 'Test quotation with frontend-controlled IDs',
    @User_Name = 'TEST_USER',
    @User_IP = '127.0.0.1'

-- Get the created folio (this would be returned by the procedure)
SELECT @TestFolio = MAX(Folio) FROM GSS_Quotation WHERE Sales_Executive = 'TEST'

-- Step 2: Create Level 1 (Frontend provides Id_Detail)
EXEC spGSS_Quotation_Detail_Create
    @Id_Detail = @Level1_Id,  -- Frontend-controlled ID
    @Folio = @TestFolio,
    @Version = @TestVersion,
    @Level_Number = 1,
    @Position_Display = '1.0',
    @Position_Sort = 1,
    @Id_Parent = NULL,
    @Description = 'TEST: Medical Equipment',
    @User_Name = 'TEST_USER',
    @User_IP = '127.0.0.1'

-- Step 3: Create Level 2 (Frontend provides Id_Detail and references Level 1)
EXEC spGSS_Quotation_Detail_Create
    @Id_Detail = @Level2_Id,  -- Frontend-controlled ID
    @Folio = @TestFolio,
    @Version = @TestVersion,
    @Level_Number = 2,
    @Position_Display = '1.1',
    @Position_Sort = 2,
    @Id_Parent = @Level1_Id,  -- Reference to Level 1
    @Quantity = 2,
    @Description = 'TEST: Monitors',
    @User_Name = 'TEST_USER',
    @User_IP = '127.0.0.1'

-- Step 4: Create Level 3 (Frontend provides Id_Detail and references Level 2)
EXEC spGSS_Quotation_Detail_Create
    @Id_Detail = @Level3_Id,  -- Frontend-controlled ID
    @Folio = @TestFolio,
    @Version = @TestVersion,
    @Level_Number = 3,
    @Position_Display = '1.1.1',
    @Position_Sort = 3,
    @Id_Parent = @Level2_Id,  -- Reference to Level 2
    @Quantity = 1,
    @Description = 'TEST: Monitor Components',
    @User_Name = 'TEST_USER',
    @User_IP = '127.0.0.1'

-- Step 5: Validate Results
SELECT 'Workflow Test Results' as Test,
       COUNT(*) as Records_Created,
       CASE WHEN COUNT(*) >= 3 THEN 'PASS' ELSE 'FAIL' END as Result
FROM GSS_Quotation_Detail 
WHERE Folio = @TestFolio AND Version = @TestVersion

-- Verify hierarchy is correct
SELECT 'Hierarchy Test' as Test,
       Id_Detail,
       Id_Parent,
       Level_Number,
       Description,
       CASE 
           WHEN Level_Number = 1 AND Id_Parent IS NULL THEN 'CORRECT'
           WHEN Level_Number = 2 AND Id_Parent = @Level1_Id THEN 'CORRECT'
           WHEN Level_Number = 3 AND Id_Parent = @Level2_Id THEN 'CORRECT'
           ELSE 'INCORRECT'
       END as Hierarchy_Status
FROM GSS_Quotation_Detail 
WHERE Folio = @TestFolio AND Version = @TestVersion
ORDER BY Position_Sort

-- Cleanup
ROLLBACK TRANSACTION
*/

PRINT ''
PRINT 'TEST 4: Validation and Error Handling Test'
PRINT '-------------------------------------------'
/*
-- Test validation procedures

-- Test hierarchy validation
EXEC spQuotation_Validate_Hierarchy 
    @Folio = 1,
    @Version = 1

-- Test error handling - try to create without required fields
BEGIN TRY
    EXEC spQuotation_Hierarchical_Detail_CRUD
        @Operation = 'CREATE',
        @Folio = NULL,  -- This should fail
        @Version = 1,
        @Level_Number = 1
END TRY
BEGIN CATCH
    SELECT 'Error Handling Test' as Test,
           ERROR_MESSAGE() as Error_Message,
           CASE WHEN ERROR_MESSAGE() LIKE '%required%' THEN 'PASS' ELSE 'FAIL' END as Result
END CATCH
*/

PRINT ''

/*==============================================================*/
/* STEP 4: SAMPLE DATA CREATION                               */
/*==============================================================*/

PRINT '=============================================================='
PRINT 'SAMPLE DATA CREATION'
PRINT '=============================================================='
PRINT ''

-- Sample customer data (if tables are empty)
/*
-- Only run this if GSS_Customers_Table is empty

IF NOT EXISTS (SELECT * FROM GSS_Customers_Table WHERE Id_Customer = 1)
BEGIN
    INSERT INTO GSS_Customers_Table (Id_Customer_Type, Id_Country, Id_Customer, Customer_Name, Status)
    VALUES 
    ('HOSP', 'US', 1, 'Test Hospital', 1),
    ('HOSP', 'MX', 1, 'Hospital General Mexico', 1),
    ('CLIN', 'CA', 1, 'Test Clinic Canada', 1)
END

-- Sample catalog items (if GSS_Cat_Item is empty)
IF NOT EXISTS (SELECT * FROM GSS_Cat_Item WHERE Id_Item = 'TEST001')
BEGIN
    INSERT INTO GSS_Cat_Item (Id_Item, Short_Desc, Long_Desc, Price, Standard_Cost, On_Request, Status)
    VALUES 
    ('TEST001', 'Test Monitor', 'Test Patient Monitor', 1200.00, 800.00, 0, 1),
    ('TEST002', 'Test Sensor', 'Test Pressure Sensor', 300.00, 200.00, 0, 1),
    ('TEST003', 'Test Premium Monitor', 'Test Premium Monitor', 0.00, 0.00, 1, 1)
END
*/

PRINT ''

/*==============================================================*/
/* STEP 5: PERFORMANCE MONITORING                             */
/*==============================================================*/

PRINT '=============================================================='
PRINT 'PERFORMANCE MONITORING'
PRINT '=============================================================='
PRINT ''

-- Index usage monitoring
/*
SELECT 
    i.name as IndexName,
    t.name as TableName,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates,
    s.last_user_seek,
    s.last_user_scan,
    s.last_user_lookup
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id
INNER JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.name IN ('GSS_Quotation', 'Quotation_Detail')
ORDER BY t.name, i.name
*/

-- Table size monitoring
/*
SELECT 
    t.name as TableName,
    p.rows as RowCount,
    SUM(a.total_pages) * 8 as TotalSpaceKB,
    SUM(a.used_pages) * 8 as UsedSpaceKB,
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 as UnusedSpaceKB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.name IN ('GSS_Quotation', 'Quotation_Detail')
GROUP BY t.name, p.rows
ORDER BY t.name
*/

PRINT ''

/*==============================================================*/
/* STEP 6: TROUBLESHOOTING GUIDE                              */
/*==============================================================*/

PRINT '=============================================================='
PRINT 'TROUBLESHOOTING GUIDE'
PRINT '=============================================================='
PRINT ''
PRINT 'COMMON ISSUES AND SOLUTIONS:'
PRINT ''
PRINT '1. Foreign Key Constraint Errors:'
PRINT '   - Ensure all referenced catalog tables exist and have data'
PRINT '   - Check GSS_Cat_Item table for valid Id_Item values'
PRINT '   - Verify GSS_Customers_Table has required customer records'
PRINT ''
PRINT '2. Position Generation Issues:'
PRINT '   - Check for orphaned records in Quotation_Detail'
PRINT '   - Run spQuotation_Validate_Hierarchy to identify problems'
PRINT '   - Verify parent-child relationships are correct'
PRINT ''
PRINT '3. Price Calculation Problems:'
PRINT '   - Run spRecalculate_Quotation_Prices manually'
PRINT '   - Check for NULL or negative prices in Level 4 items'
PRINT '   - Verify GSS_Cat_Item has valid price data'
PRINT ''
PRINT '4. Performance Issues:'
PRINT '   - Check index usage statistics'
PRINT '   - Consider partitioning for large quotation volumes'
PRINT '   - Monitor query execution plans'
PRINT ''

/*==============================================================*/
/* STEP 7: MAINTENANCE PROCEDURES                             */
/*==============================================================*/

PRINT '=============================================================='
PRINT 'MAINTENANCE PROCEDURES'
PRINT '=============================================================='
PRINT ''

-- Create maintenance job scripts
PRINT 'RECOMMENDED MAINTENANCE JOBS:'
PRINT '1. Daily: Update statistics on GSS_Quotation and Quotation_Detail'
PRINT '2. Weekly: Rebuild indexes with fragmentation > 30%'
PRINT '3. Monthly: Archive old quotations (older than 2 years)'
PRINT '4. Monthly: Validate hierarchy integrity for active quotations'
PRINT ''

-- Statistics update script
/*
UPDATE STATISTICS GSS_Quotation WITH FULLSCAN
UPDATE STATISTICS Quotation_Detail WITH FULLSCAN
*/

-- Index maintenance script
/*
DECLARE @sql NVARCHAR(4000)
DECLARE @fragmentation FLOAT
DECLARE @indexname NVARCHAR(128)
DECLARE @tablename NVARCHAR(128)

DECLARE index_cursor CURSOR FOR
SELECT 
    t.name as table_name,
    i.name as index_name,
    s.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') s
INNER JOIN sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id
INNER JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.name IN ('GSS_Quotation', 'Quotation_Detail')
  AND i.name IS NOT NULL
  AND s.avg_fragmentation_in_percent > 10

OPEN index_cursor
FETCH NEXT FROM index_cursor INTO @tablename, @indexname, @fragmentation

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @fragmentation > 30
        SET @sql = 'ALTER INDEX ' + @indexname + ' ON ' + @tablename + ' REBUILD'
    ELSE
        SET @sql = 'ALTER INDEX ' + @indexname + ' ON ' + @tablename + ' REORGANIZE'
    
    PRINT @sql
    -- EXEC sp_executesql @sql  -- Uncomment to execute
    
    FETCH NEXT FROM index_cursor INTO @tablename, @indexname, @fragmentation
END

CLOSE index_cursor
DEALLOCATE index_cursor
*/

PRINT ''
PRINT '=============================================================='
PRINT 'DEPLOYMENT GUIDE COMPLETE'
PRINT 'For questions or issues, refer to the troubleshooting section'
PRINT '=============================================================='