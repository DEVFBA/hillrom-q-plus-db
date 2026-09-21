USE DBQS
GO

/*==============================================================*/
/* Table: Max_Allowed_Discounts                                 */
/*==============================================================*/

IF EXISTS (
    SELECT 1
    FROM sysobjects
    WHERE id = OBJECT_ID('Max_Allowed_Discounts')
      AND type = 'U'
)
    DROP TABLE Max_Allowed_Discounts
GO

CREATE TABLE Max_Allowed_Discounts (
   Id_Discount_Category   varchar(10)          not null,
   Max_Allowed_Discount   float                not null,
   Modify_By              varchar(50)          not null,
   Modify_IP              varchar(20)          not null,
   Modify_Date            datetime             not null,
   CONSTRAINT PK_Max_Allowed_Discounts PRIMARY KEY CLUSTERED (Id_Discount_Category)
)
GO

ALTER TABLE Max_Allowed_Discounts
   ADD CONSTRAINT FK_MAXALWDISC_CAT_DISCOUNT_CATEGORIES FOREIGN KEY (Id_Discount_Category)
      REFERENCES Cat_Discount_Categories (Id_Discount_Category)
GO
