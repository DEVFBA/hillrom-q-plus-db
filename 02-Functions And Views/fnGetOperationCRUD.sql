USE DBQS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/* ==================================================================================*/
-- fnGetTransacErrorBD
/* ==================================================================================*/	
PRINT 'Crea fnGetOperationCRUD'

IF OBJECT_ID('[dbo].[fnGetOperationCRUD]','FN') IS NOT NULL
       DROP FUNCTION [dbo].[fnGetOperationCRUD]
GO

/*
Author:		Alejandro Zepeda
Desc:		Gets the type of CRUD operation
Creation:	31-12-2020
Return 
			@DescOperationCRUD Varchar(50)
Example:	
			Declare @DescOperationCRUD Varchar(50)
			SET @DescOperationCRUD = dbo.fnGetOperationCRUD('L')
			SELECT @DescOperationCRUD
*/
CREATE FUNCTION [dbo].[fnGetOperationCRUD](@pvOperationCRUD Varchar(1))
RETURNS VARCHAR(Max)
AS
BEGIN
	Declare @vDescOperationCRUD Varchar(50)
	
	SET @vDescOperationCRUD = CASE @pvOperationCRUD
								WHEN 'C' THEN 'Create Records'
								WHEN 'R' THEN 'Read Records'
								WHEN 'U' THEN 'Update Records'
								WHEN 'D' THEN 'Delete Records'
								WHEN 'L' THEN 'Load Records'
								WHEN 'W' THEN 'Download Records'
								WHEN 'J' THEN 'Job Execution'
								ELSE 'N/A'
							 END
	
	RETURN @vDescOperationCRUD
END
GO

