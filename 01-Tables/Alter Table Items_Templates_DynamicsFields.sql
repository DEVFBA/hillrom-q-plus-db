USE DBQS
GO


ALTER TABLE Items_Templates ADD DynamicField_DefaultValue		VARCHAR(25)          NULL
ALTER TABLE Items_Templates ADD DynamicField_AssignedValue		VARCHAR(25)          NULL
ALTER TABLE Items_Templates ADD DynamicField_ReplaceCharacter	CHAR(1)              NULL
ALTER TABLE Items_Templates ADD DynamicField_IsDynamic			BIT                  NULL
ALTER TABLE Items_Templates ADD DynamicField_IdItem				VARCHAR(50)          NULL
GO

/*==============================================================*/
/* Alter Tables: NOT NULL			                             */
/*==============================================================*/

/*
ALTER TABLE Items_Templates ALTER COLUMN DynamicField_DefaultValue		VARCHAR(25) NOT NULL;
ALTER TABLE Items_Templates ALTER COLUMN DynamicField_AssignedValue		VARCHAR(25) NOT NULL;
ALTER TABLE Items_Templates ALTER COLUMN DynamicField_ReplaceCharacter	CHAR(1)		NOT NULL;
ALTER TABLE Items_Templates ALTER COLUMN DynamicField_IsDynamic			BIT			NOT NULL;
ALTER TABLE Items_Templates ALTER COLUMN DynamicField_IdItem			VARCHAR(50) NOT NULL;
*/