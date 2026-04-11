USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spGSS_Quotation_Detail_CRUD_Records]    Script Date: 4/9/2026 8:52:49 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Autor:		Angel Gutierrez
Desc:		GSS_Quotation_Detail | Create - Read - Upadate - Delete 
Date:		02/28/26
Example:

			DECLARE @pudtGSSQuotationDetail UDT_GSS_Quotation_Detail
			INSERT INTO @pudtGSSQuotationDetail ([Id_Detail],[Folio],[Version],[Level_Number],[Position_Display],[Position_Sort],[Id_Parent],[Quantity],[Description],[Unit_Price],[Discount],[Net_Price],[Total_Price],[Id_Item],[Item_Short_Desc],[Item_Standard_Cost],[Generic_Item],[On_Request],[Notes]) VALUES (1,1,1,1,'1','001',NULL,1,'Inquiry Number N/A',0,0,0,0,'0000000','NULL',0,0,0,''),
			(2,1,1,2,'1.1','001.001',1,18,'GL0030 LAMP EXAMINATION, LED, WALL MTD',0,0,0,51390,'0000000','NULL',0,0,0,''),
			(3,1,1,3,'1.1.1','001.001.001',2,1,'TL1000 Wall',2855,0,0,2855,'0000000','NULL',0,0,0,''),
			(4,1,1,4,'1.1.1.1','001.001.001.001',3,1,'Power Supply 230V TL 1000 Wall',404,0,404,404,'1702904','Power Supply 230V TL 1000 Wall',0,0,0,''),
			(5,1,1,4,'1.1.1.2','001.001.001.002',3,1,'TruLight 1000 Wall',2333,0,2333,2333,'1700114','TruLight 1000 Wall',0,0,0,''),
			(6,1,1,4,'1.1.1.3','001.001.001.003',3,1,'Sterilizable Central Handle, 3 pcs',118,0,118,118,'0337642','Sterilizable Central Handle, 3 pcs',0,0,0,''),
			(7,1,1,2,'1.2','001.002',1,5,'TA0006 ACCESSORY SET OT TABLE, GYNAECOLOGY',0,0,0,18130,'0000000','NULL',0,0,0,''),
			(8,1,1,3,'1.2.1','001.002.001',7,1,'GYN/URO Accessories',3626,0,0,3626,'0000000','NULL',0,0,0,''),
			(9,1,1,4,'1.2.1.1','001.002.001.001',8,2,'Leg holder GOEPEL',713,0,713,1426,'4544736','Leg holder GOEPEL',0,0,0,''),
			(10,1,1,4,'1.2.1.2','001.002.001.002',8,2,'Clamp radial setting',247,0,247,494,'1218804','Clamp radial setting',0,0,0,''),
			(11,1,1,4,'1.2.1.3','001.002.001.003',8,1,'Drainage bowl adapter',1211,0,1211,1211,'4544619','Drainage bowl adapter',0,0,0,''),
			(12,1,1,4,'1.2.1.4','001.002.001.004',8,1,'Drainage bowl',495,0,495,495,'4544618','Drainage bowl',0,0,0,''),
			(13,1,1,2,'1.3','001.003',1,1,'TA0014 ACCESSORY SET OT TABLE, ORTHOPAEDIC',0,0,0,49575,'0000000','NULL',0,0,0,''),
			(14,1,1,3,'1.3.1','001.003.001',13,1,'Orthopedics Accessories',49575,0,0,49575,'0000000','NULL',0,0,0,''),
			(15,1,1,4,'1.3.1.1','001.003.001.001',14,1,'Hand/ Arm',0,0,0,0,'0333333','Hand/ Arm',0,1,0,''),
			(16,1,1,4,'1.3.1.2','001.003.001.002',14,1,'Traction device for humerus',818,0,818,818,'4544766','Traction device for humerus',0,0,0,''),
			(17,1,1,4,'1.3.1.3','001.003.001.003',14,1,'Counter traction for humerus',469,0,469,469,'4544765','Counter traction for humerus',0,0,0,''),
			(18,1,1,4,'1.3.1.4','001.003.001.004',14,1,'WEINBERGER hand traction device',494,0,494,494,'1218836','WEINBERGER hand traction device',0,0,0,''),
			(19,1,1,4,'1.3.1.5','001.003.001.005',14,2,'Clamp radial setting',247,0,247,494,'1218804','Clamp radial setting',0,0,0,''),
			(20,1,1,4,'1.3.1.6','001.003.001.006',14,1,'Holding device for upper arm support',664,0,664,664,'1302539','Holding device for upper arm support',0,0,0,''),
			(21,1,1,4,'1.3.1.7','001.003.001.007',14,1,'Upper arm pad',358,0,358,358,'1297244','Upper arm pad',0,0,0,''),
			(22,1,1,4,'1.3.1.8','001.003.001.008',14,1,'Pad roll 80 for upper arm support',462,0,462,462,'1297245','Pad roll 80 for upper arm support',0,0,0,''),
			(23,1,1,4,'1.3.1.9','001.003.001.009',14,1,'Axilla support',424,0,424,424,'1218848','Axilla support',0,0,0,''),
			(24,1,1,4,'1.3.1.10','001.003.001.010',14,1,'Elbow support',775,0,775,775,'1218847','Elbow support',0,0,0,''),
			(25,1,1,4,'1.3.1.11','001.003.001.011',14,1,'Hand operating table',2441,0,2441,2441,'4549735','Hand operating table',0,0,0,''),
			(26,1,1,4,'1.3.1.12','001.003.001.012',14,1,'Knee',0,0,0,0,'0333333','Knee',0,1,0,''),
			(27,1,1,4,'1.3.1.13','001.003.001.013',14,1,'Arthroscopy positioning device basic',993,0,993,993,'4544534','Arthroscopy positioning device basic',0,0,0,''),
			(28,1,1,4,'1.3.1.14','001.003.001.014',14,1,'Clamp radial setting',247,0,247,247,'1218804','Clamp radial setting',0,0,0,''),
			(29,1,1,4,'1.3.1.15','001.003.001.015',14,1,'Shoulder',0,0,0,0,'0333333','Shoulder',0,1,0,''),
			(30,1,1,4,'1.3.1.16','001.003.001.016',14,1,'Shoulder Chair H',8803,0,8803,8803,'2009875','Shoulder Chair H',0,0,0,''),
			(31,1,1,4,'1.3.1.17','001.003.001.017',14,1,'Shoulder Chair Dolly TS7000',1299,0,1299,1299,'1891860','Shoulder Chair Dolly TS7000',0,0,0,''),
			(32,1,1,4,'1.3.1.18','001.003.001.018',14,1,'Fracture/Extension',0,0,0,0,'0333333','Fracture/Extension',0,1,0,''),
			(33,1,1,4,'1.3.1.19','001.003.001.019',14,1,'Extension adapter PST 300',3130,0,3130,3130,'2072419','Extension adapter PST 300',0,0,0,''),
			(34,1,1,4,'1.3.1.20','001.003.001.020',14,1,'Supporting pad universal MARS B',946,0,946,946,'1897603','Supporting pad universal MARS B',0,0,0,''),
			(35,1,1,4,'1.3.1.21','001.003.001.021',14,1,'Universal support',1986,0,1986,1986,'1876707','Universal support',0,0,0,''),
			(36,1,1,4,'1.3.1.22','001.003.001.022',14,1,'Counter traction post 150',378,0,378,378,'1612706','Counter traction post 150',0,0,0,''),
			(37,1,1,4,'1.3.1.23','001.003.001.023',14,1,'Double joint strut, pair',5052,0,5052,5052,'1574734','Double joint strut, pair',0,0,0,''),
			(38,1,1,4,'1.3.1.24','001.003.001.024',14,2,'Extension strut medium',881,0,881,1762,'1597668','Extension strut medium',0,0,0,''),
			(39,1,1,4,'1.3.1.25','001.003.001.025',14,2,'Adapter spindle traction mechanism',411,0,411,822,'1593159','Adapter spindle traction mechanism',0,0,0,''),
			(40,1,1,4,'1.3.1.26','001.003.001.026',14,2,'Spindle traction mechanism FR',3928,0,3928,7856,'1881967','Spindle traction mechanism FR',0,0,0,''),
			(41,1,1,4,'1.3.1.27','001.003.001.027',14,1,'Leg holder GOEPEL',713,0,713,713,'4544736','Leg holder GOEPEL',0,0,0,''),
			(42,1,1,4,'1.3.1.28','001.003.001.028',14,1,'Clamp radial setting',247,0,247,247,'1218804','Clamp radial setting',0,0,0,''),
			(43,1,1,4,'1.3.1.29','001.003.001.029',14,1,'Side rail adapter',358,0,358,358,'4544165','Side rail adapter',0,0,0,''),
			(44,1,1,4,'1.3.1.30','001.003.001.030',14,1,'Side rail',123,0,123,123,'4544166','Side rail',0,0,0,''),
			(45,1,1,4,'1.3.1.31','001.003.001.031',14,2,'Traction boot',1310,0,1310,2620,'1574733','Traction boot',0,0,0,''),
			(46,1,1,4,'1.3.1.32','001.003.001.032',14,1,'Transfer leg section',1421,0,1421,1421,'1876708','Transfer leg section',0,0,0,''),
			(47,1,1,4,'1.3.1.33','001.003.001.033',14,1,'Docking trolley extension unit',3420,0,3420,3420,'1867129','Docking trolley extension unit',0,0,0,''),
			(48,1,1,1,'2','002',NULL,1,'Professional Services',0,0,0,0,'0000000','NULL',0,0,0,''),
			(49,1,1,2,'2.1','002.001',48,1,'In-Country Service',0,0,0,40005,'0000000','NULL',0,0,0,''),
			(50,1,1,3,'2.1.1','002.001.001',49,1,'Installation / User Training / Warranty Labor',40005,0,0,40005,'0000000','NULL',0,0,0,''),
			(51,1,1,4,'2.1.1.1','002.001.001.001',50,1,'Installation and Training',32004,0,32004,32004,'1445119','Installation and Training',0,1,0,''),
			(52,1,1,4,'2.1.1.2','002.001.001.002',50,1,'Extended LABOR Warranty (12 months extra)',8001,0,8001,8001,'1445119','Extended LABOR Warranty (12 months extra)',0,1,0,'');

			SELECT * FROM @pudtGSSQuotationDetail;

			EXEC spGSS_Quotation_Detail_CRUD_Records @pvOptionCRUD		= 'C',
									@pvIdLanguageUser			= 'ANG', 
									@pvUser						= 'ANGUTIERRE',
									@pudtGSSQuotationDetail		= @pudtGSSQuotationDetail,
									@pvIP						= '0.0.0.0';

			DECLARE @pudtGSSQuotationDetail UDT_GSS_Quotation_Detail
			INSERT INTO @pudtGSSQuotationDetail ([Id_Detail],[Folio],[Version],[Level_Number],[Position_Display],[Position_Sort],[Id_Parent],[Quantity],[Description],[Unit_Price],[Discount],[Net_Price],[Total_Price],[Id_Item],[Item_Short_Desc],[Item_Standard_Cost],[Generic_Item],[On_Request],[Notes]) VALUES (1,2,1,1,'1','001',NULL,1,'Inquiry Number N/A',0,0,0,0,'0000000','NULL',0,0,0,''),
			(2,2,1,2,'1.1','001.001',1,18,'GL0030 LAMP EXAMINATION, LED, WALL MTD',0,0,0,51390,'0000000','NULL',0,0,0,''),
			(3,2,1,3,'1.1.1','001.001.001',2,1,'TL1000 Wall',2855,0,0,2855,'0000000','NULL',0,0,0,''),
			(4,2,1,4,'1.1.1.1','001.001.001.001',3,1,'Power Supply 230V TL 1000 Wall',404,0,404,404,'1702904','Power Supply 230V TL 1000 Wall',0,0,0,''),
			(5,2,1,4,'1.1.1.2','001.001.001.002',3,1,'TruLight 1000 Wall',2333,0,2333,2333,'1700114','TruLight 1000 Wall',0,0,0,''),
			(6,2,1,4,'1.1.1.3','001.001.001.003',3,1,'Sterilizable Central Handle, 3 pcs',118,0,118,118,'0337642','Sterilizable Central Handle, 3 pcs',0,0,0,''),
			(7,2,1,2,'1.2','001.002',1,5,'TA0006 ACCESSORY SET OT TABLE, GYNAECOLOGY',0,0,0,18130,'0000000','NULL',0,0,0,''),
			(8,2,1,3,'1.2.1','001.002.001',7,1,'GYN/URO Accessories',3626,0,0,3626,'0000000','NULL',0,0,0,''),
			(9,2,1,4,'1.2.1.1','001.002.001.001',8,2,'Leg holder GOEPEL',713,0,713,1426,'4544736','Leg holder GOEPEL',0,0,0,''),
			(10,2,1,4,'1.2.1.2','001.002.001.002',8,2,'Clamp radial setting',247,0,247,494,'1218804','Clamp radial setting',0,0,0,''),
			(11,2,1,4,'1.2.1.3','001.002.001.003',8,1,'Drainage bowl adapter',1211,0,1211,1211,'4544619','Drainage bowl adapter',0,0,0,''),
			(12,2,1,4,'1.2.1.4','001.002.001.004',8,1,'Drainage bowl',495,0,495,495,'4544618','Drainage bowl',0,0,0,''),
			(13,2,1,2,'1.3','001.003',1,1,'TA0014 ACCESSORY SET OT TABLE, ORTHOPAEDIC',0,0,0,49575,'0000000','NULL',0,0,0,''),
			(14,2,1,3,'1.3.1','001.003.001',13,1,'Orthopedics Accessories',49575,0,0,49575,'0000000','NULL',0,0,0,''),
			(15,2,1,4,'1.3.1.1','001.003.001.001',14,1,'Hand/ Arm',0,0,0,0,'0333333','Hand/ Arm',0,1,0,''),
			(16,2,1,4,'1.3.1.2','001.003.001.002',14,1,'Traction device for humerus',818,0,818,818,'4544766','Traction device for humerus',0,0,0,''),
			(17,2,1,4,'1.3.1.3','001.003.001.003',14,1,'Counter traction for humerus',469,0,469,469,'4544765','Counter traction for humerus',0,0,0,''),
			(18,2,1,4,'1.3.1.4','001.003.001.004',14,1,'WEINBERGER hand traction device',494,0,494,494,'1218836','WEINBERGER hand traction device',0,0,0,''),
			(19,2,1,4,'1.3.1.5','001.003.001.005',14,2,'Clamp radial setting',247,0,247,494,'1218804','Clamp radial setting',0,0,0,''),
			(20,2,1,4,'1.3.1.6','001.003.001.006',14,1,'Holding device for upper arm support',664,0,664,664,'1302539','Holding device for upper arm support',0,0,0,''),
			(21,2,1,4,'1.3.1.7','001.003.001.007',14,1,'Upper arm pad',358,0,358,358,'1297244','Upper arm pad',0,0,0,''),
			(22,2,1,4,'1.3.1.8','001.003.001.008',14,1,'Pad roll 80 for upper arm support',462,0,462,462,'1297245','Pad roll 80 for upper arm support',0,0,0,''),
			(23,2,1,4,'1.3.1.9','001.003.001.009',14,1,'Axilla support',424,0,424,424,'1218848','Axilla support',0,0,0,''),
			(24,2,1,4,'1.3.1.10','001.003.001.010',14,1,'Elbow support',775,0,775,775,'1218847','Elbow support',0,0,0,''),
			(25,2,1,4,'1.3.1.11','001.003.001.011',14,1,'Hand operating table',2441,0,2441,2441,'4549735','Hand operating table',0,0,0,''),
			(26,2,1,4,'1.3.1.12','001.003.001.012',14,1,'Knee',0,0,0,0,'0333333','Knee',0,1,0,''),
			(27,2,1,4,'1.3.1.13','001.003.001.013',14,1,'Arthroscopy positioning device basic',993,0,993,993,'4544534','Arthroscopy positioning device basic',0,0,0,''),
			(28,2,1,4,'1.3.1.14','001.003.001.014',14,1,'Clamp radial setting',247,0,247,247,'1218804','Clamp radial setting',0,0,0,''),
			(29,2,1,4,'1.3.1.15','001.003.001.015',14,1,'Shoulder',0,0,0,0,'0333333','Shoulder',0,1,0,''),
			(30,2,1,4,'1.3.1.16','001.003.001.016',14,1,'Shoulder Chair H',8803,0,8803,8803,'2009875','Shoulder Chair H',0,0,0,''),
			(31,2,1,4,'1.3.1.17','001.003.001.017',14,1,'Shoulder Chair Dolly TS7000',1299,0,1299,1299,'1891860','Shoulder Chair Dolly TS7000',0,0,0,''),
			(32,2,1,4,'1.3.1.18','001.003.001.018',14,1,'Fracture/Extension',0,0,0,0,'0333333','Fracture/Extension',0,1,0,''),
			(33,2,1,4,'1.3.1.19','001.003.001.019',14,1,'Extension adapter PST 300',3130,0,3130,3130,'2072419','Extension adapter PST 300',0,0,0,''),
			(34,2,1,4,'1.3.1.20','001.003.001.020',14,1,'Supporting pad universal MARS B',946,0,946,946,'1897603','Supporting pad universal MARS B',0,0,0,''),
			(35,2,1,4,'1.3.1.21','001.003.001.021',14,1,'Universal support',1986,0,1986,1986,'1876707','Universal support',0,0,0,''),
			(36,2,1,4,'1.3.1.22','001.003.001.022',14,1,'Counter traction post 150',378,0,378,378,'1612706','Counter traction post 150',0,0,0,''),
			(37,2,1,4,'1.3.1.23','001.003.001.023',14,1,'Double joint strut, pair',5052,0,5052,5052,'1574734','Double joint strut, pair',0,0,0,''),
			(38,2,1,4,'1.3.1.24','001.003.001.024',14,2,'Extension strut medium',881,0,881,1762,'1597668','Extension strut medium',0,0,0,''),
			(39,2,1,4,'1.3.1.25','001.003.001.025',14,2,'Adapter spindle traction mechanism',411,0,411,822,'1593159','Adapter spindle traction mechanism',0,0,0,''),
			(40,2,1,4,'1.3.1.26','001.003.001.026',14,2,'Spindle traction mechanism FR',3928,0,3928,7856,'1881967','Spindle traction mechanism FR',0,0,0,''),
			(41,2,1,4,'1.3.1.27','001.003.001.027',14,1,'Leg holder GOEPEL',713,0,713,713,'4544736','Leg holder GOEPEL',0,0,0,''),
			(42,2,1,4,'1.3.1.28','001.003.001.028',14,1,'Clamp radial setting',247,0,247,247,'1218804','Clamp radial setting',0,0,0,''),
			(43,2,1,4,'1.3.1.29','001.003.001.029',14,1,'Side rail adapter',358,0,358,358,'4544165','Side rail adapter',0,0,0,''),
			(44,2,1,4,'1.3.1.30','001.003.001.030',14,1,'Side rail',123,0,123,123,'4544166','Side rail',0,0,0,''),
			(45,2,1,4,'1.3.1.31','001.003.001.031',14,2,'Traction boot',1310,0,1310,2620,'1574733','Traction boot',0,0,0,''),
			(46,2,1,4,'1.3.1.32','001.003.001.032',14,1,'Transfer leg section',1421,0,1421,1421,'1876708','Transfer leg section',0,0,0,''),
			(47,2,1,4,'1.3.1.33','001.003.001.033',14,1,'Docking trolley extension unit',3420,0,3420,3420,'1867129','Docking trolley extension unit',0,0,0,''),
			(48,2,1,1,'2','002',NULL,1,'Professional Services',0,0,0,0,'0000000','NULL',0,0,0,''),
			(49,2,1,2,'2.1','002.001',48,1,'In-Country Service',0,0,0,40005,'0000000','NULL',0,0,0,''),
			(50,2,1,3,'2.1.1','002.001.001',49,1,'Installation / User Training / Warranty Labor',40005,0,0,40005,'0000000','NULL',0,0,0,''),
			(51,2,1,4,'2.1.1.1','002.001.001.001',50,1,'Installation and Training',32004,0,32004,32004,'1445119','Installation and Training',0,1,0,''),
			(52,2,1,4,'2.1.1.2','002.001.001.002',50,1,'Extended LABOR Warranty (12 months extra)',8001,0,8001,8001,'1445119','Extended LABOR Warranty (12 months extra)',0,1,0,'');

			SELECT * FROM @pudtGSSQuotationDetail;

			EXEC spGSS_Quotation_Detail_CRUD_Records @pvOptionCRUD		= 'C',
									@pvIdLanguageUser			= 'ANG', 
									@pvUser						= 'ANGUTIERRE',
									@pudtGSSQuotationDetail		= @pudtGSSQuotationDetail,
									@pvIP						= '0.0.0.0';


			----------------------------------------------------------------------------------------------------------------------------
			----------------------------------------------------------------------------------------------------------------------------
			
			Create -- Approval Flow Scenario (Folio 13, Version 1) -- Saved as FINA

			-- Update to FINA 
			SELECT
				Folio,
				[Version],
				Id_Quotation_Status
			FROM GSS_Quotation 
			WHERE 
					Folio = 13 
				AND [version] = 1;

			UPDATE GSS_Quotation SET Id_Quotation_Status = 'FINA'
			WHERE 
					Folio = 13 
				AND [version] = 1;

			-- Delete Approval Flow
			SELECT
				*
			FROM GSS_Approval_Workflow
			WHERE
					Folio = 13 
				AND [version] = 1;

			DELETE GSS_Approval_Workflow
			WHERE
					Folio = 13 
				AND [version] = 1;

			-- Delete Quotation Detail
			SELECT
				*
			FROM GSS_Quotation_Detail
			WHERE
					Folio = 13 
				AND [version] = 1;

			DELETE GSS_Quotation_Detail
			WHERE
					Folio = 13 
				AND [version] = 1;
			
			DECLARE @pudtGSSQuotationDetail UDT_GSS_Quotation_Detail
			INSERT INTO @pudtGSSQuotationDetail ([Id_Detail],[Folio],[Version],[Level_Number],[Position_Display],[Position_Sort],[Id_Parent],[Quantity],[Description],[Unit_Price],[Discount],[Net_Price],[Total_Price],[Id_Item],[Item_Short_Desc],[Item_Standard_Cost],[Generic_Item],[On_Request],[Notes]) VALUES (1,13,1,1,'1','001',NULL,1,'Inquiry Number N/A',0,0,0,0,'0000000','NULL',0,0,0,''),
			(2,13,1,2,'1.1','001.001',1,18,'GL0030 LAMP EXAMINATION, LED, WALL MTD',0,0,0,68403.6,'0000000','NULL',0,0,0,''),
			(3,13,1,3,'1.1.1','001.001.001',2,1,'TL1000 Wall',3800.2,0,0,3800.2,'0000000','NULL',0,0,0,''),
			(4,13,1,4,'1.1.1.1','001.001.001.001',3,1,'Central Axis Duo 1050/1200',2818,20,2254.4,2254.4,'2078108','Central Axis Duo 1050/1200',0,0,0,''),
			(5,13,1,4,'1.1.1.2','001.001.001.002',3,1,'Central Axis Single 1500',4454,70,1336.2,1336.2,'2078100','Central Axis Single 1500',0,0,0,''),
			(6,13,1,4,'1.1.1.3','001.001.001.003',3,1,'Wall Control Panel TL3000 Single Surface',1048,80,209.6,209.6,'1583531','Wall Control Panel TL3000 Single Surface',0,0,0,'');

			SELECT * FROM @pudtGSSQuotationDetail;

			EXEC spGSS_Quotation_Detail_CRUD_Records @pvOptionCRUD		= 'C',
									@pvIdLanguageUser			= 'ANG', 
									@pvUser						= 'ANGUTIERRE',
									@pudtGSSQuotationDetail		= @pudtGSSQuotationDetail,
									@pvIP						= '0.0.0.0';

			----------------------------------------------------------------------------------------------------------------------------
			----------------------------------------------------------------------------------------------------------------------------

			Create -- Approval Flow Scenario (Folio 13, Version 1) -- Saved as DRAF

			-- Update to DRAF 
			SELECT
				Folio,
				[Version],
				Id_Quotation_Status
			FROM GSS_Quotation 
			WHERE 
					Folio = 13 
				AND [version] = 1;

			UPDATE GSS_Quotation SET Id_Quotation_Status = 'DRAF'
			WHERE 
					Folio = 13 
				AND [version] = 1;

			-- Delete Approval Flow
			SELECT
				*
			FROM GSS_Approval_Workflow
			WHERE
					Folio = 13 
				AND [version] = 1;

			DELETE GSS_Approval_Workflow
			WHERE
					Folio = 13 
				AND [version] = 1;

			-- Delete Quotation Detail
			SELECT
				*
			FROM GSS_Quotation_Detail
			WHERE
					Folio = 13 
				AND [version] = 1;

			DELETE GSS_Quotation_Detail
			WHERE
					Folio = 13 
				AND [version] = 1;
			
			DECLARE @pudtGSSQuotationDetail UDT_GSS_Quotation_Detail
			INSERT INTO @pudtGSSQuotationDetail ([Id_Detail],[Folio],[Version],[Level_Number],[Position_Display],[Position_Sort],[Id_Parent],[Quantity],[Description],[Unit_Price],[Discount],[Net_Price],[Total_Price],[Id_Item],[Item_Short_Desc],[Item_Standard_Cost],[Generic_Item],[On_Request],[Notes]) VALUES (1,13,1,1,'1','001',NULL,1,'Inquiry Number N/A',0,0,0,0,'0000000','NULL',0,0,0,''),
			(2,13,1,2,'1.1','001.001',1,18,'GL0030 LAMP EXAMINATION, LED, WALL MTD',0,0,0,68403.6,'0000000','NULL',0,0,0,''),
			(3,13,1,3,'1.1.1','001.001.001',2,1,'TL1000 Wall',3800.2,0,0,3800.2,'0000000','NULL',0,0,0,''),
			(4,13,1,4,'1.1.1.1','001.001.001.001',3,1,'Central Axis Duo 1050/1200',2818,20,2254.4,2254.4,'2078108','Central Axis Duo 1050/1200',0,0,0,''),
			(5,13,1,4,'1.1.1.2','001.001.001.002',3,1,'Central Axis Single 1500',4454,70,1336.2,1336.2,'2078100','Central Axis Single 1500',0,0,0,''),
			(6,13,1,4,'1.1.1.3','001.001.001.003',3,1,'Wall Control Panel TL3000 Single Surface',1048,80,209.6,209.6,'1583531','Wall Control Panel TL3000 Single Surface',0,0,0,'');

			SELECT * FROM @pudtGSSQuotationDetail;

			EXEC spGSS_Quotation_Detail_CRUD_Records @pvOptionCRUD		= 'C',
									@pvIdLanguageUser			= 'ANG', 
									@pvUser						= 'ANGUTIERRE',
									@pudtGSSQuotationDetail		= @pudtGSSQuotationDetail,
									@pvIP						= '0.0.0.0';

			----------------------------------------------------------------------------------------------------------------------------
			----------------------------------------------------------------------------------------------------------------------------

			EXEC spGSS_Quotation_Detail_CRUD_Records @pvOptionCRUD		= 'R',
									@piFolio							= 1,
									@piVersion							= 1,
									@pvUser								= 'ANGUTIERRE',
									@pvIP								= '0.0.0.0';


*/
CREATE PROCEDURE [dbo].[spGSS_Quotation_Detail_CRUD_Records]
@pvOptionCRUD					Varchar(1),
@pvIdLanguageUser				Varchar(10)		= 'ANG',
@pvUser							Varchar(50),
@pudtGSSQuotationDetail			UDT_GSS_Quotation_Detail Readonly,
@pvIP							Varchar(20),
@piFolio						Int				= 0,
@piVersion						Int				= 0

AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------

	Declare @vDescOperationCRUD				Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD);
	DECLARE @vjsonUDTGSSQuotationDetail		NVarchar(MAX)	= (SELECT * FROM @pudtGSSQuotationDetail FOR JSON AUTO);
	DECLARE @viLastIdDetail					Int = (SELECT MAX(Id_Detail) FROM GSS_Quotation_Detail);
		IF @viLastIdDetail IS NULL 
			SET @viLastIdDetail = 0
	DECLARE @vvIdSalesType					Varchar(10);
	DECLARE @vvIdCountry					Varchar(10);
	DECLARE @vvIdZone						Varchar(10);
	DECLARE @viFolio						INT	= (SELECT Folio FROM @pudtGSSQuotationDetail GROUP BY Folio);
	DECLARE @viVersion						INT	= (SELECT [Version] FROM @pudtGSSQuotationDetail GROUP BY [Version]);
	DECLARE @viApprovalFlowCount			INT
	DECLARE @vvQuotationStatus				VARCHAR(10)


	--------------------------------------------------------------------
	--Cursor Variables
	--------------------------------------------------------------------

	DECLARE @ciIdDetail AS Bigint 
	DECLARE @ciFolio AS  Int
	DECLARE @ciVersion AS  Smallint
	DECLARE @ciLevelNumber AS Tinyint
	DECLARE @cvPositionDisplay AS VARCHAR(50)
	DECLARE @cvPositionSort AS VARCHAR(100)
	DECLARE @ciIdParent AS Bigint
	DECLARE @cfQuantity AS Float
	DECLARE @cvDescription AS VARCHAR(500)
	DECLARE @cfUnitPrice AS Float
	DECLARE @cfDiscount AS Float
	DECLARE @cfNetPrice AS Float
	DECLARE @cfTotalPrice AS Float
	DECLARE @cvIdItem AS VARCHAR(50)
	DECLARE @cvItemShortDesc AS VARCHAR(50)
	DECLARE @cfItemStandardCost AS Float
	DECLARE @cbGenericItem AS Bit
	DECLARE @cbOnRequest AS Bit
	DECLARE @cvNotes AS VARCHAR(500)
	DECLARE @viNextNumber Int
	DECLARE @ciIdApprovalFlow Smallint

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------

	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'GSS_Quotation_Detail - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spGSS_Quotation_Detail_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @vjsonUDTConfiguration = '" + ISNULL(@vjsonUDTGSSQuotationDetail,'NULL') + "'";

	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN

		SET @vvQuotationStatus = (SELECT Id_Quotation_Status FROM GSS_Quotation WHERE Folio = @viFolio AND [Version] = @viVersion);
		
		DECLARE curQuotationDetail CURSOR FOR
			SELECT *
			FROM @pudtGSSQuotationDetail
			ORDER BY Id_Detail

		SET @viNextNumber = @viLastIdDetail + 1;

		OPEN curQuotationDetail

		FETCH NEXT FROM curQuotationDetail INTO @ciIdDetail, @ciFolio, @ciVersion, @ciLevelNumber, @cvPositionDisplay, @cvPositionSort, @ciIdParent, @cfQuantity, @cvDescription, @cfUnitPrice, @cfDiscount, @cfNetPrice, @cfTotalPrice, @cvIdItem, @cvItemShortDesc, @cfItemStandardCost, @cbGenericItem, @cbOnRequest, @cvNotes
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			PRINT CAST(@ciIdDetail AS VARCHAR(10)) + ' | ' 
				+ CAST(@ciFolio AS VARCHAR(10)) + ' | ' 
				+ CAST(@ciVersion AS VARCHAR(10)) + ' | ' 
				+ CAST(@ciLevelNumber AS VARCHAR(10)) + ' | ' 
				+ @cvPositionDisplay + ' | ' 
				+ @cvPositionSort + ' | ' 
				+ CAST(ISNULL(@ciIdParent, 0) AS VARCHAR(10)) + ' | ' 
				+ CAST(@cfQuantity AS VARCHAR(10)) + ' | ' 
				+ @cvDescription + ' | ' 
				+ CAST(@cfUnitPrice AS VARCHAR(50)) + ' | ' 
				+ CAST(@cfDiscount AS VARCHAR(10)) + ' | ' 
				+ CAST(@cfNetPrice AS VARCHAR(50)) + ' | ' 
				+ CAST(@cfTotalPrice AS VARCHAR(50)) + ' | ' 
				+ @cvIdItem + ' | ' 
				+ @cvItemShortDesc + ' | ' 
				+ CAST(@cfItemStandardCost AS VARCHAR(50)) + ' | ' 
				+ CAST(@cbGenericItem AS VARCHAR(1)) + ' | ' 
				+ CAST(@cbOnRequest AS VARCHAR(1)) + ' | ' 
				+ @cvNotes 

			DECLARE @viParentId Int
			
			IF @ciLevelNumber = 1 
				SET @viParentId =  NULL
			ELSE
				SET @viParentId = (@viLastIdDetail + @ciIdParent)

			INSERT INTO GSS_Quotation_Detail (
				Id_Detail,
				Folio,
				[Version],
				Level_Number,
				Position_Display,
				Position_Sort,
				Id_Parent,
				Quantity,
				[Description],
				Unit_Price,
				Discount,
				Net_Price,
				Total_Price,
				Id_Item,
				Item_Short_Desc,
				Item_Standard_Cost,
				Generic_Item,
				On_Request,
				Notes,
				Modify_By,
				Modify_Date,
				Modify_IP
			) 
			VALUES (
				@viNextNumber,
				@ciFolio,
				@ciVersion,
				@ciLevelNumber,
				@cvPositionDisplay,
				dbo.fnFormatPositionSort(@cvPositionDisplay),
				@viParentId,
				@cfQuantity,
				@cvDescription,
				@cfUnitPrice,
				@cfDiscount,
				@cfNetPrice,
				@cfTotalPrice,
				@cvIdItem,
				@cvItemShortDesc,
				@cfItemStandardCost,
				@cbGenericItem,
				@cbOnRequest,
				@cvNotes,
				@pvUser,
				GETDATE(),
				@pvIP
			)

			IF @vvQuotationStatus = 'FINA'
			BEGIN

				SET @vvIdSalesType				= (SELECT Id_Sales_Type FROM GSS_Quotation WHERE Folio = @ciFolio AND [Version] = @ciVersion);
				SET @vvIdCountry				= (SELECT Id_Country_Bill_To FROM GSS_Quotation WHERE Folio = @ciFolio AND [Version] = @ciVersion);
				SET @vvIdZone					= (SELECT
															Id_Zone
													   FROM Cat_Zones_Countries
													   WHERE
																Id_Country = @vvIdCountry
															AND Id_Zone IN (SELECT
																				Id_Zone
																			FROM Cat_Zones
																			WHERE
																					Id_Zone_Type = 'DISC'
																				AND [Status] = 1)
															AND [Status] = 1);

				PRINT '@cvIdItem: ' + @cvIdItem;
				PRINT '@cfDiscount: ' + CAST(@cfDiscount AS VARCHAR(MAX));
				PRINT '@vvIdCountry: ' + @vvIdCountry;
				PRINT '@vvIdZone: ' + @vvIdZone;
				PRINT '@vvIdSalesType: ' + @vvIdSalesType;

				SET @ciIdApprovalFlow = dbo.fnGetApprovalFlow(@cvIdItem, @cfDiscount, @vvIdZone, @vvIdSalesType);

				PRINT '@ciIdApprovalFlow: ' + CAST(@ciIdApprovalFlow AS VARCHAR(MAX));

				IF @ciIdApprovalFlow > 0
				BEGIN
				
					PRINT 'Approval Flow: ' + CAST(@ciIdApprovalFlow AS VARCHAR(MAX));

					EXEC spGSS_Approval_Workflow_CRUD_Records @pvOptionCRUD		= 'C',
														  @pvIdLanguageUser = 'ANG',
														  @pvUser			= @pvUser,
														  @pvIP				= @pvIP,
														  @piFolio			= @ciFolio,
														  @piVersion		= @ciVersion,
														  @piIdDetail		= @viNextNumber,
														  @pvIdItem			= @cvIdItem,
														  @piIdApprovalFlow = @ciIdApprovalFlow;

				END

			END

			SET @viNextNumber = @viNextNumber + 1;

			FETCH NEXT FROM curQuotationDetail INTO @ciIdDetail, @ciFolio, @ciVersion, @ciLevelNumber, @cvPositionDisplay, @cvPositionSort, @ciIdParent, @cfQuantity, @cvDescription, @cfUnitPrice, @cfDiscount, @cfNetPrice, @cfTotalPrice, @cvIdItem, @cvItemShortDesc, @cfItemStandardCost, @cbGenericItem, @cbOnRequest, @cvNotes

		END

		CLOSE curQuotationDetail

		DEALLOCATE curQuotationDetail

		SET @viApprovalFlowCount = (SELECT COUNT(*) FROM GSS_Approval_Workflow WHERE Folio = @viFolio AND [Version] = @viVersion);

		IF @vvQuotationStatus = 'FINA'
		BEGIN
		
			IF @viApprovalFlowCount > 0
			BEGIN
			
			EXEC spGSS_Quotation_CRUD_Records @pvOptionCRUD = 'U',
													@pvIdLanguageUser = 'ANG',
													@pvIdQuotationStatus = 'ROUT',
													@pvUser = @pvUser,
													@pvIP = @pvIP,
													@piFolio = @viFolio,
													@piVersion = @viVersion;
		
			END
		

		END
		
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN

		PRINT 'READ for Quotation Detail' 

		SELECT
			GQD.Folio,
			GQD.[Version],
			GQD.Position_Display,
			GQD.Level_Number,
			GQD.Quantity,
			GQD.Id_Item,
			GQD.[Description],
			GQD.Unit_Price,
			GQD.Discount,
			GQD.Net_Price,
			GQD.Total_Price
		FROM GSS_Quotation_Detail AS GQD
		WHERE 
				(@piFolio					= 0		OR Folio						= @piFolio) AND 
				(@piVersion					= 0		OR [Version]					= @piVersion);
	
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		
		PRINT 'UPDATE for Quotation Detail'

		IF (@piFolio = 0 OR @piFolio = NULL) OR (@piVersion = 0 OR @piVersion = NULL)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('N/A',@pvIdLanguageUser)
		END
		ELSE
		BEGIN
			DELETE GSS_Quotation_Detail
			WHERE
					Folio = @piFolio
				AND [Version] = @piVersion;

			SET @vvQuotationStatus = (SELECT Id_Quotation_Status FROM GSS_Quotation WHERE Folio = @viFolio AND [Version] = @viVersion);

			DECLARE curQuotationDetail CURSOR FOR
			SELECT *
			FROM @pudtGSSQuotationDetail
			ORDER BY Id_Detail

			SET @viNextNumber = @viLastIdDetail + 1;

			OPEN curQuotationDetail

			FETCH NEXT FROM curQuotationDetail INTO @ciIdDetail, @ciFolio, @ciVersion, @ciLevelNumber, @cvPositionDisplay, @cvPositionSort, @ciIdParent, @cfQuantity, @cvDescription, @cfUnitPrice, @cfDiscount, @cfNetPrice, @cfTotalPrice, @cvIdItem, @cvItemShortDesc, @cfItemStandardCost, @cbGenericItem, @cbOnRequest, @cvNotes
		
			WHILE @@FETCH_STATUS = 0
			BEGIN
			
				PRINT CAST(@ciIdDetail AS VARCHAR(10)) + ' | ' 
					+ CAST(@ciFolio AS VARCHAR(10)) + ' | ' 
					+ CAST(@ciVersion AS VARCHAR(10)) + ' | ' 
					+ CAST(@ciLevelNumber AS VARCHAR(10)) + ' | ' 
					+ @cvPositionDisplay + ' | ' 
					+ @cvPositionSort + ' | ' 
					+ CAST(ISNULL(@ciIdParent, 0) AS VARCHAR(10)) + ' | ' 
					+ CAST(@cfQuantity AS VARCHAR(10)) + ' | ' 
					+ @cvDescription + ' | ' 
					+ CAST(@cfUnitPrice AS VARCHAR(50)) + ' | ' 
					+ CAST(@cfDiscount AS VARCHAR(10)) + ' | ' 
					+ CAST(@cfNetPrice AS VARCHAR(50)) + ' | ' 
					+ CAST(@cfTotalPrice AS VARCHAR(50)) + ' | ' 
					+ @cvIdItem + ' | ' 
					+ @cvItemShortDesc + ' | ' 
					+ CAST(@cfItemStandardCost AS VARCHAR(50)) + ' | ' 
					+ CAST(@cbGenericItem AS VARCHAR(1)) + ' | ' 
					+ CAST(@cbOnRequest AS VARCHAR(1)) + ' | ' 
					+ @cvNotes 
			
				IF @ciLevelNumber = 1 
					SET @viParentId =  NULL
				ELSE
					SET @viParentId = (@viLastIdDetail + @ciIdParent)

				INSERT INTO GSS_Quotation_Detail (
					Id_Detail,
					Folio,
					[Version],
					Level_Number,
					Position_Display,
					Position_Sort,
					Id_Parent,
					Quantity,
					[Description],
					Unit_Price,
					Discount,
					Net_Price,
					Total_Price,
					Id_Item,
					Item_Short_Desc,
					Item_Standard_Cost,
					Generic_Item,
					On_Request,
					Notes,
					Modify_By,
					Modify_Date,
					Modify_IP
				) VALUES (
					 @viNextNumber,
					 @ciFolio,
					 @ciVersion,
					 @ciLevelNumber,
					 @cvPositionDisplay,
					 dbo.fnFormatPositionSort(@cvPositionDisplay),
					 @viParentId,
					 @cfQuantity,
					 @cvDescription,
					 @cfUnitPrice,
					 @cfDiscount,
					 @cfNetPrice,
					 @cfTotalPrice,
					 @cvIdItem,
					 @cvItemShortDesc,
					 @cfItemStandardCost,
					 @cbGenericItem,
					 @cbOnRequest,
					 @cvNotes,
					 @pvUser,
					 GETDATE(),
					 @pvIP
				)

				IF @vvQuotationStatus = 'FINA'
				BEGIN
				
					SET @vvIdSalesType				= (SELECT Id_Sales_Type FROM GSS_Quotation WHERE Folio = @ciFolio AND [Version] = @ciVersion);
					SET @vvIdCountry				= (SELECT Id_Country_Bill_To FROM GSS_Quotation WHERE Folio = @ciFolio AND [Version] = @ciVersion);
					SET @vvIdZone					= (SELECT
															Id_Zone
													   FROM Cat_Zones_Countries
													   WHERE
																Id_Country = @vvIdCountry
															AND Id_Zone IN (SELECT
																				Id_Zone
																			FROM Cat_Zones
																			WHERE
																					Id_Zone_Type = 'DISC'
																				AND [Status] = 1)
															AND [Status] = 1);

					PRINT '@cvIdItem: ' + @cvIdItem;
					PRINT '@cfDiscount: ' + CAST(@cfDiscount AS VARCHAR(MAX));
					PRINT '@vvIdCountry: ' + @vvIdCountry;
					PRINT '@vvIdZone: ' + @vvIdZone;
					PRINT '@vvIdSalesType: ' + @vvIdSalesType;

					SET @ciIdApprovalFlow = dbo.fnGetApprovalFlow(@cvIdItem, @cfDiscount, @vvIdZone, @vvIdSalesType);

					PRINT '@ciIdApprovalFlow: ' + CAST(@ciIdApprovalFlow AS VARCHAR(MAX));

					IF @ciIdApprovalFlow > 0
					BEGIN
				
						PRINT 'Approval Flow: ' + CAST(@ciIdApprovalFlow AS VARCHAR(MAX));

						EXEC spGSS_Approval_Workflow_CRUD_Records @pvOptionCRUD		= 'C',
															  @pvIdLanguageUser = 'ANG',
															  @pvUser			= @pvUser,
															  @pvIP				= @pvIP,
															  @piFolio			= @ciFolio,
															  @piVersion		= @ciVersion,
															  @piIdDetail		= @viNextNumber,
															  @pvIdItem			= @cvIdItem,
															  @piIdApprovalFlow = @ciIdApprovalFlow;

					END
				
				END


				SET @vvIdSalesType				= (SELECT Id_Sales_Type FROM GSS_Quotation WHERE Folio = @ciFolio AND [Version] = @ciVersion);
				SET @vvIdCountry				= (SELECT Id_Country_Bill_To FROM GSS_Quotation WHERE Folio = @ciFolio AND [Version] = @ciVersion);
				SET @vvIdZone					= (SELECT
														Id_Zone
												   FROM Cat_Zones_Countries
												   WHERE
															Id_Country = @vvIdCountry
														AND Id_Zone IN (SELECT
																			Id_Zone
																		FROM Cat_Zones
																		WHERE
																				Id_Zone_Type = 'DISC'
																			AND [Status] = 1)
														AND [Status] = 1);

				PRINT '@cvIdItem: ' + @cvIdItem;
				PRINT '@cfDiscount: ' + CAST(@cfDiscount AS VARCHAR(MAX));
				PRINT '@vvIdCountry: ' + @vvIdCountry;
				PRINT '@vvIdZone: ' + @vvIdZone;
				PRINT '@vvIdSalesType: ' + @vvIdSalesType;

				SET @ciIdApprovalFlow = dbo.fnGetApprovalFlow(@cvIdItem, @cfDiscount, @vvIdZone, @vvIdSalesType);

				PRINT '@ciIdApprovalFlow: ' + CAST(@ciIdApprovalFlow AS VARCHAR(MAX));

				IF @ciIdApprovalFlow > 0
				BEGIN
				
					PRINT 'Approval Flow: ' + CAST(@ciIdApprovalFlow AS VARCHAR(MAX));

					EXEC spGSS_Approval_Workflow_CRUD_Records @pvOptionCRUD		= 'C',
														  @pvIdLanguageUser = 'ANG',
														  @pvUser			= @pvUser,
														  @pvIP				= @pvIP,
														  @piFolio			= @ciFolio,
														  @piVersion		= @ciVersion,
														  @piIdDetail		= @viNextNumber,
														  @pvIdItem			= @cvIdItem,
														  @piIdApprovalFlow = @ciIdApprovalFlow;

				END

				SET @viNextNumber = @viNextNumber + 1;

				FETCH NEXT FROM curQuotationDetail INTO @ciIdDetail, @ciFolio, @ciVersion, @ciLevelNumber, @cvPositionDisplay, @cvPositionSort, @ciIdParent, @cfQuantity, @cvDescription, @cfUnitPrice, @cfDiscount, @cfNetPrice, @cfTotalPrice, @cvIdItem, @cvItemShortDesc, @cfItemStandardCost, @cbGenericItem, @cbOnRequest, @cvNotes

			END

			CLOSE curQuotationDetail

			DEALLOCATE curQuotationDetail

			SET @viApprovalFlowCount = (SELECT COUNT(*) FROM GSS_Approval_Workflow WHERE Folio = @viFolio AND [Version] = @viVersion);
			--SET @vvQuotationStatus = (SELECT Id_Quotation_Status FROM GSS_Quotation WHERE Folio = @viFolio AND [Version] = @viVersion);

			IF @vvQuotationStatus = 'FINA'
			BEGIN
		
				IF @viApprovalFlowCount > 0
				BEGIN
			
				EXEC spGSS_Quotation_CRUD_Records @pvOptionCRUD = 'U',
														@pvIdLanguageUser = 'ANG',
														@pvIdQuotationStatus = 'ROUT',
														@pvUser = @pvUser,
														@pvIP = @pvIP,
														@piFolio = @viFolio,
														@piVersion = @viVersion;
		
				END
		

			END

		END
		
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

	IF @pvOptionCRUD <> 'R'
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
		SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog
		
END CATCH
