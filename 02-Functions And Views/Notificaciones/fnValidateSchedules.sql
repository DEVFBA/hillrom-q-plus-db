use DBQS
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- fnValidateSchedules
/* ==================================================================================*/	
PRINT 'Crea fnValidateSchedules'

IF OBJECT_ID('[dbo].[fnValidateSchedules]','Fn') IS NOT NULL
       DROP FUNCTION [dbo].fnValidateSchedules
GO


/*
Author		: Alejandro Zepeda
Descrption	: Validate that the execution time is within the Execution range created by the user. 
			  This is use for fnValidateExecutionNotifications
Creation	: 17-04-2021
Return		: Boolean
Ex.:		: SELECT dbo.fnValidateSchedules ('07:20-10:24,15:00-21:04')
select getdate()

*/
CREATE FUNCTION [dbo].fnValidateSchedules(
@Horas VARCHAR(MAX)
) RETURNS BIT

BEGIN
DECLARE @Hrs			VARCHAR(MAX),
		@TrueOrFalse	BIT
DECLARE @tblSchedules	TABLE(	Fecha	DATETIME,
								FechaInicial DATETIME,
								FechaFinal	DATETIME)

	SET @TrueOrFalse	= 0
	
	DECLARE TMPHRS CURSOR FOR
	
	SELECT Valor FROM fnSplit(@Horas,',')
	OPEN TMPHRS
	FETCH NEXT FROM TMPHRS INTO @Hrs
	WHILE @@FETCH_STATUS = '0'
	BEGIN
		INSERT INTO @tblSchedules
		SELECT GETDATE(),CONVERT(DATETIME, (CONVERT(VARCHAR(10),GETDATE(),126)+' '+SUBSTRING(@Hrs,0,CHARINDEX('-',@Hrs))+':00'),120), 
				CONVERT(DATETIME,(CONVERT(VARCHAR(10),GETDATE(),126)+' '+SUBSTRING(@Hrs,CHARINDEX('-',@Hrs)+1,LEN(@Hrs)-1)+':59'),120)

		FETCH NEXT FROM TMPHRS INTO @Hrs
	END
	CLOSE TMPHRS;
	DEALLOCATE TMPHRS;
	
	IF (select count(*) from @tblSchedules where Fecha between FechaInicial and FechaFinal) > 0
		SET @TrueOrFalse = 1

RETURN @TrueOrFalse
END
