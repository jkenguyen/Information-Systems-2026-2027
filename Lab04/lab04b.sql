USE employees;

-- 1. Who have the same name as the managers of the "Finance" department?
--    (same last name, not counting the managers themselves)
SELECT
    emp_no,
    first_name,
    last_name
FROM employees
WHERE last_name IN (
    SELECT last_name
    FROM employees
    WHERE emp_no IN (
        SELECT emp_no
        FROM dept_manager
        WHERE dept_no = (
            SELECT dept_no
            FROM departments
            WHERE dept_name = 'Finance'
        )
    )
)
    AND emp_no NOT IN (
        SELECT emp_no
        FROM dept_manager
        WHERE dept_no = (
            SELECT dept_no
            FROM departments
            WHERE dept_name = 'Finance'
        )
    );

-- 2. Who in the "Production" department were hired after the promotion
--    of the last manager in that department?
--    (last manager = the one with the latest from_date in dept_manager)
SELECT
    emp_no,
    first_name,
    last_name,
    hire_date
FROM employees
WHERE emp_no IN (
    SELECT emp_no
    FROM dept_emp
    WHERE dept_no = (
        SELECT dept_no
        FROM departments
        WHERE dept_name = 'Production'
    )
)
    AND hire_date > (
        SELECT MAX(from_date)
        FROM dept_manager
        WHERE dept_no = (
            SELECT dept_no
            FROM departments
            WHERE dept_name = 'Production'
        )
    );

-- 3. Find the average salary of each department, from highest to lowest.
SELECT
    dept_name,
    avg_salary
FROM (
    SELECT
        d.dept_name,
        AVG(s.salary) AS avg_salary
    FROM departments d
    JOIN dept_emp de
        ON d.dept_no = de.dept_no
    JOIN salaries s
        ON de.emp_no = s.emp_no
    GROUP BY d.dept_name
) AS dept_avg
ORDER BY avg_salary DESC;

-- 4. Find the average salary for each type of Engineer, from highest to lowest.
SELECT
    title,
    avg_salary
FROM (
    SELECT
        t.title,
        AVG(s.salary) AS avg_salary
    FROM titles t
    JOIN salaries s
        ON t.emp_no = s.emp_no
    WHERE t.title LIKE '%Engineer%'
    GROUP BY t.title
) AS engineer_avg
ORDER BY avg_salary DESC;
