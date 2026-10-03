-- 创建 ETL 批次管理表，用于记录每次数据抽取的执行情况
CREATE TABLE etl.import_batch (
    batch_id       BIGINT IDENTITY(1,1) PRIMARY KEY,	-- 批次编号
    source_name    NVARCHAR(200) NOT NULL,			-- 数据来源名称
    salary_month   DATE NOT NULL,					-- 薪资月份
    start_time     DATETIME2 NOT NULL DEFAULT SYSDATETIME(),  -- 批次开始时间
    end_time       DATETIME2 NULL,				    -- 批次结束时间
    status         VARCHAR(20) NOT NULL DEFAULT 'RUNNING',    -- 批次状态
    total_rows     INT NULL,		-- 总处理行数
    success_rows   INT NULL,		-- 成功处理行数
    error_rows     INT NULL,		-- 失败行数
    error_message  NVARCHAR(1000) NULL   -- 错误信息
);