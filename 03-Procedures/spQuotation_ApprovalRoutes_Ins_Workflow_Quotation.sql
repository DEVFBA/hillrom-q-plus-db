USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_ApprovalRoutes_Ins_Workflow_Quotation
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_ApprovalRoutes_Ins_Workflow_Quotation'

IF OBJECT_ID('[dbo].[spQuotation_ApprovalRoutes_Ins_Workflow_Quotation]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_ApprovalRoutes_Ins_Workflow_Quotation
GO

/*
Autor:		Alejandro Zepeda
Desc:		spQuotation Approval WorkFlow | Create - Read - Upadate - Delete 
Date:		09/02/2021
Example:

select * from Quotation WHERE ID_QUOTATION_STATUS = 'ROUT'
select *  from Approval_Workflow_Quotation WHERE folio = 200

	EXEC spQuotation_ApprovalRoutes_Ins_Workflow_Quotation  @piFolio = 290, @piVersion = 1, @pvUser = 'ALZEPEDA', @pvIP ='192.168.1.254'

*/

CREATE PROCEDURE [dbo].spQuotation_ApprovalRoutes_Ins_Workflow_Quotation
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
	DECLARE @pvIdRol				Varchar(10) = (SELECT Id_Role FROM Security_Users WHERE [User] = @pvUser)

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD('C')
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Quotation Approval WorkFlow Quotation - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)	
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spQuotation_ApprovalRoutes_Ins_Workflow_Quotation  @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @piFolio = '" + ISNULL(CAST(@piFolio AS VARCHAR),'NULL') + "', @piVersion = '" + ISNULL(CAST(@piVersion AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"

	--------------------------------------------------------------------
	--Create WorkFlow
	--------------------------------------------------------------------

	-- Validate if the record already exists
	IF EXISTS(SELECT * FROM Approval_Workflow_Quotation WHERE Folio = @piFolio AND [Version] = @piVersion)
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
			--RUTA POR INCOTERM
			/*********************************************************************/
			--Validate if exist Incoterm configuration
			IF (SELECT COUNT(*)
				FROM Cat_Approval_Country_Incoterms ACI
				INNER JOIN Quotation Q ON 
				ACI.Id_Country  = Q.Id_Country_Bill_To AND
				ACI.Id_Incoterm = Q.Id_Incoterm
				WHERE Q.Folio = @piFolio AND Q.[Version] = @piVersion AND ACI.[Status] = 1) > 0
			BEGIN
				-------------------------------------------------------------------
				--Insert flow por Incoterm
				-------------------------------------------------------------------
				INSERT INTO Approval_Workflow_Quotation(
						Folio,
						[Version],
						Id_Approval_Section,
						Id_Approval_Type,
						Id_Approval_Flow,
						Id_Role,
						Id_Approval_Status,
						Approval_Flow_Sequence,
						Approval_Information,
						Comments,
						Modify_By,
						Modify_Date,
						Modify_IP)
				SELECT 
						Q.Folio,
						Q.[Version],
						Id_Approval_Section = 2, -- Quotation
						Id_Approval_Type = 1, -- Incoterm
						APT.Id_Approval_Flow,
						APT.Id_Role,
						Id_Approval_Status = 'PTA',
						SR.Approval_Flow_Sequence,
						Approval_Information = Q.Id_Incoterm + ' - ' + INC.Short_Desc ,
						Comments	= '',
						Modify_By	= @pvUser,
						Modify_Date = GETDATE(),
						Modify_IP	= @pvIP

				FROM Quotation Q 

				INNER JOIN Cat_Approval_Country_Incoterms ACI ON
				Q.Id_Country_Bill_To  = ACI.Id_Country AND
				Q.Id_Incoterm	= ACI.Id_Incoterm AND 
				ACI.[Status] = 1

				INNER JOIN Cat_Incoterm INC ON
				Q.Id_Incoterm = INC.Id_Incoterm AND
				Q.Id_Language = INC.Id_Language

				INNER JOIN Approval_Tracker  APT ON   
				ACI.Id_Approval_Flow = APT.Id_Approval_Flow

				INNER JOIN Security_Roles SR ON 
				APT.Id_Role = SR.Id_Role

				WHERE 
				Q.Folio = @piFolio AND 
				Q.[Version] = @piVersion

				ORDER BY SR.Approval_Flow_Sequence

	
			END

			/*********************************************************************/
			--RUTA POR PAYMENT TERMS
			/*********************************************************************/
			--Validate if exist Incoterm configuration
			IF (SELECT COUNT(*)
				FROM Cat_Payment_Terms PT
				INNER JOIN Quotation Q ON 
				PT.Id_Payment_Term  = PT.Id_Payment_Term
				WHERE Q.Folio = @piFolio AND Q.[Version] = @piVersion AND PT.[Status] = 1)  > 0
			BEGIN

				-------------------------------------------------------------------
				--Insert flow por Payment Terms
				-------------------------------------------------------------------
				INSERT INTO Approval_Workflow_Quotation(
						Folio,
						[Version],
						Id_Approval_Section,
						Id_Approval_Type,
						Id_Approval_Flow,
						Id_Role,
						Id_Approval_Status,
						Approval_Flow_Sequence,
						Approval_Information,
						Comments,
						Modify_By,
						Modify_Date,
						Modify_IP)
				SELECT 
						Q.Folio,
						Q.[Version],
						Id_Approval_Section = 2, -- Quotation
						Id_Approval_Type = 2, -- Payment Terms
						APT.Id_Approval_Flow,
						APT.Id_Role,
						Id_Approval_Status = 'PTA',
						SR.Approval_Flow_Sequence,
						Approval_Information = Q.Id_Payment_Term + ' - ' + PT.Short_Desc ,
						Comments	= '',
						Modify_By	= @pvUser,
						Modify_Date = GETDATE(),
						Modify_IP	= @pvIP

				FROM Quotation Q 

				INNER JOIN Cat_Payment_Terms PT ON
				Q.Id_Payment_Term = PT.Id_Payment_Term AND
				Q.Id_Language = PT.Id_Language AND
				PT.[Status] = 1

				INNER JOIN Approval_Tracker  APT ON   
				PT.Id_Approval_Flow = APT.Id_Approval_Flow

				INNER JOIN Security_Roles SR ON 
				APT.Id_Role = SR.Id_Role

				WHERE 
				Q.Folio = @piFolio AND 
				Q.[Version] = @piVersion

				ORDER BY SR.Approval_Flow_Sequence

	
			END

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
