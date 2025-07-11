USE DBQS
GO

ALTER TABLE FLC_Cat_Categories
ADD [Order] Smallint NULL
GO


ALTER TABLE FLC_Cat_Groups
ADD [Order] Smallint NULL
GO

ALTER TABLE FLC_Cat_Families
ADD [Order] Smallint NULL
GO


SELECT* FROM FLC_Cat_Categories 

SELECT* FROM FLC_Cat_Groups
GO

SELECT* FROM FLC_Cat_Families
GO

/*==============================================================*/
/* Alter Tables: NOT NULL			                             */
/*==============================================================*/

/*
ALTER TABLE FLC_Cat_Categories
ALTER COLUMN [Order] Smallint NOT NULL;

ALTER TABLE FLC_Cat_Groups
ALTER COLUMN [Order] Smallint NOT NULL;

ALTER TABLE FLC_Cat_Families
ALTER COLUMN [Order] Smallint NOT NULL;
*/