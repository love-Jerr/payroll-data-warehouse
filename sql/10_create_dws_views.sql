-- 创建 DWS 层视图，支撑部门+月份维度的薪资汇总查询
CREATE OR ALTER VIEW dws.v_department_month_salary AS
SELECT
    s.salary_month,
    d.department_no,
    d.department_name,
    COUNT(*) AS employee_count,
    SUM(s.gross_salary) AS gross_salary_total,
    SUM(s.deduction_total) AS deduction_total,
    SUM(s.net_salary) AS net_salary_total,
    AVG(s.net_salary) AS average_net_salary
FROM dws.employee_month_salary s
JOIN dwd.dim_department d
  ON d.department_key = s.department_key
GROUP BY s.salary_month, d.department_no, d.department_name;
GO
-- 时间
CREATE OR ALTER VIEW dwd.v_dim_time AS
SELECT DISTINCT
    CAST(FORMAT(salary_month, 'yyyyMM') AS INT) AS month_key,
    salary_month AS month_date,
    YEAR(salary_month) AS year_no,
    DATEPART(QUARTER, salary_month) AS quarter_no,
    MONTH(salary_month) AS month_no
FROM dwd.fact_salary_detail;