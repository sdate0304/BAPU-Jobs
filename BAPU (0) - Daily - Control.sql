USE [msdb]
GO

/****** Object:  Job [BAPU (0) - Daily - Control]    Script Date: 03/17/2021 4:04:48 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 03/17/2021 4:04:48 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BAPU (0) - Daily - Control', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'BAPU''s daily control job which determines how the daily cycles load.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'WRBTS\SVC-BAP-P-DW', 
		@notify_email_operator_name=N'BAPU DW Notifications', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run 'BAPU (1) - Daily - Load Source Data' SQL Job]    Script Date: 03/17/2021 4:04:49 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run ''BAPU (1) - Daily - Load Source Data'' SQL Job', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_start_job N''BAPU (1) - Daily - Load Source Data'';', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wait for 'BAPU (1) - Daily - Load Source Data' SQL Job to Complete]    Script Date: 03/17/2021 4:04:49 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wait for ''BAPU (1) - Daily - Load Source Data'' SQL Job to Complete', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @JobStatus INT;
EXEC  dbo.p_SQL_Server_Job_Monitor  ''BAPU (1) - Daily - Load Source Data'', ''00:00:05'', @JobStatus OUTPUT;
SELECT @JobStatus;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run 'BAPU (2) - Daily - Pre-Core Processing' SQL Job]    Script Date: 03/17/2021 4:04:50 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run ''BAPU (2) - Daily - Pre-Core Processing'' SQL Job', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_start_job N''BAPU (2) - Daily - Pre-Core Processing'';', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wait for 'BAPU (2) - Daily - Pre-Core Processing' SQL Job to Complete]    Script Date: 03/17/2021 4:04:50 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wait for ''BAPU (2) - Daily - Pre-Core Processing'' SQL Job to Complete', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @JobStatus INT;
EXEC  dbo.p_SQL_Server_Job_Monitor  ''BAPU (2) - Daily - Pre-Core Processing'', ''00:00:05'', @JobStatus OUTPUT;
SELECT @JobStatus;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run 'BAPU (3) - Daily - Core Policy Processing' SQL Job]    Script Date: 03/17/2021 4:04:50 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run ''BAPU (3) - Daily - Core Policy Processing'' SQL Job', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_start_job N''BAPU (3) - Daily - Core Policy Processing'';', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wait for 'BAPU (3) - Daily - Core Policy Processing' SQL Job to Complete]    Script Date: 03/17/2021 4:04:50 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wait for ''BAPU (3) - Daily - Core Policy Processing'' SQL Job to Complete', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=9, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @JobStatus INT;
EXEC  dbo.p_SQL_Server_Job_Monitor  ''BAPU (3) - Daily - Core Policy Processing'', ''00:00:05'', @JobStatus OUTPUT;
SELECT @JobStatus;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [(Temp) Run 'BAPU (9) - Ad Hoc - Non-Active Source Core Builds' SQL Job]    Script Date: 03/17/2021 4:04:50 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'(Temp) Run ''BAPU (9) - Ad Hoc - Non-Active Source Core Builds'' SQL Job', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_start_job N''BAPU (9) - Ad Hoc - Non-Active Source Core Builds'';', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [(Temp) Wait for 'BAPU (9) - Ad Hoc - Non-Active Source Core Builds' SQL Job to Complete]    Script Date: 03/17/2021 4:04:50 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'(Temp) Wait for ''BAPU (9) - Ad Hoc - Non-Active Source Core Builds'' SQL Job to Complete', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @JobStatus INT;
EXEC  dbo.p_SQL_Server_Job_Monitor  ''BAPU (9) - Ad Hoc - Non-Active Source Core Builds'', ''00:00:05'', @JobStatus OUTPUT;
SELECT @JobStatus;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run 'BAPU (4) - Daily - Core Claim Processing' SQL Job]    Script Date: 03/17/2021 4:04:50 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run ''BAPU (4) - Daily - Core Claim Processing'' SQL Job', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_start_job N''BAPU (4) - Daily - Core Claim Processing'';', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wait for 'BAPU (4) - Daily - Core Claim Processing' SQL Job to Complete]    Script Date: 03/17/2021 4:04:51 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wait for ''BAPU (4) - Daily - Core Claim Processing'' SQL Job to Complete', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @JobStatus INT;
EXEC  dbo.p_SQL_Server_Job_Monitor  ''BAPU (4) - Daily - Core Claim Processing'', ''00:00:05'', @JobStatus OUTPUT;
SELECT @JobStatus;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run 'BAPU (5) - Daily - Post-Core Processing' SQL Job]    Script Date: 03/17/2021 4:04:51 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run ''BAPU (5) - Daily - Post-Core Processing'' SQL Job', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_start_job N''BAPU (5) - Daily - Post-Core Processing'';', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wait for 'BAPU (5) - Daily - Post-Core Processing' SQL Job to Complete]    Script Date: 03/17/2021 4:04:51 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wait for ''BAPU (5) - Daily - Post-Core Processing'' SQL Job to Complete', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @JobStatus INT;
EXEC  dbo.p_SQL_Server_Job_Monitor  ''BAPU (5) - Daily - Post-Core Processing'', ''00:00:05'', @JobStatus OUTPUT;
SELECT @JobStatus;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run 'BAPU (6) - Daily - Cube Processing' SQL Job]    Script Date: 03/17/2021 4:04:51 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run ''BAPU (6) - Daily - Cube Processing'' SQL Job', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_start_job N''BAPU (6) - Daily - Cube Processing'';
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wait for 'BAPU (6) - Daily - Cube Processing' SQL Job to Complete]    Script Date: 03/17/2021 4:04:51 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wait for ''BAPU (6) - Daily - Cube Processing'' SQL Job to Complete', 
		@step_id=14, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @JobStatus INT;
EXEC  dbo.p_SQL_Server_Job_Monitor  ''BAPU (6) - Daily - Cube Processing'', ''00:00:05'', @JobStatus OUTPUT;
SELECT @JobStatus;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run 'BAPU (7) - Daily - Balancing' SQL Job]    Script Date: 03/17/2021 4:04:51 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run ''BAPU (7) - Daily - Balancing'' SQL Job', 
		@step_id=15, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_start_job N''BAPU (7) - Daily - Balancing'';', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wait for 'BAPU (7) - Daily - Balancing' SQL Job to Complete]    Script Date: 03/17/2021 4:04:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wait for ''BAPU (7) - Daily - Balancing'' SQL Job to Complete', 
		@step_id=16, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @JobStatus INT;
EXEC  dbo.p_SQL_Server_Job_Monitor  ''BAPU (7) - Daily - Balancing'', ''00:00:05'', @JobStatus OUTPUT;
SELECT @JobStatus;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Log Disaster Recovery Data Points]    Script Date: 03/17/2021 4:04:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Log Disaster Recovery Data Points', 
		@step_id=17, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_Logging.DR.p_Log_Data_Points ''After regular daily processing'';

EXEC BAPU_Logging.DR.p_Security_Audit ''After regular daily processing'';', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run 'BAPU - Monthly - FRS Data Pull' SQL Job (On 1st Of Month)]    Script Date: 03/17/2021 4:04:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run ''BAPU - Monthly - FRS Data Pull'' SQL Job (On 1st Of Month)', 
		@step_id=18, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @DoW SMALLINT = 0;

SELECT  @DoW = DATEPART(DAY, GETDATE());

IF @DoW = 1
    BEGIN
        EXEC msdb.dbo.sp_start_job N''BAPU - Monthly - FRS Data Pull'';
    END;', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run 'BAPU (8) - Daily - Cycle Complete' SQL Job]    Script Date: 03/17/2021 4:04:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run ''BAPU (8) - Daily - Cycle Complete'' SQL Job', 
		@step_id=19, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_start_job N''BAPU (8) - Daily - Cycle Complete'';', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily 2:05 AM ET', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170612, 
		@active_end_date=99991231, 
		@active_start_time=20500, 
		@active_end_time=235959, 
		@schedule_uid=N'790c24b0-3f9d-4814-9f84-52d134f4ae46'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


