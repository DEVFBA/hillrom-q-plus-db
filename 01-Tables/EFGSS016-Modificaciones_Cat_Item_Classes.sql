ALTER TABLE Cat_Item_Classes
ADD Id_Business_Line VARCHAR(10) NOT NULL DEFAULT 'PSSLIKO';

ALTER TABLE Cat_Item_Classes
ADD CONSTRAINT FK_CatItemClasses_BusinessLine
FOREIGN KEY (Id_Business_Line)
REFERENCES Cat_Business_Line (Id_Business_Line);