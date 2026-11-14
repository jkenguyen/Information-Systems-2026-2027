USE employees;

-- 1. All info of all employees
SELECT * FROM employees;

-- 2. All info of all departments
SELECT * FROM departments;

-- 3. Full names of all employees
SELECT
    first_name,
    last_name
FROM employees;

-- 4. Names of all departments
SELECT dept_name FROM departments;

-- 5. Full names of employees working in "Sales" department
SELECT
    e.first_name,
    e.last_name
FROM employees e
JOIN dept_emp de
    ON e.emp_no = de.emp_no
JOIN departments d
    ON de.dept_no = d.dept_no
WHERE d.dept_name = 'Sales';

-- 6. Full names of male employees working in "Finance" department
SELECT
    e.first_name,
    e.last_name
FROM employees e
JOIN dept_emp de
    ON e.emp_no = de.emp_no
JOIN departments d
    ON de.dept_no = d.dept_no
WHERE d.dept_name = 'Finance'
    AND e.gender = 'M';

-- 7. Salaries of female employees working in "Marketing" department
SELECT
    e.first_name,
    e.last_name,
    s.salary
FROM employees e
JOIN dept_emp de
    ON e.emp_no = de.emp_no
JOIN departments d
    ON de.dept_no = d.dept_no
JOIN salaries s
    ON e.emp_no = s.emp_no
WHERE d.dept_name = 'Marketing'
    AND e.gender = 'F';

-- 8. Full names of employees who have the same last name as their manager
SELECT DISTINCT
    e.first_name,
    e.last_name
FROM employees e
JOIN dept_emp de
    ON e.emp_no = de.emp_no
JOIN dept_manager dm
    ON de.dept_no = dm.dept_no
JOIN employees m
    ON dm.emp_no = m.emp_no
WHERE e.last_name = m.last_name
    AND e.emp_no <> m.emp_no;

-- 9. Full names of managers who have been doing the job at least twice
SELECT
    e.first_name,
    e.last_name
FROM employees e
JOIN dept_manager dm
    ON e.emp_no = dm.emp_no
GROUP BY e.emp_no, e.first_name, e.last_name
HAVING COUNT(*) >= 2;

-- 10. Full names of employees who were paid more than $100000
SELECT DISTINCT
    e.first_name,
    e.last_name
FROM employees e
JOIN salaries s
    ON e.emp_no = s.emp_no
WHERE s.salary > 100000;

-- 11. Names of all departments that have employees paid more than $100000
SELECT DISTINCT
    d.dept_name
FROM departments d
JOIN dept_emp de
    ON d.dept_no = de.dept_no
JOIN salaries s
    ON de.emp_no = s.emp_no
WHERE s.salary > 100000;

-- Department changes
INSERT INTO departments VALUES ('d010', 'Research and Development');
INSERT INTO departments VALUES ('d011', 'Marketing and Sales');

-- Move employees and managers to the new departments
UPDATE IGNORE dept_emp     SET dept_no = 'd010' WHERE dept_no IN ('d005', 'd008');
UPDATE IGNORE dept_emp     SET dept_no = 'd011' WHERE dept_no IN ('d001', 'd007');
UPDATE IGNORE dept_manager SET dept_no = 'd010' WHERE dept_no IN ('d005', 'd008');
UPDATE IGNORE dept_manager SET dept_no = 'd011' WHERE dept_no IN ('d001', 'd007');

-- Delete the old departments
DELETE FROM departments WHERE dept_no IN ('d001', 'd005', 'd007', 'd008');
