-- ...existing code...

IF COL_LENGTH('dbo.Quotation_Files', 'Id_Business_Line') IS NULL
BEGIN
    ALTER TABLE dbo.Quotation_Files
    ADD Id_Business_Line VARCHAR(10) NOT NULL;
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_Quotation_Files_Cat_Business_Line'
      AND parent_object_id = OBJECT_ID('dbo.Quotation_Files')
)
BEGIN
    ALTER TABLE dbo.Quotation_Files
    WITH CHECK ADD CONSTRAINT FK_Quotation_Files_Cat_Business_Line
    FOREIGN KEY (Id_Business_Line)
    REFERENCES dbo.Cat_Business_Line (Id_Business_Line);
END;

-- ...existing code...