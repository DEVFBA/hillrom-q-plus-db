USE [DBQS]
GO

/* ==================================================================================*/
-- UDT_GSS_Packages_Templates
/* ==================================================================================*/
PRINT 'Crea UDT_GSS_Packages_Templates' 
IF type_id('[dbo].[UDT_GSS_Packages_Templates]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_GSS_Packages_Templates]
GO

CREATE TYPE [dbo].[UDT_GSS_Packages_Templates] AS TABLE(
	Id_Package				varchar(50)        		not null,
	Id_Item		          	varchar(10)          	not null
)
GO
