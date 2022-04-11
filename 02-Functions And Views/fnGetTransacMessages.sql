USE DBQS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/* ==================================================================================*/
-- fnGetTransacMessages
/* ==================================================================================*/	
PRINT 'Crea fnGetTransacMessages'

IF OBJECT_ID('[dbo].[fnGetTransacMessages]','FN') IS NOT NULL
       DROP FUNCTION [dbo].fnGetTransacMessages
GO

/*
Author:		Alejandro Zepeda
Desc:		Gets the type of Messages
Creation:	03-12-2020
Return 
			@vTransacMessage Varchar(255)
Example:	
			Declare @vTransacMessage Varchar(50)
			SET @vTransacMessage = dbo.fnGetTransacMessages('OK','BRA')
			SELECT @vTransacMessage
*/
CREATE FUNCTION [dbo].[fnGetTransacMessages](@pvTypeMessage Varchar(50), @pvIdLanguageUser Varchar(10))
RETURNS VARCHAR(Max)
AS
BEGIN
	Declare @vTransacMessage Varchar(255)
	IF  @pvIdLanguageUser = ''  SET @pvIdLanguageUser = 'ANG'
	
	SET @vTransacMessage = ISNULL((SELECT Translation 
							FROM Lenguages_Translation 
							WHERE Interface_Name	= 'DataBase' AND  
								  [Object_Name]		= 'TransacMessages' AND
								  SubObject_Name	= @pvTypeMessage AND
								  Id_Language		= @pvIdLanguageUser),'Translation not found')
	RETURN @vTransacMessage
END
GO

