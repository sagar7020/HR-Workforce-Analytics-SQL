-- =====================================================================
-- 04_analysis_queries.sql
-- HR Analytics KPI library. Mirrors the kind of measures typically
-- built in Power BI (headcount, attrition, tenure, diversity) but
-- implemented natively in SQL.
-- =====================================================================

USE hr_analytics;

-- ---------------------------------------------------------------------
-- 1. Headcount overview
-- ---------------------------------------------------------------------
SELECT
    COUNT(*)                                   AS total_employees,
    SUM(is_active)                              AS active_employees,
    SUM(1 - is_active)                          AS terminated_employees,
    ROUND(SUM(1 - is_active) / COUNT(*) * 100, 2) AS overall_attrition_rate_pct
FROM employees;

-- ---------------------------------------------------------------------
-- 2. Headcount and attrition rate by department
-- ---------------------------------------------------------------------
SELECT
    department,
    COUNT(*)                                      AS total_headcount,
    SUM(is_active)                                 AS active_headcount,
    SUM(1 - is_active)                             AS terminated_headcount,
    ROUND(SUM(1 - is_active) / COUNT(*) * 100, 2)  AS attrition_rate_pct
FROM employees
GROUP BY department
ORDER BY attrition_rate_pct DESC;

-- ---------------------------------------------------------------------
-- 3. Attrition trend by year (terminations per year)
-- ---------------------------------------------------------------------
SELECT
    YEAR(termdate)      AS term_year,
    COUNT(*)            AS terminations
FROM employees
WHERE termdate IS NOT NULL
GROUP BY YEAR(termdate)
ORDER BY term_year;

-- ---------------------------------------------------------------------
-- 4. Hiring trend by year
-- ---------------------------------------------------------------------
SELECT
    YEAR(hire_date)     AS hire_year,
    COUNT(*)            AS hires
FROM employees
GROUP BY YEAR(hire_date)
ORDER BY hire_year;

-- ---------------------------------------------------------------------
-- 5. Average tenure by department (active employees only)
-- ---------------------------------------------------------------------
SELECT
    department,
    ROUND(AVG(tenure_years), 2) AS avg_tenure_years,
    COUNT(*)                    AS active_employees
FROM employees
WHERE is_active = 1
GROUP BY department
ORDER BY avg_tenure_years DESC;

-- ---------------------------------------------------------------------
-- 6. Gender distribution overall and by department
-- ---------------------------------------------------------------------
SELECT gender, COUNT(*) AS headcount,
       ROUND(COUNT(*) / (SELECT COUNT(*) FROM employees) * 100, 2) AS pct_of_workforce
FROM employees
GROUP BY gender;

SELECT department, gender, COUNT(*) AS headcount
FROM employees
GROUP BY department, gender
ORDER BY department, gender;

-- ---------------------------------------------------------------------
-- 7. Race/ethnicity diversity breakdown
-- ---------------------------------------------------------------------
SELECT race, COUNT(*) AS headcount,
       ROUND(COUNT(*) / (SELECT COUNT(*) FROM employees) * 100, 2) AS pct_of_workforce
FROM employees
GROUP BY race
ORDER BY headcount DESC;

-- ---------------------------------------------------------------------
-- 8. Age distribution by generation
-- ---------------------------------------------------------------------
SELECT
    CASE
        WHEN age BETWEEN 18 AND 27 THEN 'Gen Z (18-27)'
        WHEN age BETWEEN 28 AND 43 THEN 'Millennial (28-43)'
        WHEN age BETWEEN 44 AND 59 THEN 'Gen X (44-59)'
        WHEN age >= 60              THEN 'Boomer (60+)'
        ELSE 'Unknown'
    END                          AS generation,
    COUNT(*)                     AS headcount,
    ROUND(AVG(tenure_years), 2)  AS avg_tenure_years
FROM employees
GROUP BY generation
ORDER BY headcount DESC;

-- ---------------------------------------------------------------------
-- 9. Remote vs Headquarters headcount and attrition
-- ---------------------------------------------------------------------
SELECT
    work_location,
    COUNT(*)                                       AS headcount,
    ROUND(SUM(1 - is_active) / COUNT(*) * 100, 2)   AS attrition_rate_pct
FROM employees
GROUP BY work_location;

-- ---------------------------------------------------------------------
-- 10. Top 10 job titles by headcount
-- ---------------------------------------------------------------------
SELECT jobtitle, COUNT(*) AS headcount
FROM employees
GROUP BY jobtitle
ORDER BY headcount DESC
LIMIT 10;

-- ---------------------------------------------------------------------
-- 11. Headcount by state (geographic spread)
-- ---------------------------------------------------------------------
SELECT location_state, COUNT(*) AS headcount
FROM employees
GROUP BY location_state
ORDER BY headcount DESC;

-- ---------------------------------------------------------------------
-- 12. Early attrition: employees who left within their first year
-- ---------------------------------------------------------------------
SELECT
    department,
    COUNT(*) AS early_leavers
FROM employees
WHERE is_active = 0
  AND TIMESTAMPDIFF(MONTH, hire_date, termdate) <= 12
GROUP BY department
ORDER BY early_leavers DESC;

-- ---------------------------------------------------------------------
-- 13. Departments with highest tenure vs. highest attrition
--     (a "retention risk" view worth building into a dashboard)
-- ---------------------------------------------------------------------
SELECT
    department,
    ROUND(AVG(tenure_years), 2)                    AS avg_tenure_years,
    ROUND(SUM(1 - is_active) / COUNT(*) * 100, 2)  AS attrition_rate_pct,
    COUNT(*)                                       AS total_headcount
FROM employees
GROUP BY department
ORDER BY attrition_rate_pct DESC, avg_tenure_years ASC;
