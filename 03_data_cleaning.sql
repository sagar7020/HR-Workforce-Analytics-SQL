-- =====================================================================
-- 03_data_cleaning.sql
-- Transforms stg_employees (raw text) into the typed, analysis-ready
-- employees table. Documents every data-quality issue found and fixed.
-- =====================================================================

USE hr_analytics;

-- ---------------------------------------------------------------------
-- ISSUE 1: ~1,000 termdate values are in the FUTURE (up to year 2041).
-- A termination date in the future is not valid -- these employees are
-- actually still active. We null out termdate for any date > today.
--
-- ISSUE 2: Two job titles have typos that fragment what should be a
-- single job title: 'Data Coordiator' -> 'Data Coordinator',
-- 'Relationshiop Manager' -> 'Relationship Manager'.
--
-- ISSUE 3: Dates arrive as text in M/D/YYYY format (hire_date,
-- birthdate) or 'YYYY-MM-DD HH:MM:SS UTC' (termdate) and need casting.
--
-- ISSUE 4: Blank rows at the end of the source file are excluded by
-- only selecting rows with a non-null id (handled at load time).
-- ---------------------------------------------------------------------

INSERT INTO employees (
    employee_id, first_name, last_name, birthdate, gender, race,
    department, jobtitle, work_location, hire_date, termdate,
    is_active, location_city, location_state, age, tenure_years
)
SELECT
    TRIM(id),
    TRIM(first_name),
    TRIM(last_name),
    STR_TO_DATE(TRIM(birthdate), '%m/%d/%Y')                      AS birthdate,
    TRIM(gender),
    TRIM(race),
    TRIM(department),
    CASE TRIM(jobtitle)
        WHEN 'Data Coordiator'        THEN 'Data Coordinator'
        WHEN 'Relationshiop Manager'  THEN 'Relationship Manager'
        ELSE TRIM(jobtitle)
    END                                                            AS jobtitle,
    TRIM(location)                                                 AS work_location,
    STR_TO_DATE(TRIM(hire_date), '%m/%d/%Y')                       AS hire_date,
    CASE
        WHEN termdate IS NULL OR TRIM(termdate) = '' THEN NULL
        WHEN STR_TO_DATE(LEFT(TRIM(termdate), 10), '%Y-%m-%d') > CURDATE() THEN NULL  -- future date = bad data
        ELSE STR_TO_DATE(LEFT(TRIM(termdate), 10), '%Y-%m-%d')
    END                                                             AS termdate,
    CASE
        WHEN termdate IS NULL OR TRIM(termdate) = '' THEN 1
        WHEN STR_TO_DATE(LEFT(TRIM(termdate), 10), '%Y-%m-%d') > CURDATE() THEN 1     -- treat as still active
        ELSE 0
    END                                                             AS is_active,
    TRIM(location_city),
    TRIM(location_state),
    TIMESTAMPDIFF(YEAR, STR_TO_DATE(TRIM(birthdate), '%m/%d/%Y'), CURDATE())          AS age,
    ROUND(
        TIMESTAMPDIFF(
            DAY,
            STR_TO_DATE(TRIM(hire_date), '%m/%d/%Y'),
            LEAST(
                COALESCE(
                    CASE
                        WHEN termdate IS NOT NULL AND TRIM(termdate) <> ''
                             AND STR_TO_DATE(LEFT(TRIM(termdate), 10), '%Y-%m-%d') <= CURDATE()
                        THEN STR_TO_DATE(LEFT(TRIM(termdate), 10), '%Y-%m-%d')
                    END,
                    CURDATE()
                ),
                CURDATE()
            )
        ) / 365.25, 2)                                              AS tenure_years
FROM stg_employees
WHERE id IS NOT NULL AND TRIM(id) <> '';

-- ---------------------------------------------------------------------
-- Validation checks
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS total_employees FROM employees;
SELECT COUNT(*) AS still_future_termdates FROM employees WHERE termdate > CURDATE();   -- expect 0
SELECT COUNT(*) AS null_dates FROM employees WHERE birthdate IS NULL OR hire_date IS NULL; -- expect 0
SELECT jobtitle, COUNT(*) FROM employees WHERE jobtitle LIKE '%Coordiator%' OR jobtitle LIKE '%Relationshiop%' GROUP BY jobtitle; -- expect 0 rows
