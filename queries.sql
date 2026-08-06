-- =====================================================================
-- HR ANALYTICS SQL PROJECT
-- Simple, single-file version: create table, load data, run queries.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS hr_analytics;
USE hr_analytics;

-- ---------------------------------------------------------------------
-- 1. CREATE TABLE
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    id              VARCHAR(20) PRIMARY KEY,
    first_name      VARCHAR(50),
    last_name       VARCHAR(50),
    birthdate       DATE,
    gender          VARCHAR(20),
    race            VARCHAR(60),
    department      VARCHAR(60),
    jobtitle        VARCHAR(80),
    location        VARCHAR(20),
    hire_date       DATE,
    termdate        DATE,
    location_city   VARCHAR(60),
    location_state  VARCHAR(60)
);

-- ---------------------------------------------------------------------
-- 2. LOAD DATA
-- Update the file path to wherever employees.csv sits on your machine.
-- Dates in the CSV are M/D/YYYY, so we load into a staging table first
-- and cast them, since LOAD DATA can't parse that format directly.
-- ---------------------------------------------------------------------
CREATE TABLE stg_employees LIKE employees;
ALTER TABLE stg_employees
    MODIFY birthdate VARCHAR(20),
    MODIFY hire_date VARCHAR(20),
    MODIFY termdate  VARCHAR(20);

LOAD DATA LOCAL INFILE 'employees.csv'
INTO TABLE stg_employees
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, first_name, last_name, birthdate, gender, race, department,
 jobtitle, location, hire_date, termdate, location_city, location_state);

INSERT INTO employees
SELECT
    id, first_name, last_name,
    STR_TO_DATE(birthdate, '%m/%d/%Y'),
    gender, race, department, jobtitle, location,
    STR_TO_DATE(hire_date, '%m/%d/%Y'),
    STR_TO_DATE(LEFT(termdate, 10), '%Y-%m-%d'),
    location_city, location_state
FROM stg_employees
WHERE id IS NOT NULL AND id <> '';

-- Some termdates in the file are future dates (data errors) -- treat
-- those employees as still active.
UPDATE employees
SET termdate = NULL
WHERE termdate > CURDATE();

-- ---------------------------------------------------------------------
-- 3. QUERIES
-- ---------------------------------------------------------------------

-- Total headcount, active vs terminated
SELECT
    COUNT(*) AS total_employees,
    SUM(CASE WHEN termdate IS NULL THEN 1 ELSE 0 END) AS active_employees,
    SUM(CASE WHEN termdate IS NOT NULL THEN 1 ELSE 0 END) AS terminated_employees
FROM employees;

-- Headcount by department
SELECT department, COUNT(*) AS headcount
FROM employees
GROUP BY department
ORDER BY headcount DESC;

-- Attrition rate by department
SELECT
    department,
    COUNT(*) AS total,
    SUM(CASE WHEN termdate IS NOT NULL THEN 1 ELSE 0 END) AS terminated,
    ROUND(SUM(CASE WHEN termdate IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS attrition_rate_pct
FROM employees
GROUP BY department
ORDER BY attrition_rate_pct DESC;

-- Headcount by gender
SELECT gender, COUNT(*) AS headcount
FROM employees
GROUP BY gender;

-- Headcount by race
SELECT race, COUNT(*) AS headcount
FROM employees
GROUP BY race
ORDER BY headcount DESC;

-- New hires by year
SELECT YEAR(hire_date) AS hire_year, COUNT(*) AS new_hires
FROM employees
GROUP BY YEAR(hire_date)
ORDER BY hire_year;

-- Terminations by year
SELECT YEAR(termdate) AS term_year, COUNT(*) AS terminations
FROM employees
WHERE termdate IS NOT NULL
GROUP BY YEAR(termdate)
ORDER BY term_year;

-- Average tenure (in years) for active employees
SELECT
    department,
    ROUND(AVG(TIMESTAMPDIFF(DAY, hire_date, CURDATE()) / 365.25), 2) AS avg_tenure_years
FROM employees
WHERE termdate IS NULL
GROUP BY department
ORDER BY avg_tenure_years DESC;

-- Top 10 job titles by headcount
SELECT jobtitle, COUNT(*) AS headcount
FROM employees
GROUP BY jobtitle
ORDER BY headcount DESC
LIMIT 10;

-- Headcount by work location (Remote vs Headquarters)
SELECT location, COUNT(*) AS headcount
FROM employees
GROUP BY location;

-- Headcount by state
SELECT location_state, COUNT(*) AS headcount
FROM employees
GROUP BY location_state
ORDER BY headcount DESC;
