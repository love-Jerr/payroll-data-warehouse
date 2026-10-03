-- 薪资项目字典数据
INSERT INTO dwd.dim_salary_item
(item_code, item_name, item_type, sign_value)
VALUES
('BASIC', N'基本工资', 'EARNING', 1),
('ALLOWANCE', N'岗位津贴', 'EARNING', 1),
('BONUS', N'绩效奖金', 'EARNING', 1),
('SOCIAL', N'社会保险', 'DEDUCTION', -1),
('FUND', N'住房公积金', 'DEDUCTION', -1),
('TAX', N'个人所得税', 'DEDUCTION', -1);