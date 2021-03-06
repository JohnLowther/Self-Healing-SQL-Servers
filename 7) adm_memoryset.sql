

USE GPTECH2019
GO

drop procedure if exists adm_memoryset
GO

CREATE PROCEDURE adm_memoryset AS
    BEGIN
	   EXEC sp_configure 'show advanced options', 1; RECONFIGURE;

	   EXEC sys.sp_configure N'max server memory (MB)', N'5120'
	   RECONFIGURE WITH OVERRIDE
	  
	   EXEC sp_configure 'show advanced options', 0; RECONFIGURE;
    END

GO 
GRANT EXECUTE ON adm_memoryset to public as dbo
GO


-- EXEC adm_memoryset

