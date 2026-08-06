-- =====================================================================
-- HR ANALYTICS SQL PROJECT
-- 01_schema.sql
-- Creates the database, a raw staging table (mirrors the CSV exactly),
-- and a cleaned production table used for all downstream analysis.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS hr_analytics;
USE hr_analytics;

-- ---------------------------------------------------------------------
-- STAGING TABLE
-- Loads the CSV as-is (text columns for dates) so we can inspect and
-- clean the data with SQL before casting to proper types.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS stg_employees;
CREATE TABLE stg_employees (
    id              VARCHAR(20),
    first_name      VARCHAR(50),
    last_name       VARCHAR(50),
    birthdate       VARCHAR(20),
    gender          VARCHAR(20),
    race            VARCHAR(60),
    department      VARCHAR(60),
    jobtitle        VARCHAR(80),
    location        VARCHAR(20),
    hire_date       VARCHAR(20),
    termdate        VARCHAR(40),
    location_city   VARCHAR(60),
    location_state  VARCHAR(60)
);

-- ---------------------------------------------------------------------
-- PRODUCTION TABLE
-- Typed, cleaned, and ready for KPI queries and BI tools (Power BI/Tableau).
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    employee_id     VARCHAR(20)   PRIMARY KEY,
    first_name      VARCHAR(50),
    last_name       VARCHAR(50),
    birthdate       DATE,
    gender          VARCHAR(20),
    race            VARCHAR(60),
    department      VARCHAR(60),
    jobtitle        VARCHAR(80),
    work_location   VARCHAR(20),
    hire_date       DATE,
    termdate        DATE          NULL,
    is_active       TINYINT(1)    NOT NULL DEFAULT 1,
    location_city   VARCHAR(60),
    location_state  VARCHAR(60),
    age             INT,
    tenure_years    DECIMAL(5,2)
);

CREATE INDEX idx_emp_department ON employees(department);
CREATE INDEX idx_emp_active     ON employees(is_active);
CREATE INDEX idx_emp_hiredate   ON employees(hire_date);
