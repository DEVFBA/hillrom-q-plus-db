USE [DBQS]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGSSQuotation]    Script Date: 02/05/2024 10:09:09 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


/*
Author		: Angel Gutierrez
Descrption	: Returns GSS Quotation Table by User Language
Creation	: 01/10/2026

Example:
		SELECT * FROM [fnGSSQuotation]('ANG')
		SELECT * FROM GSS_Quotation
*/
CREATE FUNCTION [dbo].[fnGSSQuotation](@pvIdLanguageUser VARCHAR(10)) 
RETURNS TABLE 
AS

RETURN (SELECT        
				Folio						= GSS_Quotation.Folio, 
				[Version]					= GSS_Quotation.[Version], 
		
				Id_Customer_Bill_To			= GSS_Quotation.Id_Customer_Bill_To, 
				Customer_Bill_To			= Customer_Bill_To.[Name], 
				Customer_Email				= Customer_Bill_To.Email,
				Id_Customer_Type_Bill_To	= GSS_Quotation.Id_Customer_Type_Bill_To, 
				Customer_Type_Bill_To		= Cat_Customers_Type.Short_Desc, 
				Id_Country_Bill_To			= GSS_Quotation.Id_Country_Bill_To, 
				Country_Bill_To				= Cat_Countries.Short_Desc, 
		
				Id_Customer_Final			= GSS_Quotation.Id_Customer_Final, 
				Customer_Final				= Customer_Final.[Name],
				Id_Customer_Type_Final		= GSS_Quotation.Id_Customer_Type_Final,  
				Customer_Type_Final			= Cat_Customers_Type_Final.Short_Desc, 
				Id_Country_Final			= GSS_Quotation.Id_Country_Final, 
				Country_Final				= Cat_Countries_Final.Short_Desc, 		
		
				--Id_Voltage					= GSS_Quotation.Id_Voltage, 
				--Voltage_Desc				= Cat_Voltages.Short_Desc, 

				--Id_Language					= GSS_Quotation.Id_Language, 
				--Language_Desc				= Cat_Languages.Short_Desc, 
		
				--Id_Plug						= GSS_Quotation.Id_Plug, 
				--Plug_Desc					= Cat_Plugs.Short_Desc, 
		
				Id_Incoterm					= GSS_Quotation.Id_Incoterm, 
				Incoterm_Desc				= Cat_Incoterm.Short_Desc, 
		
				Id_Currency					= GSS_Quotation.Id_Currency, 
				Currency_Desc				= Cat_Currencies.Short_Desc, 
		
				Id_Exchange_Rate			= GSS_Quotation.Id_Exchange_Rate, 
				Exchange_Rate				= Cat_Exchange_Rates.Exchange_Rate, 
		
				Id_Sales_Type				= GSS_Quotation.Id_Sales_Type, 
				Sales_Type_Desc				= Cat_Sales_Types.Short_Desc, 
		
				Id_Price_List				= GSS_Quotation.Id_Price_List, 
				Price_List_Desc				= Cat_Prices_Lists.Short_Desc, 

				Id_Validity_Price			= GSS_Quotation.Id_Validity_Price,
				Validity_Price_Desc			= Cat_Validity_Prices.Short_Desc,
		
				Id_Quotation_Status			= GSS_Quotation.Id_Quotation_Status, 
				Quotation_Status_Desc		= Cat_Quotation_Status.Short_Desc, 

				--Id_Language_Translation		= GSS_Quotation.Id_Language_Translation, 
				--Language_Translation_Desc	= Cat_Languages_Translation.Short_Desc, 
		
				Id_Sales_Executive			= GSS_Quotation.Sales_Executive, 
				Sales_Executive				= Security_Users.[Name],
				Sales_Executive_Email		= Security_Users.Email,

				--Id_Payment_Terms			= Quotation.Id_Payment_Term, --- AEGH || Modify since Payment Terms will not be used anymore Ticket Q+CO020 (001203 IT Global)
				--Payment_Terms_Desc			= Cat_Payment_Terms.Short_Desc, --- AEGH || Modify since Payment Terms will not be used anymore Ticket Q+CO020 (001203 IT Global)

				Creation_Date				= GSS_Quotation.Creation_Date, 
				SPR_Number					= GSS_Quotation.SPR_Number, 
				Purchase_Order				= GSS_Quotation.Purchase_Order, 
				Comments					= GSS_Quotation.Comments, 
				Modify_By					= GSS_Quotation.Modify_By, 
				Modify_Date					= GSS_Quotation.Modify_Date, 
				Modify_IP					= GSS_Quotation.Modify_IP

		FROM	GSS_Quotation WITH(NOLOCK)

				INNER JOIN GSS_Cat_Customers  AS Customer_Bill_To WITH(NOLOCK) ON
				GSS_Quotation.Id_Customer_Type_Bill_To = Customer_Bill_To.Id_Customer_Type AND 
				GSS_Quotation.Id_Country_Bill_To = Customer_Bill_To.Id_Country AND 
				GSS_Quotation.Id_Customer_Bill_To = Customer_Bill_To.Id_Customer 

				INNER JOIN Cat_Countries WITH(NOLOCK) ON
				GSS_Quotation.Id_Country_Bill_To = Cat_Countries.Id_Country 

				INNER JOIN Cat_Customers_Type WITH(NOLOCK) ON
				GSS_Quotation.Id_Customer_Type_Bill_To = Cat_Customers_Type.Id_Customer_Type AND
				Cat_Customers_Type.Id_Language = @pvIdLanguageUser

				INNER JOIN GSS_Cat_Customers AS Customer_Final WITH(NOLOCK) ON
				GSS_Quotation.Id_Customer_Type_Final = Customer_Final.Id_Customer_Type AND 
				GSS_Quotation.Id_Country_Final = Customer_Final.Id_Country AND 
				GSS_Quotation.Id_Customer_Final = Customer_Final.Id_Customer 

				INNER JOIN Cat_Customers_Type AS Cat_Customers_Type_Final WITH(NOLOCK) ON
				GSS_Quotation.Id_Customer_Type_Final = Cat_Customers_Type_Final.Id_Customer_Type AND
				Cat_Customers_Type_Final.Id_Language = @pvIdLanguageUser

				INNER JOIN Cat_Countries AS Cat_Countries_Final WITH(NOLOCK) ON
				GSS_Quotation.Id_Country_Final = Cat_Countries_Final.Id_Country

				--INNER JOIN Cat_Voltages WITH(NOLOCK) ON
				--GSS_Quotation.Id_Voltage = Cat_Voltages.Id_Voltage 

				--INNER JOIN Cat_Languages WITH(NOLOCK) ON
				--GSS_Quotation.Id_Language = Cat_Languages.Id_Language AND
				--Cat_Languages.Id_Language_Translation = @pvIdLanguageUser

				--INNER JOIN Cat_Plugs WITH(NOLOCK) ON
				--GSS_Quotation.Id_Plug = Cat_Plugs.Id_Plug 

				INNER JOIN Cat_Incoterm ON
				GSS_Quotation.Id_Incoterm = Cat_Incoterm.Id_Incoterm AND
				Cat_Incoterm.Id_Language = @pvIdLanguageUser

				INNER JOIN Cat_Currencies WITH(NOLOCK) ON
				GSS_Quotation.Id_Currency = Cat_Currencies.Id_Currency AND
				Cat_Currencies.Id_Language = @pvIdLanguageUser

				INNER JOIN Cat_Exchange_Rates WITH(NOLOCK) ON
				GSS_Quotation.Id_Currency = Cat_Exchange_Rates.Id_Currency AND 
				GSS_Quotation.Id_Exchange_Rate = Cat_Exchange_Rates.Id_Exchange_Rate 

				INNER JOIN Cat_Sales_Types WITH(NOLOCK) ON
				GSS_Quotation.Id_Sales_Type = Cat_Sales_Types.Id_Sales_Type AND
				Cat_Sales_Types.Id_Language = @pvIdLanguageUser

				INNER JOIN Cat_Prices_Lists WITH(NOLOCK) ON
				GSS_Quotation.Id_Price_List = Cat_Prices_Lists.Id_Price_List AND
				Cat_Prices_Lists.Id_Language = @pvIdLanguageUser

				INNER JOIN Security_Users WITH(NOLOCK) ON
				GSS_Quotation.Sales_Executive = Security_Users.[User] 

				INNER JOIN Cat_Quotation_Status WITH(NOLOCK) ON
				GSS_Quotation.Id_Quotation_Status = Cat_Quotation_Status.Id_Quotation_Status AND
				Cat_Quotation_Status.Id_Language = @pvIdLanguageUser

				INNER JOIN Cat_Validity_Prices WITH(NOLOCK) ON
				Cat_Validity_Prices.Id_Validity_Price = GSS_Quotation.Id_Validity_Price AND
				Cat_Validity_Prices.Id_Language = @pvIdLanguageUser

				--LEFT OUTER JOIN Cat_Languages AS Cat_Languages_Translation WITH(NOLOCK) ON
				--GSS_Quotation.Id_Language_Translation = Cat_Languages_Translation.Id_Language AND
				--Cat_Languages_Translation.Id_Language_Translation = @pvIdLanguageUser

				--INNER JOIN Cat_Payment_Terms WITH(NOLOCK) ON  --- AEGH || Modify since Payment Terms will not be used anymore Ticket Q+CO020 (001203 IT Global)
				--Quotation.Id_Payment_Term = Cat_Payment_Terms.Id_Payment_Term AND  --- AEGH || Modify since Payment Terms will not be used anymore Ticket Q+CO020 (001203 IT Global)
				--Cat_Payment_Terms.Id_Language = @pvIdLanguageUser --- AEGH || Modify since Payment Terms will not be used anymore Ticket Q+CO020 (001203 IT Global)
		)

