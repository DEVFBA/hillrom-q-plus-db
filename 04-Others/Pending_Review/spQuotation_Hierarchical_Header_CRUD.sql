USE DBQS
GO

/*==============================================================*/
/* CRUD Operations for GSS_Quotation Header                   */
/* Based on EFGSS006_Create_Tables.sql exact structure        */
/*==============================================================*/

-- ============================================
-- CREATE: Insert new quotation header
-- ============================================

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'spGSS_Quotation_Header_Create')
    DROP PROCEDURE spGSS_Quotation_Header_Create
GO

CREATE PROCEDURE spGSS_Quotation_Header_Create
    @Folio INT OUTPUT,
    @Version SMALLINT = 1,
    @Id_GSS_Customer BIGINT,
    @Quotation_Date DATETIME = NULL,
    @Expiration_Date DATETIME = NULL,
    @Id_Exchange_Rate BIGINT = NULL,
    @Id_User BIGINT,
    @Comments NVARCHAR(MAX) = NULL,
    @Result_Message VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Generated_Folio INT
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Set defaults
        IF @Quotation_Date IS NULL SET @Quotation_Date = GETDATE()
        IF @Expiration_Date IS NULL SET @Expiration_Date = DATEADD(MONTH, 1, GETDATE())
        
        -- Validate customer exists
        IF NOT EXISTS (SELECT 1 FROM GSS_Cat_Customers WHERE Id_Customer = @Id_GSS_Customer)
        BEGIN
            RAISERROR('Customer not found', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Validate user exists
        IF NOT EXISTS (SELECT 1 FROM Security_Users WHERE Id_User = @Id_User)
        BEGIN
            RAISERROR('User not found', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
                FROM GSS_Quotation
            END
            
            -- Set version to 1 for new quotations
            IF @Version IS NULL
                SET @Version = 1
            
            INSERT INTO GSS_Quotation (
                Folio, Version, Id_Customer_Bill_To, Id_Customer_Type_Bill_To, Id_Country_Bill_To,
                Id_Customer_Final, Id_Customer_Type_Final, Id_Country_Final, Id_Incoterm,
                Id_Currency, Id_Exchange_Rate, Id_Sales_Type, Id_Price_List, Id_Validity_Price,
                Id_Quotation_Status, Sales_Executive, Creation_Date, SPR_Number, Purchase_Order,
                Comments, Modify_By, Modify_Date, Modify_IP
            )
            VALUES (
                @Folio, @Version, @Id_Customer_Bill_To, @Id_Customer_Type_Bill_To, @Id_Country_Bill_To,
                @Id_Customer_Final, @Id_Customer_Type_Final, @Id_Country_Final, @Id_Incoterm,
                @Id_Currency, @Id_Exchange_Rate, @Id_Sales_Type, @Id_Price_List, @Id_Validity_Price,
                ISNULL(@Id_Quotation_Status, 'DRAFT'), @Sales_Executive, GETDATE(), @SPR_Number, 
                @Purchase_Order, @Comments, @User_Name, GETDATE(), @User_IP
            )
            
            -- Return the created record
            SELECT * FROM GSS_Quotation WHERE Folio = @Folio AND Version = @Version
        END
        
        ELSE IF @Operation = 'READ'
        BEGIN
            IF @Folio IS NOT NULL AND @Version IS NOT NULL
            BEGIN
                -- Read specific quotation version
                SELECT * FROM GSS_Quotation 
                WHERE Folio = @Folio AND Version = @Version
            END
            ELSE IF @Folio IS NOT NULL
            BEGIN
                -- Read all versions of a folio
                SELECT * FROM GSS_Quotation 
                WHERE Folio = @Folio
                ORDER BY Version DESC
            END
            ELSE
            BEGIN
                -- Read all quotations (with pagination if needed)
                SELECT TOP 100 * FROM GSS_Quotation 
                ORDER BY Creation_Date DESC, Folio, Version DESC
            END
        END
        
        ELSE IF @Operation = 'UPDATE'
        BEGIN
            IF @Folio IS NULL OR @Version IS NULL
            BEGIN
                RAISERROR('Folio and Version are required for UPDATE operation', 16, 1)
                RETURN
            END
            
            UPDATE GSS_Quotation SET
                Id_Customer_Bill_To = ISNULL(@Id_Customer_Bill_To, Id_Customer_Bill_To),
                Id_Customer_Type_Bill_To = ISNULL(@Id_Customer_Type_Bill_To, Id_Customer_Type_Bill_To),
                Id_Country_Bill_To = ISNULL(@Id_Country_Bill_To, Id_Country_Bill_To),
                Id_Customer_Final = ISNULL(@Id_Customer_Final, Id_Customer_Final),
                Id_Customer_Type_Final = ISNULL(@Id_Customer_Type_Final, Id_Customer_Type_Final),
                Id_Country_Final = ISNULL(@Id_Country_Final, Id_Country_Final),
                Id_Incoterm = ISNULL(@Id_Incoterm, Id_Incoterm),
                Id_Currency = ISNULL(@Id_Currency, Id_Currency),
                Id_Exchange_Rate = ISNULL(@Id_Exchange_Rate, Id_Exchange_Rate),
                Id_Sales_Type = ISNULL(@Id_Sales_Type, Id_Sales_Type),
                Id_Price_List = ISNULL(@Id_Price_List, Id_Price_List),
                Id_Validity_Price = ISNULL(@Id_Validity_Price, Id_Validity_Price),
                Id_Quotation_Status = ISNULL(@Id_Quotation_Status, Id_Quotation_Status),
                Sales_Executive = ISNULL(@Sales_Executive, Sales_Executive),
                SPR_Number = ISNULL(@SPR_Number, SPR_Number),
                Purchase_Order = ISNULL(@Purchase_Order, Purchase_Order),
                Comments = ISNULL(@Comments, Comments),
                Modify_By = @User_Name,
                Modify_Date = GETDATE(),
                Modify_IP = @User_IP
            WHERE Folio = @Folio AND Version = @Version
            
            -- Return the updated record
            SELECT * FROM GSS_Quotation WHERE Folio = @Folio AND Version = @Version
        END
        
        ELSE
        BEGIN
            RAISERROR('Invalid operation. Use CREATE, READ, or UPDATE', 16, 1)
            RETURN
        END
        
    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO