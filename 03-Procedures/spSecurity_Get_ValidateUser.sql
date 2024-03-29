USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spSecurity_Get_ValidateUser
/* ==================================================================================*/	
PRINT 'Crea Procedure: spSecurity_Get_ValidateUser'

IF OBJECT_ID('[dbo].[spSecurity_Get_ValidateUser]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spSecurity_Get_ValidateUser
GO
/*
Author:
Description:
Date:
Example: exec spSecurity_Get_ValidateUser 'MIHAMILTON','HillRom2020'
*/
CREATE PROCEDURE [dbo].[spSecurity_Get_ValidateUser]
@pvUser		Varchar(20),
@pvPassword	Varchar(255)
AS

DECLARE @Id_Rol  varchar(10)
DECLARE @User  varchar(20)
DECLARE @Final_Effective_Date  datetime
DECLARE @Id_Language  varchar(10)

BEGIN TRY



SELECT @User = isnull(max([User]),''), @Id_Rol = isnull(max(Id_Role),0),@Final_Effective_Date = MAX(Final_Effective_Date), @Id_Language =  isnull(max(Id_Language),'')
FROM Security_Users
WHERE [User] = @pvUser AND [Password] = @pvPassword AND [Status] = 1



IF (@User <> '')
BEGIN

	DECLARE @XMLMenu XML;

	IF (@Final_Effective_Date is null or DATEDIFF(day,getdate(),@Final_Effective_Date) >= 0)
	BEGIN
		--obtiene Menu
	EXECUTE spSecurity_Get_Access @Id_Rol, @Id_Language,  @pXmlOUT = @XMLMenu OUTPUT;

	SELECT	Successfully= '1',
			[Message] = 'OK',
			[User],
			Usr.Id_Role,
			[Role] = Rol.Short_Desc,
			Id_Zone,
			[Name],
			Email = isnull(Email,''),
			Usr.[Status],
			menuXML = isnull(@XMLMenu,''),
			Temporal_Password = ISNULL(Temporal_Password,0),
			Id_Language = ISNULL(Id_Language,''),
			Rol.Id_Business_Line
	FROM Security_Users Usr 
	INNER JOIN Security_Roles Rol ON
			Usr.Id_Role = Rol.Id_Role
	WHERE Usr.[User] = @pvUser

	END
	ELSE
	BEGIN


	DECLARE @EffectiveDay			Int			= (SELECT Value FROM Cat_General_Parameters WHERE Id_Parameter = 2)
	DECLARE @vFinal_Effective_Date	Varchar(8)	= CONVERT(VARCHAR(8),DATEADD(DAY,@EffectiveDay,GETDATE()),112)

	update Security_Users
	set Final_Effective_Date = @vFinal_Effective_Date
	WHERE [User] = @pvUser


	EXECUTE spSecurity_Get_Access @Id_Rol, @Id_Language,  @pXmlOUT = @XMLMenu OUTPUT;

	SELECT	Successfully= '1',
			[Message] = 'OK',
			[User],
			Usr.Id_Role,
			[Role] = Rol.Short_Desc,
			Id_Zone,
			[Name],
			Email = isnull(Email,''),
			Usr.[Status],
			menuXML = isnull(@XMLMenu,''),
			Temporal_Password = CAST('1' as bit),
			Id_Language = ISNULL(Id_Language,''),
			Rol.Id_Business_Line
	FROM Security_Users Usr 
	INNER JOIN Security_Roles Rol ON
			Usr.Id_Role = Rol.Id_Role
	WHERE Usr.[User] = @pvUser



		--SELECT 
		--Successfully= '0',
		--[Message] = 'Your account has expired, please contact the system administrator'
	END



	


END
ELSE
	SELECT 
		Successfully= '0',
		[Message] = 'User not authorized to access the system'

END TRY

BEGIN CATCH
select Successfully= '0',ERROR_MESSAGE() AS [Message]
 
  
END CATCH







