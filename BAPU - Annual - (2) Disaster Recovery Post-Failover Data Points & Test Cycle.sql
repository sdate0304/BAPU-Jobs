USE [msdb]
GO

/****** Object:  Job [BAPU - Annual - (2) Disaster Recovery Post-Failover Data Points & Test Cycle]    Script Date: 03/17/2021 4:02:18 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 03/17/2021 4:02:19 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BAPU - Annual - (2) Disaster Recovery Post-Failover Data Points & Test Cycle', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job is used to take balancing data point copies the after the DR event and failover, run a test cycle, then take balancing data point copies after the test cycle.

Job is maintained by the Data Services team at BTS (PrimaryITData@wrberkley.com).', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'WRBTS\SVC-BAP-P-DW', 
		@notify_email_operator_name=N'BAPU DW Notifications', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Log Disaster Recovery Data Points - 'Day of DR Test After Failover to DR Server']    Script Date: 03/17/2021 4:02:19 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Log Disaster Recovery Data Points - ''Day of DR Test After Failover to DR Server''', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_Logging.DR.p_Log_Data_Points ''Day of DR Test After Failover to DR Server'';
EXEC BAPU_Logging.DR.p_Security_Audit  ''Day of DR Test After Failover to DR Server'';', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Export 'Day of DR Test After Failover to DR Server' Data Points]    Script Date: 03/17/2021 4:02:20 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Export ''Day of DR Test After Failover to DR Server'' Data Points', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\BAP DR Testing\Export DR Data Points File.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 2 /Par "\"$Project::FileSuffix\"";"\"Day of DR Test After Failover to DR Server\"" /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run 'BAPU - Annual - (0) Disaster Recovery Cycle Test' SQL Agent Job]    Script Date: 03/17/2021 4:02:20 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run ''BAPU - Annual - (0) Disaster Recovery Cycle Test'' SQL Agent Job', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_start_job N''BAPU - Annual - (0) Disaster Recovery Cycle Test'';', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wait for 'BAPU - Annual - (0) Disaster Recovery Cycle Test' SQL Job to Complete]    Script Date: 03/17/2021 4:02:20 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wait for ''BAPU - Annual - (0) Disaster Recovery Cycle Test'' SQL Job to Complete', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @JobStatus INT;
EXEC  dbo.p_SQL_Server_Job_Monitor  ''BAPU - Annual - (0) Disaster Recovery Cycle Test'', ''00:00:05'', @JobStatus OUTPUT;
SELECT @JobStatus;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Log Disaster Recovery Data Points - 'Day of DR Test After Failover to DR Server & Cycle Test']    Script Date: 03/17/2021 4:02:20 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Log Disaster Recovery Data Points - ''Day of DR Test After Failover to DR Server & Cycle Test''', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_Logging.DR.p_Log_Data_Points ''Day of DR Test After Failover to DR Server & Cycle Test'';
EXEC BAPU_Logging.DR.p_Security_Audit  ''Day of DR Test After Failover to DR Server & Cycle Test'';', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Export 'Day of DR Test After Failover to DR Server & Cycle Test' Data Points]    Script Date: 03/17/2021 4:02:20 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Export ''Day of DR Test After Failover to DR Server & Cycle Test'' Data Points', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\BAP DR Testing\Export DR Data Points File.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 2 /Par "\"$Project::FileSuffix\"";"\"Day of DR Test After Failover to DR Server & Cycle Test\"" /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
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


