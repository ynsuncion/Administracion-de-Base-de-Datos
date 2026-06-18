USE msdb ;
GO

-- =========================================================================
-- 1. CREACIÓN DEL JOB DE MANERA GLOBAL
-- =========================================================================
EXEC dbo.sp_add_job
    @job_name = N'Backup_Diario_Pubs_Full_TSQL', 
    @enabled = 1,
    @description = N'Job automatizado para el backup FULL diario de la base de datos Pubs.' ;
GO

-- =========================================================================
-- 2. VINCULACIÓN DEL PASO DE EJECUCIÓN (CON COMANDO DE SOBREESCRITURA INIT)
-- =========================================================================
EXEC sp_add_jobstep
    @job_name = N'Backup_Diario_Pubs_Full_TSQL',
    @step_name = N'Ejecutar BACKUP T-SQL Pubs',
    @subsystem = N'TSQL',
    @command = N'BACKUP DATABASE [pubs] 
                 TO DISK = N''C:\Backups\pubs_daily.bak'' 
                 WITH NOFORMAT, INIT, NAME = N''Pubs-Full Database Backup'', 
                 SKIP, NOREWIND, NOUNLOAD, STATS = 10', 
    @retry_attempts = 3,
    @retry_interval = 5 ;
GO

-- =========================================================================
-- 3. ASIGNACIÓN DEL HORARIO RECURRENTE (TODOS LOS DÍAS A LAS 02:00 AM)
-- =========================================================================
EXEC dbo.sp_add_jobschedule
    @job_name = N'Backup_Diario_Pubs_Full_TSQL',
    @name = N'Programacion_Diaria_02AM',
    @freq_type = 4,                   -- Tipo 4 indica frecuencia Diaria
    @freq_interval = 1,               -- Ejecución cada 1 día
    @active_start_time = 040600 ;     -- Formato de hora estándar HHMMSS
GO

-- =========================================================================
-- 4. ACOPLAMIENTO DEL JOB AL SERVIDOR DE INSTANCIA LOCAL
-- =========================================================================
EXEC dbo.sp_add_jobserver
    @job_name = N'Backup_Diario_Pubs_Full_TSQL',
    @server_name = N'(local)' ;
GO