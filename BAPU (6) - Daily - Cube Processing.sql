USE [msdb]
GO

/****** Object:  Job [BAPU (6) - Daily - Cube Processing]    Script Date: 03/17/2021 4:07:18 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 03/17/2021 4:07:18 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BAPU (6) - Daily - Cube Processing', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job is kicked off by the "BAPU (0) Daily Control" job. This job includes any items related to processing of BAPU''s SSAS cube.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'WRBTS\SVC-BAP-P-DW', 
		@notify_email_operator_name=N'BAPU DW Notifications', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Cube Processing Batch (Batch_Type_Key = 24)]    Script Date: 03/17/2021 4:07:19 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Cube Processing Batch (Batch_Type_Key = 24)', 
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
DECLARE @batch_type_key INT = 24; /* "Cube Processing" */
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
/****** Object:  Step [p_Cube_Premium_Transaction_Staging_Load]    Script Date: 03/17/2021 4:07:19 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'p_Cube_Premium_Transaction_Staging_Load', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC Cube.p_Cube_Premium_Transaction_Staging_Load;', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [p_Cube_Loss_Transaction_Staging_Load]    Script Date: 03/17/2021 4:07:19 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'p_Cube_Loss_Transaction_Staging_Load', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC Cube.p_Cube_Loss_Transaction_Staging_Load;', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [p_Cube_Dimension_Table_Load]    Script Date: 03/17/2021 4:07:20 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'p_Cube_Dimension_Table_Load', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC cube.p_Cube_Dimension_Table_Load;
', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [p_Cube_Fact_Table_Load]    Script Date: 03/17/2021 4:07:20 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'p_Cube_Fact_Table_Load', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC cube.p_Cube_Fact_Table_Load;', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Process_Key 8002 (Cube Processing)]    Script Date: 03/17/2021 4:07:20 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Process_Key 8002 (Cube Processing)', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Start Process Log
EXEC Batch.p_Process_Log
		8002, 
		''Start'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Process SSAS Cube: BAPU_Cube]    Script Date: 03/17/2021 4:07:20 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Process SSAS Cube: BAPU_Cube', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=9, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'ANALYSISCOMMAND', 
		@command=N'<Batch xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
  <Parallel>
    <Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400" xmlns:ddl500="http://schemas.microsoft.com/analysisservices/2013/engine/500" xmlns:ddl500_500="http://schemas.microsoft.com/analysisservices/2013/engine/500/500">
      <Object>
        <DatabaseID>BAPU Cube</DatabaseID>
      </Object>
      <Type>ProcessFull</Type>
      <WriteBackTableCreation>UseExisting</WriteBackTableCreation>
    </Process>
  </Parallel>
</Batch>', 
		@server=N'BAP_DWAR_PROD', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Complete Process_Key 8002 (BAPU_Cube Processing)]    Script Date: 03/17/2021 4:07:20 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Complete Process_Key 8002 (BAPU_Cube Processing)', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=10, 
		@on_fail_action=4, 
		@on_fail_step_id=10, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @process_log_key_out INT;

-- Complete Process Log
EXEC Batch.p_Process_Log
		8002, 
		''Complete'', 
		NULL, 
		NULL,
		NULL,
		NULL,
		@process_log_key_out OUTPUT;', 
		@database_name=N'BAPU_Logging', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Fail Process_Key 8002 (BAPU_Cube Processing)]    Script Date: 03/17/2021 4:07:20 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Fail Process_Key 8002 (BAPU_Cube Processing)', 
		@step_id=9, 
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
		8002, 
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
/****** Object:  Step [Complete Cube Processing Batch (Batch_Type_Key = 24)]    Script Date: 03/17/2021 4:07:21 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Complete Cube Processing Batch (Batch_Type_Key = 24)', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @batch_action VARCHAR(50) = ''Retrieve''
DECLARE @batch_type_key INT = 24; /* "Cube Processing" */
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


