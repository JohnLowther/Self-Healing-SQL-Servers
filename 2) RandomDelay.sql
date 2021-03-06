
USE GPTECH2019
GO

if OBJECT_ID('RandomDelay') <> 0 drop procedure RandomDelay
GO

CREATE PROCEDURE RandomDelay(@MinValue int = 0, @MaxValue int = 30) as
    BEGIN
	   --This is a random delay in minutes
	   declare @RandomInteger int
	   declare @Delay varchar(15)

	   select @RandomInteger = ((@MaxValue + 1) - @MinValue) * Rand() + @MinValue
	   Set @Delay = convert(varchar(2), @RandomInteger) 
	   if len(@Delay) = 1 set @Delay = '0' + @Delay

	   set @Delay = '00:' + @Delay + ':00.000'
	   --set @delay = '00:00:' + @delay + '.000' -- I could use something like this for seconds
			 
	   WAITFOR DELAY @Delay
    END
GO

GRANT EXECUTE ON RandomDelay to public
GO