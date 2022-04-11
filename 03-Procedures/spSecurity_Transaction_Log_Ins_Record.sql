USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spSecurity_Transaction_Log_Ins_Record
/* ==================================================================================*/	
PRINT 'Crea Procedure: spSecurity_Transaction_Log_Ins_Record'

IF OBJECT_ID('[dbo].[spSecurity_Transaction_Log_Ins_Record]','P') IS NOT NULL
       DROP PROCEDURE [dbo].[spSecurity_Transaction_Log_Ins_Record]
GO

/*
Author:		Alejandro Zepeda
Desc:		Register Log
Date:		14/11/2020
Example:	
			DECLARE @nIdTransacLog NUMERIC
			EXEC spSecurity_Transaction_Log_Ins_Record	@pvDescription	= 'Cat_Categories - Insert Record ', 
														@pvExecCommand	= 'EXEC spCat_Categories_Ins_Record ',
														@pbSuccessful	= 1, 
														@pvMessagetType = 'Success',
														@pvMessage		= 'OK', 
														@pvUser			= 'AZEPEDA', 
														@pnIdTransacLog	= @nIdTransacLog OUTPUT
			SELECT @nIdTransacLog
			
			select * from Security_Transaction_Log 
*/
CREATE PROCEDURE [dbo].[spSecurity_Transaction_Log_Ins_Record]
@pvDescription		VARCHAR(255),
@pvExecCommand		VARCHAR(MAX),
@pbSuccessful		Bit, -- 1 - Successful | 0 - With error
@pvMessagetType		VARCHAR(30),
@pvMessage			VARCHAR(MAX),
@pvUser				VARCHAR(20),
@pnIdTransacLog		NUMERIC OUTPUT
AS
SET NOCOUNT ON

INSERT INTO Security_Transaction_Log(
		[Description],
		Register_Date,
		Exec_Command,
		Successful,
		MessagetType,
		[Message],
		[User])
			
VALUES(	@pvDescription,
		GETDATE(),
		@pvExecCommand,
		@pbSuccessful,
		@pvMessagetType,
		@pvMessage,
		@pvUser)
		
			
SET @pnIdTransacLog =  @@IDENTITY

RETURN
