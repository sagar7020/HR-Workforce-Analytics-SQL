-- =====================================================================
-- 02_load_data.sql
-- Loads employees_raw.csv into the staging table.
--
-- NOTE: LOAD DATA INFILE requires the file to be readable by the MySQL
-- server and (usually) sits under secure_file_priv. Two options below —
-- use whichever matches your setup.
-- =====================================================================

USE hr_analytics;

-- Check where your server allows file loads from:
-- SHOW VARIABLES LIKE 'secure_file_priv';

-- OPTION A: server-side load (fast, file must be on the MySQL server /
-- inside secure_file_priv directory). Copy employees_raw.csv there first.
LOAD DATA INFILE '/var/lib/mysql-files/employees_raw.csv'
INTO TABLE stg_employees
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, first_name, last_name, birthdate, gender, race, department,
 jobtitle, location, hire_date, termdate, location_city, location_state);

-- OPTION B: client-side load (works from any machine via CLI / Workbench;
-- requires --local-infile=1 on the client and local_infile=ON on the server).
-- LOAD DATA LOCAL INFILE '/home/claude/hr-project/employees_raw.csv'
-- INTO TABLE stg_employees
-- CHARACTER SET utf8mb4
-- FIELDS TERMINATED BY ','
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (id, first_name, last_name, birthdate, gender, race, department,
--  jobtitle, location, hire_date, termdate, location_city, location_state);

SELECT COUNT(*) AS rows_loaded FROM stg_employees;
