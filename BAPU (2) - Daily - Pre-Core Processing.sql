USE [msdb]
GO

/****** Object:  Job [BAPU (2) - Daily - Pre-Core Processing]    Script Date: 09/08/2021 10:08:30 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 09/08/2021 10:08:30 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BAPU (2) - Daily - Pre-Core Processing', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job processes the staging area to correct, clean up and prepare data prior to core processing. This job is called by the "BAPU (0) Daily Control" SQL Server Agent Job.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'WRBTS\SVC-BAP-P-DW', 
		@notify_email_operator_name=N'BAPU DW Notifications', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [TEMPORARY BUS Custom Property Clean Up]    Script Date: 09/08/2021 10:08:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'TEMPORARY BUS Custom Property Clean Up', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'---- This step is being added temporarily to account for a BUS custom property duplication issue
---- For additional information please see: https://jira.wrberkley.com/browse/BAPU-524
USE BAPU_PolicyAdministration;

DROP TABLE IF EXISTS #DupCustomProperty;
DROP TABLE IF EXISTS #CustPropToDelete;

DECLARE @RowCount INT = 0;

---- Are there any policies duplicated in the BUS policy view?
SELECT  @RowCount = SUM(row_count.pol_count)
FROM    ( SELECT    COUNT(DISTINCT vcbpb.policy_source_key) AS pol_count
          FROM  BAPU_CORE.dbo.v_core_bld_policy_BUS AS vcbpb
          GROUP BY vcbpb.policy_source_key
          HAVING   COUNT(*) > 1 ) AS row_count;

--SELECT  @RowCount;

---- If there are duplicated policies then find the affected policies and their max & min create date
IF @RowCount >= 1
    BEGIN

        ---- Identify Policies on the BUS side that have more than 12 custom property IDs associated with the Policy (each BUS policy should ONLY have 12 as of the time this query was written)
        ---- Queries above can be used for additional research
        SELECT  cp.InstanceId AS PolicyId
               ,p.PolicyNumber
               ,COUNT(cp.CustomPropertyId) AS CustomPropertyCount ---- Should be 12 or less
               ,MIN(cp.CreateDate) AS MinCreateDate
               ,MAX(cp.CreateDate) AS MaxCreateDate
        INTO    #DupCustomProperty
        FROM    BAPU_PolicyAdministration.Global.CustomProperty AS cp
        INNER JOIN BAPU_PolicyAdministration.Global.CustomPropertyDefinition AS cpd ON cpd.CustomPropertyDefinitionId = cp.CustomPropertyDefinitionId
        LEFT OUTER JOIN BAPU_PolicyAdministration.Global.EntityType AS et ON et.EntityTypeId = cp.EntityTypeId
        LEFT OUTER JOIN BAPU_PolicyAdministration.PolicyAdministration.Policy AS p ON p.PolicyId = cp.InstanceId
        WHERE   cp.EntityTypeId = 23 ---- policy
        GROUP BY cp.InstanceId
                ,p.PolicyNumber
        HAVING  COUNT(cp.CustomPropertyId) > 12
        ORDER BY cp.InstanceId
                ,p.PolicyNumber;

        ---- Here are the custom property ids to DELETE (those that match the maximum create date
        SELECT  DISTINCT cp.CustomPropertyId
        INTO    #CustPropToDelete
        FROM    BAPU_PolicyAdministration.Global.CustomProperty AS cp
        INNER JOIN BAPU_PolicyAdministration.Global.CustomPropertyDefinition AS cpd ON cpd.CustomPropertyDefinitionId = cp.CustomPropertyDefinitionId
        LEFT OUTER JOIN BAPU_PolicyAdministration.Global.EntityType AS et ON et.EntityTypeId = cp.EntityTypeId
        LEFT OUTER JOIN BAPU_PolicyAdministration.PolicyAdministration.Policy AS p ON p.PolicyId = cp.InstanceId
        INNER JOIN #DupCustomProperty AS dcp ON dcp.PolicyId = cp.InstanceId
                                            AND TRY_CAST(dcp.MaxCreateDate AS DATE) = TRY_CAST(cp.CreateDate AS DATE)
        WHERE   cp.EntityTypeId = 23 ---- policy
        ;

        ---- Delete those custom properties
        DELETE
        --SELECT  *
        FROM BAPU_PolicyAdministration.Global.CustomProperty
        WHERE   EXISTS ( SELECT cp.CustomPropertyId
                         FROM   #CustPropToDelete AS cp
                         WHERE  cp.CustomPropertyId = BAPU_PolicyAdministration.Global.CustomProperty.CustomPropertyId );
    END;
ELSE
    BEGIN
        PRINT ''No Duplicated Policies'';
    END;

DROP TABLE IF EXISTS #DupCustomProperty;
DROP TABLE IF EXISTS #CustPropToDelete;', 
		@database_name=N'BAPU_PolicyAdministration', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Pre-Core Data Work Batch (Batch_Type_Key = 18)]    Script Date: 09/08/2021 10:08:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Pre-Core Data Work Batch (Batch_Type_Key = 18)', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @batch_action VARCHAR(50) = ''Start In Sequence'';
DECLARE @batch_type_key INT = 18; /* "BAPU - Pre-Core" */
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
/****** Object:  Step [p_PDR_SSP_Insert_LastRiskUnitVersion]    Script Date: 09/08/2021 10:08:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'p_PDR_SSP_Insert_LastRiskUnitVersion', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_PDR_SSP_Insert_LastRiskUnitVersion;', 
		@database_name=N'BAPU', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [p_PDR_SSP_Insert_LastCoverageUnitVersion]    Script Date: 09/08/2021 10:08:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'p_PDR_SSP_Insert_LastCoverageUnitVersion', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_PDR_SSP_Insert_LastCoverageUnitVersion;', 
		@database_name=N'BAPU', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [p_BUS_Custom_Property_Risk_Detail_Load]    Script Date: 09/08/2021 10:08:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'p_BUS_Custom_Property_Risk_Detail_Load', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.p_BUS_Custom_Property_Risk_Detail_Load;', 
		@database_name=N'BAPU_CORE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Complete Pre-Core Data Work Batch (Batch_Type_Key = 18)]    Script Date: 09/08/2021 10:08:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Complete Pre-Core Data Work Batch (Batch_Type_Key = 18)', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @batch_action VARCHAR(50);
DECLARE @batch_type_key INT = 18;/* "BAPU - Pre-Core" */
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


