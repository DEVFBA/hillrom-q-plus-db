USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
 
/* ==================================================================================*/
-- spGetApprovalFlowsExcelFile
/* ==================================================================================*/	
PRINT 'Crea Procedure: spGetApprovalFlowsExcelFile'

IF OBJECT_ID('[dbo].[spGetApprovalFlowsExcelFile]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spGetApprovalFlowsExcelFile
GO

/*
Autor:		Angel Gutierrez
Desc:		Approval Flows | Read
Date:		10/12/2026
Example:
			EXEC spGetApprovalFlowsExcelFile @pvOptionCRUD = 'R', 
                                             @piMode = 1, 
                                             @pvSalesType = 'DIRSA',
                                             @pvIdCountry = 'MX',
                                             @pvIdLanguageUser = 'ANG', 
                                             @pvUser = 'ANGUTIERRE', 
                                             @pvIP = 'TEST';
            
            EXEC spGetApprovalFlowsExcelFile @pvOptionCRUD = 'R', 
                                             @piMode = 2, 
                                             @pvSalesType = 'DIRSA',
                                             @pvIdCountry = 'MX',
                                             @piMaxSeq = 10,
                                             @pvIdLanguageUser = 'ANG', 
                                             @pvUser = 'ANGUTIERRE', 
                                             @pvIP = 'TEST';

			EXEC spGetApprovalFlowsExcelFile @pvOptionCRUD = 'R', 
                                             @piMode = 3, 
                                             @pvSalesType = 'DIRSA',
                                             @pvIdCountry = 'MX',
                                             @piMaxSeq = 10,
                                             @pvIdLanguageUser = 'ANG', 
                                             @pvUser = 'ANGUTIERRE', 
                                             @pvIP = 'TEST';

*/
CREATE PROCEDURE [dbo].spGetApprovalFlowsExcelFile
@pvOptionCRUD		Varchar(1),
@pvIdLanguageUser	Varchar(10) = '',
@pvUser				Varchar(50) = '',
@pvIP				Varchar(20) = '',
@pvSalesType		Varchar(10) = '',
@pvIdCountry		Varchar(10) = '',
@piMaxSeq			Int			= 0,
@piMode             Int         = 0
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Get Approval Flows Excel - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spGetApprovalFlowsExcelFile @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') 
																			+ "', @piMode = '" + ISNULL(CAST(@piMode AS VARCHAR),'NULL')
																			+ "', @pvSalesType = '" + ISNULL(@pvSalesType,'NULL')
																			+ "', @pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL')
																			+ "', @piMaxSeq = '" + ISNULL(CAST(@piMaxSeq AS VARCHAR),'NULL')
                                                                            + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL')  
                                                                            + "', @pvUser = '" + ISNULL(@pvUser,'NULL') 
                                                                            + "', @pvIP = '" + ISNULL(@pvIP,'NULL') 
                                                                            + "'"
	
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
        
		IF @piMode = 1 -- Get the Approvers for the sales type and country
		BEGIN
			
			WITH cteSalesTypeCountryApprovalFlows AS (SELECT
															*
													FROM vwApprovalsFlows
													WHERE 
																Id_Sales_Type = @pvSalesType
															AND Id_Country = @pvIdCountry
			)
			SELECT
				Approval_Flow_Sequence,
				[User_Name],
				Role_Desc,
				Id_Role,
				REPLACE(Discount_Zone_Desc, 'Discount ', ' ') + ' (' + REPLACE(Sales_Type_Desc, ' Sale', '') + ')' AS Zone_Sales_Type
			FROM cteSalesTypeCountryApprovalFlows
			GROUP BY
					Approval_Flow_Sequence,
					[User_Name],
					Role_Desc,
					Id_Role,
					Discount_Zone_Desc,
					Sales_Type_Desc
			ORDER BY
					Approval_Flow_Sequence;

		END
		
		IF @piMode = 2 -- Get the Floor Discount
		BEGIN
			
			WITH cteSalesTypeCountryApprovalFlows AS (SELECT
												*
										  FROM vwApprovalsFlows
										  WHERE 
													Id_Sales_Type = @pvSalesType
												AND Id_Country = @pvIdCountry
			),
			cteMaxSeq AS (SELECT 
								Id_Approval_Flow,
								MAX(Approval_Flow_Sequence) AS MaxSeq
						FROM vwApprovalsFlows
						WHERE Id_Role <> 'SPAPP'
						GROUP BY Id_Approval_Flow),
			cteApprovalFlowsByMaxLevel AS (SELECT
												Id_Approval_Flow
										FROM cteMaxSeq
										WHERE 
												MaxSeq = @piMaxSeq)
			SELECT
				Id_Approval_Flow,
				Discount_Category_Desc,
				Approval_Flow_Sequence,
				Id_Role,
				CAST((FLOOR(Bottom_Limit * 2) / 2.0) AS VARCHAR(MAX)) + '%' AS [KAE]
			FROM cteSalesTypeCountryApprovalFlows
			WHERE
					Id_Role <> 'SPAPP'
				AND Id_Approval_Flow IN (SELECT
											Id_Approval_Flow
										FROM cteApprovalFlowsByMaxLevel)
			GROUP BY
				Id_Approval_Flow,
				Discount_Category_Desc,
				Approval_Flow_Sequence,
				Id_Role,
				Bottom_Limit,
				Upper_Limit
			ORDER BY
					Discount_Category_Desc ASC;

		END
		
		IF @piMode = 3 -- Get the columns of each role
		BEGIN

			DECLARE @maxApprover AS BIT;

			SET @maxApprover = dbo.fnIsMaxPSSApprover(@pvIdLanguageUser, @pvSalesType, @pvIdCountry, @piMaxSeq);
			
			WITH cteSalesTypeCountryApprovalFlows AS (SELECT
												*
										  FROM vwApprovalsFlows
										  WHERE 
													Id_Sales_Type = @pvSalesType
												AND Id_Country = @pvIdCountry
			),
			cteMaxSeq AS (SELECT 
								Id_Approval_Flow,
								MAX(Approval_Flow_Sequence) AS MaxSeq
						FROM vwApprovalsFlows
						WHERE Id_Role <> 'SPAPP'
						GROUP BY Id_Approval_Flow),
			cteApprovalFlowsByMaxLevel AS (SELECT
												Id_Approval_Flow
										FROM cteMaxSeq
										WHERE 
												MaxSeq = @piMaxSeq)
			SELECT
				Id_Approval_Flow,
				Id_Discount_Category,
				Discount_Category_Desc,
				Approval_Flow_Sequence,
				Id_Role,
				CAST(Bottom_Limit AS VARCHAR(MAX)) + '%' AS [Low],
				--CAST(Upper_Limit AS VARCHAR(MAX)) + '%' AS [High]
				(CASE @maxApprover
					WHEN 0 THEN CAST(Upper_Limit AS VARCHAR(MAX)) + '%'
					ELSE (SELECT
								CAST(Max_Allowed_Discount AS VARCHAR(MAX)) + '%'
						  FROM Max_Allowed_Discounts AS MAD
						  WHERE
						  		MAD.Id_Discount_Category = cteSalesTypeCountryApprovalFlows.Id_Discount_Category)
				END) AS [High]
			FROM cteSalesTypeCountryApprovalFlows
			WHERE
					Id_Role <> 'SPAPP'
				AND Id_Approval_Flow IN (SELECT
											Id_Approval_Flow
										FROM cteApprovalFlowsByMaxLevel)
				AND Approval_Flow_Sequence = @piMaxSeq
			GROUP BY
				Id_Approval_Flow,
				Id_Discount_Category,
				Discount_Category_Desc,
				Approval_Flow_Sequence,
				Id_Role,
				Bottom_Limit,
				Upper_Limit
			ORDER BY
					Discount_Category_Desc ASC;

		END

	END

	--------------------------------------------------------------------
	--Register Transaction Log
	--------------------------------------------------------------------
	EXEC spSecurity_Transaction_Log_Ins_Record	@pvDescription	= @vDescription, 
												@pvExecCommand	= @vExecCommand,
												@pbSuccessful	= @bSuccessful, 
												@pvMessagetType = @vMessageType,
												@pvMessage		= @vMessage, 
												@pvUser			= @pvUser, 
													@pnIdTransacLog	= @nIdTransacLog OUTPUT
	SET NOCOUNT OFF

	IF @pvOptionCRUD <> 'R'
	SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog

END TRY
BEGIN CATCH
	--------------------------------------------------------------------
	-- Exception Handling
	--------------------------------------------------------------------
	SET @vMessageType	= dbo.fnGetTransacMessages('ERR',@pvIdLanguageUser)	--Erro
	SET @vMessage		= dbo.fnGetTransacErrorBD()
	SET @bSuccessful	= 0 --Execution with errors
	EXEC spSecurity_Transaction_Log_Ins_Record	@pvDescription	= @vDescription, 
												@pvExecCommand	= @vExecCommand,
												@pbSuccessful	= @bSuccessful, 
												@pvMessagetType = @vMessageType,
												@pvMessage		= @vMessage, 
												@pvUser			= @pvUser, 
												@pnIdTransacLog	= @nIdTransacLog OUTPUT
	
	SET @vMessage		= dbo.fnGetTransacMessages('Generic Error',@pvIdLanguageUser)
	SET NOCOUNT OFF
		SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog
		
END CATCH
