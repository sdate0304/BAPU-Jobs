USE [msdb]
GO

/****** Object:  Job [Restore BAPU_PolicyAdministration_WarehouseCopy_From_BapuBUSSqlProd]    Script Date: 05/08/2021 2:25:36 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 05/08/2021 2:25:37 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Restore BAPU_PolicyAdministration_WarehouseCopy_From_BapuBUSSqlProd', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job is called by the "BAPU (1) Load Source Data" job, it does not run off it''s own schedule. This job will copy the BUS Production back up database to this server, restore the database, change compatibility to be SQL 2016, and add users back to the database.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'BAPU DW Notifications', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 1: Kill User Connections]    Script Date: 05/08/2021 2:25:38 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 1: Kill User Connections', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF  EXISTS (SELECT name FROM sys.databases WHERE name = N''BAPU_PolicyAdministration'')
	ALTER DATABASE [BAPU_PolicyAdministration] SET SINGLE_USER WITH ROLLBACK IMMEDIATE', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 2: Drop Existing BAPU PolicyAdministration Database]    Script Date: 05/08/2021 2:25:39 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 2: Drop Existing BAPU PolicyAdministration Database', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF  EXISTS (SELECT name FROM sys.databases WHERE name = N''BAPU_PolicyAdministration'')
	drop database BAPU_PolicyAdministration', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 3: Delete Existing Backup File]    Script Date: 05/08/2021 2:25:39 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 3: Delete Existing Backup File', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec xp_cmdshell "del L:\BAPU_CopyDown\BAPU_PolicyAdmin_Backup\BAPU_PolicyAdmin_copy.bak"', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 4: Copy Backup File From BapuBUSSqlProd]    Script Date: 05/08/2021 2:25:39 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 4: Copy Backup File From BapuBUSSqlProd', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'copy "\\BapuBUSSqlProd\BUSBackups\BAPU_PolicyAdmin_copy.bak" "L:\BAPU_CopyDown\BAPU_PolicyAdmin_copy.bak" /Y', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 5: Restore BAPU PolicyAdministration Database]    Script Date: 05/08/2021 2:25:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 5: Restore BAPU PolicyAdministration Database', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'restore database BAPU_PolicyAdministration from disk = ''L:\BAPU_CopyDown\BAPU_PolicyAdmin_copy.bak''
with move ''BAPU_PolicyAdministration_Validation'' to ''D:\sqldata\BAPU_PolicyAdministration.mdf'',
move ''BAPU_PolicyAdministration_Validation_log'' to ''L:\sqldata\BAPU_PolicyAdministration_log.ldf'',
move ''ftfg_Organization.Address.FTCatalog_52D5A5E7'' to ''D:\sqldata\BAPU_Organization.Address.FTCatalog'',
move ''ftfg_Organization.ClientNamedInsured.FTCatalog_3933E293'' to ''D:\sqldata\BAPU_Organization.ClientNamedInsured.FTCatalog'',
move ''ftfg_Organization.DoingBusinessAs.FTCatalog_EC684D2'' to ''D:\sqldata\BAPU_Organization.DoingBusinessAs.FTCatalog'', replace', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 6: Set BAPU PolicyAdministration to Multi-User Access]    Script Date: 05/08/2021 2:25:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 6: Set BAPU PolicyAdministration to Multi-User Access', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'ALTER DATABASE [BAPU_PolicyAdministration] SET MULTI_USER WITH ROLLBACK IMMEDIATE', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 7: Set Recovery Model to Simple]    Script Date: 05/08/2021 2:25:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 7: Set Recovery Model to Simple', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'ALTER DATABASE [BAPU_PolicyAdministration] SET RECOVERY SIMPLE WITH ROLLBACK IMMEDIATE', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 8: Set Permissions]    Script Date: 05/08/2021 2:25:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 8: Set Permissions', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'ALTER ROLE db_owner ADD MEMBER [WRBTS\Primary IT Support Team];

ALTER ROLE db_datareader ADD MEMBER [WRBTS\Primary IT Support Team];

IF NOT EXISTS ( SELECT  *
                FROM    sys.database_principals AS s
                WHERE   s.name = ''WRBTS\svc-bap-d-dw'' )
    BEGIN
        CREATE USER [WRBTS\svc-bap-d-dw] FOR LOGIN [WRBTS\svc-bap-d-dw]
            WITH DEFAULT_SCHEMA = dbo;
    END;

ALTER ROLE db_datareader ADD MEMBER [WRBTS\svc-bap-d-dw];

IF NOT EXISTS ( SELECT  * FROM  sys.database_principals AS s WHERE  s.name = ''bapu_olap'' )
    BEGIN
        CREATE USER bapu_olap FOR LOGIN bapu_olap
            WITH DEFAULT_SCHEMA = dbo;
    END;

ALTER ROLE db_datareader ADD MEMBER bapu_olap;

IF NOT EXISTS ( SELECT  *
                FROM    sys.database_principals AS s
                WHERE   s.name = ''WRBTS\ACL-BAP-DW-Actuarial-R'' )
    BEGIN
        CREATE USER [WRBTS\ACL-BAP-DW-Actuarial-R] FOR LOGIN [WRBTS\ACL-BAP-DW-Actuarial-R]
            WITH DEFAULT_SCHEMA = dbo;
    END;

ALTER ROLE db_datareader ADD MEMBER [WRBTS\ACL-BAP-DW-Actuarial-R];

EXEC sys.sp_changedbowner ''sa'';', 
		@database_name=N'BAPU_PolicyAdministration', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 9: Update Statistics]    Script Date: 05/08/2021 2:25:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 9: Update Statistics', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/* Update stats to improve query performance */

EXECUTE dbo.sp_updatestats', 
		@database_name=N'BAPU_PolicyAdministration', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 10: Run Fix User's Script]    Script Date: 05/08/2021 2:25:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 10: Run Fix User''s Script', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON

DECLARE @loop INT
DECLARE @USER sysname
DECLARE @sqlcmd NVARCHAR(500) = ''''
 
IF OBJECT_ID(''tempdb..#Orphaned'') IS NOT NULL 
 BEGIN
  DROP TABLE #orphaned
 END
 
CREATE TABLE #Orphaned (UserName sysname,IDENT INT IDENTITY(1,1))
 INSERT INTO #Orphaned (UserName)
	SELECT [name]
	FROM sys.database_principals
	WHERE [type] IN (''U'', ''S'')
		AND is_fixed_role = 0
		AND [Name] NOT IN (''dbo'', ''guest'', ''sys'', ''INFORMATION_SCHEMA'')
		AND sid NOT IN (
			SELECT sid
			FROM master.sys.server_principals
			)
		AND NAME IN (
			SELECT NAME
			FROM master.sys.server_principals
			)
		AND type_desc != ''DATABASE_ROLE''
		

IF(SELECT COUNT(*) FROM #Orphaned) > 0
BEGIN
 SET @loop = 1
 WHILE @loop <= (SELECT MAX(IDENT) FROM #Orphaned)
  BEGIN
    SET @USER = (SELECT UserName FROM #Orphaned WHERE IDENT = @loop)
    SET @sqlcmd = ''ALTER USER ['' + @USER + ''] WITH LOGIN = ['' + @USER + '']''
    EXEC(@sqlcmd)
    PRINT @USER + '' link to DB user reset'';
    SET @loop = @loop + 1
  END
END
SET NOCOUNT OFF



----DECLARE @uname varchar(128)
----DECLARE @sqlcmd nvarchar(250)
----DECLARE cur1 CURSOR FOR  select name from sysusers where islogin=1 and hasdbaccess=1
 
----OPEN cur1
----FETCH NEXT FROM cur1 INTO @uname
 
----WHILE @@FETCH_STATUS = 0
----  BEGIN
----    SET @sqlcmd = N''exec sp_change_users_login ''''Update_One'''',''
----    SET @sqlcmd = @sqlcmd + N''''''''+@uname+'''''',''
----    SET @sqlcmd = @sqlcmd + N''''''''+@uname+''''''''
 
----    PRINT @sqlcmd
----    exec sp_executesql @statement=@sqlcmd
 
----    FETCH NEXT FROM cur1 INTO @uname
----  END', 
		@database_name=N'BAPU_PolicyAdministration', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


