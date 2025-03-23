USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spNotification_Quotation_Pending_to_Approve_List_CRUD_Records]    Script Date: 3/23/2025 12:38:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
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
ALTER PROCEDURE [dbo].[spNotification_Quotation_Pending_to_Approve_List_CRUD_Records]
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
	DECLARE @vApproverNamePrevious	Varchar(50)
	DECLARE @vApproverUserPrevious	Varchar(255) = ''
	DECLARE @vApproverName			Varchar(255)
	DECLARE @vApproverEmail			Varchar(50)
	DECLARE @vApproverEmailPrevious	Varchar(50)
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
		--SELECT Folio,  [Version], MIN(Approval_Flow_Sequence)
		--FROM vwWorkflows 
		--WHERE Id_Approval_Status = @vIdApprovalStatus
		--GROUP BY Folio,  [Version]
		--ORDER BY Folio,  [Version]
		/** AEGH 02/21/25 Correction for Notofication Mail, only retrieve what is actually in Approval Roue **/

		SELECT VW.Folio,  VW.[Version], MIN(VW.Approval_Flow_Sequence)
		FROM vwWorkflows AS VW INNER JOIN Quotation AS Q
							ON VW.Folio = Q.Folio
								AND VW.[Version] = Q.[Version]
								AND Q.Id_Quotation_Status = 'ROUT'
		WHERE VW.Id_Approval_Status = @vIdApprovalStatus
		GROUP BY VW.Folio,  VW.[Version]
		ORDER BY VW.Folio,  VW.[Version]
		/**/

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
		/* mgj 02/21/25 Se corrigió la lógica para el resolver correctamente la asignación del @htmlList a su aprobador correspondiente*/
		BEGIN
			PRINT 'Procesando fila:';
			PRINT 'Usuario: ' + ISNULL(@vApproverUser, 'N/A');
			PRINT 'Folio: ' + CAST(@iFolio AS VARCHAR);
			PRINT 'Versión: ' + CAST(@iVersion AS VARCHAR);
			PRINT 'País: ' + ISNULL(@vCountry, 'N/A');
			PRINT 'Cliente: ' + ISNULL(@vCustomer, 'N/A');
			PRINT '';
			PRINT '';


			/*mgj 21/03/25 Se corrigió la lógica para el resolver correctamente la asignación en el pidntification = 4 */
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

			SET @htmlList = '' 

			END

			/**/
			
			-- Verificar si cambia el usuario
			IF @piIdNotification <> 4 
			BEGIN
			IF @vApproverUserPrevious <> @vApproverUser AND @vApproverUserPrevious <> ''
			BEGIN 
				-- Insertar datos acumulados para el usuario anterior
				INSERT INTO Notification_Quotation_Pending_Approvals(
					Id_Notification,
					Approver,
					Approver_Email,
					Pending_Approvals,
					Register_Date,
					Notification_Send)
				VALUES(
					@piIdNotification,
					@vApproverNamePrevious, -- Usar el nombre y correo del usuario anterior
					@vApproverEmailPrevious,
					@htmlList,
					GETDATE(),
					@bNotificationSend);

				-- Reiniciar el htmlList
				SET @htmlList = ''; 
			END

				-- Actualizar el usuario anterior
				SET @vApproverUserPrevious = @vApproverUser;
				SET @vApproverNamePrevious = @vApproverName; -- Guardar el nombre del usuario actual
				SET @vApproverEmailPrevious = @vApproverEmail; -- Guardar el correo del usuario actual
			END

				-- Concatenar el nuevo registro al htmlList
				SET @htmlList += '<li style="margin-top: 10px;">QN ' + CAST(@iFolio AS VARCHAR) + ' / ' + @vCountry + ' / ' + @vCustomer + '</li>';

				FETCH NEXT FROM ITEM_CURSOR INTO @iFolio, @iVersion, @vCustomer, @vCountry, @vApproverUser, @vApproverName, @vApproverEmail 
			END

			-- Insertar datos restantes al final del bucle
			IF @htmlList <> '' AND @piIdNotification <> 4
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
					@vApproverNamePrevious, -- Usar el nombre y correo del último usuario
					@vApproverEmailPrevious,
					@htmlList,
					GETDATE(),
					@bNotificationSend);
			END

		/* CIERRA CAMBIO */

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