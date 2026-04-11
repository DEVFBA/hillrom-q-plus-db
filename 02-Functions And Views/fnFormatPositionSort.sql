USE [DBQS]
GO
/****** Object:  UserDefinedFunction [dbo].[fnFormatPositionSort]    Script Date: 2/28/2026 6:10:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Author:		Angel Gutierrez
Desc:		Gets the hierarchy to a position sort format
Creation:	02/28/26
Returns 
			Varchar(500)
Example:	
			SELECT	dbo.fnFormatPositionSort('1')       AS Test1,
					dbo.fnFormatPositionSort('1.1')     AS Test2,
					dbo.fnFormatPositionSort('1.2.3')   AS Test3,
					dbo.fnFormatPositionSort('12.34.567.8') AS Test4,
					dbo.fnFormatPositionSort('1.2.3.4.5.6') AS Test5;
*/

ALTER FUNCTION [dbo].[fnFormatPositionSort] (@val VARCHAR(200))
RETURNS VARCHAR(500)
AS
BEGIN
    DECLARE @result VARCHAR(500);

    ;WITH Parts AS (
        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn,
               x.value('.', 'VARCHAR(10)') AS part
        FROM (
            SELECT CAST('<i>' + REPLACE(@val, '.', '</i><i>') + '</i>' AS XML) AS xmlval
        ) AS t
        CROSS APPLY xmlval.nodes('/i') AS n(x)
    )
    SELECT @result = STUFF((
        SELECT '.' + FORMAT(CAST(part AS INT), '000')
        FROM Parts
        ORDER BY rn
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

    RETURN @result;
END;