USE DBQS
/*==============================================================*/
/* ALTER TABLE : Security_Users                                 */
/*==============================================================*/

-- Add Field
ALTER TABLE Security_Users ADD Id_Language VARCHAR(10)


-- Delete Constraint
alter table Security_Users
   add constraint FK_SECURITY_FK_LENGUA_CAT_LANG foreign key (Id_Language)
      references Cat_Languages (Id_Language)
go

-- Delete Index
create index FK_LENGUAGES_USERS_FK on Security_Users (
Id_Language ASC
)
go
