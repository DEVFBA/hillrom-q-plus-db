ALTER TABLE [dbo].[Cat_Discount_Categories]
ADD [Id_Business_Line] VARCHAR(10) NULL;

ALTER TABLE [dbo].[Cat_Discount_Categories]
ADD CONSTRAINT FK_Discount_Business_Line
FOREIGN KEY ([Id_Business_Line])
REFERENCES [dbo].[Cat_Business_Line]([Id_Business_Line]);

/** Execute the Update to original Discount Categories as PSSLIKO **/

ALTER TABLE [dbo].[Cat_Discount_Categories]
ALTER COLUMN [Id_Business_Line] VARCHAR(10) NOT NULL;
