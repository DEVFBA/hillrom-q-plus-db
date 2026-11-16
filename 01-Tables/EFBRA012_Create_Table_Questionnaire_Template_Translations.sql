USE DBQS
GO

/*==============================================================*/
/* Table: Questionnaire_Template_Translations                   */
/*==============================================================*/

/*-- Drop Table if Exists --*/
IF OBJECT_ID('dbo.Questionnaire_Template_Translations', 'U') IS NOT NULL
    DROP TABLE dbo.Questionnaire_Template_Translations
GO

/*-- Drop Foreign Key Constraints if They Exist --*/
IF OBJECT_ID('dbo.Questionnaire_Template_Translations', 'U') IS NOT NULL
BEGIN
    IF OBJECT_ID('dbo.FK_QUESTTEMPL_FK_QUESTIO_QUESTION', 'F') IS NOT NULL
        ALTER TABLE dbo.Questionnaire_Template_Translations
            DROP CONSTRAINT FK_QUESTTEMPL_FK_QUESTIO_QUESTION
    
    IF OBJECT_ID('dbo.FK_QUESTTEMPL_FK_LANGUA_LANGUAGE', 'F') IS NOT NULL
        ALTER TABLE dbo.Questionnaire_Template_Translations
            DROP CONSTRAINT FK_QUESTTEMPL_FK_LANGUA_LANGUAGE
    
    IF OBJECT_ID('dbo.FK_QUESTTEMPL_FK_LANGTRANS_TRANSLATION', 'F') IS NOT NULL
        ALTER TABLE dbo.Questionnaire_Template_Translations
            DROP CONSTRAINT FK_QUESTTEMPL_FK_LANGTRANS_TRANSLATION
END
GO

/*-- Create Table --*/
CREATE TABLE dbo.Questionnaire_Template_Translations
(
    Id_Question             NUMERIC(18, 0) NOT NULL,
    Id_Language             VARCHAR(10) NOT NULL,
    Id_Language_Translation VARCHAR(10) NOT NULL,
    Question                VARCHAR(100) NOT NULL,
    Data_JSON               VARCHAR(8000) NULL,
    Modify_By               VARCHAR(50) NOT NULL,
    Modify_Date             DATETIME NOT NULL,
    Modify_IP               VARCHAR(20) NOT NULL,
    CONSTRAINT PK_QUESTTEMPL_TRANSLATIONS PRIMARY KEY NONCLUSTERED 
        (Id_Question ASC, Id_Language_Translation ASC, Id_Language ASC)
)
GO

/*-- Create Foreign Key Constraint to Questionnaire_Template (Id_Question) --*/
ALTER TABLE dbo.Questionnaire_Template_Translations
    ADD CONSTRAINT FK_QUESTTEMPL_FK_QUESTIO_QUESTION FOREIGN KEY (Id_Question)
        REFERENCES dbo.Questionnaire_Template (Id_Question)
GO

/*-- Create Indexes for Foreign Keys --*/
CREATE INDEX FK_QUESTTEMPL_QUESTION_IDX 
    ON dbo.Questionnaire_Template_Translations (Id_Question ASC)
GO

CREATE INDEX FK_QUESTTEMPL_LANGUAGE_IDX 
    ON dbo.Questionnaire_Template_Translations (Id_Language ASC)
GO

CREATE INDEX FK_QUESTTEMPL_LANGTRANS_IDX 
    ON dbo.Questionnaire_Template_Translations (Id_Language_Translation ASC)
GO

PRINT 'Table Questionnaire_Template_Translations created successfully'
GO

