CREATE TABLE GSS_Cat_Packages_Lines
(
	Id_Package_Line VARCHAR(10) NOT NULL,
	Short_Desc VARCHAR(50) NULL,
	Long_Desc VARCHAR(255) NULL,
	Status VARCHAR(20) NULL,
	Modify_By VARCHAR(50) NULL,
	Modify_Date DATETIME NULL,
	Modify_IP VARCHAR(20) NULL,
	CONSTRAINT PK_GSS_Cat_Packages_Lines PRIMARY KEY (Id_Package_Line)
);
