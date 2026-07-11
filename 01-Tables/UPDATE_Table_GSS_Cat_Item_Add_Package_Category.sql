/** Update Adding Package_Category column to GSS_Cat_Item table */

ALTER TABLE GSS_Cat_Item
ADD Package_Category VARCHAR(10) NULL;