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