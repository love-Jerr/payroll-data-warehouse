-- 创建四张维度表（部门、员工、薪资项目、时间）

-- 部门维度
CREATE TABLE dwd.dim_department (
    department_key INT IDENTITY(1,1) PRIMARY KEY,	-- 自增主键
    department_no  NVARCHAR(30) NOT NULL UNIQUE,	-- 部门业务编号
    department_name NVARCHAR(100) NOT NULL,			-- 部门名称
    parent_department_no NVARCHAR(30) NULL,			-- 上级部门编号
    is_active BIT NOT NULL DEFAULT 1,				-- 是否有效
    create_time DATETIME2 NOT NULL DEFAULT SYSDATETIME(),  -- 创建时间(自动填当前时间)
    update_time DATETIME2 NOT NULL DEFAULT SYSDATETIME()   -- 更新时间
);

-- 员工维度
CREATE TABLE dwd.dim_employee (
    employee_key INT IDENTITY(1,1) PRIMARY KEY,
    employee_no NVARCHAR(30) NOT NULL UNIQUE,
    employee_name NVARCHAR(100) NOT NULL,
    department_key INT NOT NULL,		-- 所属部门外键
    job_title NVARCHAR(100) NULL,		-- 岗位/职称
    entry_date DATE NULL,
    employee_status VARCHAR(20) NOT NULL DEFAULT '在职',
    CONSTRAINT fk_employee_department	-- 外键约束
        FOREIGN KEY (department_key)
        REFERENCES dwd.dim_department(department_key)
);

-- 薪资项目维度
CREATE TABLE dwd.dim_salary_item (
    item_key INT IDENTITY(1,1) PRIMARY KEY,
    item_code NVARCHAR(30) NOT NULL UNIQUE,		-- 薪资项目编号
    item_name NVARCHAR(100) NOT NULL,
    item_type VARCHAR(20) NOT NULL,
    sign_value SMALLINT NOT NULL,		-- 正负号(增项为1，减项为-1)
    is_active BIT NOT NULL DEFAULT 1,
    CONSTRAINT ck_item_type CHECK (item_type IN ('EARNING','DEDUCTION')),	-- 约束
    CONSTRAINT ck_sign_value CHECK (sign_value IN (1,-1))		-- 约束
);

