USE DBQS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spQuotation_Questionnaire_Get_Validate_ApprovalRoute
/* ==================================================================================*/	
PRINT 'Crea Procedure: spQuotation_Questionnaire_Get_Validate_ApprovalRoute'

IF OBJECT_ID('[dbo].[spQuotation_Questionnaire_Get_Validate_ApprovalRoute]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spQuotation_Questionnaire_Get_Validate_ApprovalRoute
GO

/*
Autor:		Alejandro Zepeda
Desc:		Quotation | Validate Approval Route
Date:		07/02/2021
Example:
			---------------------------------
			--1.- VALIDA RUTA POR DESCUENTO
			---------------------------------
			DECLARE  @udtQuotation_Discounts	UDT_Quotation_Discounts 

			INSERT INTO @udtQuotation_Discounts
			SELECT 'ACCELLA', 52.0, 'CR' 

			EXEC spQuotation_Questionnaire_Get_Validate_ApprovalRoute  @pudtQuotation_Discounts = @udtQuotation_Discounts

			---------------------------------
			--2.- VALIDA RUTA POR INCOTERM
			---------------------------------
			DECLARE  @udtQuotation_Incoterms	UDT_Quotation_Incoterms
			
			INSERT INTO @udtQuotation_Incoterms (Id_Country,Id_Incoterm) 
			VALUES('CR','EXW')
			
			EXEC spQuotation_Questionnaire_Get_Validate_ApprovalRoute  @pudtQuotation_Incoterms = @udtQuotation_Incoterms
			
			---------------------------------
			--3.- VALIDA RUTA POR EXTENCION DE GARANTIA
			---------------------------------
			DECLARE  @udtQuotation_Warranties	UDT_Quotation_Warranties

			INSERT INTO @udtQuotation_Warranties (Id_Line,Id_Year_Warranty) 
			VALUES ('ACCELLA',0)

			EXEC spQuotation_Questionnaire_Get_Validate_ApprovalRoute   @pudtQuotation_Warranties = @udtQuotation_Warranties

			/*********************************************************************/
			--4.- VALIDA RUTA POR PAYMENT TERM
			/*********************************************************************/

			EXEC spQuotation_Questionnaire_Get_Validate_ApprovalRoute   @pvIdPaymentTerm = 15

*/
CREATE PROCEDURE [dbo].spQuotation_Questionnaire_Get_Validate_ApprovalRoute
@pudtQuotation_Discounts		UDT_Quotation_Discounts  Readonly,
@pudtQuotation_Incoterms	UDT_Quotation_Incoterms  Readonly,
@pudtQuotation_Warranties	UDT_Quotation_Warranties Readonly,
@pvIdPaymentTerm			Varchar(10) = ''

AS 
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @ApplyQuestionnaire		BIT = 0


	/*********************************************************************/
	--1.- VALIDA RUTA POR DESCUENTO
	/*********************************************************************/
		DECLARE @tblApproved_Discounts	TABLE (Id_Item Varchar(50), Discount float)

		-- register discounts per item
		INSERT INTO @tblApproved_Discounts
		SELECT I.Id_Item, MIN(Bottom_Limit) 
		FROM Approved_Discounts AD
		
		INNER JOIN Cat_Item I ON
		AD.Id_Discount_Category = I.Id_Discount_Category

		INNER JOIN Cat_Zones Z ON 
		AD.Id_Zone = Z.Id_Zone AND
		Id_Zone_Type =  'DISC' AND 
		Z.[Status] = 1

		INNER JOIN @pudtQuotation_Discounts udt ON
		I.Id_Item = udt.Id_Item

		INNER JOIN Cat_Zones_Countries ZC ON
		ZC.Id_Zone = Z.Id_Zone AND
		ZC.Id_Country = udt.Id_Country AND
		ZC.[Status] = 1

		WHERE Id_Discount_Type = 'PERC'
		GROUP BY I.Id_Item


		--Validate if exist more that discoun 
		IF (SELECT COUNT(*)
			FROM @tblApproved_Discounts D
			
			INNER JOIN @pudtQuotation_Discounts Q ON 
			D.Id_Item = Q.Id_Item

			WHERE Q.Discount >= D.Discount) > 0
		BEGIN
			SET @ApplyQuestionnaire = 1 
			GOTO ReturnValidation
		END


	/*********************************************************************/
	--2.- VALIDA RUTA POR INCOTERM
	/*********************************************************************/
	--Validate if exist Incoterm configuration
		IF (SELECT COUNT(*)
			FROM Cat_Approval_Country_Incoterms CI
			INNER JOIN @pudtQuotation_Incoterms UDT ON 
			CI.Id_Country	= UDT.Id_Country AND
			CI.Id_Incoterm	= UDT.Id_Incoterm
			WHERE CI.[Status] = 1 ) > 0
		BEGIN
			SET @ApplyQuestionnaire = 1 
			GOTO ReturnValidation
		END



	/*********************************************************************/
	--3.- VALIDA RUTA POR EXTENCION DE GARANTIA
	/*********************************************************************/
	--Validate if exist Incoterm configuration
		IF (SELECT COUNT(*)
			FROM Cat_Extended_Warranties CI
			INNER JOIN @pudtQuotation_Warranties UDT ON 
			CI.Id_Line			= UDT.Id_Line AND
			CI.Id_Year_Warranty	= UDT.Id_Year_Warranty
			WHERE Id_Approval_Flow IS NOT NULL AND CI.[Status] = 1 ) > 0
		BEGIN
			SET @ApplyQuestionnaire = 1 
			GOTO ReturnValidation
		END


	/*********************************************************************/
	--4.- VALIDA RUTA POR PAYMENT TERM
	/*********************************************************************/
	--Validate if exist Id_Payment_Term
		IF (SELECT COUNT(*)
			FROM Cat_Payment_Terms CI
			WHERE Id_Approval_Flow IS NOT NULL AND 
			Id_Payment_Term = @pvIdPaymentTerm AND CI.[Status] = 1) > 0
		BEGIN
			SET @ApplyQuestionnaire = 1 
			GOTO ReturnValidation
		END

		
	/*********************************************************************/
	--RETURN
	/*********************************************************************/
	ReturnValidation:	
	SELECT Apply_Questionnaire = @ApplyQuestionnaire
