

USE GPTECH2019
GO

drop procedure if exists CreateError
GO

CREATE PROCEDURE CreateError AS
    BEGIN
	   DECLARE @Results int = 0
	   Set @results = 25 / 1

	   --RAISERROR ('Just because I Want to', 16, 1); 

	   /*
	   Whenever I want to let the Master Stored procedure do something specific
	    depending on something I find in the sub stored procedures
	    I prefer to return a value other then zero
	    by using SQL's built in Return abiity
	    I usually reutn a number greater than 50000 to get above the range 
	    of SQL's own set of return codes when there is a actual problem with 
	    the Sub stored procedure.
	    Example:
	    RETURN 50000
	    you could send back different numbers based on what you want to know 
	    based on some sort of flow logic like a set of "IF" statements as 
	    shown below.
	    */  


	   --if 1=0
		  -- RETURN 50000
	   --if 1=1
		  -- RETURN 50001
	  -- if 1=2
		  -- RETURN 50002

    END
GO 


GRANT EXECUTE ON CreateError to public as dbo
GO


