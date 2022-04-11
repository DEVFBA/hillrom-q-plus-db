USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spNotification_Quotation_Status_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spNotification_Quotation_Pending_to_Approve_List_CRUD_Records'

IF OBJECT_ID('[dbo].[spNotification_Quotation_Pending_to_Approve_List_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spNotification_Quotation_Pending_to_Approve_List_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Quotation_Pending_to_Approve_List | Create - Read - Upadate - Delete 
Date:		11/04/2021
Example:
Id_Notification | Short_Desc 
4	Quotation Pending to Approve
5	Quotation Pending to Approve List

			EXEC spNotification_Quotation_Pending_to_Approve_List_CRUD_Records @pvOptionCRUD = 'C', @piIdNotification = 4, @piFolio =  34 , @piVersion = 1, @pvUser = 'SA'
			EXEC spNotification_Quotation_Pending_to_Approve_List_CRUD_Records @pvOptionCRUD = 'C', @piIdNotification = 4, @piFolio =  445 , @piVersion = 1, @pvUser = 'SA'
			spNotification_Quotation_Pending_to_Approve_List_CRUD_Records @pvOptionCRUD = 'C', @piIdNotification = 5

			EXEC spNotification_Quotation_Pending_to_Approve_List_CRUD_Records @pvOptionCRUD = 'R' , @piIdNotification = 4
			EXEC spNotification_Quotation_Pending_to_Approve_List_CRUD_Records @pvOptionCRUD = 'R' , @piIdNotification = 5
			spNotification_Quotation_Pending_to_Approve_List_CRUD_Records @pvOptionCRUD = 'U', @pnIdMailNotification = 1

			select * from Notification_Quotation_Pending_Approvals where notification_send =0
			DELETE Notification_Quotation_Pending_Approvals where notification_send =0
		
*/
create PROCEDURE [dbo].spNotification_Quotation_Pending_to_Approve_List_CRUD_Records
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10) = 'ANG',
@pnIdMailNotification	Numeric		= 0,
@piIdNotification		Int			= 0,
@piFolio				Int			= 0,
@piVersion				Int			= 0,
@pvUser					Varchar(50) = 'sa'

AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vDescOperationCRUD		Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @tblWF_CurrentFolios	TABLE(Folio Int, [Version] Int, Approval_Flow_Sequence Int)
	DECLARE @vIdApprovalStatus		Varchar(20) = 'PTA' --Pending to Appprove
	DECLARE @bNotificationSend		Bit			= 0-- 0 = Not Sent 

	DECLARE @iFolio					Int
	DECLARE @iVersion				Int
	DECLARE @vCustomer				Varchar(255)
	DECLARE @vCountry				Varchar(255)
	DECLARE @vApproverUser			Varchar(50)
	DECLARE @vApproverUserPrevious	Varchar(255) = ''
	DECLARE @vApproverName			Varchar(255)
	DECLARE @vApproverEmail			Varchar(50)
	DECLARE @htmlList				Varchar(MAX) = ''
	
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Notification_Quotation_Pending_to_Approve - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spNotification_Quotation_Pending_to_Approve_List_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pnIdMailNotification = " + ISNULL(CAST(@pnIdMailNotification AS VARCHAR),'NULL') + ", , @piIdNotification = " + ISNULL(CAST(@piIdNotification AS VARCHAR),'NULL') + ", @piFolio = " + ISNULL(CAST(@piFolio AS VARCHAR),'NULL') + ", @piVersion = " + ISNULL(CAST(@piVersion AS VARCHAR),'NULL') + " "
	

	--------------------------------------------------------------------
	--Create Records and Read Not Send
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN

		------------------------------------------------------------
		--Insert Quotation Pending to Approve
		------------------------------------------------------------
		INSERT INTO @tblWF_CurrentFolios
		SELECT Folio,  [Version], MIN(Approval_Flow_Sequence)
		FROM vwWorkflows
		WHERE Id_Approval_Status = @vIdApprovalStatus
		GROUP BY Folio,  [Version]
		ORDER BY Folio,  [Version]

		------------------------------------------------------------
		DECLARE ITEM_CURSOR CURSOR 
		FOR
		SELECT DISTINCT 
		Approval_Roles.Folio,
		Approval_Roles.[Version],
		Quotation.Customer_Bill_To,
		Quotation.Country_Bill_To,
		Users.[User],
		Users.Name,
		Users.Email
		FROM @tblWF_CurrentFolios AS Approval_Roles 

		INNER JOIN [fnQuotation](@pvIdLanguageUser) AS Quotation
		ON Approval_Roles.Folio = Quotation.Folio
		AND Approval_Roles.[Version] = Quotation.[Version]

		INNER JOIN vwWorkflows Workflow ON
		Approval_Roles.Folio = Workflow.Folio AND
		Approval_Roles.[Version] = Workflow.[Version] AND
		Approval_Roles.Approval_Flow_Sequence = Workflow.Approval_Flow_Sequence

		INNER JOIN Cat_Zones_Countries AS Zones
		ON Quotation.Id_Country_Bill_To = Zones.Id_Country AND
		Zones.[Status] = 1

		INNER JOIN Security_Users AS Users
		ON USERS.Id_Zone = Zones.Id_Zone
		AND Users.Id_Role = Workflow.Id_Role AND 
		Users.[Status] = 1
		
		WHERE (@piFolio		= 0	OR Workflow.Folio	  = @piFolio) AND 
			  (@piVersion	= 0	OR Workflow.[Version] = @piVersion)  
		
		ORDER BY Users.[User], Approval_Roles.Folio, Approval_Roles.[Version]

		------------------------------------------------------------

		OPEN ITEM_CURSOR 
		FETCH NEXT FROM ITEM_CURSOR INTO @iFolio, @iVersion, @vCustomer, @vCountry, @vApproverUser, @vApproverName, @vApproverEmail 
 
		WHILE @@FETCH_STATUS = 0 
		BEGIN
 
			--SELECT @vApproverUserPrevious,@vApproverUser, @iFolio, @iVersion, @vCustomer, @vCountry, @vApproverUser, @vApproverName, @vApproverEmail 


			IF @piIdNotification = 4 
			BEGIN 
				SET @htmlList += '<li style = "margin-top: 10px;">									
									QN ' + CAST(@iFolio AS VARCHAR) + ' / ' + @vCountry + ' / ' + @vCustomer + '
								</li>'

				INSERT INTO Notification_Quotation_Pending_Approvals(
					Id_Notification,
					Folio,
					Version,
					Country,
					Customer,
					Approver,
					Approver_Email,
					Pending_Approvals,
					Register_Date,
					Notification_Send)
				VALUES(
					@piIdNotification,
					@iFolio,
					@iVersion,
					@vCountry,
					@vCustomer,
					@vApproverName,
					@vApproverEmail,
					@htmlList,
					GETDATE(),
					@bNotificationSend)
			END
			ELSE
			BEGIN
				IF @vApproverUserPrevious <> @vApproverUser AND @vApproverUserPrevious <> ''
				BEGIN 
					INSERT INTO Notification_Quotation_Pending_Approvals(
							Id_Notification,
							Approver,
							Approver_Email,
							Pending_Approvals,
							Register_Date,
							Notification_Send)
					VALUES(
							@piIdNotification,
							@vApproverName,
							@vApproverEmail,
							@htmlList,
							GETDATE(),
							@bNotificationSend)

					SET @htmlList = '' 

					--PRINT @vApproverUserPrevious
					--PRINT @htmlList
				END

				SET @vApproverUserPrevious =  @vApproverUser
				SET @htmlList += '<li style = "margin-top: 10px;">									
										QN ' + CAST(@iFolio AS VARCHAR) + ' / ' + @vCountry + ' / ' + @vCustomer + '
									</li>'
			END

		FETCH NEXT FROM ITEM_CURSOR INTO @iFolio, @iVersion, @vCustomer, @vCountry, @vApproverUser, @vApproverName, @vApproverEmail 
		END
		
		CLOSE ITEM_CURSOR  
		DEALLOCATE ITEM_CURSOR 

		------------------------------------------------------------
		-- Read Records Not Send
		------------------------------------------------------------

		IF @piIdNotification = 5 
		--5	Quotation Pending to Approve List
		BEGIN 
			SELECT 
				Id_Mail_Notification,
				Folio		=  ISNULL(Folio,0),
				[Version]	=  ISNULL([Version],0),
				Country		=  ISNULL(Country,''),
				Customer	=  ISNULL(Customer,''),
				Approver,
				Approver_Email,
				Pending_Approvals,
				Register_Date,
				Notification_Send
			FROM Notification_Quotation_Pending_Approvals
			WHERE Id_Notification = @piIdNotification AND 
				  Notification_Send = @bNotificationSend	
		RETURN
		END
		
	END

--------------------------------------------------------------------
	--Read Records Sent
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
			Id_Mail_Notification,
			Folio		=  ISNULL(Folio,0),
			[Version]	=  ISNULL([Version],0),
			Country		=  ISNULL(Country,''),
			Customer	=  ISNULL(Customer,''),
			Approver,
			Approver_Email,
			Pending_Approvals,
			Register_Date,
			Notification_Send
		FROM Notification_Quotation_Pending_Approvals
		WHERE Id_Notification = @piIdNotification AND 
				Notification_Send = @bNotificationSend
		RETURN
	END

	--------------------------------------------------------------------
	--Update Records Sent
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		SET  @bNotificationSend = 1 -- Sent

		UPDATE Notification_Quotation_Pending_Approvals 
		SET Notification_Date = GETDATE(),
			Notification_Send = @bNotificationSend
		WHERE Id_Mail_Notification = @pnIdMailNotification
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
	
	IF @pvOptionCRUD = 'U' 
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
	IF @pvOptionCRUD = 'U'
		SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog
		
END CATCH