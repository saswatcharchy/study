--Drop table #Listoftables
SELECT
t.Name AS TableName,ROW_NUMBER() Over(Order by t.Name asc) rnk into #Listoftables
FROM sys.tables t
INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
where p.rows>0 AND T.name not in ('PMT_PayloadStatus','PMT_Schema')
GROUP BY t.Name, s.Name, p.Rows
ORDER BY s.Name, t.Name


--Drop table #Payloadlevelcount
Create Table #Payloadlevelcount (TableName Varchar(800),PMT_PayloadId Varchar(800),[rowcount] INT)
Declare  @Tablecount int =1
while @Tablecount<(select count(*) from #Listoftables)
Begin
Declare @Tablename Varchar(800);

select @Tablename=TableName from #Listoftables where rnk=@Tablecount

Declare @SQLCountQuery Nvarchar(Max)

set @SQLCountQuery='SELECT '''+@Tablename+''' as TableName,PMT_PayloadId,Count(1) as [rowcount] FROM '+@Tablename+ ' Group by PMT_PayloadId'

Insert into #Payloadlevelcount
exec(@SQLCountQuery)

Print @SQLCountQuery
set @Tablecount=@Tablecount+1

end

select * from #Payloadlevelcount where TableName<>'NOte' order by PMT_Payloadid


select * from #Payloadlevelcount where PMT_Payloadid='WA155926'

;with cte as (
select PMT_Payloadid,Sum([rowcount]) as TotalrowsperPayload
 from #Payloadlevelcount 
 where TableName<>'NOte'
 Group by PMT_Payloadid
 )
 select * from cte order by TotalrowsperPayload desc
