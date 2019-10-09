
use GPTECH2019
go

drop procedure if exists adm_JenK
go

Create procedure adm_JenK as
BEGIN
    select * from GP16S..ACTIVITY
    where LOGINDAT < dateadd(Day, -2, GETDATE())
END

GO
Grant execute on adm_JenK to public as dbo
GO
 