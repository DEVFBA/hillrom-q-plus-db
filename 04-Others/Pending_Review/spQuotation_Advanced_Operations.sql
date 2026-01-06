USE DBQS
GO

/*==============================================================*/
/* Advanced Operations for GSS Quotation System              */
/* Based on EFGSS006_Create_Tables.sql exact structure        */
/* Operations: Full structure retrieval, validation, etc.     */
/*==============================================================*/

-- ============================================
-- GET FULL STRUCTURE: Complete quotation with hierarchy
-- ============================================

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'spGSS_Quotation_Get_Full_Structure')
    DROP PROCEDURE spGSS_Quotation_Get_Full_Structure
GO

CREATE PROCEDURE spGSS_Quotation_Get_Full_Structure
    @Folio INT,
    @Version SMALLINT,
    @Include_Summary BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Header information
    SELECT 
        q.Folio,
        q.Version,
        q.Id_GSS_Customer,
        c.Customer_Name,
        c.Customer_Code,
        q.Quotation_Date,
        q.Expiration_Date,
        q.Id_Exchange_Rate,
        er.Currency_Code,
        er.Exchange_Rate,
        q.Id_User,
        u.User_Name,
        q.Comments,
        q.Creation_Date,
        q.Modify_Date,
        -- Status
        CASE 
            WHEN q.Expiration_Date < GETDATE() THEN 'Expired'
            WHEN q.Expiration_Date <= DATEADD(DAY, 7, GETDATE()) THEN 'Expiring Soon'
            ELSE 'Active'
        END as Status
    FROM GSS_Quotation q
    LEFT JOIN GSS_Cat_Customers c ON q.Id_GSS_Customer = c.Id_Customer
    LEFT JOIN Cat_Exchange_Rates er ON q.Id_Exchange_Rate = er.Id_Exchange_Rate
    LEFT JOIN Security_Users u ON q.Id_User = u.Id_User
    WHERE q.Folio = @Folio AND q.Version = @Version
    
    -- Detail structure with hierarchy
    SELECT 
        d.Id_Detail,
        d.Folio,
        d.Version,
        d.Id_Parent,
        d.Level_Number,
        d.Position_Display,
        d.Position_Sort,
        d.Description,
        d.Id_GSS_Item,
        i.Item_Number,
        i.Item_Description,
        d.Generic_Item,
        d.On_Request,
        d.Quantity,
        d.Unit_Price,
        d.Discount,
        d.Net_Price,
        d.Total_Price,
        d.Comments,
        d.Creation_Date,
        d.Modify_Date,
        -- Hierarchy display helpers
        REPLICATE('    ', d.Level_Number - 1) + d.Position_Display as Indented_Position,
        CASE d.Level_Number
            WHEN 1 THEN 'Main Item'
            WHEN 2 THEN 'Sub-Assembly'
            WHEN 3 THEN 'Component'
            WHEN 4 THEN 'Part'
        END as Level_Description,
        (SELECT COUNT(*) FROM GSS_Quotation_Detail child 
         WHERE child.Id_Parent = d.Id_Detail) as Child_Count
    FROM GSS_Quotation_Detail d
    LEFT JOIN GSS_Cat_Item i ON d.Id_GSS_Item = i.Id_Item
    WHERE d.Folio = @Folio AND d.Version = @Version
    ORDER BY d.Position_Sort
    
    -- Summary information
    IF @Include_Summary = 1
    BEGIN
        SELECT 
            'Summary' as Section,
            COUNT(*) as Total_Lines,
            SUM(CASE WHEN Level_Number = 1 THEN 1 ELSE 0 END) as Level_1_Count,
            SUM(CASE WHEN Level_Number = 2 THEN 1 ELSE 0 END) as Level_2_Count,
            SUM(CASE WHEN Level_Number = 3 THEN 1 ELSE 0 END) as Level_3_Count,
            SUM(CASE WHEN Level_Number = 4 THEN 1 ELSE 0 END) as Level_4_Count,
            SUM(CASE WHEN Generic_Item = 1 THEN 1 ELSE 0 END) as Generic_Items,
            SUM(CASE WHEN On_Request = 1 THEN 1 ELSE 0 END) as On_Request_Items,
            SUM(CASE WHEN Level_Number = 1 THEN Total_Price ELSE 0 END) as Quotation_Total,
            MIN(Unit_Price) as Min_Unit_Price,
            MAX(Unit_Price) as Max_Unit_Price,
            AVG(Unit_Price) as Avg_Unit_Price
        FROM GSS_Quotation_Detail
        WHERE Folio = @Folio AND Version = @Version
    END
END
GO
GO

CREATE PROCEDURE spQuotation_Get_Full_Structure
    @Folio                  INT,
    @Version                SMALLINT
AS
BEGIN
    SET NOCOUNT ON
    
    -- Return header information
    SELECT 'HEADER' as RecordType, * 
    FROM GSS_Quotation 
    WHERE Folio = @Folio AND Version = @Version
    
    -- Return complete detail structure with item information
    SELECT 
        'DETAIL' as RecordType,
        qd.*,
        -- Additional calculated fields
        CASE 
            WHEN qd.Level_Number = 4 THEN gci.Model
            ELSE NULL 
        END as Item_Model,
        CASE 
            WHEN qd.Level_Number = 4 THEN gci.Specifications
            ELSE NULL 
        END as Item_Specifications,
        CASE 
            WHEN qd.Level_Number = 4 THEN gci.Weight
            ELSE NULL 
        END as Item_Weight,
        CASE 
            WHEN qd.Level_Number = 4 THEN gci.Measurements
            ELSE NULL 
        END as Item_Measurements,
        CASE 
            WHEN qd.Level_Number = 4 THEN gci.Image_Path
            ELSE NULL 
        END as Item_Image_Path,
        -- Hierarchy indicators
        CASE qd.Level_Number
            WHEN 1 THEN 'Main Category'
            WHEN 2 THEN 'Sub Category'
            WHEN 3 THEN 'Item Group'
            WHEN 4 THEN 'Catalog Item'
        END as Level_Description,
        -- Children count
        (SELECT COUNT(*) 
         FROM GSS_Quotation_Detail children 
         WHERE children.Id_Parent = qd.Id_Detail 
           AND children.Is_Active = 1) as Children_Count
    FROM GSS_Quotation_Detail qd
    LEFT JOIN GSS_Cat_Item gci ON qd.Id_Item = gci.Id_Item AND qd.Level_Number = 4
    WHERE qd.Folio = @Folio 
      AND qd.Version = @Version 
      AND qd.Is_Active = 1
    ORDER BY qd.Position_Sort
END
GO

/*==============================================================*/
/* User Defined Table Type: UDT_Id_Mapping                    */
/* Purpose: Map old Id_Detail to new Id_Detail for cloning    */
/*==============================================================*/

IF EXISTS (SELECT * FROM sys.types WHERE name = 'UDT_Id_Mapping' AND is_user_defined = 1)
    DROP TYPE UDT_Id_Mapping
GO

CREATE TYPE [dbo].[UDT_Id_Mapping] AS TABLE
(
    Old_Id_Detail BIGINT NOT NULL,
    New_Id_Detail BIGINT NOT NULL,
    PRIMARY KEY (Old_Id_Detail),
    UNIQUE (New_Id_Detail)
)
GO

/*==============================================================*/
/* Stored Procedure: spQuotation_Clone_Version                 */
/* Purpose: Create a new version of an existing quotation      */
/* NOTE: Id_Detail values must be provided by frontend         */
/*==============================================================*/

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID('spQuotation_Clone_Version') AND type = 'P')
    DROP PROCEDURE spQuotation_Clone_Version
GO

CREATE PROCEDURE spQuotation_Clone_Version
    @Source_Folio           INT,
    @Source_Version         SMALLINT,
    @Id_Mapping             UDT_Id_Mapping READONLY,  -- Frontend must provide old->new ID mapping
    @User_Name              VARCHAR(50),
    @User_IP                VARCHAR(20),
    @New_Version            SMALLINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @ErrorMessage NVARCHAR(4000)
    DECLARE @ErrorSeverity INT
    DECLARE @ErrorState INT
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Validate that ID mapping is provided
        IF NOT EXISTS (SELECT 1 FROM @Id_Mapping)
        BEGIN
            RAISERROR('Id_Mapping parameter is required for quotation cloning. Frontend must provide old->new ID mapping.', 16, 1)
            RETURN -1
        END
        
        -- Validate all source IDs exist and new IDs don't exist in target
        IF EXISTS (
            SELECT 1 FROM @Id_Mapping m 
            WHERE NOT EXISTS (
                SELECT 1 FROM GSS_Quotation_Detail 
                WHERE Id_Detail = m.Old_Id_Detail 
                  AND Folio = @Source_Folio 
                  AND Version = @Source_Version
                  AND Is_Active = 1
            )
        )
        BEGIN
            RAISERROR('One or more source Id_Detail values in mapping do not exist in source quotation.', 16, 1)
            RETURN -1
        END
        
        -- Get next version number
        SELECT @New_Version = ISNULL(MAX(Version), 0) + 1
        FROM GSS_Quotation
        WHERE Folio = @Source_Folio
        
        -- Verify no new IDs already exist in any quotation
        IF EXISTS (
            SELECT 1 FROM @Id_Mapping m
            INNER JOIN GSS_Quotation_Detail qd ON m.New_Id_Detail = qd.Id_Detail
            WHERE qd.Is_Active = 1
        )
        BEGIN
            RAISERROR('One or more new Id_Detail values already exist in database. All new IDs must be unique.', 16, 1)
            RETURN -1
        END
        
        -- Clone header
        INSERT INTO GSS_Quotation (
            Folio, Version, Id_Customer_Bill_To, Id_Customer_Type_Bill_To, Id_Country_Bill_To,
            Id_Customer_Final, Id_Customer_Type_Final, Id_Country_Final, Id_Incoterm,
            Id_Currency, Id_Exchange_Rate, Id_Sales_Type, Id_Price_List, Id_Validity_Price,
            Id_Quotation_Status, Sales_Executive, Creation_Date, SPR_Number, Purchase_Order,
            Comments, Modify_By, Modify_Date, Modify_IP
        )
        SELECT 
            Folio, @New_Version, Id_Customer_Bill_To, Id_Customer_Type_Bill_To, Id_Country_Bill_To,
            Id_Customer_Final, Id_Customer_Type_Final, Id_Country_Final, Id_Incoterm,
            Id_Currency, Id_Exchange_Rate, Id_Sales_Type, Id_Price_List, Id_Validity_Price,
            'DRAFT', Sales_Executive, GETDATE(), SPR_Number, Purchase_Order,
            Comments, @User_Name, GETDATE(), @User_IP
        FROM GSS_Quotation
        WHERE Folio = @Source_Folio AND Version = @Source_Version
        
        -- Clone details using frontend-provided ID mapping
        -- Insert Level 1 items first
        INSERT INTO GSS_Quotation_Detail (
            Id_Detail, Folio, Version, Level_Number, Position_Display, Position_Sort, Id_Parent,
            Quantity, Description, Unit_Price, Total_Price, Net_Price,
            Id_Item, Item_Short_Desc, Item_Standard_Cost, Item_On_Request, Price_Override,
            Notes, Created_By, Created_IP
        )
        SELECT 
            m.New_Id_Detail, @Source_Folio, @New_Version, qd.Level_Number, qd.Position_Display, qd.Position_Sort, NULL,
            qd.Quantity, qd.Description, qd.Unit_Price, qd.Total_Price, qd.Net_Price,
            qd.Id_Item, qd.Item_Short_Desc, qd.Item_Standard_Cost, qd.Item_On_Request, qd.Price_Override,
            qd.Notes, @User_Name, @User_IP
        FROM GSS_Quotation_Detail qd
        INNER JOIN @Id_Mapping m ON qd.Id_Detail = m.Old_Id_Detail
        WHERE qd.Folio = @Source_Folio AND qd.Version = @Source_Version 
          AND qd.Level_Number = 1 AND qd.Is_Active = 1
        
        -- Insert remaining levels (2, 3, 4) with proper parent mapping
        DECLARE @CurrentLevel INT = 2
        WHILE @CurrentLevel <= 4
        BEGIN
            INSERT INTO GSS_Quotation_Detail (
                Id_Detail, Folio, Version, Level_Number, Position_Display, Position_Sort, Id_Parent,
                Quantity, Description, Unit_Price, Total_Price, Net_Price,
                Id_Item, Item_Short_Desc, Item_Standard_Cost, Item_On_Request, Price_Override,
                Notes, Created_By, Created_IP
            )
            SELECT 
                m.New_Id_Detail, @Source_Folio, @New_Version, qd.Level_Number, qd.Position_Display, qd.Position_Sort, 
                m_parent.New_Id_Detail, -- Map to new parent ID using mapping table
                qd.Quantity, qd.Description, qd.Unit_Price, qd.Total_Price, qd.Net_Price,
                qd.Id_Item, qd.Item_Short_Desc, qd.Item_Standard_Cost, qd.Item_On_Request, qd.Price_Override,
                qd.Notes, @User_Name, @User_IP
            FROM GSS_Quotation_Detail qd
            INNER JOIN @Id_Mapping m ON qd.Id_Detail = m.Old_Id_Detail
            INNER JOIN @Id_Mapping m_parent ON qd.Id_Parent = m_parent.Old_Id_Detail
            WHERE qd.Folio = @Source_Folio AND qd.Version = @Source_Version 
              AND qd.Level_Number = @CurrentLevel AND qd.Is_Active = 1
            
            SET @CurrentLevel = @CurrentLevel + 1
        END
        
        COMMIT TRANSACTION
        
        -- Return new quotation structure
        EXEC spQuotation_Get_Full_Structure @Source_Folio, @New_Version
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

/*==============================================================*/
/* Stored Procedure: spQuotation_Validate_Hierarchy            */
/* Purpose: Validate quotation hierarchy integrity             */
/*==============================================================*/

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID('spQuotation_Validate_Hierarchy') AND type = 'P')
    DROP PROCEDURE spQuotation_Validate_Hierarchy
GO

CREATE PROCEDURE spQuotation_Validate_Hierarchy
    @Folio                  INT,
    @Version                SMALLINT,
    @Fix_Issues             BIT = 0     -- If 1, attempt to fix validation issues
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @Issues TABLE (
        Issue_Type VARCHAR(50),
        Issue_Description VARCHAR(500),
        Id_Detail BIGINT,
        Position_Display VARCHAR(50),
        Severity VARCHAR(20)
    )
    
    -- Check for orphaned children (parent doesn't exist)
    INSERT INTO @Issues
    SELECT 'ORPHANED_CHILD', 
           'Child record has no valid parent: ' + Position_Display,
           Id_Detail,
           Position_Display,
           'HIGH'
    FROM GSS_Quotation_Detail child
    WHERE child.Folio = @Folio 
      AND child.Version = @Version 
      AND child.Is_Active = 1
      AND child.Id_Parent IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM GSS_Quotation_Detail parent 
          WHERE parent.Id_Detail = child.Id_Parent 
            AND parent.Is_Active = 1
      )
    
    -- Check for incorrect level hierarchy
    INSERT INTO @Issues
    SELECT 'LEVEL_MISMATCH',
           'Level ' + CAST(child.Level_Number AS VARCHAR) + ' has parent at level ' + CAST(parent.Level_Number AS VARCHAR),
           child.Id_Detail,
           child.Position_Display,
           'HIGH'
    FROM GSS_Quotation_Detail child
    INNER JOIN GSS_Quotation_Detail parent ON child.Id_Parent = parent.Id_Detail
    WHERE child.Folio = @Folio 
      AND child.Version = @Version 
      AND child.Is_Active = 1
      AND parent.Is_Active = 1
      AND child.Level_Number != parent.Level_Number + 1
    
    -- Check for Level 4 items without GSS_Cat_Item reference
    INSERT INTO @Issues
    SELECT 'MISSING_ITEM',
           'Level 4 record missing Id_Item reference',
           Id_Detail,
           Position_Display,
           'MEDIUM'
    FROM GSS_Quotation_Detail
    WHERE Folio = @Folio 
      AND Version = @Version 
      AND Is_Active = 1
      AND Level_Number = 4
      AND Id_Item IS NULL
    
    -- Return validation results
    SELECT * FROM @Issues ORDER BY Severity DESC, Issue_Type, Position_Display
    
    -- Summary
    SELECT 
        COUNT(*) as Total_Issues,
        SUM(CASE WHEN Severity = 'HIGH' THEN 1 ELSE 0 END) as High_Priority,
        SUM(CASE WHEN Severity = 'MEDIUM' THEN 1 ELSE 0 END) as Medium_Priority,
        SUM(CASE WHEN Severity = 'LOW' THEN 1 ELSE 0 END) as Low_Priority
    FROM @Issues
END
GO