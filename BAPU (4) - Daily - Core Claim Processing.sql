USE [msdb]
GO

/****** Object:  Job [BAPU (4) - Daily - Core Claim Processing]    Script Date: 03/17/2021 4:06:30 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 03/17/2021 4:06:30 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BAPU (4) - Daily - Core Claim Processing', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Load core claim tables for active data sources. This job is called by the "BAPU (0) Daily Control" SQL Server Agent Job', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'WRBTS\SVC-BAP-P-DW', 
		@notify_email_operator_name=N'BAPU DW Notifications', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Core Model Claim Processing Batch (Batch_Type_Key = 20)]    Script Date: 03/17/2021 4:06:31 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Core Model Claim Processing Batch (Batch_Type_Key = 20)', 
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
DECLARE @batch_type_key INT = 20; /*"Core Claim Load"*/
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
/****** Object:  Step [Load Claim Examiner LDR]    Script Date: 03/17/2021 4:06:31 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Examiner LDR', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claimexaminer ''v_core_bld_claimexaminer_LDR'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Adjuster LDR]    Script Date: 03/17/2021 4:06:31 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Adjuster LDR', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claimadjuster ''v_core_bld_claimadjuster_LDR'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claimant LDR]    Script Date: 03/17/2021 4:06:31 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claimant LDR', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claimant ''v_core_bld_claimant_LDR'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Payee LDR]    Script Date: 03/17/2021 4:06:32 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Payee LDR', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_payee ''v_core_bld_payee_LDR'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Vendor LDR]    Script Date: 03/17/2021 4:06:32 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Vendor LDR', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_vendor ''v_core_bld_vendor_LDR'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim SSP & LDR]    Script Date: 03/17/2021 4:06:32 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim SSP & LDR', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claim ''v_core_bld_claim_SSP_LDR'';', 
		@database_name=N'BAPU_BPM', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim OpenCo & LDR]    Script Date: 03/17/2021 4:06:32 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim OpenCo & LDR', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claim ''v_core_bld_claim_OpenCo_LDR'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim BUS & LDR]    Script Date: 03/17/2021 4:06:32 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim BUS & LDR', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claim ''v_core_bld_claim_BUS_LDR'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Gemshield & LDR]    Script Date: 03/17/2021 4:06:32 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Gemshield & LDR', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claim ''v_core_bld_claim_GSI_LDR'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Gempostage & LDR]    Script Date: 03/17/2021 4:06:33 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Gempostage & LDR', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claim ''v_core_bld_claim_GPX_LDR'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Lavalier & LDR]    Script Date: 03/17/2021 4:06:33 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Lavalier & LDR', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claim ''v_core_bld_claim_LAV_LDR'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Stamp Collectors & LDR]    Script Date: 03/17/2021 4:06:33 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Stamp Collectors & LDR', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claim ''v_core_bld_claim_APX_LDR'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Transaction SSP & LDR]    Script Date: 03/17/2021 4:06:33 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Transaction SSP & LDR', 
		@step_id=14, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claimtransaction ''v_core_bld_claimtransaction_SSP_LDR'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Transaction OpenCo & LDR]    Script Date: 03/17/2021 4:06:33 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Transaction OpenCo & LDR', 
		@step_id=15, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claimtransaction ''v_core_bld_claimtransaction_OpenCo_LDR'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Transaction BUS & LDR]    Script Date: 03/17/2021 4:06:33 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Transaction BUS & LDR', 
		@step_id=16, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claimtransaction ''v_core_bld_claimtransaction_BUS_LDR'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Transaction Gemshield & LDR]    Script Date: 03/17/2021 4:06:34 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Transaction Gemshield & LDR', 
		@step_id=17, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claimtransaction ''v_core_bld_claimtransaction_GSI_LDR'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Transaction Gempostage & LDR]    Script Date: 03/17/2021 4:06:34 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Transaction Gempostage & LDR', 
		@step_id=18, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=20, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claimtransaction ''v_core_bld_claimtransaction_GPX_LDR'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Transaction Lavalier & LDR]    Script Date: 03/17/2021 4:06:34 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Transaction Lavalier & LDR', 
		@step_id=19, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claimtransaction ''v_core_bld_claimtransaction_LAV_LDR'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Transaction Stamp Collectors & LDR]    Script Date: 03/17/2021 4:06:34 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Transaction Stamp Collectors & LDR', 
		@step_id=20, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=38, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claimtransaction ''v_core_bld_claimtransaction_APX_LDR''', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Examiner BAPU Claims]    Script Date: 03/17/2021 4:06:34 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Examiner BAPU Claims', 
		@step_id=21, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_claimexaminer @View = ''v_core_bld_claimexaminer_CLX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Adjuster BAPU Claims]    Script Date: 03/17/2021 4:06:34 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Adjuster BAPU Claims', 
		@step_id=22, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_claimadjuster @View = ''v_core_bld_claimadjuster_CLX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claimant BAPU Claims]    Script Date: 03/17/2021 4:06:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claimant BAPU Claims', 
		@step_id=23, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_claimant @View = ''v_core_bld_claimant_CLX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Payee BAPU Claims]    Script Date: 03/17/2021 4:06:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Payee BAPU Claims', 
		@step_id=24, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_payee @View = ''v_core_bld_payee_CLX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Vendor BAPU Claims]    Script Date: 03/17/2021 4:06:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Vendor BAPU Claims', 
		@step_id=25, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_vendor @View = ''v_core_bld_vendor_CLX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim SSP & BAPU Claims]    Script Date: 03/17/2021 4:06:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim SSP & BAPU Claims', 
		@step_id=26, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claim @View = ''v_core_bld_claim_SSP_CLX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim OpenCo & BAPU Claims]    Script Date: 03/17/2021 4:06:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim OpenCo & BAPU Claims', 
		@step_id=27, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_claim @View = ''v_core_bld_claim_OpenCo_CLX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim BUS & BAPU Claims]    Script Date: 03/17/2021 4:06:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim BUS & BAPU Claims', 
		@step_id=28, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_claim @View = ''v_core_bld_claim_BUS_CLX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Gempostage & BAPU Claims]    Script Date: 03/17/2021 4:06:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Gempostage & BAPU Claims', 
		@step_id=29, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_claim @View = ''v_core_bld_claim_GPX_CLX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Booking Premium & BAPU Claims]    Script Date: 03/17/2021 4:06:36 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Booking Premium & BAPU Claims', 
		@step_id=30, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_claim @View = ''v_core_bld_claim_BPX_CLX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Assumed & BAPU Claims]    Script Date: 03/17/2021 4:06:36 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Assumed & BAPU Claims', 
		@step_id=31, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_claim @View = ''v_core_bld_claim_AXL_CLX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Transaction SSP & BAPU Claims]    Script Date: 03/17/2021 4:06:36 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Transaction SSP & BAPU Claims', 
		@step_id=32, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_claimtransaction @View = ''v_core_bld_claimtransaction_SSP_CLX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Transaction OpenCo & BAPU Claims]    Script Date: 03/17/2021 4:06:36 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Transaction OpenCo & BAPU Claims', 
		@step_id=33, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_claimtransaction @View = ''v_core_bld_claimtransaction_OpenCo_CLX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Transaction BUS & BAPU Claims]    Script Date: 03/17/2021 4:06:36 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Transaction BUS & BAPU Claims', 
		@step_id=34, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_claimtransaction @View = ''v_core_bld_claimtransaction_BUS_CLX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Transaction Gempostage & BAPU Claims]    Script Date: 03/17/2021 4:06:36 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Transaction Gempostage & BAPU Claims', 
		@step_id=35, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_claimtransaction @View = ''v_core_bld_claimtransaction_GPX_CLX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Transaction Booking Premium & BAPU Claims]    Script Date: 03/17/2021 4:06:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Transaction Booking Premium & BAPU Claims', 
		@step_id=36, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_claimtransaction @View = ''v_core_bld_claimtransaction_BPX_CLX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Transaction Assumed & BAPU Claims]    Script Date: 03/17/2021 4:06:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Transaction Assumed & BAPU Claims', 
		@step_id=37, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_claimtransaction @View = ''v_core_bld_claimtransaction_AXL_CLX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load York Pre-Core Tables (p_York_SSP_Claim_Data_Compile)]    Script Date: 03/17/2021 4:06:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load York Pre-Core Tables (p_York_SSP_Claim_Data_Compile)', 
		@step_id=38, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_York_SSP_Claim_Data_Compile;', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Examiner York]    Script Date: 03/17/2021 4:06:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Examiner York', 
		@step_id=39, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claimexaminer ''v_core_bld_claimexaminer_York'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Adjuster York]    Script Date: 03/17/2021 4:06:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Adjuster York', 
		@step_id=40, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claimadjuster ''v_core_bld_claimadjuster_York'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claimant York]    Script Date: 03/17/2021 4:06:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claimant York', 
		@step_id=41, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claimant ''v_core_bld_claimant_York'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Payee York]    Script Date: 03/17/2021 4:06:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Payee York', 
		@step_id=42, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_payee ''v_core_bld_payee_York'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Vendor York]    Script Date: 03/17/2021 4:06:38 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Vendor York', 
		@step_id=43, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_vendor ''v_core_bld_vendor_York'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim SSP & York]    Script Date: 03/17/2021 4:06:38 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim SSP & York', 
		@step_id=44, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claim ''v_core_bld_claim_SSP_York'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Claim Transaction SSP & YORK]    Script Date: 03/17/2021 4:06:38 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Claim Transaction SSP & YORK', 
		@step_id=45, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claimtransaction ''v_core_bld_claimtransaction_SSP_York'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Complete Core Model Claim Processing (Batch_Type_Key = 20)]    Script Date: 03/17/2021 4:06:38 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Complete Core Model Claim Processing (Batch_Type_Key = 20)', 
		@step_id=46, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @batch_action VARCHAR(50) = ''Retrieve''
DECLARE @batch_type_key INT = 20; /* "Core ClaimLoad" */
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


