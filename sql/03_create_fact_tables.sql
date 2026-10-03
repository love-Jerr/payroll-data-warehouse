-- 创建薪资明细事实表与薪资核算汇总表
CREATE TABLE dwd.fact_salary_detail (
    salary_detail_key BIGINT IDENTITY(1,1) PRIMARY KEY,		-- 自增主键
    batch_id BIGINT NOT NULL,
    employee_key INT NOT NULL,
    department_key INT NOT NULL,
    item_key INT NOT NULL,
    salary_month DATE NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    source_raw_id BIGINT NULL,		-- 回溯字段
    create_time DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
	-- 外键约束
    CONSTRAINT fk_fact_employee FOREIGN KEY (employee_key)
        REFERENCES dwd.dim_employee(employee_key),
    CONSTRAINT fk_fact_department FOREIGN KEY (department_key)
        REFERENCES dwd.dim_department(department_key),
    CONSTRAINT fk_fact_item FOREIGN KEY (item_key)
        REFERENCES dwd.dim_salary_item(item_key),
    CONSTRAINT ck_fact_amount CHECK (amount >= 0)
);

-- 唯一索引(保证 同一个批次、同一个员工、同一个月、同一个薪资项目，只能有一条记录)
CREATE UNIQUE INDEX ux_fact_salary_detail
ON dwd.fact_salary_detail(batch_id, employee_key, salary_month, item_key);

-- 薪资核算的汇总结果表
CREATE TABLE dwd.salary_calculation (
    calculation_id BIGINT IDENTITY(1,1) PRIMARY KEY,	--	自增主键
    batch_id BIGINT NOT NULL,
    employee_key INT NOT NULL,
    department_key INT NOT NULL,
    salary_month DATE NOT NULL,
    gross_salary DECIMAL(18,2) NOT NULL DEFAULT 0,			-- 应发工资
    deduction_total DECIMAL(18,2) NOT NULL DEFAULT 0,		-- 应扣合计
    net_salary AS (gross_salary - deduction_total) PERSISTED, -- 实发工资
    update_time DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT ck_gross_salary CHECK (gross_salary >= 0),
    CONSTRAINT ck_deduction_total CHECK (deduction_total >= 0),
    CONSTRAINT uq_salary_calculation
        UNIQUE(batch_id, employee_key, salary_month)
);