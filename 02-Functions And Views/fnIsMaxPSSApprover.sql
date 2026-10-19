USE [DBQS]
GO
/****** Object:  UserDefinedFunction [dbo].[fnIsMaxPSSApprover]    Script Date: 02/05/2024 10:09:09 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- fnIsMaxPSSApprover
/* ==================================================================================*/
PRINT 'Crea fnIsMaxPSSApprover'

IF OBJECT_ID('[dbo].[fnIsMaxPSSApprover]') IS NOT NULL
       DROP FUNCTION [dbo].[fnIsMaxPSSApprover]
GO

/*
Author		: Angel Gutierrez
Descrption	: Returns Approval Flow Sequence for a Sales Type and Country
Creation	: 10/18/2026

Example:
		SELECT dbo.fnIsMaxPSSApprover('ANG', 'DIRSA', 'MX', 10)
*/
CREATE FUNCTION [dbo].[fnIsMaxPSSApprover](@pvIdLanguageUser VARCHAR(10), @pvIdSalesType VARCHAR(10), @pvIdCountry VARCHAR(10), @piApprovalSequence INT)
RETURNS BIT
AS
BEGIN

    DECLARE @maxApproverFlowSequence INT;

    SET @maxApproverFlowSequence = (SELECT
                                        MAX(Approval_Flow_Sequence)
                                    FROM vwApprovalsFlows
                                    WHERE
                                            Id_Sales_Type = @pvIdSalesType
                                        AND Id_Country = @pvIdCountry
                                        AND Id_Role <> 'SPAPP');

    IF @piApprovalSequence = @maxApproverFlowSequence
        RETURN 1;

    RETURN 0;
END
GO

