USE GPTECH2019
GO

drop procedure if exists as_Missing401kBenefit
go

Create procedure as_Missing401kBenefit with encryption as


    set nocount on
    ---Changed per script
    declare @ToAddress as varchar(8000) --A semicolon delimited list of who receives the email message.
    set @ToAddress = 'This email address is to the person or group that should know about this problem.' --Try to use a DL if at all possible



--Changed per script
declare @ScriptName as varchar(100)
set @ScriptName = 'Missing 401k Benefit'

declare @MessageBody as varchar(8000) --Body of email message. 
--Message should be formatted as Script Name: message text.
set @MessageBody = @ScriptName + ': Employee has an Active 401K Deduction but not a 401k Benefit.' + char(13) + char(13)

--Changed per script
declare @SqlTemplate as nvarchar(4000) --The template of the sqlcommand that is changed by a replace command.

set @SqlTemplate = N'select UPR00500.EMPLOYID as Employee_id, 
					UPR00600.Benefit, 
					UPR00600.INACTIVE as Benefit_Inactive, 
					UPR00500.DEDUCTON as Deduction, 
					UPR00500.INACTIVE as Deduction_Inactive
				from <dbname>..UPR00500 as UPR00500 
					Left join <dbname>..UPR00600 as UPR00600 on UPR00500.EMPLOYID = UPR00600.EMPLOYID 
										AND UPR00500.DEDUCTON = UPR00600.BENEFIT
				where upr00500.inactive = 0
					and upr00500.deducton = ''401K''
					and upr00600.employid is null'


--Changed per script, depends on @SqlTemplate for structure. TABLE NAME MUST ALWAYS BE ##Results!!!! 
create table ##M4B(Employee_ID char(10), Benefit char(5) null, Benefit_Inactive Int null, Deduction char(5), Deduction_Inactive int)


--DO NOT CHANGE ANYTHONG BELOW THIS POINT. --Except maybe the order by part of @Query
--Constant never change this
declare @MessageSubject as varchar(250) --Subject line of email message. Always set to 'Great Plains Alert'.
Set @MessageSubject = 'Great Plains Alert: ' + @ScriptName

--Used internally never change.
declare @SqlCommand as nvarchar(4000)  --The resulting sql statement after the replace command. 

set @SqlCommand = Replace(@SqlTemplate, '<dbname>','GP16C')
insert into ##M4B exec sp_executesql @sqlcommand	

--set @SqlCommand = Replace(@SqlTemplate, '<dbname>','CompanyA')
--insert into ##M4B exec sp_executesql @sqlcommand				

--set @SqlCommand = Replace(@SqlTemplate, '<dbname>','CompanyB')
--insert into ##M4B exec sp_executesql @sqlcommand	

--set @SqlCommand = Replace(@SqlTemplate, '<dbname>','CompanyC')
--insert into ##M4B exec sp_executesql @sqlcommand				

if (select count(*) from ##M4B) > 0 --If anything to report then mail the results back to the user
	begin
		exec	msdb..sp_send_dbmail @recipients = @ToAddress, 
											@blind_copy_recipients = 'Your email address goes here.',
											@body = @MessageBody, 
											@subject = @MessageSubject,
											@query = 'SELECT * from ##M4B order by employee_id',
											@query_result_width = 160
 	end	

drop table ##M4B




go

grant exec on as_Missing401kBenefit to public

go


-- exec as_Missing401kBenefit

