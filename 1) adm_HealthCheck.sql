
USE GPTECH2019
GO

if object_id('adm_HealthCheck') <> 0 drop procedure adm_HealthCheck
go


CREATE PROCEDURE adm_HealthCheck AS
     BEGIN
	   DECLARE @ReturnResults as int
	   Declare @ThisRun DateTime = getdate()
	   PRINT '******************************************************************************'
	   Print 'adm_HealthCheck Starting: ' + convert(varchar(50), @ThisRun, 101) + ' ' + convert(varchar(50), @ThisRun, 108)

	   --Print '----'
	   --Print 'Starting RandomDelay: ' + convert(varchar(19), getdate())
	   --Execute @ReturnResults = Admin.dbo.RandomDelay 0, 1
	   --IF @ReturnResults <> 0 Print 'IHADANERROR: adm_MemReset'
	   --SET @ReturnResults = 0
	   --Print 'Finished RandomDelay'
	   --Print '----'

	   Print '----'
	   If datepart(hour, @ThisRun) = 20
		  begin
			 Print 'Starting adm_MemReset: ' + convert(varchar(50), getdate(), 101) + ' ' + convert(varchar(50), getdate(), 108)
			 Execute @ReturnResults = Admin.dbo.adm_MemReset
			 IF @ReturnResults <> 0 Print 'IHADANERROR: adm_MemReset'
			 SET @ReturnResults = 0
			 Print 'Finished adm_MemReset: ' + convert(varchar(50), getdate(), 101) + ' ' + convert(varchar(50), getdate(), 108)
		  end
	   else
		  begin
			 Print 'Skipping adm_MemReset: ' + convert(varchar(50), getdate(), 101) + ' ' + convert(varchar(50), getdate(), 108)
		  end
	   Print '----'

	   --Print '----'
	   --Print 'Start adm_JenK: ' + convert(varchar(50), getdate(), 101) + ' ' + convert(varchar(50), getdate(), 108)
	   --EXECUTE @ReturnResults = adm_JenK
	   --IF @ReturnResults <> 0 Print 'IHADANERROR: adm_JenK'
	   --SET @ReturnResults = 0
	   --Print 'Finished adm_JenK: ' + convert(varchar(50), getdate(), 101) + ' ' + convert(varchar(50), getdate(), 108)
	   --Print '----'

	   Print '----'
	   PRINT 'Start check for missing 401k benefit'
	   Execute  @ReturnResults = as_Missing401kBenefit
	   IF @ReturnResults <> 0 Print 'IHADANERROR: as_Missing401kBenefit'
	   SET @ReturnResults = 0
	   PRINT 'Finished check for missing 401k benefit'
	   Print '----'

	   Print '----'
	   PRINT 'Starting SQL Server Memory Setting Validation: ' + convert(varchar(50), getdate(), 101) + ' ' + convert(varchar(50), getdate(), 108)
	   Execute @ReturnResults = adm_memoryset
	   IF @ReturnResults <> 0 Print 'IHADANERROR: adm_memoryset'
	   SET @ReturnResults = 0
	   Print 'Finished SQL Server Memory Setting Validation: ' + convert(varchar(50), getdate(), 101) + ' ' + convert(varchar(50), getdate(), 108)
	   Print '----'

	   Print '----'
	   PRINT 'Start CreateError'
	   Execute @ReturnResults = CreateError
	   IF @ReturnResults <> 0 Print 'IHADANERROR: Create Error Generated an error'
	   SET @ReturnResults = 0
	   PRINT 'Finished CreateError'
	   Print '----'
	   

	   Print 'adm_HealthCheck Finished: ' + convert(varchar(50), GETDATE(), 101) + ' ' + convert(varchar(50), getdate(), 108)
	   Print 'Total Duration: ' + convert(varchar(2000), datediff(second, @ThisRun, getdate())) + ' seconds.'
	   PRINT '******************************************************************************'
     END;
go

grant execute on adm_HealthCheck to public
go