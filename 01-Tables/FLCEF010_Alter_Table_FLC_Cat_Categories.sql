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
GO

SELECT* FROM FLC_Cat_Categories
GO

SELECT* FROM FLC_Cat_Families
GO

ALTER TABLE FLC_Cat_Categories
ALTER COLUMN [Order]   varchar(10)   NOT NULL;


ALTER TABLE FLC_Cat_Groups
ALTER COLUMN [Order]   varchar(10)   NOT NULL;

ALTER TABLE FLC_Cat_Families
ALTER COLUMN [Order]   varchar(10)   NOT NULL;