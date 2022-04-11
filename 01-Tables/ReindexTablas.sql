USE DBQS
GO


ALTER INDEX ALL ON [dbo].Commercial_Release
REORGANIZE ;   
GO
ALTER INDEX ALL ON [dbo].Commercial_Release 
REBUILD WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO


ALTER INDEX ALL ON [dbo].Cat_Item
REORGANIZE ;   
GO
ALTER INDEX ALL ON [dbo].Cat_Item 
REBUILD WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO


ALTER INDEX ALL ON [dbo].Items_Templates
REORGANIZE ;   
GO
ALTER INDEX ALL ON [dbo].Items_Templates 
REBUILD WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO


ALTER INDEX ALL ON [dbo].Cat_Zones_Countries
REORGANIZE ;   
GO
ALTER INDEX ALL ON [dbo].Cat_Zones_Countries 
REBUILD WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
