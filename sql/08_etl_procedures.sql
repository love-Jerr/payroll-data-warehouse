CREATE OR ALTER PROCEDURE etl.usp_load_salary_detail
    @batch_id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
		-- 清洗CTE(数据清洗，把ods层的脏数据转为干净数据)
        ;WITH cleaned AS (
            SELECT
                r.raw_id,
                r.batch_id,
                LTRIM(RTRIM(r.employee_no)) AS employee_no,
                TRY_CONVERT(DATE, r.salary_month) AS salary_month,
                LTRIM(RTRIM(r.item_code)) AS item_code,
                TRY_CONVERT(DECIMAL(18,2),
                    NULLIF(REPLACE(LTRIM(RTRIM(r.amount_text)), ',', ''), '')) AS amount,
                ROW_NUMBER() OVER (
                    PARTITION BY r.batch_id, r.employee_no,
                                 r.salary_month, r.item_code
                    ORDER BY r.raw_id
                ) AS rn
            FROM ods.salary_raw r
            WHERE r.batch_id = @batch_id
        )
		-- 插入事实表
        INSERT INTO dwd.fact_salary_detail
        (
            batch_id, employee_key, department_key, item_key,
            salary_month, amount, source_raw_id
        )
        SELECT
            c.batch_id,
            e.employee_key,
            e.department_key,
            i.item_key,
            c.salary_month,
            c.amount,
            c.raw_id
        FROM cleaned c
        INNER JOIN dwd.dim_employee e
            ON e.employee_no = c.employee_no
        INNER JOIN dwd.dim_salary_item i
            ON i.item_code = c.item_code
        WHERE c.rn = 1
          AND c.salary_month IS NOT NULL
          AND c.amount IS NOT NULL
          AND c.amount >= 0
          AND NOT EXISTS (
              SELECT 1
              FROM dwd.fact_salary_detail f
              WHERE f.batch_id = c.batch_id
                AND f.employee_key = e.employee_key
                AND f.salary_month = c.salary_month
                AND f.item_key = i.item_key
          );

        UPDATE etl.import_batch
        SET status = 'SUCCESS',
            end_time = SYSDATETIME()
        WHERE batch_id = @batch_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        UPDATE etl.import_batch
        SET status = 'FAILED',
            end_time = SYSDATETIME(),
            error_message = ERROR_MESSAGE()
        WHERE batch_id = @batch_id;

        THROW;
    END CATCH;
END;
GO
-- 拿一个批次号，从 ODS 层读原始薪资数据，清洗、去重、关联维度、过滤脏数据，插进事实表，然后更新批次状态。
-- 全程包在事务里，成功就提交，失败就回滚并记录错误