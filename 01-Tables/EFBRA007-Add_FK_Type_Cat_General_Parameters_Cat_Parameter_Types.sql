IF COL_LENGTH('dbo.Cat_General_Parameters', 'Type') IS NULL
BEGIN
    ALTER TABLE dbo.Cat_General_Parameters
    ADD [Type] VARCHAR(50) NULL;
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_Cat_General_Parameters_Cat_Parameter_Types'
      AND parent_object_id = OBJECT_ID('dbo.Cat_General_Parameters')
)
BEGIN
    ALTER TABLE dbo.Cat_General_Parameters
    WITH CHECK ADD CONSTRAINT FK_Cat_General_Parameters_Cat_Parameter_Types
    FOREIGN KEY ([Type])
    REFERENCES dbo.Cat_Parameter_Types (Id_Type);
END;
