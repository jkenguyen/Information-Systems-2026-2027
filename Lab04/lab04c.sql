USE employees;

-- 1. Who have the same name as the managers of the "Finance" department?
CREATE OR REPLACE VIEW finance_managers AS
SELECT
    e.emp_no,
    e.first_name,
    e.last_name
FROM employees e
JOIN dept_manager dm
    ON e.emp_no = dm.emp_no
JOIN departments d
    ON dm.dept_no = d.dept_no
WHERE d.dept_name = 'Finance';

SELECT
    e.emp_no,
    e.first_name,
    e.last_name
FROM employees e
JOIN finance_managers fm
    ON e.last_name = fm.last_name
WHERE e.emp_no <> fm.emp_no;

-- 2. Who in the "Production" department were hired after the promotion
CREATE OR REPLACE VIEW production_employees AS
SELECT
    e.emp_no,
    e.first_name,
    e.last_name,
    e.hire_date
FROM employees e
JOIN dept_emp de
    ON e.emp_no = de.emp_no
JOIN departments d
    ON de.dept_no = d.dept_no
WHERE d.dept_name = 'Production';

CREATE OR REPLACE VIEW production_last_manager AS
SELECT MAX(dm.from_date) AS promotion_date
FROM dept_manager dm
JOIN departments d
    ON dm.dept_no = d.dept_no
WHERE d.dept_name = 'Production';

SELECT pe.*
FROM production_employees pe, production_last_manager plm
WHERE pe.hire_date > plm.promotion_date;

-- 3. Find the average salary of each department, from highest to lowest.
CREATE OR REPLACE VIEW dept_avg_salary AS
SELECT
    d.dept_name,
    AVG(s.salary) AS avg_salary
FROM departments d
JOIN dept_emp de
    ON d.dept_no = de.dept_no
JOIN salaries s
    ON de.emp_no = s.emp_no
GROUP BY d.dept_name;

SELECT * FROM dept_avg_salary
ORDER BY avg_salary DESC;

-- 4. Find the average salary for each type of Engineer, from highest to lowest.
CREATE OR REPLACE VIEW engineer_avg_salary AS
SELECT
    t.title,
    AVG(s.salary) AS avg_salary
FROM titles t
JOIN salaries s
    ON t.emp_no = s.emp_no
WHERE t.title LIKE '%Engineer%'
GROUP BY t.title;

SELECT * FROM engineer_avg_salary
ORDER BY avg_salary DESC;
