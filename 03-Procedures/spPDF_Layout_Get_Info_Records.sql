USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spPDF_Layout_Get_Info_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spPDF_Layout_Get_Info_Records'
IF OBJECT_ID('[dbo].[spPDF_Layout_Get_Info_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spPDF_Layout_Get_Info_Records
GO
/*
Autor:		Alejandro Zepeda
Desc:		Get spPDF_Layout_Get_Info_Records
Date:		13/03/2021
Example:

	============================================================
	-- CAMAS
	============================================================
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'PRP7500'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'CP7800A'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'ACCELLA'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'CENTURI'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'CENP750'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = '305MABE'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'RVP3200'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'HR100LB'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'AFF4P37'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'STP80XX'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'HIRO900'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'CH700B4'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'CH700B3'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'OTTA270'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'SCH770A'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'TRCHANA'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'SEAFURN'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'SLEESOFA'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'SLEECHA'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'OBTAOC'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'BEDSPRE'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'TRANBO'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'MEDSURGACC'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'THSUR'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'ACCUMAX'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'POWSURF'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'HRRP870'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'OBTP0094##'


	============================================================
	-- GRUGAS
	============================================================
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'GOLVO9000'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'SABINA'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'VIKING'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'MOBLIFTACCE'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'OLLIKORAL'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'RAILSYSTEM'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'FREESTLIFT'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'CURTAINSYST'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'LIFTINGACCE'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'SLINGCHILDREN'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'SLINGADULTS'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'SLINGACESS'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'LIKOSTRET'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'REPOMULTI'
	EXEC spPDF_Layout_Get_Info_Records @pvLayoutRef = 'MANUALAIDS'
*/
CREATE PROCEDURE [dbo].spPDF_Layout_Get_Info_Records
@pvLayoutRef Varchar(50)
AS

/*============================================================*/
-- GRUGAS
/*============================================================*/

IF @pvLayoutRef = 'PRP7500'
	EXEC spPDF_Layout_Get_Info_PRP7500 

ELSE IF @pvLayoutRef = 'CP7800A'
	EXEC spPDF_Layout_Get_Info_CP7800A 

ELSE IF @pvLayoutRef = 'ACCELLA'
	EXEC spPDF_Layout_Get_Info_ACCELLA 

ELSE IF @pvLayoutRef = 'CENTURI'
	EXEC spPDF_Layout_Get_Info_CENTURI

ELSE IF @pvLayoutRef = 'CENP750'
	EXEC spPDF_Layout_Get_Info_CENP750 

ELSE IF @pvLayoutRef = '305MABE'
	EXEC spPDF_Layout_Get_Info_305MABE

ELSE IF @pvLayoutRef = 'RVP3200'
	EXEC spPDF_Layout_Get_Info_RVP3200

ELSE IF @pvLayoutRef = 'HR100LB'
	EXEC spPDF_Layout_Get_Info_HR100LB

ELSE IF @pvLayoutRef = 'AFF4P37'
	EXEC spPDF_Layout_Get_Info_AFF4P37

ELSE IF @pvLayoutRef = 'STP80XX'
	EXEC spPDF_Layout_Get_Info_STP80XX

ELSE IF @pvLayoutRef = 'HIRO900'
	EXEC spPDF_Layout_Get_Info_HIRO900

ELSE IF @pvLayoutRef = 'CH700B4'
	EXEC spPDF_Layout_Get_Info_CH700B4

ELSE IF @pvLayoutRef = 'CH700B3'
	EXEC spPDF_Layout_Get_Info_CH700B3

ELSE IF @pvLayoutRef = 'OTTA270'
	EXEC spPDF_Layout_Get_Info_OTTA270

ELSE IF @pvLayoutRef = 'SCH770A'
	EXEC spPDF_Layout_Get_Info_SCH770A

ELSE IF @pvLayoutRef = 'TRCHANA'
	EXEC spPDF_Layout_Get_Info_TRCHANA

ELSE IF @pvLayoutRef = 'SEAFURN'
	EXEC spPDF_Layout_Get_Info_SEAFURN

ELSE IF @pvLayoutRef = 'SLEESOFA'
	EXEC spPDF_Layout_Get_Info_SLEESOFA

ELSE IF @pvLayoutRef = 'SLEECHA'
	EXEC spPDF_Layout_Get_Info_SLEECHA

ELSE IF @pvLayoutRef = 'OBTAOC'
	EXEC spPDF_Layout_Get_Info_OBTAOC

ELSE IF @pvLayoutRef = 'BEDSPRE'
	EXEC spPDF_Layout_Get_Info_BEDSPRE

ELSE IF @pvLayoutRef = 'TRANBO'
	EXEC spPDF_Layout_Get_Info_TRANBO
	
ELSE IF @pvLayoutRef = 'MedSurgAcc'
	EXEC spPDF_Layout_Get_Info_MEDSURGACC

ELSE IF @pvLayoutRef = 'THSUR'
	EXEC spPDF_Layout_Get_Info_THSUR

ELSE IF @pvLayoutRef = 'ACCUMAX'
	EXEC spPDF_Layout_Get_Info_ACCUMAX

ELSE IF @pvLayoutRef = 'POWSURF'
	EXEC spPDF_Layout_Get_Info_POWSURF

ELSE IF @pvLayoutRef = 'HRRP870'
	EXEC spPDF_Layout_Get_Info_HRRP870

ELSE IF @pvLayoutRef = 'OBTP0094##'
	EXEC spPDF_Layout_Get_Info_OBTP0094##

/*============================================================*/
-- GRUGAS
/*============================================================*/

ELSE IF @pvLayoutRef = 'GOLVO9000'
	EXEC spPDF_Layout_Get_Info_GOLVO9000

ELSE IF @pvLayoutRef = 'SABINA'
	EXEC spPDF_Layout_Get_Info_SABINA

ELSE IF @pvLayoutRef = 'VIKING'
	EXEC spPDF_Layout_Get_Info_VIKING

ELSE IF @pvLayoutRef = 'MOBLIFTACCE'
	EXEC spPDF_Layout_Get_Info_MOBLIFTACCE

ELSE IF @pvLayoutRef = 'OLLIKORAL'
	EXEC spPDF_Layout_Get_Info_OLLIKORAL

ELSE IF @pvLayoutRef = 'RAILSYSTEM'
	EXEC spPDF_Layout_Get_Info_RAILSYSTEM

ELSE IF @pvLayoutRef = 'FREESTLIFT'
	EXEC spPDF_Layout_Get_Info_FREESTLIFT

ELSE IF @pvLayoutRef = 'CURTAINSYST'
	EXEC spPDF_Layout_Get_Info_CURTAINSYST

ELSE IF @pvLayoutRef = 'LIFTINGACCE'
	EXEC spPDF_Layout_Get_Info_LIFTINGACCE

ELSE IF @pvLayoutRef = 'SLINGCHILDREN'
	EXEC spPDF_Layout_Get_Info_SLINGCHILDREN

ELSE IF @pvLayoutRef = 'SLINGADULTS'
	EXEC spPDF_Layout_Get_Info_SLINGADULTS

ELSE IF @pvLayoutRef = 'SLINGACESS'
	EXEC spPDF_Layout_Get_Info_SLINGACESS

ELSE IF @pvLayoutRef = 'LIKOSTRET'
	EXEC spPDF_Layout_Get_Info_LIKOSTRET

ELSE IF @pvLayoutRef = 'REPOMULTI'
	EXEC spPDF_Layout_Get_Info_REPOMULTI

ELSE IF @pvLayoutRef = 'MANUALAIDS'
	EXEC spPDF_Layout_Get_Info_MANUALAIDS