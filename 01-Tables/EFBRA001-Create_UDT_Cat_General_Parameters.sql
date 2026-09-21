/* ==================================================================================*/
-- UDT_Cat_General_Parameters
/* ==================================================================================*/
PRINT 'Crea UDT_Cat_General_Parameters' 
IF type_id('[dbo].[UDT_Cat_General_Parameters]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Cat_General_Parameters]
GO

CREATE TYPE [dbo].[UDT_Cat_General_Parameters]AS TABLE
(
   Id_Parameter					smallint                not null,
   [Value]                      varchar(max)            not null
)
GO