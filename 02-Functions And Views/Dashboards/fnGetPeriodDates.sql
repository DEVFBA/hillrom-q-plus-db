SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- fnGetPeriodDates
/* ==================================================================================*/	
PRINT 'Crea fnGetPeriodDates'

IF OBJECT_ID('[dbo].[fnGetPeriodDates]','TF') IS NOT NULL
       DROP FUNCTION [dbo].[fnGetPeriodDates]
GO


/*
Author		: Alejandro Zepeda
Descrption	: Returns Initial Date and Final Date of a Period
Creation	: 05-06-2021
Periods 
			CM = Mes Actual <Current Month>,
			LM = Mes Anterior <Last Month>,
			NM = Mes Siguiente <Next Month>,
			CY = Año Actual <Current Year>
			LY = Año Anterior <Last Year>

Example: 
	Select * from fnGetPeriodDates('CM')
	Select * from fnGetPeriodDates('LM')
	Select * from fnGetPeriodDates('NM')
	Select * from fnGetPeriodDates('CY')
	Select * from fnGetPeriodDates('LY')
*/
CREATE FUNCTION [dbo].[fnGetPeriodDates](
@pvIdPeriod VARCHAR(5)
) RETURNS @Table TABLE (IdPeriod Varchar(5), [Period] Varchar(50), InitialDate Varchar(8), FinalDate Varchar(8))

BEGIN
	DECLARE @vPeriod		Varchar(50)
	DECLARE @vInitialDate	Varchar(8)
	DECLARE @vFinalDate		Varchar(8)
	DECLARE @vFiscalYear	Varchar(6) = (SELECT [Value] FROM Cat_General_Parameters WHERE Id_Parameter = 41) 
		
	IF @pvIdPeriod = 'CM' --Mes Actual <Current Month>
	BEGIN
		SET @vPeriod = 'Current Month'
		SET @vFinalDate = CONVERT(VARCHAR(8),(EOMONTH (GETDATE())), 112)
		SET @vInitialDate = CONVERT(VARCHAR(8), (@vFinalDate-DAY(@vFinalDate)+1 ), 112)
	END

	IF @pvIdPeriod = 'LM' --Mes Anterior <Last Month>
	BEGIN
		SET @vPeriod = 'Last Month'
		SET @vFinalDate = CONVERT(VARCHAR(8),(EOMONTH (GETDATE(), -1)), 112)
		SET @vInitialDate = CONVERT(VARCHAR(8), (@vFinalDate-DAY(@vFinalDate)+1 ), 112)
	END

	IF @pvIdPeriod = 'NM' --Mes Siguiente <Next Month> 
	BEGIN
		SET @vPeriod = 'Next Month'
		SET @vFinalDate = CONVERT(VARCHAR(8),(EOMONTH (GETDATE(), 1)), 112)
		SET @vInitialDate = CONVERT(VARCHAR(8), (@vFinalDate-DAY(@vFinalDate)+1 ), 112)
	END

	IF @pvIdPeriod = 'CY' --Año Actual <Current Year>
	BEGIN
		SET @vPeriod = 'Current Year'
		SET @vFinalDate = CONVERT(VARCHAR(8),(EOMONTH (@vFiscalYear + '01')), 112)
		SET @vInitialDate = CONVERT(VARCHAR(8), (@vFinalDate-DAY(@vFinalDate)+1 ), 112)
		SET @vFinalDate = CONVERT(VARCHAR(8),DATEADD(YEAR,1,(DATEADD(MONTH,-1,@vFinalDate))), 112)
	END
   

	IF @pvIdPeriod = 'LY' --Año Anterior <Last Year>
	BEGIN
	--RESTAR EL AÑO FISCAL -1
		SET @vPeriod = 'Last Year'
		SET @vFinalDate = CONVERT(VARCHAR(8),(DATEADD(YEAR,-1,(EOMONTH (@vFiscalYear + '01')))), 112)
		SET @vInitialDate = CONVERT(VARCHAR(8), (@vFinalDate-DAY(@vFinalDate)+1 ), 112)
		SET @vFinalDate = CONVERT(VARCHAR(8),DATEADD(YEAR,1,(DATEADD(MONTH,-1,@vFinalDate))), 112)
	END


	INSERT INTO @Table (IdPeriod, [Period], InitialDate, FinalDate)
	VALUES(@pvIdPeriod, @vPeriod, @vInitialDate,@vFinalDate )

RETURN
END
