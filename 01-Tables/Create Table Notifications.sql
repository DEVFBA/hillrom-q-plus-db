USE [DBQS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


/*====================================================================================*/
--Cat_General_Parameters
/*====================================================================================*/

	UPDATE Cat_General_Parameters
	SET Type = 'User_Notification'
	WHERE Type = 'User_Email'

	UPDATE Cat_General_Parameters
	SET Long_Desc = 'SMTP Port'
	WHERE Id_Parameter = 24

	UPDATE Cat_General_Parameters
	SET Long_Desc = 'Email From'
	WHERE Id_Parameter = 25

	UPDATE Cat_General_Parameters
	SET Long_Desc = 'SMTP Password'
	WHERE Id_Parameter = 26


	
	DELETE Cat_General_Parameters WHERE Id_Parameter IN (31,32,33,34,35,36)

	INSERT INTO Cat_General_Parameters VALUES (31, 'Production Server', '150.136.190.124','User_Notification','Text', 1, 'Ángel Gutiérrez', GETDATE(),'First Batch')
	INSERT INTO Cat_General_Parameters VALUES (32, 'Email From Alias', 'QS Notifcations','User_Notification','Text', 1, 'Ángel Gutiérrez', GETDATE(),'First Batch')
	INSERT INTO Cat_General_Parameters VALUES (33, 'TI Notifications Email', 'kelberoz@hotmail.com,vic5rc@hotmail.com,agutierrez@gtcta.mx,haparicio@gtcta.mx,ogarcia@gtcta.mx','User_Notification','Text', 1, 'Ángel Gutiérrez', GETDATE(),'First Batch')
	INSERT INTO Cat_General_Parameters VALUES (34, 'Notifications Log Path', 'C:\Processes\NotificaMailQS\Log','User_Notification','Text', 1, 'Ángel Gutiérrez', GETDATE(),'First Batch')
	INSERT INTO Cat_General_Parameters VALUES (35, 'Max Number Notifications', '100','User_Notification','Numeric', 1, 'Ángel Gutiérrez', GETDATE(),'First Batch')
	INSERT INTO Cat_General_Parameters VALUES (36, 'Email Regular Expression', "^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$",'User_Notification','Text', 1, 'Ángel Gutiérrez', GETDATE(),'First Batch')


	SELECT * FROM Cat_General_Parameters	
	WHERE Type = 'User_Notification'
	ORDER BY 1





/*==============================================================*/
/* Table: Cat_Notifications                                     */
/*==============================================================*/
	if exists (select 1
		from  sysobjects
		where  id = object_id('Cat_Notifications')
		and   type = 'U')
	drop table Cat_Notifications
	go

	create table Cat_Notifications (
	   Id_Notification      int                  not null,
	   Short_Desc           varchar(50)          not null,
	   Subject              varchar(255)         not null,
	   Template_Path        varchar(255)         not null,
	   Images_Path          varchar(255)         null,
	   Specific_Frequency   varchar(255)         null,
	   Status               bit                  not null,
	   constraint PK_CAT_NOTIFICATIONS primary key nonclustered (Id_Notification)
	)
	go


	DELETE Cat_Notifications

	INSERT INTO Cat_Notifications VALUES (0, 'TI Notification Error',				'HOUSTON... We have a problem',											'C:\Processes\NotificaMailQS\Templates\TI\NotificationTI.html',										'C:\Processes\NotificaMailQS\Templates\TI\images\',					NULL, 1)
	INSERT INTO Cat_Notifications VALUES (1, 'Quotation Send to Client',			'LATAM – PN @Folio / SPR @SPR_Number / @Customer',						'C:\Processes\NotificaMailQS\Templates\Quotation_Sent\Quotation_Mail.html',							'C:\Processes\NotificaMailQS\Templates\Quotation_Sent\images\',				NULL, 1)
	INSERT INTO Cat_Notifications VALUES (2, 'Quotation Approved ',					'DISCOUNT APPROVED – LATAM / PN @Folio / Version @Version / @Customer', 'C:\Processes\NotificaMailQS\Templates\Quotation_Approved\approved_discount_mail.html',				'C:\Processes\NotificaMailQS\Templates\Quotation_Approved\images\',			NULL, 1)
	INSERT INTO Cat_Notifications VALUES (3, 'Quotation Rejected ',					'DISCOUNT REJECTED – LATAM / PN @Folio / Version @Version / @Customer', 'C:\Processes\NotificaMailQS\Templates\Quotation_Rejected\rejected_discount_mail.html',				'C:\Processes\NotificaMailQS\Templates\Quotation_Rejected\images\',			NULL, 1)
	INSERT INTO Cat_Notifications VALUES (4, 'Quotation Pending to Approve',		'APPROVAL NEEDED / @Country / QN @Folio / @Customer',					'C:\Processes\NotificaMailQS\Templates\Quotation_Pending_Approve\new_approval_mail.html',			'C:\Processes\NotificaMailQS\Templates\Quotation_Pending_Approve\images\',	NULL, 1)
	INSERT INTO Cat_Notifications VALUES (5, 'Quotation Pending to Approve List',	'PENDING APPROVALS NEEDED – LATAM',										'C:\Processes\NotificaMailQS\Templates\Quotation_Pending_Approve_List\pending_approvals_mail.html', 'C:\Processes\NotificaMailQS\Templates\Quotation_Pending_Approve_List\images\',	'D|09:00-09:04', 1)

	
	SELECT * FROM Cat_Notifications
	


	/*==============================================================*/
	/* Table: Notification_Quotation_Status                         */
	/*==============================================================*/
	if exists (select 1
		from  sysobjects
		where  id = object_id('Notification_Quotation_Status')
		and   type = 'U')
	drop table Notification_Quotation_Status
	go

	create table Notification_Quotation_Status (
	   Id_Mail_Notification		numeric              identity,
	   Id_Notification			int                  not null,
	   Folio					int                  not null,
	   Version					smallint             not null,
	   Customer					varchar(255)         not null,
	   Customer_Email			varchar(50)          not null,
	   Sales_Executive			varchar(255)         not null,
	   Sales_Executive_Email	varchar(50)          not null,
	   Sales_Executive_Region	varchar(50)          not null,
	   SPR_Number				varchar(50)          not null,
	   Country					varchar(50)          not null,
	   Quotation_Status			varchar(50)          not null,
	   Register_Date			datetime             not null,
	   Notification_Date		datetime             null,
	   Notification_Send		bit                  not null,
	   constraint PK_NOTIFICATION_QUOTATION_STAT primary key nonclustered (Id_Mail_Notification)
	)
	go

	SELECT * FROM Notification_Quotation_Status

	/*==============================================================*/
	/* Table: Notification_Quotation_Pending_Approvals              */
	/*==============================================================*/
	if exists (select 1
		from  sysobjects
		where  id = object_id('Notification_Quotation_Pending_Approvals')
		and   type = 'U')
	drop table Notification_Quotation_Pending_Approvals
	go 

	create table Notification_Quotation_Pending_Approvals (
	   Id_Mail_Notification numeric              identity,
	   Id_Notification		int                  not null,
	   Folio				int                  null,
	   Version				smallint             null,
	   Country				varchar(50)          null,	   
	   Customer				varchar(255)		 null,
	   Approver             varchar(255)         not null,
	   Approver_Email       varchar(50)          not null,
	   Pending_Approvals    varchar(8000)        not null,
	   Register_Date        datetime             not null,
	   Notification_Date    datetime             null,
	   Notification_Send    bit                  not null,
	   constraint PK_NOTIFICATION_QUOTATION_PEND primary key nonclustered (Id_Mail_Notification)
	)
	go

	SELECT * FROM Notification_Quotation_Pending_Approvals