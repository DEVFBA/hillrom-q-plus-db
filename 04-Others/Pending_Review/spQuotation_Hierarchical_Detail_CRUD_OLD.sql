USE DBQS
GO

/*==============================================================*/
/* CRUD Operations for GSS_Quotation_Detail                   */
/* Based on EFGSS006_Create_Tables.sql exact structure        */
/* Hierarchical levels 1-4 with Generic_Item/On_Request       */
/*==============================================================*/

-- ============================================
-- CREATE: Insert new detail record
-- ============================================

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'spGSS_Quotation_Detail_Create')
    DROP PROCEDURE spGSS_Quotation_Detail_Create
GO

CREATE PROCEDURE spGSS_Quotation_Detail_Create
    @Id_Detail BIGINT,
    @Folio INT,
    @Version SMALLINT,
    @Id_Parent BIGINT = NULL,
    @Level_Number TINYINT,
    @Description NVARCHAR(255) = NULL,
    @Id_GSS_Item BIGINT = NULL,
    @Generic_Item BIT = 0,
    @On_Request BIT = 0,
    @Quantity FLOAT = 1.0,
    @Unit_Price FLOAT = 0.0,
    @Discount FLOAT = 0.0,
    @Comments NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Position_Display VARCHAR(50)
    DECLARE @Position_Sort VARCHAR(100)
    DECLARE @Level_For_Position TINYINT
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Validate level constraints
        IF @Level_Number NOT BETWEEN 1 AND 4
        BEGIN
            RAISERROR('Level_Number must be between 1 and 4', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Validate parent existence for levels > 1
        IF @Level_Number > 1 AND (@Id_Parent IS NULL OR @Id_Parent = 0)
        BEGIN
            RAISERROR('Parent ID is required for levels 2-4', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
        
        IF @Level_Number > 1
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM GSS_Quotation_Detail 
                WHERE Id_Detail = @Id_Parent 
                  AND Folio = @Folio 
                  AND Version = @Version
                  AND Level_Number = @Level_Number - 1
            )
            BEGIN
                RAISERROR('Parent record not found at correct level', 16, 1)
                ROLLBACK TRANSACTION
                RETURN
            END
        END
        
        -- Generate position using support procedure
        EXEC spGenerate_Quotation_Position 
            @Folio = @Folio,
            @Version = @Version,
            @ParentId = @Id_Parent,
            @Position_Display = @Position_Display OUTPUT,
            @Position_Sort = @Position_Sort OUTPUT,
            @Level_Number = @Level_For_Position OUTPUT
        
        -- Calculate Net_Price and Total_Price
        DECLARE @Net_Price FLOAT = @Unit_Price - @Discount
        DECLARE @Total_Price FLOAT = @Quantity * @Net_Price
        
        -- Insert the record
        INSERT INTO GSS_Quotation_Detail (
            Id_Detail, Folio, Version, Id_Parent, Level_Number,
            Position_Display, Position_Sort,
            Description, Id_GSS_Item, Generic_Item, On_Request,
            Quantity, Unit_Price, Discount, Net_Price, Total_Price,
            Comments
        ) VALUES (
            @Id_Detail, @Folio, @Version, @Id_Parent, @Level_Number,
            @Position_Display, @Position_Sort,
            @Description, @Id_GSS_Item, @Generic_Item, @On_Request,
            @Quantity, @Unit_Price, @Discount, @Net_Price, @Total_Price,
            @Comments
        )
        
        -- Recalculate parent prices
        EXEC spRecalculate_Quotation_Prices @Folio, @Version
        
        COMMIT TRANSACTION
        
        SELECT 'Detail created successfully' as Message,
               @Id_Detail as Id_Detail,
               @Position_Display as Position_Display
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        
        DECLARE @ErrorMessage VARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR('Error creating detail: %s', 16, 1, @ErrorMessage)
    END CATCH
END
GO
        
        IF @Operation IN ('CREATE', 'UPDATE') AND @User_IP IS NULL
        BEGIN
            RAISERROR('User_IP is required for CREATE and UPDATE operations', 16, 1)
            RETURN
        END
        
        IF @Operation = 'CREATE'
        BEGIN
            -- Validation
            IF @Folio IS NULL OR @Version IS NULL OR @Level_Number IS NULL
            BEGIN
                RAISERROR('Folio, Version, and Level_Number are required for CREATE operation', 16, 1)
                RETURN
            END
            
            -- Generate position based on level and parent
            EXEC spGenerate_Quotation_Position @Folio, @Version, @Level_Number, @Id_Parent, 
                 @Position_Display OUTPUT, @Position_Sort OUTPUT
            
            -- Get item details if Level 4
            DECLARE @Item_Short_Desc VARCHAR(50) = NULL
            DECLARE @Item_Price FLOAT = 0
            DECLARE @Item_Standard_Cost FLOAT = 0
            DECLARE @Item_On_Request BIT = 0
            
            IF @Level_Number = 4 AND @Id_Item IS NOT NULL
            BEGIN
                SELECT @Item_Short_Desc = Short_Desc,
                       @Item_Price = Price,
                       @Item_Standard_Cost = Standard_Cost,
                       @Item_On_Request = On_Request
                FROM GSS_Cat_Item
                WHERE Id_Item = @Id_Item
                
                -- Use item price unless overridden and On_Request is true
                IF @Unit_Price IS NULL OR (@Item_On_Request = 0)
                    SET @Unit_Price = @Item_Price
                    
                -- Use item description if not provided
                IF @Description IS NULL
                    SET @Description = @Item_Short_Desc
            END
            
            -- Set defaults
            SET @Quantity = ISNULL(@Quantity, 1)
            SET @Unit_Price = ISNULL(@Unit_Price, 0)
            
            DECLARE @Total_Price FLOAT = @Quantity * @Unit_Price
            DECLARE @Price_Override BIT = 0
            
            IF @Level_Number = 4 AND @Item_On_Request = 1 AND @Unit_Price != @Item_Price
                SET @Price_Override = 1
            
            INSERT INTO GSS_Quotation_Detail (
                Folio, Version, Level_Number, Position_Display, Position_Sort, Id_Parent,
                Quantity, Description, Unit_Price, Total_Price, Net_Price,
                Id_Item, Item_Short_Desc, Item_Standard_Cost, Item_On_Request, Price_Override,
                Notes, Created_By, Created_IP
            )
            VALUES (
                @Folio, @Version, @Level_Number, @Position_Display, @Position_Sort, @Id_Parent,
                @Quantity, @Description, @Unit_Price, @Total_Price, @Total_Price,
                @Id_Item, @Item_Short_Desc, @Item_Standard_Cost, @Item_On_Request, @Price_Override,
                @Notes, @User_Name, @User_IP
            )
            
            SET @Id_Detail = SCOPE_IDENTITY()
            
            -- Recalculate parent prices
            EXEC spRecalculate_Quotation_Prices @Folio, @Version
            
            -- Return the created record
            SELECT * FROM GSS_Quotation_Detail WHERE Id_Detail = @Id_Detail
        END
        
        ELSE IF @Operation = 'READ'
-- ============================================
-- READ: Get detail record(s)
-- ============================================

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'spGSS_Quotation_Detail_Read')
    DROP PROCEDURE spGSS_Quotation_Detail_Read
GO

CREATE PROCEDURE spGSS_Quotation_Detail_Read
    @Folio INT,
    @Version SMALLINT,
    @Id_Detail BIGINT = NULL,
    @Level_Number TINYINT = NULL,
    @Id_Parent BIGINT = NULL,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
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
        i.Item_Description as Item_Full_Description,
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
        -- Hierarchy info
        CASE 
            WHEN d.Level_Number = 1 THEN 'Main Item'
            WHEN d.Level_Number = 2 THEN 'Sub-Assembly'
            WHEN d.Level_Number = 3 THEN 'Component'
            WHEN d.Level_Number = 4 THEN 'Part'
        END as Level_Description,
        (SELECT COUNT(*) FROM GSS_Quotation_Detail child 
         WHERE child.Id_Parent = d.Id_Detail) as Child_Count
    FROM GSS_Quotation_Detail d
    LEFT JOIN GSS_Cat_Item i ON d.Id_GSS_Item = i.Id_Item
    WHERE d.Folio = @Folio 
      AND d.Version = @Version
      AND (@Id_Detail IS NULL OR d.Id_Detail = @Id_Detail)
      AND (@Level_Number IS NULL OR d.Level_Number = @Level_Number)
      AND (@Id_Parent IS NULL OR d.Id_Parent = @Id_Parent)
    ORDER BY d.Position_Sort
END
GO

-- ============================================
-- UPDATE: Modify existing detail record
-- ============================================

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'spGSS_Quotation_Detail_Update')
    DROP PROCEDURE spGSS_Quotation_Detail_Update
GO

CREATE PROCEDURE spGSS_Quotation_Detail_Update
    @Id_Detail BIGINT,
    @Description NVARCHAR(255) = NULL,
    @Id_GSS_Item BIGINT = NULL,
    @Generic_Item BIT = NULL,
    @On_Request BIT = NULL,
    @Quantity FLOAT = NULL,
    @Unit_Price FLOAT = NULL,
    @Discount FLOAT = NULL,
    @Comments NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Folio INT, @Version SMALLINT
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Get quotation info for price recalculation
        SELECT @Folio = Folio, @Version = Version
        FROM GSS_Quotation_Detail
        WHERE Id_Detail = @Id_Detail
        
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Detail record not found', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Calculate new prices if Unit_Price or Discount changed
        DECLARE @New_Net_Price FLOAT = NULL
        DECLARE @New_Total_Price FLOAT = NULL
        DECLARE @Current_Quantity FLOAT, @Current_Unit_Price FLOAT, @Current_Discount FLOAT
        
        SELECT @Current_Quantity = Quantity, 
               @Current_Unit_Price = Unit_Price,
               @Current_Discount = Discount
        FROM GSS_Quotation_Detail
        WHERE Id_Detail = @Id_Detail
        
        IF @Unit_Price IS NOT NULL OR @Discount IS NOT NULL OR @Quantity IS NOT NULL
        BEGIN
            DECLARE @Final_Unit_Price FLOAT = ISNULL(@Unit_Price, @Current_Unit_Price)
            DECLARE @Final_Discount FLOAT = ISNULL(@Discount, @Current_Discount)
            DECLARE @Final_Quantity FLOAT = ISNULL(@Quantity, @Current_Quantity)
            
            SET @New_Net_Price = @Final_Unit_Price - @Final_Discount
            SET @New_Total_Price = @Final_Quantity * @New_Net_Price
        END
        
        -- Update the record
        UPDATE GSS_Quotation_Detail SET
            Description = ISNULL(@Description, Description),
            Id_GSS_Item = ISNULL(@Id_GSS_Item, Id_GSS_Item),
            Generic_Item = ISNULL(@Generic_Item, Generic_Item),
            On_Request = ISNULL(@On_Request, On_Request),
            Quantity = ISNULL(@Quantity, Quantity),
            Unit_Price = ISNULL(@Unit_Price, Unit_Price),
            Discount = ISNULL(@Discount, Discount),
            Net_Price = ISNULL(@New_Net_Price, Net_Price),
            Total_Price = ISNULL(@New_Total_Price, Total_Price),
            Comments = ISNULL(@Comments, Comments),
            Modify_Date = GETDATE()
        WHERE Id_Detail = @Id_Detail
        
        -- Recalculate parent prices if prices changed
        IF @New_Net_Price IS NOT NULL
        BEGIN
            EXEC spRecalculate_Quotation_Prices @Folio, @Version
        END
        
        COMMIT TRANSACTION
        
        SELECT 'Detail updated successfully' as Message,
               @@ROWCOUNT as Rows_Affected
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        
        DECLARE @ErrorMessage VARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR('Error updating detail: %s', 16, 1, @ErrorMessage)
    END CATCH
END
GO

-- ============================================
-- DELETE: Remove detail record and children
-- ============================================

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'spGSS_Quotation_Detail_Delete')
    DROP PROCEDURE spGSS_Quotation_Detail_Delete
GO

CREATE PROCEDURE spGSS_Quotation_Detail_Delete
    @Id_Detail BIGINT,
    @DeleteChildren BIT = 1,
    @Force BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Folio INT, @Version SMALLINT
    DECLARE @ChildCount INT
    DECLARE @DeletedCount INT = 0
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Get quotation info
        SELECT @Folio = Folio, @Version = Version
        FROM GSS_Quotation_Detail
        WHERE Id_Detail = @Id_Detail
        
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Detail record not found', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Check for children
        SELECT @ChildCount = COUNT(*)
        FROM GSS_Quotation_Detail
        WHERE Id_Parent = @Id_Detail
        
        IF @ChildCount > 0 AND @DeleteChildren = 0 AND @Force = 0
        BEGIN
            RAISERROR('Cannot delete record with children. Set @DeleteChildren = 1 or @Force = 1', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Recursive delete children first
        IF @DeleteChildren = 1
        BEGIN
            WITH ChildHierarchy AS (
                -- Anchor: Direct children
                SELECT Id_Detail as Child_Id, 1 as Level
                FROM GSS_Quotation_Detail
                WHERE Id_Parent = @Id_Detail
                
                UNION ALL
                
                -- Recursive: Children of children
                SELECT d.Id_Detail as Child_Id, ch.Level + 1
                FROM GSS_Quotation_Detail d
                INNER JOIN ChildHierarchy ch ON d.Id_Parent = ch.Child_Id
            )
            DELETE FROM GSS_Quotation_Detail
            WHERE Id_Detail IN (SELECT Child_Id FROM ChildHierarchy)
            
            SET @DeletedCount = @DeletedCount + @@ROWCOUNT
        END
        
        -- Delete the main record
        DELETE FROM GSS_Quotation_Detail
        WHERE Id_Detail = @Id_Detail
        
        SET @DeletedCount = @DeletedCount + @@ROWCOUNT
        
        -- Recalculate parent prices
        EXEC spRecalculate_Quotation_Prices @Folio, @Version
        
        COMMIT TRANSACTION
        
        SELECT 'Detail deleted successfully' as Message,
               @DeletedCount as Deleted_Records
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        
        DECLARE @ErrorMessage VARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR('Error deleting detail: %s', 16, 1, @ErrorMessage)
    END CATCH
END
GO

PRINT 'GSS_Quotation_Detail CRUD procedures created for EFGSS006 structure'
PRINT '- spGSS_Quotation_Detail_Create'
PRINT '- spGSS_Quotation_Detail_Read'  
PRINT '- spGSS_Quotation_Detail_Update'
PRINT '- spGSS_Quotation_Detail_Delete'
            
            -- Return the updated record
            SELECT * FROM GSS_Quotation_Detail WHERE Id_Detail = @Id_Detail
        END
        
        ELSE IF @Operation = 'DELETE'
        BEGIN
            IF @Id_Detail IS NULL
            BEGIN
                RAISERROR('Id_Detail is required for DELETE operation', 16, 1)
                RETURN
            END
            
            -- Check if record has children (cannot delete if it has active children)
            DECLARE @ChildCount INT
            SELECT @ChildCount = COUNT(*)
            FROM GSS_Quotation_Detail 
            WHERE Id_Parent = @Id_Detail AND Is_Active = 1
            
            IF @ChildCount > 0
            BEGIN
                RAISERROR('Cannot delete record with active children. Delete children first.', 16, 1)
                RETURN
            END
            
            -- Get quotation info for recalculation
            SELECT @Folio = Folio, @Version = Version FROM GSS_Quotation_Detail WHERE Id_Detail = @Id_Detail
            
            -- Soft delete (set Is_Active = 0)
            UPDATE GSS_Quotation_Detail SET
                Is_Active = 0,
                Modified_By = @User_Name,
                Modified_Date = GETDATE(),
                Modified_IP = @User_IP
            WHERE Id_Detail = @Id_Detail
            
            -- Recalculate parent prices
            EXEC spRecalculate_Quotation_Prices @Folio, @Version
            
            -- Return success message
            SELECT 'Record deleted successfully' as Message, @Id_Detail as Id_Detail
        END
        
        ELSE
        BEGIN
            RAISERROR('Invalid operation. Use CREATE, READ, UPDATE, or DELETE', 16, 1)
            RETURN
        END
        
    END TRY
    BEGIN CATCH
        -- Log error details
        DECLARE @ErrorLine INT = ERROR_LINE()
        DECLARE @ErrorProcedure NVARCHAR(200) = ERROR_PROCEDURE()
        
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE()
        
        -- Return detailed error information
        SELECT 
            'ERROR' as Status,
            @ErrorMessage as ErrorMessage,
            @ErrorProcedure as ErrorProcedure,
            @ErrorLine as ErrorLine,
            @ErrorSeverity as ErrorSeverity,
            @ErrorState as ErrorState
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO