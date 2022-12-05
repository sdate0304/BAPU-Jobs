USE [msdb]
GO

/****** Object:  Job [BAPU (3) - Daily - Core Policy Processing]    Script Date: 12/5/2022 3:35:52 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/5/2022 3:35:52 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BAPU (3) - Daily - Core Policy Processing', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Load core policy tables for active data sources. This job is called by the "BAPU (0) Daily Control" SQL Server Agent Job.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'WRBTS\SVC-BAP-P-DW', 
		@notify_email_operator_name=N'BAPU DW Notifications', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Core Model Policy Processing Batch (Batch_Type_Key = 19)]    Script Date: 12/5/2022 3:35:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Core Model Policy Processing Batch (Batch_Type_Key = 19)', 
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
DECLARE @batch_type_key INT = 19; /* "Core Policy Load" */
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
/****** Object:  Step [Build Agent SSP PDR]    Script Date: 12/5/2022 3:35:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Agent SSP PDR', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_agent @View = ''v_core_bld_agent_SSP'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Insured SSP PDR]    Script Date: 12/5/2022 3:35:52 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Insured SSP PDR', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_insured @View = ''v_core_bld_insured_SSP'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Reinsured SSP PDR]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Reinsured SSP PDR', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_reinsured @View = ''v_core_bld_reinsured_SSP'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Underwriter SSP PDR]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Underwriter SSP PDR', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_underwriter @View = ''v_core_bld_underwriter_SSP'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy SSP PDR]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy SSP PDR', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policy @View = ''v_core_bld_policy_SSP'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Detail SSP PDR]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Detail SSP PDR', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policydetail @View = ''v_core_bld_policydetail_SSP'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Risk SSP PDR]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Risk SSP PDR', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_risk @View = ''v_core_bld_risk_SSP'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Risk Detail SSP PDR]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Risk Detail SSP PDR', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_riskdetail @View = ''v_core_bld_riskdetail_SSP'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Coverage SSP PDR]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Coverage SSP PDR', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_coverage @View = ''v_core_bld_coverage_SSP'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Coverage Detail SSP PDR]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Coverage Detail SSP PDR', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_coveragedetail @View = ''v_core_bld_coveragedetail_SSP'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Transaction SSP PDR]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Transaction SSP PDR', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policytransaction @View = ''v_core_bld_policytransaction_SSP'';

', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Transaction Detail SSP PDR]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Transaction Detail SSP PDR', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policytransactiondetail @View = ''v_core_bld_policytransactiondetail_SSP'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Agent BUS]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Agent BUS', 
		@step_id=14, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_agent @View = ''v_core_bld_agent_BUS'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Insured BUS]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Insured BUS', 
		@step_id=15, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_insured @View = ''v_core_bld_insured_BUS'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Reinsured BUS]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Reinsured BUS', 
		@step_id=16, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_reinsured @View = ''v_core_bld_reinsured_BUS'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Underwriter BUS]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Underwriter BUS', 
		@step_id=17, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_underwriter @View = ''v_core_bld_underwriter_BUS'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy BUS]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy BUS', 
		@step_id=18, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policy @View = ''v_core_bld_policy_BUS'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Detail BUS]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Detail BUS', 
		@step_id=19, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policydetail @View = ''v_core_bld_policydetail_BUS'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Risk BUS]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Risk BUS', 
		@step_id=20, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_risk @View = ''v_core_bld_risk_BUS'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Risk Detail BUS]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Risk Detail BUS', 
		@step_id=21, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_riskdetail @View = ''v_core_bld_riskdetail_BUS'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Coverage BUS]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Coverage BUS', 
		@step_id=22, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_coverage @View = ''v_core_bld_coverage_BUS'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Coverage Detail BUS]    Script Date: 12/5/2022 3:35:53 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Coverage Detail BUS', 
		@step_id=23, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_coveragedetail @View = ''v_core_bld_coveragedetail_BUS'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Transaction BUS]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Transaction BUS', 
		@step_id=24, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policytransaction @View = ''v_core_bld_policytransaction_BUS'';

', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Transaction Detail BUS]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Transaction Detail BUS', 
		@step_id=25, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policytransactiondetail @View = ''v_core_bld_policytransactiondetail_BUS'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Agent Gempostage]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Agent Gempostage', 
		@step_id=26, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_agent @View = ''v_core_bld_agent_GPX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Insured Gempostage]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Insured Gempostage', 
		@step_id=27, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_insured @View = ''v_core_bld_insured_GPX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Reinsured Gempostage]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Reinsured Gempostage', 
		@step_id=28, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_reinsured @View = ''v_core_bld_reinsured_GPX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Underwriter Gempostage]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Underwriter Gempostage', 
		@step_id=29, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_underwriter @View = ''v_core_bld_underwriter_GPX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Gempostage]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Gempostage', 
		@step_id=30, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policy @View = ''v_core_bld_policy_GPX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Detail Gempostage]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Detail Gempostage', 
		@step_id=31, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policydetail @View = ''v_core_bld_policydetail_GPX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Risk Gempostage]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Risk Gempostage', 
		@step_id=32, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_risk @View = ''v_core_bld_risk_GPX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Risk Detail Gempostage]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Risk Detail Gempostage', 
		@step_id=33, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_riskdetail @View = ''v_core_bld_riskdetail_GPX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Coverage Gempostage]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Coverage Gempostage', 
		@step_id=34, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_coverage @View = ''v_core_bld_coverage_GPX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Coverage Detail Gempostage]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Coverage Detail Gempostage', 
		@step_id=35, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_coveragedetail @View = ''v_core_bld_coveragedetail_GPX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Transaction Gempostage]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Transaction Gempostage', 
		@step_id=36, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policytransaction @View = ''v_core_bld_policytransaction_GPX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Transaction Detail Gempostage]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Transaction Detail Gempostage', 
		@step_id=37, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policytransactiondetail @View = ''v_core_bld_policytransactiondetail_GPX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Agent APS (Stamp Collectors)]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Agent APS (Stamp Collectors)', 
		@step_id=38, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_agent @View = ''v_core_bld_agent_APX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Insured APS (Stamp Collectors)]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Insured APS (Stamp Collectors)', 
		@step_id=39, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_insured @View = ''v_core_bld_insured_APX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Reinsured APS (Stamp Collectors)]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Reinsured APS (Stamp Collectors)', 
		@step_id=40, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_reinsured @View = ''v_core_bld_reinsured_APX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Underwriter APS (Stamp Collectors)]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Underwriter APS (Stamp Collectors)', 
		@step_id=41, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_underwriter @View = ''v_core_bld_underwriter_APX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy APS (Stamp Collectors)]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy APS (Stamp Collectors)', 
		@step_id=42, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policy @View = ''v_core_bld_policy_APX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Detail APS (Stamp Collectors)]    Script Date: 12/5/2022 3:35:54 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Detail APS (Stamp Collectors)', 
		@step_id=43, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policydetail @View = ''v_core_bld_policydetail_APX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Risk APS (Stamp Collectors)]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Risk APS (Stamp Collectors)', 
		@step_id=44, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_risk @View = ''v_core_bld_risk_APX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Risk Detail APS (Stamp Collectors)]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Risk Detail APS (Stamp Collectors)', 
		@step_id=45, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_riskdetail @View = ''v_core_bld_riskdetail_APX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Coverage APS (Stamp Collectors)]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Coverage APS (Stamp Collectors)', 
		@step_id=46, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_coverage @View = ''v_core_bld_coverage_APX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Coverage Detail APS (Stamp Collectors)]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Coverage Detail APS (Stamp Collectors)', 
		@step_id=47, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_coveragedetail @View = ''v_core_bld_coveragedetail_APX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Transaction APS (Stamp Collectors)]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Transaction APS (Stamp Collectors)', 
		@step_id=48, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policytransaction @View = ''v_core_bld_policytransaction_APX'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Transaction Detail APS (Stamp Collectors)]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Transaction Detail APS (Stamp Collectors)', 
		@step_id=49, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policytransactiondetail @View = ''v_core_bld_policytransactiondetail_APX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Agent Lavalier]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Agent Lavalier', 
		@step_id=50, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_agent @View = ''v_core_bld_agent_LAV'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Insured Lavalier]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Insured Lavalier', 
		@step_id=51, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_insured @View = ''v_core_bld_insured_LAV'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Reinsured Lavalier]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Reinsured Lavalier', 
		@step_id=52, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_reinsured @View = ''v_core_bld_reinsured_LAV'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Underwriter Lavalier]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Underwriter Lavalier', 
		@step_id=53, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_underwriter @View = ''v_core_bld_underwriter_LAV'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Lavalier]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Lavalier', 
		@step_id=54, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policy @View = ''v_core_bld_policy_LAV'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Detail Lavalier]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Detail Lavalier', 
		@step_id=55, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policydetail @View = ''v_core_bld_policydetail_LAV'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Risk Lavalier]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Risk Lavalier', 
		@step_id=56, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_risk @View = ''v_core_bld_risk_LAV'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Risk Detail Lavalier]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Risk Detail Lavalier', 
		@step_id=57, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_riskdetail @View = ''v_core_bld_riskdetail_LAV'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Coverage Lavalier]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Coverage Lavalier', 
		@step_id=58, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_coverage @View = ''v_core_bld_coverage_LAV'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Coverage Detail Lavalier]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Coverage Detail Lavalier', 
		@step_id=59, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_coveragedetail @View = ''v_core_bld_coveragedetail_LAV'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Transaction Lavalier]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Transaction Lavalier', 
		@step_id=60, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policytransaction @View = ''v_core_bld_policytransaction_LAV'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Transaction Detail Lavalier]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Transaction Detail Lavalier', 
		@step_id=61, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=74, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policytransactiondetail @View = ''v_core_bld_policytransactiondetail_LAV'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Agent HTB (Huntington T. Block)]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Agent HTB (Huntington T. Block)', 
		@step_id=62, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_agent @View = ''v_core_bld_agent_HTB'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Insured HTB (Huntington T. Block)]    Script Date: 12/5/2022 3:35:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Insured HTB (Huntington T. Block)', 
		@step_id=63, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_insured @View = ''v_core_bld_insured_HTB'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Reinsured HTB (Huntington T. Block)]    Script Date: 12/5/2022 3:35:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Reinsured HTB (Huntington T. Block)', 
		@step_id=64, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_reinsured @View = ''v_core_bld_reinsured_HTB'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Underwriter HTB (Huntington T. Block)]    Script Date: 12/5/2022 3:35:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Underwriter HTB (Huntington T. Block)', 
		@step_id=65, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_underwriter @View = ''v_core_bld_underwriter_HTB'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy HTB (Huntington T. Block)]    Script Date: 12/5/2022 3:35:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy HTB (Huntington T. Block)', 
		@step_id=66, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policy @View = ''v_core_bld_policy_HTB'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Detail HTB (Huntington T. Block)]    Script Date: 12/5/2022 3:35:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Detail HTB (Huntington T. Block)', 
		@step_id=67, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policydetail @View = ''v_core_bld_policydetail_HTB'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Risk HTB (Huntington T. Block)]    Script Date: 12/5/2022 3:35:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Risk HTB (Huntington T. Block)', 
		@step_id=68, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_risk @View = ''v_core_bld_risk_HTB'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Risk Detail HTB (Huntington T. Block)]    Script Date: 12/5/2022 3:35:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Risk Detail HTB (Huntington T. Block)', 
		@step_id=69, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_riskdetail @View = ''v_core_bld_riskdetail_HTB'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Coverage HTB (Huntington T. Block)]    Script Date: 12/5/2022 3:35:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Coverage HTB (Huntington T. Block)', 
		@step_id=70, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_coverage @View = ''v_core_bld_coverage_HTB'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Coverage Detail HTB (Huntington T. Block)]    Script Date: 12/5/2022 3:35:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Coverage Detail HTB (Huntington T. Block)', 
		@step_id=71, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_coveragedetail @View = ''v_core_bld_coveragedetail_HTB'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Transaction HTB (Huntington T. Block)]    Script Date: 12/5/2022 3:35:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Transaction HTB (Huntington T. Block)', 
		@step_id=72, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policytransaction @View = ''v_core_bld_policytransaction_HTB'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Build Policy Transaction Detail HTB (Huntington T. Block)]    Script Date: 12/5/2022 3:35:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Build Policy Transaction Detail HTB (Huntington T. Block)', 
		@step_id=73, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_policytransactiondetail @View = ''v_core_bld_policytransactiondetail_HTB'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Complete Core Model Policy Processing (Batch_Type_Key = 19)]    Script Date: 12/5/2022 3:35:56 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Complete Core Model Policy Processing (Batch_Type_Key = 19)', 
		@step_id=74, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @batch_action VARCHAR(50) = ''Retrieve''
DECLARE @batch_type_key INT = 19; /* "Core Policy Load" */
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


