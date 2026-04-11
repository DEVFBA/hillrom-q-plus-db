/* ==================================================================================*/
-- 1. UDT_GSS_Quotation_Detail
/* ==================================================================================*/
PRINT 'Crea 1.  UDT_GSS_Quotation_Detail' 

CREATE TYPE [dbo].[UDT_GSS_Quotation_Detail]AS TABLE
(
   Id_Detail					Bigint				NULL,
   Folio						   Int					NOT NULL,
   [Version]					Smallint			   NOT NULL,
   Level_Number				Tinyint				NOT NULL,
   Position_Display			Varchar(50)			NOT NULL,
   Position_Sort				Varchar(100)		NOT NULL,
   Id_Parent					Bigint				NULL,
   Quantity						Float				   NULL,
   [Description]				Varchar(500)		NULL,
   Unit_Price					Float				   NULL,
   Discount						Float				   NULL,
   Net_Price					Float				   NULL,
   Total_Price					Float				   NULL,
   Id_Item						Varchar(50)			NULL,
   Item_Short_Desc			Varchar(50)			NULL,
   Item_Standard_Cost		Float				   NULL,
   Generic_Item				Bit					NOT NULL,
   On_Request					Bit					NOT NULL,
   [Notes]						Varchar(500)		NULL
)
GO