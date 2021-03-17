USE [msdb]
GO

/****** Object:  Job [BAPU - Annual - (0) Disaster Recovery Cycle Test]    Script Date: 03/17/2021 4:01:12 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 03/17/2021 4:01:12 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BAPU - Annual - (0) Disaster Recovery Cycle Test', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job is used during the Annual Disaster Recovery testing completed by BTS. The job will run a sub-section of BAPU''s nightly cycle for testing puporses. This job is called during the DR testing after failover to the DR server and then again once the environment is failed back over to the production server.

Job is maintained by the Data Services team at BTS (PrimaryITData@wrberkley.com).', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'WRBTS\SVC-BAP-P-DW', 
		@notify_email_operator_name=N'BAPU DW Notifications', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [APS (Stamp Collectors) ETL]    Script Date: 03/17/2021 4:01:13 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'APS (Stamp Collectors) ETL', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=4, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\APS\APS Load.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 1 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run 'Restore BAPU_PolicyAdministration_WarehouseCopy_From_BapuBUSSqlProd' SQL Server Agent Job]    Script Date: 03/17/2021 4:01:13 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run ''Restore BAPU_PolicyAdministration_WarehouseCopy_From_BapuBUSSqlProd'' SQL Server Agent Job', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_start_job N''Restore BAPU_PolicyAdministration_WarehouseCopy_From_BapuBUSSqlProd'';', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wait for 'Restore BAPU_PolicyAdministration_WarehouseCopy_From_BapuBUSSqlProd' SQL Job to Complete]    Script Date: 03/17/2021 4:01:14 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wait for ''Restore BAPU_PolicyAdministration_WarehouseCopy_From_BapuBUSSqlProd'' SQL Job to Complete', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @JobStatus INT;
EXEC  dbo.p_SQL_Server_Job_Monitor  ''Restore BAPU_PolicyAdministration_WarehouseCopy_From_BapuBUSSqlProd'', ''00:00:05'', @JobStatus OUTPUT;
SELECT @JobStatus;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SSP PDR ETL]    Script Date: 03/17/2021 4:01:14 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SSP PDR ETL', 
		@step_id=4, 
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
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Claim Workbook ETL]    Script Date: 03/17/2021 4:01:14 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Claim Workbook ETL', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\Loss XLS\BAPU_Loss_XLS.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 9 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [LDR ETL]    Script Date: 03/17/2021 4:01:14 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'LDR ETL', 
		@step_id=6, 
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
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [BDR ETL]    Script Date: 03/17/2021 4:01:14 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'BDR ETL', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\BAPU SSIS Processing\BDR\BDR_BDR.dtsx\"" /SERVER "\"BAP_DW_PROD\"" /ENVREFERENCE 4 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run 'BAPU (2) - Daily - Pre-Core Processing' SQL Agent Job]    Script Date: 03/17/2021 4:01:14 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run ''BAPU (2) - Daily - Pre-Core Processing'' SQL Agent Job', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_start_job N''BAPU (2) - Daily - Pre-Core Processing'';', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wait for 'BAPU (2) - Daily - Pre-Core Processing' Job to Complete]    Script Date: 03/17/2021 4:01:15 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wait for ''BAPU (2) - Daily - Pre-Core Processing'' Job to Complete', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @JobStatus INT;
EXEC  dbo.p_SQL_Server_Job_Monitor  ''BAPU (2) - Daily - Pre-Core Processing'', ''00:00:05'', @JobStatus OUTPUT;
SELECT @JobStatus;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Core Model Policy Processing Batch (Batch_Type_Key = 19)]    Script Date: 03/17/2021 4:01:15 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Core Model Policy Processing Batch (Batch_Type_Key = 19)', 
		@step_id=10, 
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
/****** Object:  Step [SSP PDR CORE Policy Load]    Script Date: 03/17/2021 4:01:15 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SSP PDR CORE Policy Load', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_agent @View = ''v_core_bld_agent_SSP'';
EXEC dbo.p_core_bld_insured @View = ''v_core_bld_insured_SSP'';
EXEC dbo.p_core_bld_reinsured @View = ''v_core_bld_reinsured_SSP'';
EXEC dbo.p_core_bld_underwriter @View = ''v_core_bld_underwriter_SSP'';
EXEC dbo.p_core_bld_policy @View = ''v_core_bld_policy_SSP'';
EXEC dbo.p_core_bld_policydetail @View = ''v_core_bld_policydetail_SSP'';
EXEC dbo.p_core_bld_risk @View = ''v_core_bld_risk_SSP'';
EXEC dbo.p_core_bld_riskdetail @View = ''v_core_bld_riskdetail_SSP'';
EXEC dbo.p_core_bld_coverage @View = ''v_core_bld_coverage_SSP'';
EXEC dbo.p_core_bld_coveragedetail @View = ''v_core_bld_coveragedetail_SSP'';
EXEC dbo.p_core_bld_policytransaction @View = ''v_core_bld_policytransaction_SSP'';
EXEC dbo.p_core_bld_policytransactiondetail @View = ''v_core_bld_policytransactiondetail_SSP'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [BUS CORE Policy Load]    Script Date: 03/17/2021 4:01:15 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'BUS CORE Policy Load', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_agent @View = ''v_core_bld_agent_BUS'';
EXEC dbo.p_core_bld_insured @View = ''v_core_bld_insured_BUS'';
EXEC dbo.p_core_bld_reinsured @View = ''v_core_bld_reinsured_BUS'';
EXEC dbo.p_core_bld_underwriter @View = ''v_core_bld_underwriter_BUS'';
EXEC dbo.p_core_bld_policy @View = ''v_core_bld_policy_BUS'';
EXEC dbo.p_core_bld_policydetail @View = ''v_core_bld_policydetail_BUS'';
EXEC dbo.p_core_bld_risk @View = ''v_core_bld_risk_BUS'';
EXEC dbo.p_core_bld_riskdetail @View = ''v_core_bld_riskdetail_BUS'';
EXEC dbo.p_core_bld_coverage @View = ''v_core_bld_coverage_BUS'';
EXEC dbo.p_core_bld_coveragedetail @View = ''v_core_bld_coveragedetail_BUS'';
EXEC dbo.p_core_bld_policytransaction @View = ''v_core_bld_policytransaction_BUS'';
EXEC dbo.p_core_bld_policytransactiondetail @View = ''v_core_bld_policytransactiondetail_BUS'';', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [APS (Stamp Collectors) CORE Policy Load]    Script Date: 03/17/2021 4:01:15 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'APS (Stamp Collectors) CORE Policy Load', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_agent @View = ''v_core_bld_agent_APX'';
EXEC dbo.p_core_bld_insured @View = ''v_core_bld_insured_APX'';
EXEC dbo.p_core_bld_reinsured @View = ''v_core_bld_reinsured_APX'';
EXEC dbo.p_core_bld_underwriter @View = ''v_core_bld_underwriter_APX'';
EXEC dbo.p_core_bld_policy @View = ''v_core_bld_policy_APX'';
EXEC dbo.p_core_bld_policydetail @View = ''v_core_bld_policydetail_APX'';
EXEC dbo.p_core_bld_risk @View = ''v_core_bld_risk_APX'';
EXEC dbo.p_core_bld_riskdetail @View = ''v_core_bld_riskdetail_APX'';
EXEC dbo.p_core_bld_coverage @View = ''v_core_bld_coverage_APX'';
EXEC dbo.p_core_bld_coveragedetail @View = ''v_core_bld_coveragedetail_APX'';
EXEC dbo.p_core_bld_policytransaction @View = ''v_core_bld_policytransaction_APX'';
EXEC dbo.p_core_bld_policytransactiondetail @View = ''v_core_bld_policytransactiondetail_APX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Complete Core Model Policy Processing (Batch_Type_Key = 19)]    Script Date: 03/17/2021 4:01:15 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Complete Core Model Policy Processing (Batch_Type_Key = 19)', 
		@step_id=14, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
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
/****** Object:  Step [Start Core Model Claim Processing Batch (Batch_Type_Key = 20)]    Script Date: 03/17/2021 4:01:15 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Core Model Claim Processing Batch (Batch_Type_Key = 20)', 
		@step_id=15, 
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
/****** Object:  Step [LDR CORE Claim Load (SSP PDR / BUS / APS)]    Script Date: 03/17/2021 4:01:16 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'LDR CORE Claim Load (SSP PDR / BUS / APS)', 
		@step_id=16, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC BAPU_CORE.dbo.p_core_bld_claimexaminer ''v_core_bld_claimexaminer_LDR'';
EXEC BAPU_CORE.dbo.p_core_bld_claimadjuster ''v_core_bld_claimadjuster_LDR'';
EXEC BAPU_CORE.dbo.p_core_bld_claimant ''v_core_bld_claimant_LDR'';
EXEC BAPU_CORE.dbo.p_core_bld_payee ''v_core_bld_payee_LDR'';
EXEC BAPU_CORE.dbo.p_core_bld_vendor ''v_core_bld_vendor_LDR'';
EXEC BAPU_CORE.dbo.p_core_bld_claim ''v_core_bld_claim_SSP_LDR'';
EXEC BAPU_CORE.dbo.p_core_bld_claim ''v_core_bld_claim_BUS_LDR'';
EXEC BAPU_CORE.dbo.p_core_bld_claim ''v_core_bld_claim_APX_LDR'';
EXEC BAPU_CORE.dbo.p_core_bld_claimtransaction ''v_core_bld_claimtransaction_SSP_LDR'';
EXEC BAPU_CORE.dbo.p_core_bld_claimtransaction ''v_core_bld_claimtransaction_BUS_LDR'';
EXEC BAPU_CORE.dbo.p_core_bld_claimtransaction ''v_core_bld_claimtransaction_APX_LDR''', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Claim Workbook CORE Claim Load (SSP PDR / BUS)]    Script Date: 03/17/2021 4:01:16 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Claim Workbook CORE Claim Load (SSP PDR / BUS)', 
		@step_id=17, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_core_bld_claimexaminer @View = ''v_core_bld_claimexaminer_CLX'';
EXEC dbo.p_core_bld_claimadjuster @View = ''v_core_bld_claimadjuster_CLX'';
EXEC dbo.p_core_bld_claimant @View = ''v_core_bld_claimant_CLX'';
EXEC dbo.p_core_bld_payee @View = ''v_core_bld_payee_CLX'';
EXEC dbo.p_core_bld_vendor @View = ''v_core_bld_vendor_CLX'';
EXEC dbo.p_core_bld_claim @View = ''v_core_bld_claim_SSP_CLX'';
EXEC dbo.p_core_bld_claim @View = ''v_core_bld_claim_BUS_CLX'';
EXEC dbo.p_core_bld_claimtransaction @View = ''v_core_bld_claimtransaction_SSP_CLX'';
EXEC dbo.p_core_bld_claimtransaction @View = ''v_core_bld_claimtransaction_BUS_CLX'';
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Complete Core Model Claim Processing (Batch_Type_Key = 20)]    Script Date: 03/17/2021 4:01:16 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Complete Core Model Claim Processing (Batch_Type_Key = 20)', 
		@step_id=18, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
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
/****** Object:  Step [Run p_Policy_Transaction_Earnings (Start/Complete Batch_Type_Key 21)]    Script Date: 03/17/2021 4:01:16 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run p_Policy_Transaction_Earnings (Start/Complete Batch_Type_Key 21)', 
		@step_id=19, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Start Batch

DECLARE @batch_action VARCHAR(50) = ''Start In Sequence'';
DECLARE @batch_type_key INT = 21;  /* "Earnings Load" */
DECLARE @batch_status_out VARCHAR(10);
DECLARE @batch_log_key_out INT;
EXEC BAPU_Logging.Batch.p_Batch_Log
     @batch_action
    ,@batch_type_key
    ,@batch_status_out OUTPUT
    ,@batch_log_key_out OUTPUT;

-- Run earnings procedures
EXEC dbo.p_Policy_Transaction_Earnings;
-- Complete Batch
-- Retrieve Batch Details if batch is running
SET @batch_action = ''Retrieve'';

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
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run 'BAPU (6) - Daily - Cube Processing' SQL Job]    Script Date: 03/17/2021 4:01:16 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run ''BAPU (6) - Daily - Cube Processing'' SQL Job', 
		@step_id=20, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_start_job N''BAPU (6) - Daily - Cube Processing'';', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wait for 'BAPU (6) - Daily - Cube Processing' SQL Job to Complete]    Script Date: 03/17/2021 4:01:16 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wait for ''BAPU (6) - Daily - Cube Processing'' SQL Job to Complete', 
		@step_id=21, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @JobStatus INT;
EXEC  dbo.p_SQL_Server_Job_Monitor  ''BAPU (6) - Daily - Cube Processing'', ''00:00:05'', @JobStatus OUTPUT;
SELECT @JobStatus;', 
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


