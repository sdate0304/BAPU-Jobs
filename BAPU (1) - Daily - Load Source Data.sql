USE [msdb]
GO

/****** Object:  Job [BAPU (1) - Daily - Load Source Data]    Script Date: 8/17/2022 3:28:39 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 8/17/2022 3:28:39 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BAPU (1) - Daily - Load Source Data', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job loads source data for claims and policy systems. This job is called by the "BAPU (0) Daily Control" SQL Server Agent Job.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'WRBTS\SVC-BAP-P-DW', 
		@notify_email_operator_name=N'BAPU DW Notifications', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Create Folders for Excel Files]    Script Date: 8/17/2022 3:28:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create Folders for Excel Files', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\Daily File Work\Daily File Work.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 6 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0, 
		@proxy_name=N'BAPU_SVC_Proxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Clear Historical Balancing Records]    Script Date: 8/17/2022 3:28:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Clear Historical Balancing Records', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_BalancingDataCleanUp ''30'';', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Restore BUS Database Batch (Batch_Type_Key = 3) & Start Process_Key_300]    Script Date: 8/17/2022 3:28:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Restore BUS Database Batch (Batch_Type_Key = 3) & Start Process_Key_300', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @batch_action VARCHAR(50) = ''Start In Sequence'';
DECLARE @batch_type_key INT = 3;
DECLARE @batch_status_out VARCHAR(10);
DECLARE @batch_log_key_out INT;
EXEC Batch.p_Batch_Log
     @batch_action
    ,@batch_type_key
    ,@batch_status_out OUTPUT
    ,@batch_log_key_out OUTPUT;

DECLARE @process_log_key_out INT;

-- Start Process Log
EXEC Batch.p_Process_Log
		300, 
		''Start'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run 'Restore BAPU_PolicyAdministration_WarehouseCopy_From_BapuBUSSqlProd SQL Server Agent Job]    Script Date: 8/17/2022 3:28:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run ''Restore BAPU_PolicyAdministration_WarehouseCopy_From_BapuBUSSqlProd SQL Server Agent Job', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=7, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_start_job N''Restore BAPU_PolicyAdministration_WarehouseCopy_From_BapuBUSSqlProd'';', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wait for 'Restore BAPU_PolicyAdministration_WarehouseCopy_From_BapuBUSSqlProd' SQL Job to Complete]    Script Date: 8/17/2022 3:28:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wait for ''Restore BAPU_PolicyAdministration_WarehouseCopy_From_BapuBUSSqlProd'' SQL Job to Complete', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=7, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @JobStatus INT;
EXEC  dbo.p_SQL_Server_Job_Monitor  ''Restore BAPU_PolicyAdministration_WarehouseCopy_From_BapuBUSSqlProd'', ''00:00:05'', @JobStatus OUTPUT;
SELECT @JobStatus;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Complete Restore BUS Database Batch (Batch_Type_Key = 3) & Complete Process_Key 300]    Script Date: 8/17/2022 3:28:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Complete Restore BUS Database Batch (Batch_Type_Key = 3) & Complete Process_Key 300', 
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
		300, 
		''Complete'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;

DECLARE @batch_action VARCHAR(50);
DECLARE @batch_type_key INT = 3; 
DECLARE @batch_status_out VARCHAR(10);
DECLARE @batch_log_key_out INT;

-- Retrieve Batch Details if batch is running
EXEC Batch.p_Batch_Log
      @batch_action
     ,@batch_type_key
     ,@batch_status_out OUTPUT
     ,@batch_log_key_out OUTPUT;

-- If there is a batch running then complete it (by having this in here if a batch has been started/completed manually 
-- then this step in the SQL server agent job will not fail by trying to ''complete'' a batch that is not running''
IF @batch_status_out = ''Running''
      BEGIN
            SET @batch_action = ''Complete''

            EXEC Batch.p_Batch_Log
                  @batch_action
                 ,@batch_type_key
                 ,@batch_status_out OUTPUT
                 ,@batch_log_key_out OUTPUT;

      END;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Fail Process_Key 300 (BUS Staging Restore)]    Script Date: 8/17/2022 3:28:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Fail Process_Key 300 (BUS Staging Restore)', 
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
		300, 
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
/****** Object:  Step [LDR Load]    Script Date: 8/17/2022 3:28:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'LDR Load', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\LDR\BAPU LDR.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 8 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0, 
		@proxy_name=N'BAPU_SVC_Proxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [APS Load]    Script Date: 8/17/2022 3:28:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'APS Load', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\APS\APS Load.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 1 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0, 
		@proxy_name=N'BAPU_SVC_Proxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Gempostage Load]    Script Date: 8/17/2022 3:28:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Gempostage Load', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=14, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\Gempostage\BAPU_Gempostage.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 7 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0, 
		@proxy_name=N'BAPU_SVC_Proxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [OWSY Policy/Item/Partner ETL]    Script Date: 8/17/2022 3:28:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'OWSY Policy/Item/Partner ETL', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\OWSY\Owsy.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 10 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0, 
		@proxy_name=N'BAPU_SVC_Proxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [OWSY Partner Code Reference ETL]    Script Date: 8/17/2022 3:28:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'OWSY Partner Code Reference ETL', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=2, 
		@retry_interval=2, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\OWSY\OWSY Partner Codes.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 10 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0, 
		@proxy_name=N'BAPU_SVC_Proxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Loss XLS Load]    Script Date: 8/17/2022 3:28:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Loss XLS Load', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=15, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\Loss XLS\BAPU_Loss_XLS.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 9 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0, 
		@proxy_name=N'BAPU_SVC_Proxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [WC Claim Load (TPA: Sedgwick (Legacy TPA Name: York)]    Script Date: 8/17/2022 3:28:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'WC Claim Load (TPA: Sedgwick (Legacy TPA Name: York)', 
		@step_id=14, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=16, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\York\BAPU_York.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 14 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0, 
		@proxy_name=N'BAPU_SVC_Proxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SSP PDR Load Check]    Script Date: 8/17/2022 3:28:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SSP PDR Load Check', 
		@step_id=15, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=18, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_SSP_PDR_Load_Check;		  
', 
		@database_name=N'BAPU', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SSP PDR Policy Load (BAPU)]    Script Date: 8/17/2022 3:28:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SSP PDR Policy Load (BAPU)', 
		@step_id=16, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\SSP PDR\BAPU PDR.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 12 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0, 
		@proxy_name=N'BAPU_SVC_Proxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SSP PDR Quote (BAPU)]    Script Date: 8/17/2022 3:28:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SSP PDR Quote (BAPU)', 
		@step_id=17, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\SSP PDR\BAPU PDR Quote Data.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 12 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0, 
		@proxy_name=N'BAPU_SVC_Proxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Syndicate Load]    Script Date: 8/17/2022 3:28:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Syndicate Load', 
		@step_id=18, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\Syndicate\Syndicate Data.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 13 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0, 
		@proxy_name=N'BAPU_SVC_Proxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [BDR Load]    Script Date: 8/17/2022 3:28:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'BDR Load', 
		@step_id=19, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\BDR\BDR_BDR.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 4 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0, 
		@proxy_name=N'BAPU_SVC_Proxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [BPM & BPMi Load]    Script Date: 8/17/2022 3:28:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'BPM & BPMi Load', 
		@step_id=20, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\BPM\BAPU_BPM.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 5 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0, 
		@proxy_name=N'BAPU_SVC_Proxy'
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


