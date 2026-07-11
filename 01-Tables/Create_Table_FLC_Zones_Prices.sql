use DBQS
GO

/*==============================================================*/
/* Table: FLC_Zones_Prices                                      */
/*==============================================================*/
if exists (select 1
				from  sysobjects
			  where  id = object_id('FLC_Zones_Prices')
				and   type = 'U')
	drop table FLC_Zones_Prices
go

create table FLC_Zones_Prices (
	Id_Item              varchar(50)          not null,
	Id_Region            varchar(10)          not null,
	Id_Zone              varchar(10)          not null,
	Price                float                not null,
	Modify_By            varchar(50)          not null,
	Modify_IP            varchar(20)          not null,
	Modify_Date          datetime             not null,
	constraint PK_FLC_ZONES_PRICES primary key (Id_Item, Id_Region, Id_Zone)
)
go

create index FK_FLC_CAT_ITEM_ZONES_PRICES_FK on FLC_Zones_Prices (
Id_Item ASC
)
go

create index FK_CAT_REGION_ZONES_PRICES_FK on FLC_Zones_Prices (
Id_Region ASC,
Id_Zone ASC
)
go

alter table FLC_Zones_Prices
	add constraint FK_FLC_CatItem_ZonesPrices foreign key (Id_Item)
		references FLC_Cat_Item (Id_Item)
go

alter table FLC_Zones_Prices
	add constraint FK_CatRegionZone_ZonesPrices foreign key (Id_Region, Id_Zone)
		references Cat_Region_Zones (Id_Region, Id_Zone)
go
