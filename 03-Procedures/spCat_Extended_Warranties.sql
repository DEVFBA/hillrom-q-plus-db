USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Extended_Warranties
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Extended_Warranties'

IF OBJECT_ID('[dbo].[spCat_Extended_Warranties]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Extended_Warranties
GO
/*
Autor:		Alejandro Zepeda
Desc:		Cat_Extended_Warranties | Create - Read - Upadate - Delete 
Date:		10/06/2021
Example:
			spCat_Extended_Warranties @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdLine = 'CH700B3', @piIdYearWarranty = 1 ,  @piIdApprovalFlow = 1, @pfPercentage = 1.30, @pvCodeWarranty = 'CodeABC', @pfCostPercentageWarranty = 50, @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			<R, @pvIdLine = '305MABE'
			spCat_Extended_Warranties @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG',@pvIdItem = 'P1441B000001', @piIdYearWarranty = 0 
			spCat_Extended_Warranties @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdLine = 'ACCELLA', @piIdYearWarranty = 1 , @piIdApprovalFlow = 2,  @pfPercentage = 2.8, @pvCodeWarranty = 'CodeABC', @pfCostPercentageWarranty = 50, @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Extended_Warranties @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdLine = 'ACCELLA', @piIdYearWarranty = 1 , @pfPercentage = 2.8, @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			
			spCat_Extended_Warranties @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdItem='HR900 X3', @piIdYearWarranty = 3
			spCat_Extended_Warranties @pvOptionCRUD = 'R', @pvIdLanguageUser = 'SPA'

			select * from Cat_Extended_Warranties
*/
CREATE PROCEDURE [dbo].spCat_Extended_Warranties
@pvOptionCRUD				Varchar(1),
@pvIdLanguageUser			Varchar(10) = 'ANG',
@pvIdLine					Varchar(10) = '',
@piIdYearWarranty			Smallint	= 0,
@piIdApprovalFlow			Smallint	= 0,	
@pvIdItem					Varchar(50) = '',
@pfPercentage				Float		= 0,
@pvCodeWarranty				Varchar(50) = '',
@pfCostPercentageWarranty	Float		= 0,
@pbStatus					Bit			= '',
@pvUser						Varchar(50) = '',
@pvIP						Varchar(20) = ''
AS
SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	IF @piIdApprovalFlow = 0 SET @piIdApprovalFlow = NULL
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Cat_Extended_Warranties - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Extended_Warranties @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser = '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdLine = '" + ISNULL(@pvIdLine,'NULL') + "', @piIdYearWarranty = " + ISNULL(CAST(@piIdYearWarranty AS VARCHAR),'NULL') + ", @pvIdItem = '" + ISNULL(@pvIdItem,'NULL') + "', @piIdApprovalFlow = " + ISNULL(CAST(@piIdApprovalFlow AS VARCHAR),'NULL') + ", @pfPercentage = " + ISNULL(CAST(@pfPercentage AS VARCHAR),'NULL') + ", @pvCodeWarranty = '" + ISNULL(@pvCodeWarranty,'NULL') + "', @pfCostPercentageWarranty = " + ISNULL(CAST(@pfCostPercentageWarranty AS VARCHAR),'NULL') + ", @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Extended_Warranties WHERE Id_Line = @pvIdLine AND Id_Year_Warranty = @piIdYearWarranty )
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Cat_Extended_Warranties(
				Id_Line,
				Id_Year_Warranty,		
				Id_Approval_Flow,
				Percentage_Warranty,
				Code_Warranty,
				Cost_Percentage_Warranty,
				Status,
				Modify_Date,
				Modify_By,
				Modify_IP)
			VALUES (
				@pvIdLine,
				@piIdYearWarranty,
				@piIdApprovalFlow,
				@pfPercentage,
				@pvCodeWarranty,
				@pfCostPercentageWarranty,
				@pbStatus,
				GETDATE(),
				@pvUser,
				@pvIP)
		END
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT DISTINCT
		W.Id_Line,
		Line_Desc = L.Short_Desc,
		W.Id_Year_Warranty,
		Year_Warranty= Y.Short_Desc,
		W.Id_Approval_Flow,
		Approval_Flow_Desc = AF.Short_Desc,
		Percentage_Warranty,
		Percentage_Warranty_Accumulate = (	SELECT SUM(A.Percentage_Warranty) 
											FROM Cat_Extended_Warranties A
											WHERE A.Id_Line = W.Id_Line
											AND A.Id_Year_Warranty <= @piIdYearWarranty
										 ),
		Code_Warranty,
		Cost_Percentage_Warranty,
		W.[Status],
		W.Modify_Date,
		W.Modify_By,
		W.Modify_IP
		FROM Cat_Extended_Warranties W

		INNER JOIN Cat_Years_Warranty Y ON 
		W.Id_Year_Warranty = Y.Id_Year_Warranty AND
		Y.Id_Language = @pvIdLanguageUser

		INNER JOIN Cat_Lines L WITH(NOLOCK) ON 
		W.Id_Line = L.Id_Line
		
		INNER JOIN Items_Configuration IC WITH(NOLOCK) ON
		L.Id_Line = IC.Id_Line

		LEFT OUTER JOIN Cat_Approvals_Flows AF WITH(NOLOCK) ON
		W.Id_Approval_Flow = AF.Id_Approval_Flow
		
		WHERE 
		(@pvIdLine = '' OR W.Id_Line = @pvIdLine) AND 
		(@piIdYearWarranty = 0 OR W.Id_Year_Warranty = @piIdYearWarranty) AND 
		(@pvIdItem = '' OR IC.Id_Item = @pvIdItem) AND
		(@piIdApprovalFlow IS NULL OR W.Id_Approval_Flow = @piIdApprovalFlow)
		ORDER BY W.Id_Line, W.Id_Year_Warranty
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Extended_Warranties 
		SET 
			Id_Approval_Flow			= @piIdApprovalFlow,
			Percentage_Warranty			= @pfPercentage,
			Code_Warranty				= @pvCodeWarranty,
			Cost_Percentage_Warranty	= @pfCostPercentageWarranty,
			[Status]					= @pbStatus,
			Modify_Date					= GETDATE(),
			Modify_By					= @pvUser,
			Modify_IP					= @pvIP
		WHERE Id_Line					= @pvIdLine  
		AND	Id_Year_Warranty = @piIdYearWarranty 
	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D' OR @vDescOperationCRUD = 'N/A'
	BEGIN
		SET @bSuccessful	= 0
		SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
		SET @vMessage		= dbo.fnGetTransacMessages('N/A',@pvIdLanguageUser)
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
