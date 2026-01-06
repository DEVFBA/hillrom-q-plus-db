USE DBQS
GO

/*==============================================================*/
/* Support Procedures for GSS Quotation System                */
/* Based on EFGSS006_Create_Tables.sql exact structure        */
/* Note: No Is_Active field in EFGSS006 structure             */
/*==============================================================*/

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'spGenerate_Quotation_Position')
    DROP PROCEDURE spGenerate_Quotation_Position
GO

CREATE PROCEDURE spGenerate_Quotation_Position
    @Folio INT,
    @Version SMALLINT,
    @ParentId BIGINT = NULL,
    @Position_Display VARCHAR(50) OUTPUT,
    @Position_Sort VARCHAR(100) OUTPUT,
    @Level_Number TINYINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ParentPosition VARCHAR(50) = ''
    DECLARE @ParentSort VARCHAR(100) = ''
    DECLARE @NextSequence INT
    
    BEGIN TRY
        IF @ParentId IS NULL
        BEGIN
            SET @Level_Number = 1
            
            SELECT @NextSequence = ISNULL(MAX(CAST(Position_Display AS INT)), 0) + 1
            FROM GSS_Quotation_Detail
            WHERE Folio = @Folio AND Version = @Version 
              AND Level_Number = 1 AND Id_Parent IS NULL
            
            SET @Position_Display = CAST(@NextSequence AS VARCHAR)
            SET @Position_Sort = RIGHT('000' + CAST(@NextSequence AS VARCHAR), 3) + '.000.000.000'
        END
        ELSE
        BEGIN
            SELECT @ParentPosition = Position_Display,
                   @ParentSort = Position_Sort,
                   @Level_Number = Level_Number + 1
            FROM GSS_Quotation_Detail
            WHERE Id_Detail = @ParentId
              AND Folio = @Folio AND Version = @Version
            
            IF @@ROWCOUNT = 0
            BEGIN
                RAISERROR('Parent detail not found', 16, 1)
                RETURN
            END
            
            IF @Level_Number > 4
            BEGIN
                RAISERROR('Maximum hierarchy level (4) exceeded', 16, 1)
                RETURN
            END
            
            SELECT @NextSequence = ISNULL(MAX(
                CAST(SUBSTRING(Position_Display, 
                     LEN(@ParentPosition) + 2, 
                     CHARINDEX('.', Position_Display + '.', LEN(@ParentPosition) + 2) - LEN(@ParentPosition) - 2) AS INT)
            ), 0) + 1
            FROM GSS_Quotation_Detail
            WHERE Folio = @Folio AND Version = @Version
              AND Id_Parent = @ParentId
            
            SET @Position_Display = @ParentPosition + '.' + CAST(@NextSequence AS VARCHAR)
            
            IF @Level_Number = 2
                SET @Position_Sort = SUBSTRING(@ParentSort, 1, 3) + '.' + 
                                   RIGHT('000' + CAST(@NextSequence AS VARCHAR), 3) + '.000.000'
            ELSE IF @Level_Number = 3
                SET @Position_Sort = SUBSTRING(@ParentSort, 1, 7) + '.' + 
                                   RIGHT('000' + CAST(@NextSequence AS VARCHAR), 3) + '.000'
            ELSE IF @Level_Number = 4
                SET @Position_Sort = SUBSTRING(@ParentSort, 1, 11) + '.' + 
                                   RIGHT('000' + CAST(@NextSequence AS VARCHAR), 3)
        END
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage VARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR('Error generating position: %s', 16, 1, @ErrorMessage)
    END CATCH
END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'spRecalculate_Quotation_Prices')
    DROP PROCEDURE spRecalculate_Quotation_Prices
GO

CREATE PROCEDURE spRecalculate_Quotation_Prices
    @Folio INT,
    @Version SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Level 4: Calculate Net_Price and Total_Price
        UPDATE GSS_Quotation_Detail
        SET Net_Price = Unit_Price - Discount,
            Total_Price = Quantity * (Unit_Price - Discount)
        WHERE Folio = @Folio AND Version = @Version AND Level_Number = 4
        
        -- Level 3: Sum of Level 4 children
        UPDATE parent
        SET Unit_Price = children_sum.Total_Sum,
            Net_Price = children_sum.Total_Sum,
            Total_Price = parent.Quantity * children_sum.Total_Sum
        FROM GSS_Quotation_Detail parent
        INNER JOIN (
            SELECT Id_Parent, SUM(Total_Price) as Total_Sum
            FROM GSS_Quotation_Detail
            WHERE Folio = @Folio AND Version = @Version AND Level_Number = 4
            GROUP BY Id_Parent
        ) children_sum ON parent.Id_Detail = children_sum.Id_Parent
        WHERE parent.Level_Number = 3
        
        -- Level 2: Sum of Level 3 children
        UPDATE parent
        SET Unit_Price = children_sum.Total_Sum,
            Net_Price = children_sum.Total_Sum,
            Total_Price = parent.Quantity * children_sum.Total_Sum
        FROM GSS_Quotation_Detail parent
        INNER JOIN (
            SELECT Id_Parent, SUM(Total_Price) as Total_Sum
            FROM GSS_Quotation_Detail
            WHERE Folio = @Folio AND Version = @Version AND Level_Number = 3
            GROUP BY Id_Parent
        ) children_sum ON parent.Id_Detail = children_sum.Id_Parent
        WHERE parent.Level_Number = 2
        
        -- Level 1: Sum of Level 2 children
        UPDATE parent
        SET Unit_Price = children_sum.Total_Sum,
            Net_Price = children_sum.Total_Sum,
            Total_Price = parent.Quantity * children_sum.Total_Sum
        FROM GSS_Quotation_Detail parent
        INNER JOIN (
            SELECT Id_Parent, SUM(Total_Price) as Total_Sum
            FROM GSS_Quotation_Detail
            WHERE Folio = @Folio AND Version = @Version AND Level_Number = 2
            GROUP BY Id_Parent
        ) children_sum ON parent.Id_Detail = children_sum.Id_Parent
        WHERE parent.Level_Number = 1
        
        SELECT 'Price recalculation completed' as Message,
               COUNT(*) as Updated_Records,
               SUM(Total_Price) as Quotation_Total
        FROM GSS_Quotation_Detail
        WHERE Folio = @Folio AND Version = @Version AND Level_Number = 1
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage VARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR('Error recalculating prices: %s', 16, 1, @ErrorMessage)
    END CATCH
END
GO

PRINT 'Support procedures updated for EFGSS006 structure (no Is_Active field)'
PRINT '- spGenerate_Quotation_Position'
PRINT '- spRecalculate_Quotation_Prices'