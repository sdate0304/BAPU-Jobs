USE [msdb]
GO

/****** Object:  Job [BAPU (7) - Daily - Balancing]    Script Date: 03/17/2021 4:07:39 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 03/17/2021 4:07:40 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BAPU (7) - Daily - Balancing', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job performs balancing for policy and claim data. This job is called by the "BAPU (0) Daily Control" SQL Server Agent Job.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'WRBTS\SVC-BAP-P-DW', 
		@notify_email_operator_name=N'BAPU DW Notifications', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start BAPU Post-Load Balancing (Batch_Type_Key = 23)]    Script Date: 03/17/2021 4:07:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start BAPU Post-Load Balancing (Batch_Type_Key = 23)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @batch_action VARCHAR(50) = ''Start In Sequence'';
DECLARE @batch_type_key INT = 23; /* "BAPU Post-Load Balancing" */
DECLARE @batch_status_out VARCHAR(10);
DECLARE @batch_log_key_out INT;
EXEC BAPU_Logging.Batch.p_Batch_Log
     @batch_action
    ,@batch_type_key
    ,@batch_status_out OUTPUT
    ,@batch_log_key_out OUTPUT;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[     Run p_DataQuality for 'Policy Source to Staging' & Start Process_Key 6000]    Script Date: 03/17/2021 4:07:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[     Run p_DataQuality for ''Policy Source to Staging'' & Start Process_Key 6000', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=4, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Start Process Log
EXEC Batch.p_Process_Log
		6000, 
		''Start'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;

EXEC dbo.p_DataQuality ''Policy Source to Staging'';', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Complete Process_Key 6000]    Script Date: 03/17/2021 4:07:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Complete Process_Key 6000', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=5, 
		@on_fail_action=4, 
		@on_fail_step_id=5, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Complete Process Log
EXEC Batch.p_Process_Log
		6000, 
		''Complete'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Fail Process_Key 6000]    Script Date: 03/17/2021 4:07:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Fail Process_Key 6000', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Fail Process Log
EXEC Batch.p_Process_Log
		6000, 
		''Failure'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[     Run p_RunAllBalancingChecks for 'Policy Source to Staging' & Start Process_Key 6006]    Script Date: 03/17/2021 4:07:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[     Run p_RunAllBalancingChecks for ''Policy Source to Staging'' & Start Process_Key 6006', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=7, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Start Process Log
EXEC Batch.p_Process_Log
		6006, 
		''Start'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;

EXEC dbo.p_RunAllBalancingChecks ''Policy Source to Staging'', ''N'';', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[         Complete Process_Key 6006]    Script Date: 03/17/2021 4:07:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[         Complete Process_Key 6006', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=8, 
		@on_fail_action=4, 
		@on_fail_step_id=8, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Complete Process Log
EXEC Batch.p_Process_Log
		6006, 
		''Complete'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[         Fail Process_Key 6006]    Script Date: 03/17/2021 4:07:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[         Fail Process_Key 6006', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Fail Process Log
EXEC Batch.p_Process_Log
		6006, 
		''Failure'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[     Run p_DataQuality for 'Claim Source to Staging' & Start Process_Key 6001]    Script Date: 03/17/2021 4:07:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[     Run p_DataQuality for ''Claim Source to Staging'' & Start Process_Key 6001', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=10, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Start Process Log
EXEC Batch.p_Process_Log
		6001, 
		''Start'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;

EXEC dbo.p_DataQuality ''Claim Source to Staging'';', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Complete Process_Key 6001 (DataQuality Claim Source to Staging)]    Script Date: 03/17/2021 4:07:42 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Complete Process_Key 6001 (DataQuality Claim Source to Staging)', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=11, 
		@on_fail_action=4, 
		@on_fail_step_id=11, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Complete Process Log
EXEC Batch.p_Process_Log
		6001, 
		''Complete'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Fail Process_Key 6001 (DataQuality for Claim Source to Staging)]    Script Date: 03/17/2021 4:07:42 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Fail Process_Key 6001 (DataQuality for Claim Source to Staging)', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Fail Process Log
EXEC Batch.p_Process_Log
		6001, 
		''Failure'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;

-- Batch Failure is handled when the process fails', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[     Run p_RunAllBalancingChecks for 'Claim Source to Staging' & Start Process_Key 6007]    Script Date: 03/17/2021 4:07:42 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[     Run p_RunAllBalancingChecks for ''Claim Source to Staging'' & Start Process_Key 6007', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=13, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Start Process Log
EXEC Batch.p_Process_Log
		6007, 
		''Start'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;

EXEC dbo.p_RunAllBalancingChecks ''Claim Source to Staging'', ''N'';', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Complete Process_Key 6007 (RunAllBalancingChecks for Claim Source to Staging)]    Script Date: 03/17/2021 4:07:42 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Complete Process_Key 6007 (RunAllBalancingChecks for Claim Source to Staging)', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=14, 
		@on_fail_action=4, 
		@on_fail_step_id=14, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Complete Process Log
EXEC Batch.p_Process_Log
		6007, 
		''Complete'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Fail Process_Key 6007 (RunAllBalancingChecks for Claim Source to Staging)]    Script Date: 03/17/2021 4:07:42 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Fail Process_Key 6007 (RunAllBalancingChecks for Claim Source to Staging)', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Fail Process Log
EXEC Batch.p_Process_Log
		6007, 
		''Failure'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;

-- Batch Failure is handled when the process fails', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[     Run p_DataQuality for 'Policy Staging to Core' & Start Process_Key 6002]    Script Date: 03/17/2021 4:07:42 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[     Run p_DataQuality for ''Policy Staging to Core'' & Start Process_Key 6002', 
		@step_id=14, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=16, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Start Process Log
EXEC Batch.p_Process_Log
		6002, 
		''Start'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;

EXEC dbo.p_DataQuality ''Policy Staging to Core'';
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Complete Process_Key 6002]    Script Date: 03/17/2021 4:07:43 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Complete Process_Key 6002', 
		@step_id=15, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=17, 
		@on_fail_action=4, 
		@on_fail_step_id=17, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Complete Process Log
EXEC Batch.p_Process_Log
		6002, 
		''Complete'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Fail Process_Key 6002]    Script Date: 03/17/2021 4:07:43 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Fail Process_Key 6002', 
		@step_id=16, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Fail Process Log
EXEC Batch.p_Process_Log
		6002, 
		''Failure'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[     Run p_RunAllBalancingChecks for 'Policy Staging to Core' & Start Process_Key 6008]    Script Date: 03/17/2021 4:07:43 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[     Run p_RunAllBalancingChecks for ''Policy Staging to Core'' & Start Process_Key 6008', 
		@step_id=17, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=19, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Start Process Log
EXEC Batch.p_Process_Log
		6008, 
		''Start'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;

EXEC dbo.p_RunAllBalancingChecks ''Policy Staging to Core'', ''N'';
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Complete Process_Key 6008]    Script Date: 03/17/2021 4:07:43 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Complete Process_Key 6008', 
		@step_id=18, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=20, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Complete Process Log
EXEC Batch.p_Process_Log
		6008, 
		''Complete'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Fail Process_Key 6008]    Script Date: 03/17/2021 4:07:43 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Fail Process_Key 6008', 
		@step_id=19, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Fail Process Log
EXEC Batch.p_Process_Log
		6008, 
		''Failure'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[     Run p_DataQuality for 'Claim Staging to Core' & Start Process_Key 6003]    Script Date: 03/17/2021 4:07:44 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[     Run p_DataQuality for ''Claim Staging to Core'' & Start Process_Key 6003', 
		@step_id=20, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=22, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Start Process Log
EXEC Batch.p_Process_Log
		6003, 
		''Start'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;

EXEC dbo.p_DataQuality ''Claim Staging to Core'';
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Complete Process_Key 6003]    Script Date: 03/17/2021 4:07:44 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Complete Process_Key 6003', 
		@step_id=21, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=23, 
		@on_fail_action=4, 
		@on_fail_step_id=23, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Complete Process Log
EXEC Batch.p_Process_Log
		6003, 
		''Complete'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Fail Process_Key 6003]    Script Date: 03/17/2021 4:07:44 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Fail Process_Key 6003', 
		@step_id=22, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Fail Process Log
EXEC Batch.p_Process_Log
		6003, 
		''Failure'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[     Run p_RunAllBalancingChecks for 'Claim Staging to Core' & Start Process_Key 6009]    Script Date: 03/17/2021 4:07:44 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[     Run p_RunAllBalancingChecks for ''Claim Staging to Core'' & Start Process_Key 6009', 
		@step_id=23, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=25, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Start Process Log
EXEC Batch.p_Process_Log
		6009, 
		''Start'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;

EXEC dbo.p_RunAllBalancingChecks ''Claim Staging to Core'', ''N'';
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Complete Process_Key 6009]    Script Date: 03/17/2021 4:07:44 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Complete Process_Key 6009', 
		@step_id=24, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=26, 
		@on_fail_action=4, 
		@on_fail_step_id=26, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Complete Process Log
EXEC Batch.p_Process_Log
		6009, 
		''Complete'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Fail Process_Key 6009]    Script Date: 03/17/2021 4:07:44 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Fail Process_Key 6009', 
		@step_id=25, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Fail Process Log
EXEC Batch.p_Process_Log
		6009, 
		''Failure'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[     Run p_RunAllBalancingChecks for 'CORE Data Check' & Start Process_Key 6010]    Script Date: 03/17/2021 4:07:44 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[     Run p_RunAllBalancingChecks for ''CORE Data Check'' & Start Process_Key 6010', 
		@step_id=26, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Start Process Log
EXEC Batch.p_Process_Log
		6010, 
		''Start'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;

EXEC dbo.p_RunAllBalancingChecks ''CORE Data Check'', ''N'';
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Complete Process_Key 6010]    Script Date: 03/17/2021 4:07:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Complete Process_Key 6010', 
		@step_id=27, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=29, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Complete Process Log
EXEC Batch.p_Process_Log
		6010, 
		''Complete'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Fail Process_Key 6010]    Script Date: 03/17/2021 4:07:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Fail Process_Key 6010', 
		@step_id=28, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Fail Process Log
EXEC Batch.p_Process_Log
		6010, 
		''Failure'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[     Run p_RunAllBalancingChecks for 'Workflow Source to Staging' & Start Process_Key 6004]    Script Date: 03/17/2021 4:07:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[     Run p_RunAllBalancingChecks for ''Workflow Source to Staging'' & Start Process_Key 6004', 
		@step_id=29, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=31, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Start Process Log
EXEC Batch.p_Process_Log
		6004, 
		''Start'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;

EXEC dbo.p_RunAllBalancingChecks ''Workflow Source to Staging'', ''N'';
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Complete Process_Key 6004]    Script Date: 03/17/2021 4:07:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Complete Process_Key 6004', 
		@step_id=30, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=32, 
		@on_fail_action=4, 
		@on_fail_step_id=32, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Complete Process Log
EXEC Batch.p_Process_Log
		6004, 
		''Complete'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Fail Process_Key 6004]    Script Date: 03/17/2021 4:07:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Fail Process_Key 6004', 
		@step_id=31, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Fail Process Log
EXEC Batch.p_Process_Log
		6004, 
		''Failure'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;
', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[     Run p_RunAllBalancingChecks for 'Billing Source to Staging' & Start Process_Key 6005]    Script Date: 03/17/2021 4:07:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[     Run p_RunAllBalancingChecks for ''Billing Source to Staging'' & Start Process_Key 6005', 
		@step_id=32, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=34, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Start Process Log
EXEC Batch.p_Process_Log
		6005, 
		''Start'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;

EXEC dbo.p_RunAllBalancingChecks ''Billing Source to Staging'', ''N'';', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Complete Process_Key 6005]    Script Date: 03/17/2021 4:07:46 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Complete Process_Key 6005', 
		@step_id=33, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=35, 
		@on_fail_action=4, 
		@on_fail_step_id=35, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Complete Process Log
EXEC Batch.p_Process_Log
		6005, 
		''Complete'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Fail Process_Key 6005]    Script Date: 03/17/2021 4:07:46 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Fail Process_Key 6005', 
		@step_id=34, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Fail Process Log
EXEC Batch.p_Process_Log
		6005, 
		''Failure'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[     Clear Historical Balancing Records]    Script Date: 03/17/2021 4:07:46 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[     Clear Historical Balancing Records', 
		@step_id=35, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_BalancingDataCleanUp ''60'';', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[     Run p_RunAllBalancingChecks for 'DWH System Check' & Start Process_Key 6012]    Script Date: 03/17/2021 4:07:46 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[     Run p_RunAllBalancingChecks for ''DWH System Check'' & Start Process_Key 6012', 
		@step_id=36, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=38, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Start Process Log
DECLARE @process_log_key_out INT;

EXEC Batch.p_Process_Log
		6012, 
		''Start'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;

EXEC dbo.p_RunAllBalancingChecks ''DWH System Check'', ''N'';', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Complete Process_Key 6012]    Script Date: 03/17/2021 4:07:46 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Complete Process_Key 6012', 
		@step_id=37, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=39, 
		@on_fail_action=4, 
		@on_fail_step_id=39, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Complete Process Log
EXEC Batch.p_Process_Log
		6012, 
		''Complete'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[          Fail but Continue Process_Key 6012]    Script Date: 03/17/2021 4:07:46 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[          Fail but Continue Process_Key 6012', 
		@step_id=38, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Fail Process Log
EXEC Batch.p_Process_Log
		6012, 
		''Fail But Continue'', 
		NULL,
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Complete BAPU Post-Load Balancing (Batch_Type_Key = 23)]    Script Date: 03/17/2021 4:07:47 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Complete BAPU Post-Load Balancing (Batch_Type_Key = 23)', 
		@step_id=39, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @batch_action VARCHAR(50);
DECLARE @batch_type_key INT = 23; /* "Bapu Balancing" */
DECLARE @batch_status_out VARCHAR(10);
DECLARE @batch_log_key_out INT;

-- Retrieve Batch Details if batch is running
EXEC BAPU_Logging.Batch.p_Batch_Log
      @batch_action
     ,@batch_type_key
     ,@batch_status_out OUTPUT
     ,@batch_log_key_out OUTPUT;

-- If there is a batch running then complete it (by having this in here if a batch has been started/completed manually 
-- then this step in the SQL server agent job will not fail by trying to ''complete'' a batch that is not running''
IF @batch_status_out = ''Running''
      BEGIN
            SET @batch_action = ''Complete''

            EXEC BAPU_Logging.Batch.p_Batch_Log
                  @batch_action
                 ,@batch_type_key
                 ,@batch_status_out OUTPUT
                 ,@batch_log_key_out OUTPUT;

      END;', 
		@database_name=N'BAPU_Logging', 
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


