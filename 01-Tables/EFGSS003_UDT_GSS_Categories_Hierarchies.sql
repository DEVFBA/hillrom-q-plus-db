USE [DBQS]
GO

/* ==================================================================================*/
-- UDT_GSS_Categories_Hierarchies -- EFGSS003
/* ==================================================================================*/
PRINT 'Crea UDT_GSS_Categories_Hierarchies' 
IF type_id('[dbo].[UDT_GSS_Categories_Hierarchies]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_GSS_Categories_Hierarchies]
GO

CREATE TYPE [dbo].[UDT_GSS_Categories_Hierarchies] AS TABLE(
	Id_Category_Hierarchy 	int             		not null,
	Id_Category          	varchar(10)          	not null,
	Parent               	varchar(5)           	not null,
	Level                	int                  	not null,
	Path                	varchar(1000)        	null,
	[Order]				 	int                  	not null,
	Status               	bit                  	not null
)
GO

