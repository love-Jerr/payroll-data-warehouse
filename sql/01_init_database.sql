-- 初始化薪资数据仓库，创建数据库及各分层
CREATE DATABASE SalaryDW;
GO

USE SalaryDW;
GO

CREATE SCHEMA ods;	  
GO

CREATE SCHEMA dwd;
GO

CREATE SCHEMA dws;
GO

CREATE SCHEMA etl;
GO

CREATE SCHEMA audit;
GO