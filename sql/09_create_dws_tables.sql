-- 建 DWS 层汇总表 + 建一个“月度汇总构建”存储过程

-- 建DWS汇总表
CREATE TABLE dws.employee_month_salary (
    salary_month DATE NOT NULL,
    employee_key INT NOT NULL,
    department_key INT NOT NULL,
    gross_salary DECIMAL(18,2) NOT NULL,
    deduction_total DECIMAL(18,2) NOT NULL,
    net_salary DECIMAL(18,2) NOT NULL,
    PRIMARY KEY (salary_month, employee_key)
);
GO

-- 月度汇总存储过程
CREATE OR ALTER PROCEDURE etl.usp_build_month_summary
    @salary_month DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    DELETE FROM dws.employee_month_salary
    WHERE salary_month = @salary_month;

    INSERT INTO dws.employee_month_salary
    (
        salary_month, employee_key, department_key,
        gross_salary, deduction_total, net_salary
    )
    SELECT
        salary_month,
        employee_key,
        department_key,
        gross_salary,
        deduction_total,
        net_salary
    FROM dwd.salary_calculation
    WHERE salary_month = @salary_month;

    COMMIT TRANSACTION;
END;
GO