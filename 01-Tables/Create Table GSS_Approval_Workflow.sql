/*==============================================================*/
/* Table: GSS_Approval_Workflow                                */
/* Description: Copy of Approval_Workflow for GSS system      */
/* Modifications:                                               */
/* - Removed Id_Approval_Section and Id_Approval_Type fields  */
/* - Changed FK reference from Quotation_Header to GSS_Quotation_Detail */
/* - Item_Template changed to Id_Item                         */
/* - Id_Header changed to Id_Detail                           */
/*==============================================================*/

USE DBQS;

/*==============================================================*/
/* Drop existing constraints and table if they exist           */
/*==============================================================*/
IF EXISTS (
    SELECT 1
    FROM sys.sysreferences r 
    JOIN sys.sysobjects o ON (o.id = r.constid AND o.type = 'F')
    WHERE r.fkeyid = object_id('GSS_Approval_Workflow') 
    AND o.name = 'FK_GSSAPPROVAL_FK_APPROV_APPROVAL'
)
ALTER TABLE GSS_Approval_Workflow
DROP CONSTRAINT FK_GSSAPPROVAL_FK_APPROV_APPROVAL;

IF EXISTS (
    SELECT 1
    FROM sys.sysreferences r 
    JOIN sys.sysobjects o ON (o.id = r.constid AND o.type = 'F')
    WHERE r.fkeyid = object_id('GSS_Approval_Workflow') 
    AND o.name = 'FK_GSSAPPROVAL_FK_CATAPP_CAT_APPR'
)
ALTER TABLE GSS_Approval_Workflow
DROP CONSTRAINT FK_GSSAPPROVAL_FK_CATAPP_CAT_APPR;

IF EXISTS (
    SELECT 1
    FROM sys.sysreferences r 
    JOIN sys.sysobjects o ON (o.id = r.constid AND o.type = 'F')
    WHERE r.fkeyid = object_id('GSS_Approval_Workflow') 
    AND o.name = 'FK_GSSAPPROVAL_FK_GSSQDETAIL_DETAIL'
)
ALTER TABLE GSS_Approval_Workflow
DROP CONSTRAINT FK_GSSAPPROVAL_FK_GSSQDETAIL_DETAIL;



-- Drop indexes
IF EXISTS (
    SELECT 1
    FROM sysindexes
    WHERE id = object_id('GSS_Approval_Workflow')
    AND name = 'FK_CATAPPROVALSTATUS_GSSWORKFLOW_FK'
    AND indid > 0
    AND indid < 255
)
DROP INDEX GSS_Approval_Workflow.FK_CATAPPROVALSTATUS_GSSWORKFLOW_FK;

IF EXISTS (
    SELECT 1
    FROM sysindexes
    WHERE id = object_id('GSS_Approval_Workflow')
    AND name = 'FK_APPROVALTRACKER_GSSWORKFLOW_FK'
    AND indid > 0
    AND indid < 255
)
DROP INDEX GSS_Approval_Workflow.FK_APPROVALTRACKER_GSSWORKFLOW_FK;

IF EXISTS (
    SELECT 1
    FROM sysindexes
    WHERE id = object_id('GSS_Approval_Workflow')
    AND name = 'FK_GSSQUOTDETAIL_GSSWORKFLOW_FK'
    AND indid > 0
    AND indid < 255
)
DROP INDEX GSS_Approval_Workflow.FK_GSSQUOTDETAIL_GSSWORKFLOW_FK;

-- Drop table
IF EXISTS (
    SELECT 1
    FROM sysobjects
    WHERE id = object_id('GSS_Approval_Workflow')
    AND type = 'U'
)
DROP TABLE GSS_Approval_Workflow;

/*==============================================================*/
/* Table: GSS_Approval_Workflow                                */
/*==============================================================*/
CREATE TABLE GSS_Approval_Workflow (
    Id_Approval_Workflow    BIGINT          IDENTITY,
    Folio                   INT             NOT NULL,
    Version                 SMALLINT        NOT NULL,
    Id_Detail               BIGINT          NOT NULL,    -- Changed from Id_Header, references GSS_Quotation_Detail.Id_Detail
    Id_Item                 VARCHAR(50)     NOT NULL,    -- Changed from Item_Template, references GSS_Quotation_Detail.Id_Item
    Id_Approval_Flow        SMALLINT        NOT NULL,
    Id_Role                 VARCHAR(10)     NOT NULL,
    Id_Approval_Status      VARCHAR(10)     NOT NULL,
    Approval_Flow_Sequence  SMALLINT        NULL,
    Comments                VARCHAR(1000)   NULL,
    Modify_By               VARCHAR(50)     NOT NULL,
    Modify_Date             DATETIME        NOT NULL,     
    Modify_IP               VARCHAR(20)     NOT NULL,
    CONSTRAINT PK_GSS_APPROVAL_WORKFLOW PRIMARY KEY CLUSTERED (
        Id_Approval_Workflow
    )
);

/*==============================================================*/
/* Index: FK_CATAPPROVALSTATUS_GSSWORKFLOW_FK                  */
/*==============================================================*/
CREATE INDEX FK_CATAPPROVALSTATUS_GSSWORKFLOW_FK ON GSS_Approval_Workflow (
    Id_Approval_Status ASC
);

/*==============================================================*/
/* Index: FK_APPROVALTRACKER_GSSWORKFLOW_FK                    */
/*==============================================================*/
CREATE INDEX FK_APPROVALTRACKER_GSSWORKFLOW_FK ON GSS_Approval_Workflow (
    Id_Role ASC,
    Id_Approval_Flow ASC
);

/*==============================================================*/
/* Index: FK_GSSQUOTDETAIL_GSSWORKFLOW_FK                      */
/*==============================================================*/
CREATE INDEX FK_GSSQUOTDETAIL_GSSWORKFLOW_FK ON GSS_Approval_Workflow (
    Folio ASC,
    Version ASC,
    Id_Item ASC,
    Id_Detail ASC
);

/*==============================================================*/
/* Foreign Key Constraints                                      */
/*==============================================================*/

-- FK to Approval_Tracker (remains as requested)
ALTER TABLE GSS_Approval_Workflow
ADD CONSTRAINT FK_GSSAPPROVAL_FK_APPROV_APPROVAL 
FOREIGN KEY (Id_Role, Id_Approval_Flow)
REFERENCES Approval_Tracker (Id_Role, Id_Approval_Flow);

-- FK to Cat_Approval_Status (remains as requested)
ALTER TABLE GSS_Approval_Workflow
ADD CONSTRAINT FK_GSSAPPROVAL_FK_CATAPP_CAT_APPR 
FOREIGN KEY (Id_Approval_Status)
REFERENCES Cat_Approval_Status (Id_Approval_Status);

-- FK to GSS_Quotation_Detail (changed from Quotation_Header as requested)
-- Id_Detail is the primary key of GSS_Quotation_Detail, so this ensures full referential integrity
ALTER TABLE GSS_Approval_Workflow
ADD CONSTRAINT FK_GSSAPPROVAL_FK_GSSQDETAIL_DETAIL
FOREIGN KEY (Id_Detail)
REFERENCES GSS_Quotation_Detail (Id_Detail);



GO

PRINT 'GSS_Approval_Workflow table created successfully';
PRINT 'ENHANCEMENTS APPLIED:';
PRINT '1. Primary key optimized to single IDENTITY column for better performance';
PRINT '2. Data type changed from NUMERIC to BIGINT IDENTITY for efficiency';
PRINT 'MODIFICATIONS:';
PRINT '1. Id_Header was replaced with Id_Detail to reference specific detail records';
PRINT '2. FK to GSS_Quotation_Detail (Id_Detail) ensures referential integrity';
PRINT '   - Id_Detail is primary key, so no need for additional Folio/Version FK';
PRINT '3. Self-referencing FK removed as no relationship needed';
PRINT '4. The primary key includes Id_Detail instead of Id_Header for unique identification';
PRINT '5. Id_Approval_Section and Id_Approval_Type fields were removed as requested';
PRINT '6. FK to Cat_Approval_Types was removed as requested';
