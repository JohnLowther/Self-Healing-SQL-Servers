

USE GPTECH2019
GO

drop procedure if exists SomeName
GO

CREATE PROCEDURE SomeName AS
    BEGIN
	   PRINT 'This is where you insert your code'
    END
GO 


GRANT EXECUTE ON SomeName to public as dbo
GO


