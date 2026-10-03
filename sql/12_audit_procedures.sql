-- 创建数据质量检查存储过程，包含空值率、重复记录等规则
CREATE OR ALTER PROCEDURE audit.usp_check_salary_quality
    @batch_id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    -- 规则 1：员工编号为空
    INSERT INTO audit.data_quality_result
    (batch_id, rule_code, rule_name, error_count, check_result, detail_message)
    SELECT
        @batch_id,
        'NULL_EMPLOYEE',
        N'员工编号为空',
        COUNT(*),
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
        N'检查ODS工资记录员工编号'
    FROM ods.salary_raw
    WHERE batch_id = @batch_id
      AND NULLIF(LTRIM(RTRIM(employee_no)), '') IS NULL;

    -- 规则 2：工资明细重复
    INSERT INTO audit.data_quality_result
    (batch_id, rule_code, rule_name, error_count, check_result, detail_message)
    SELECT
        @batch_id,
        'DUPLICATE_SALARY',
        N'工资明细重复',
        COALESCE(SUM(cnt - 1), 0),
        CASE WHEN COALESCE(SUM(cnt - 1), 0) = 0 THEN 'PASS' ELSE 'FAIL' END,
        N'同批次、员工、月份、薪资项目重复'
    FROM (
        SELECT employee_no, salary_month, item_code, COUNT(*) AS cnt
        FROM ods.salary_raw
        WHERE batch_id = @batch_id
        GROUP BY employee_no, salary_month, item_code
        HAVING COUNT(*) > 1
    ) x;

    COMMIT TRANSACTION;
END;
GO