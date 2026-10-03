-- 1. 插入测试批次
INSERT INTO etl.import_batch (source_name, salary_month)
VALUES (N'测试导入', '2026-09-01');

-- 2. 插入测试员工和部门
INSERT INTO dwd.dim_department (department_no, department_name)
VALUES ('D01', N'计算机学院');

INSERT INTO dwd.dim_employee (employee_no, employee_name, department_key)
VALUES ('E001', N'张三', 1);

-- 3. 插入 ODS 原始数据
INSERT INTO ods.salary_raw
(batch_id, employee_no, salary_month, item_code, amount_text)
VALUES
(1, 'E001', '2026-09-01', 'BASIC', '10000.00'),
(1, 'E001', '2026-09-01', 'TAX', '500.00');

-- 4. 调用 ETL
EXEC etl.usp_load_salary_detail @batch_id = 1;

-- 5. 调用月度汇总
EXEC etl.usp_build_month_summary @salary_month = '2026-09-01';

-- 6. 调用质量检查
EXEC audit.usp_check_salary_quality @batch_id = 1;

-- 7. 查看结果
SELECT * FROM dwd.fact_salary_detail;
SELECT * FROM dwd.salary_calculation;
SELECT * FROM dws.employee_month_salary;
SELECT * FROM dws.v_department_month_salary;
SELECT * FROM audit.data_quality_result;