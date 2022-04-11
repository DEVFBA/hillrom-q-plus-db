USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_ApprovalRoutes_Ins_Workflow_Discounts
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_ApprovalRoutes_Ins_Workflow_Discounts'

IF OBJECT_ID('[dbo].[spQuotation_ApprovalRoutes_Ins_Workflow_Discounts]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_ApprovalRoutes_Ins_Workflow_Discounts
GO

/*
Autor:		Alejandro Zepeda
Desc:		spQuotation Approval WorkFlow | Create - Read - Upadate - Delete 
Date:		09/02/2021
Example:

select * from Quotation WHERE ID_QUOTATION_STATUS = 'ROUT'
delete from Approval_Workflow WHERE folio = 200
	EXEC spQuotation_ApprovalRoutes_Ins_Workflow_Discounts  @piFolio = 290, @piVersion = 1, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'

*/

CREATE PROCEDURE [dbo].spQuotation_ApprovalRoutes_Ins_Workflow_Discounts
@pvIdLanguageUser	Varchar(10) = '',
@piFolio			Int			= 0,
@piVersion			Int			= 0,
@pvUser				Varchar(50) = '',
@pvIP				Varchar(20) = ''
AS

BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD		Varchar(50) = dbo.fnGetOperationCRUD('C')
	DECLARE @pvIdRol				Varchar(10) = (SELECT Id_Role FROM Security_Users WHERE [User] = @pvUser)
	DECLARE @tblDscountTypes		TABLE (Item_Template Varchar(50),Total Float, Id_Discount_Type Varchar(10) )
	DECLARE @fMinimumRouteAmount	FLOAT = (SELECT [Value] FROM Cat_General_Parameters WHERE Id_Parameter = 21)
	DECLARE @fExchangeRate			FLOAT = (SELECT ER.Exchange_Rate FROM Cat_Exchange_Rates ER
											INNER JOIN Quotation Q ON 
											ER.Id_Currency = Q.Id_Currency AND
											ER.Id_Exchange_Rate = Q.Id_Exchange_Rate
											WHERE Q.Folio = @piFolio AND Q.[Version] = @piVersion )

	SET @fMinimumRouteAmount = @fMinimumRouteAmount * @fExchangeRate
	
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Quotation Approval WorkFlow Discounts - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spQuotation_ApprovalRoutes_Ins_Workflow_Discounts  @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piFolio = '" + ISNULL(CAST(@piFolio AS VARCHAR),'NULL') + "', @piVersion = '" + ISNULL(CAST(@piVersion AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"

	--------------------------------------------------------------------
	--Create WorkFlow
	--------------------------------------------------------------------

	-- Validate if the record already exists
	IF EXISTS(SELECT * FROM Approval_Workflow WHERE Folio = @piFolio AND [Version] = @piVersion)
	BEGIN
		SET @bSuccessful	= 0
		SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
		SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
	END
	ELSE 
	BEGIN
		-------------------------------------------------------------------
		-- Validate if Quote status is in route
		-------------------------------------------------------------------
		IF EXISTS(SELECT * FROM Quotation WHERE Folio = @piFolio AND [Version] = @piVersion AND Id_Quotation_Status = 'ROUT')
		BEGIN

			/*********************************************************************/
			--RUTA POR DISCOUNT
			/*********************************************************************/
			INSERT INTO @tblDscountTypes
			SELECT	QH.Item_Template, 
					Total = (SELECT SUM(Total) Quotation_Header from Quotation_Header where  Folio = QH.Folio  AND [Version] = QH.[Version]),
					Id_Discount_Type = (CASE AD.Apply_Amount
										WHEN 1 THEN --Si el item aplica por monto
												--Valida si entra dentro del monto minimo
												(CASE WHEN ((SELECT SUM(Total) Quotation_Header from Quotation_Header where  Folio = QH.Folio  AND [Version] = QH.[Version])) >= @fMinimumRouteAmount THEN 'AMOU'
													ELSE 'PERC' -- si o lo deja por porcentaje
												 END)
										ELSE AD.Id_Discount_Type
									END)
			FROM Approved_Discounts AD

			INNER JOIN Cat_Item I ON
			AD.Id_Discount_Category = I.Id_Discount_Category

			INNER JOIN Quotation_Header QH ON
			I.Id_Item = QH.Item_Template

			INNER JOIN Quotation Q ON 
			QH.Folio = Q.Folio AND
			QH.[Version] = Q.[Version] 

			INNER JOIN Cat_Zones_Countries ZC ON 
			Q.Id_Country_Bill_To = ZC.Id_Country
			
			INNER JOIN Cat_Zones Z ON 
			ZC.Id_Zone = Z.Id_Zone AND
			AD.Id_Zone = Z.Id_Zone AND
			Z.Id_Zone_Type = 'DISC'

			WHERE QH.Folio = @piFolio AND QH.[Version] = @piVersion 
			AND AD.Id_Discount_Type = 'PERC'
			AND QH.Discount BETWEEN AD.Bottom_Limit AND AD.Upper_Limit	


			-------------------------------------------------------------------
			--Insert flow
			-------------------------------------------------------------------
			INSERT INTO Approval_Workflow(
					Folio,
					[Version],
					Id_Header,
					Item_Template,
					Id_Approval_Flow,
					Id_Role,
					Id_Approval_Status,
					Approval_Flow_Sequence,
					Comments,
					Modify_By,
					Modify_Date,
					Modify_IP)
			-------------------------------------------------------------------
			-- For Percentage
			-------------------------------------------------------------------
			SELECT 
					QH.Folio,
					QH.[Version],
					QH.Id_Header,
					QH.Item_Template,
					APT.Id_Approval_Flow,
					APT.Id_Role,
					Id_Approval_Status = 'PTA',
					SR.Approval_Flow_Sequence,
					Comments	= '',
					Modify_By	= @pvUser,
					Modify_Date = GETDATE(),
					Modify_IP	= @pvIP
			FROM Approved_Discounts AD

			INNER JOIN Cat_Item I ON
			AD.Id_Discount_Category = I.Id_Discount_Category

			INNER JOIN Quotation_Header QH ON
			I.Id_Item = QH.Item_Template

			INNER JOIN @tblDscountTypes TMP ON
			QH.Item_Template	= TMP.Item_Template AND
			AD.Id_Discount_Type = TMP.Id_Discount_Type

			INNER JOIN Quotation Q ON 
			QH.Folio = Q.Folio AND
			QH.[Version] = Q.[Version] 

			INNER JOIN Cat_Zones_Countries ZC ON 
			Q.Id_Country_Bill_To = ZC.Id_Country
			
			INNER JOIN Cat_Zones Z ON 
			ZC.Id_Zone = Z.Id_Zone AND
			AD.Id_Zone = Z.Id_Zone AND
			Z.Id_Zone_Type = 'DISC'

			INNER JOIN Approval_Tracker  APT ON   
			AD.Id_Approval_Flow = APT.Id_Approval_Flow

			INNER JOIN Security_Roles SR ON 
			APT.Id_Role = SR.Id_Role

			WHERE QH.Folio = @piFolio AND QH.[Version] = @piVersion 
			AND QH.Discount BETWEEN AD.Bottom_Limit AND AD.Upper_Limit
			AND AD.Id_Discount_Type = 'PERC'
	
			
		UNION ALL
		-------------------------------------------------------------------
		-- For Amount	
		-------------------------------------------------------------------
			SELECT 
					QH.Folio,
					QH.[Version],
					QH.Id_Header,
					QH.Item_Template,
					APT.Id_Approval_Flow,
					APT.Id_Role,
					Id_Approval_Status = 'PTA',
					SR.Approval_Flow_Sequence,
					Comments	= '',
					Modify_By	= @pvUser,
					Modify_Date = GETDATE(),
					Modify_IP	= @pvIP
			FROM Approved_Discounts AD

			INNER JOIN Cat_Item I ON
			AD.Id_Discount_Category = I.Id_Discount_Category

			INNER JOIN Quotation_Header QH ON
			I.Id_Item = QH.Item_Template

			INNER JOIN @tblDscountTypes TMP ON
			QH.Item_Template = TMP.Item_Template AND
			AD.Id_Discount_Type = TMP.Id_Discount_Type

			INNER JOIN Quotation Q ON 
			QH.Folio = Q.Folio AND
			QH.[Version] = Q.[Version] 

			INNER JOIN Cat_Zones_Countries ZC ON 
			Q.Id_Country_Bill_To = ZC.Id_Country
			
			INNER JOIN Cat_Zones Z ON 
			ZC.Id_Zone = Z.Id_Zone AND
			AD.Id_Zone = Z.Id_Zone AND
			Z.Id_Zone_Type = 'DISC'

			INNER JOIN Approval_Tracker  APT ON   
			AD.Id_Approval_Flow = APT.Id_Approval_Flow

			INNER JOIN Security_Roles SR ON 
			APT.Id_Role = SR.Id_Role

			WHERE QH.Folio = @piFolio AND QH.[Version] = @piVersion 
			AND TMP.Total BETWEEN (AD.Bottom_Limit * @fExchangeRate) AND (AD.Upper_Limit * @fExchangeRate)	
			AND AD.Id_Discount_Type = 'AMOU'
					
			
			ORDER BY  QH.Item_Template, SR.Approval_Flow_Sequence
			

			/*********************************************************************/
			--RUTA POR EXTENDED WARRANTY
			/*********************************************************************/





			-------------------------------------------------------------------
			-- Update Flow PRAPP Rol
			-------------------------------------------------------------------
			IF @pvIdRol = 'PRAPP'
			BEGIN 
				 UPDATE Approval_Workflow
				 SET Id_Approval_Status = 'APP'
				 WHERE Folio = @piFolio AND [Version] = @piVersion 
				 AND Id_Role = @pvIdRol
			END 
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
	SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog
END TRY
BEGIN CATCH
	--------------------------------------------------------------------
	-- Exception Handling
	--------------------------------------------------------------------
	SET @vMessageType	= dbo.fnGetTransacMessages('ERR',@pvIdLanguageUser)	--Error
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
