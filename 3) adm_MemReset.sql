
USE GPTECH2019
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE Name = 'adm_MemReset') DROP PROCEDURE adm_MemReset
GO


CREATE PROCEDURE adm_MemReset (@MinMem AS INT = 3072, @DefaultMem AS INT = 4096) AS
     BEGIN
			DECLARE @MaxMemSetting INT;
			DECLARE @ActualMem INT;
			DECLARE @MinMemSetting INT;

			SET NOCOUNT ON;

			PRINT '@MinMem = 3072'
			Print '@DefaultMem = 4096'

			--Get Actual memory setting from SQL 
			SET @MaxMemSetting = CONVERT(INT, (SELECT value_in_use FROM sys.configurations WHERE name = 'max server memory (MB)'))
			PRINT 'Max Memory is ' + CAST(@MaxMemSetting AS VARCHAR)

			SET @MinMemSetting = CONVERT(INT, (SELECT value_in_use FROM sys.configurations WHERE name = 'min server memory (MB)'))
			PRINT 'Min Memory is ' + CAST(@MinMemSetting AS VARCHAR)

			IF @MinMemSetting > @MinMem -- a default of 0 will return at least 16
				Begin
					SET @MinMem = @MinMemSetting
					Print '@MinMemSetting is greater than @MinMem'
					Print 'Resetting @MinMem to @MinMemSetting'
				End
			Else
				Begin
					Print '@MinMemSetting is NOT greater than @MinMem'
				End

			If @MinMem < @MaxMemSetting / 2.0
				Begin
					SET @MinMem = @MaxMemSetting / 2.0
					Print '@MinMem is less than @MaxMemSetting / 2.0'
					Print 'Resetting @MinMem to @MaxMemSetting / 2.0'
				End
			Else
				Begin
					Print '@MinMem is NOT less than @MaxMemSetting / 2.0'
				End  

			-- Write the Setting to a table and create the table if it does not already exists
			-- If there is a table then delete all records before writing this to that table.
			IF OBJECT_ID('GPTECH2019.dbo.MemorySettings') <> 0 drop table GPTECH2019.dbo.MemorySettings; -- This will remove any records that were in the table and prepare for the create table statement
			CREATE TABLE GPTECH2019.dbo.MemorySettings(MemorySetting varchar(50), SettingValue int)
			INSERT INTO GPTECH2019.dbo.MemorySettings (MemorySetting, SettingValue) Values ('Max Memory', @MaxMemSetting)
			INSERT INTO GPTECH2019.dbo.MemorySettings (MemorySetting, SettingValue) Values ('Min Memory', @MinMemSetting)


			BEGIN TRY		
				--If Max Memory is set below our minimum, set to our minimum. 
				IF @MaxMemSetting < @DefaultMem
					BEGIN
						Print 'Memory below our minimum. Setting memory to our minimum'
						SET @MaxMemSetting = @DefaultMem
						EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
						EXEC sp_configure 'max server memory', @MaxMemSetting; RECONFIGURE;
					END

				--Memory is set to 2TB
				If @MaxMemSetting = 2147483647
					BEGIN
						PRINT 'Memory set to 2TB--This is not good';
						EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
						EXEC sp_configure 'max server memory', @DefaultMem; RECONFIGURE;
					END;

				--Get Actual memory in use from SQL 
				SET @ActualMem = (SELECT(physical_memory_in_use_kb / 1024) FROM sys.dm_os_process_memory);

				PRINT 'Actual Memory is ' + CAST(@ActualMem AS VARCHAR);

				IF @ActualMem > (@MaxMemSetting * .75)
					BEGIN
						PRINT '@ActualMem is greater than @MaxMemSetting * .75'
						Print 'Setting Advanced Options'
						EXEC sp_configure 'show advanced options', 1
						Print 'Advanced Options Reconfigure' 
						RECONFIGURE
						Print 'Setting Memory to Minimum'
						EXEC sp_configure 'max server memory', @MinMem
						Print 'Minimum Memory Reconfigure'
						RECONFIGURE
                 
						PRINT 'Dropping Memory'

                		     WHILE(@ActualMem) > (@MinMem + 512)
						  begin
							 SET @ActualMem = (SELECT(physical_memory_in_use_kb / 1024) FROM sys.dm_os_process_memory);
						  end

						PRINT 'Memory Dropped'

						PRINT 'Setting Memory to '+ CAST(@MaxMemSetting AS VARCHAR)
						EXEC sp_configure 'show advanced options', 1; RECONFIGURE
						EXEC sp_configure 'max server memory', @MaxMemSetting; RECONFIGURE
					END
				ELSE
					BEGIN
						PRINT '@ActualMem is NOT greater than @MaxMemSetting * .75' 
					END
			END TRY
			BEGIN CATCH
				PRINT 'ENTERED CATCH SECTION!'
				EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
				EXEC sp_configure 'max server memory', @MaxMemSetting; RECONFIGURE;
			END CATCH
     END;

GO

GRANT EXECUTE ON adm_MemReset TO public as dbo
GO