-- 创建 ODS 层原始数据表与错误记录表
-- 原始薪资数据表
CREATE TABLE ods.salary_raw (
    raw_id         BIGINT IDENTITY(1,1) PRIMARY KEY,
    batch_id       BIGINT NOT NULL,
    employee_no    NVARCHAR(30) NULL,
    employee_name  NVARCHAR(100) NULL,
    department_no  NVARCHAR(30) NULL,
    salary_month   DATE NULL,
    item_code      NVARCHAR(30) NULL,
    item_name      NVARCHAR(100) NULL,
    amount_text    NVARCHAR(50) NULL,
    source_file    NVARCHAR(300) NULL,
    load_time      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT fk_salary_raw_batch
        FOREIGN KEY (batch_id) REFERENCES etl.import_batch(batch_id)
);

-- 错误记录表
CREATE TABLE ods.salary_error (
    error_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    batch_id BIGINT NOT NULL,
    raw_id BIGINT NULL,
    error_type VARCHAR(50) NOT NULL,
    error_message NVARCHAR(500) NOT NULL,
    raw_content NVARCHAR(MAX) NULL,
    create_time DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

