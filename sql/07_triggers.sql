-- 创建触发器，实现明细事实表到薪资核算汇总表的自动同步

CREATE TRIGGER dwd.trg_fact_salary_detail_sync
ON dwd.fact_salary_detail
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

	-- 收集受影响的数据
    ;WITH affected AS (
        SELECT employee_key, department_key, salary_month, batch_id FROM inserted
        UNION
        SELECT employee_key, department_key, salary_month, batch_id FROM deleted
    ), summary AS (
	
	-- 汇总计算
        SELECT
            a.batch_id,
            a.employee_key,
            a.department_key,
            a.salary_month,
            COALESCE(SUM(CASE WHEN i.item_type = 'EARNING'
                              THEN f.amount ELSE 0 END), 0) AS gross_salary,
            COALESCE(SUM(CASE WHEN i.item_type = 'DEDUCTION'
                              THEN f.amount ELSE 0 END), 0) AS deduction_total
        FROM affected a
        LEFT JOIN dwd.fact_salary_detail f
          ON f.batch_id = a.batch_id
         AND f.employee_key = a.employee_key
         AND f.salary_month = a.salary_month
        LEFT JOIN dwd.dim_salary_item i
          ON i.item_key = f.item_key
        GROUP BY a.batch_id, a.employee_key, a.department_key, a.salary_month
    )
	-- MERGE 同步到汇总表
	-- 同时处理更新和插入
    MERGE dwd.salary_calculation AS target
    USING summary AS source
       ON target.batch_id = source.batch_id
      AND target.employee_key = source.employee_key
      AND target.salary_month = source.salary_month
    WHEN MATCHED THEN
        UPDATE SET
            gross_salary = source.gross_salary,
            deduction_total = source.deduction_total,
            department_key = source.department_key,
            update_time = SYSDATETIME()
    WHEN NOT MATCHED THEN
        INSERT (batch_id, employee_key, department_key, salary_month,
                gross_salary, deduction_total)
        VALUES (source.batch_id, source.employee_key, source.department_key,
                source.salary_month, source.gross_salary, source.deduction_total);
END;
GO