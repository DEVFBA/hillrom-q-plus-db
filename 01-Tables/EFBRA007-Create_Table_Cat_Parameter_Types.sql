IF OBJECT_ID('dbo.Cat_Parameter_Types', 'U') IS NOT NULL
    DROP TABLE dbo.Cat_Parameter_Types;
GO

CREATE TABLE dbo.Cat_Parameter_Types (
    Id_Type     VARCHAR(50) NOT NULL,
    Short_Desc  VARCHAR(50) NULL,
    Long_Desc   VARCHAR(255) NULL,
    Modify_By   VARCHAR(50) NULL,
    Modify_IP   VARCHAR(20) NULL,
    Modify_Date DATETIME NULL,
    CONSTRAINT PK_Cat_Parameter_Types PRIMARY KEY (Id_Type)
);
GO
