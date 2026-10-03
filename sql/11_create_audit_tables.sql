-- 创建数据质量检查结果表，记录每次质量监控的检查结果
CREATE TABLE audit.data_quality_result (
    quality_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    batch_id BIGINT NULL,
    check_time DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    rule_code VARCHAR(50) NOT NULL,
    rule_name NVARCHAR(100) NOT NULL,
    error_count INT NOT NULL,
    check_result VARCHAR(20) NOT NULL,
    detail_message NVARCHAR(1000) NULL
);