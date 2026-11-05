BEGIN EXECUTE IMMEDIATE 'DROP TABLE JOB_HISTORY CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE EMPLOYEES CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE DEPARTMENTS CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE JOBS CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE LOCATIONS CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE COUNTRIES CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE REGIONS CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE TABLE regions AS SELECT * FROM hr.regions;
CREATE TABLE countries AS SELECT * FROM hr.countries;
CREATE TABLE locations AS SELECT * FROM hr.locations;
CREATE TABLE departments AS SELECT * FROM hr.departments;
CREATE TABLE jobs AS SELECT * FROM hr.jobs;
CREATE TABLE employees AS SELECT * FROM hr.employees;
CREATE TABLE job_history AS SELECT * FROM hr.job_history;
CREATE TABLE job_grades AS SELECT * FROM hr.job_grades;
CREATE TABLE products AS SELECT * FROM hr.products;
CREATE TABLE sales AS SELECT * FROM hr.sales;

ALTER TABLE regions ADD PRIMARY KEY (region_id);
ALTER TABLE countries ADD PRIMARY KEY (country_id);
ALTER TABLE locations ADD PRIMARY KEY (location_id);
ALTER TABLE departments ADD PRIMARY KEY (department_id);
ALTER TABLE jobs ADD PRIMARY KEY (job_id);
ALTER TABLE employees ADD PRIMARY KEY (employee_id);
ALTER TABLE job_history ADD CONSTRAINT pk_job_history PRIMARY KEY (employee_id, start_date);
ALTER TABLE job_grades ADD PRIMARY KEY (grade);
ALTER TABLE products ADD PRIMARY KEY (product_id);
ALTER TABLE sales ADD PRIMARY KEY (sale_id);

ALTER TABLE countries ADD CONSTRAINT fk_countries_regions FOREIGN KEY (region_id) REFERENCES regions(region_id);
ALTER TABLE locations ADD CONSTRAINT fk_locations_countries FOREIGN KEY (country_id) REFERENCES countries(country_id);
ALTER TABLE departments ADD CONSTRAINT fk_departments_locations FOREIGN KEY (location_id) REFERENCES locations(location_id);

ALTER TABLE employees ADD CONSTRAINT fk_employees_jobs FOREIGN KEY (job_id) REFERENCES jobs(job_id);
ALTER TABLE employees ADD CONSTRAINT fk_employees_departments FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE employees ADD CONSTRAINT fk_employees_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

ALTER TABLE departments ADD CONSTRAINT fk_departments_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

ALTER TABLE job_history ADD CONSTRAINT fk_jh_employees FOREIGN KEY (employee_id) REFERENCES employees(employee_id);
ALTER TABLE job_history ADD CONSTRAINT fk_jh_jobs FOREIGN KEY (job_id) REFERENCES jobs(job_id);
ALTER TABLE job_history ADD CONSTRAINT fk_jh_departments FOREIGN KEY (department_id) REFERENCES departments(department_id);

ALTER TABLE sales ADD CONSTRAINT fk_sales_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id);
ALTER TABLE sales ADD CONSTRAINT fk_sales_product FOREIGN KEY (product_id) REFERENCES products(product_id);


SELECT last_name || ' - ' || salary AS wynagrodzenie
FROM employees
WHERE department_id IN (20, 50) 
  AND salary BETWEEN 2000 AND 7000
ORDER BY last_name;

SELECT hire_date, last_name, &nazwa_kolumny
FROM employees
WHERE manager_id IS NOT NULL 
  AND EXTRACT(YEAR FROM hire_date) = 2005
ORDER BY &nazwa_kolumny;

SELECT first_name || ' ' || last_name AS imie_nazwisko, salary, phone_number
FROM employees
WHERE last_name LIKE '__e%' 
  AND first_name LIKE '%' || '&czesc_imienia' || '%'
ORDER BY 1 DESC, 2 ASC;

SELECT first_name, 
       last_name, 
       ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) AS liczba_miesiecy,
       CASE 
           WHEN ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) <= 150 THEN salary * 0.10
           WHEN ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) BETWEEN 151 AND 200 THEN salary * 0.20
           ELSE salary * 0.30 
       END AS wysokosc_dodatku
FROM employees
ORDER BY liczba_miesiecy;

SELECT department_id, 
       SUM(salary) AS suma_zarobkow, 
       ROUND(AVG(salary)) AS srednia_zarobkow
FROM employees
GROUP BY department_id
HAVING MIN(salary) > 5000;

SELECT e.last_name, 
       e.department_id, 
       d.department_name, 
       e.job_id
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id
WHERE UPPER(l.city) = 'TORONTO';

SELECT j.first_name || ' ' || j.last_name AS jennifer, 
       c.first_name || ' ' || c.last_name AS wspolpracownik
FROM employees j
JOIN employees c ON j.department_id = c.department_id
WHERE j.first_name = 'Jennifer' 
  AND j.employee_id != c.employee_id;

SELECT d.department_id, d.department_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;

SELECT e.first_name, 
       e.last_name, 
       e.job_id, 
       d.department_name, 
       e.salary, 
       jg.grade AS grade
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN job_grades jg ON e.salary BETWEEN jg.min_salary AND jg.max_salary;

SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

SELECT employee_id, first_name, last_name
FROM employees
WHERE department_id IN (
    SELECT DISTINCT department_id 
    FROM employees 
    WHERE LOWER(last_name) LIKE '%u%' AND department_id IS NOT NULL
);

SELECT first_name, last_name, hire_date
FROM employees
WHERE MONTHS_BETWEEN(SYSDATE, hire_date) > (
    SELECT AVG(MONTHS_BETWEEN(SYSDATE, hire_date)) FROM employees
);

SELECT d.department_name, 
       COUNT(e.employee_id) AS liczba_pracownikow, 
       ROUND(AVG(e.salary), 2) AS srednia_pensja
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY liczba_pracownikow DESC;

SELECT first_name, last_name, salary
FROM employees
WHERE salary < ANY (
    SELECT e.salary 
    FROM employees e 
    JOIN departments d ON e.department_id = d.department_id 
    WHERE d.department_name = 'IT'
);

-- Zadanie 15
SELECT DISTINCT d.department_id, d.department_name
FROM departments d
JOIN employees e ON d.department_id = e.department_id
WHERE e.salary > (SELECT AVG(salary) FROM employees);

SELECT job_title, srednie_zarobki
FROM (
    SELECT j.job_title, ROUND(AVG(e.salary), 2) AS srednie_zarobki
    FROM jobs j
    JOIN employees e ON j.job_id = e.job_id
    GROUP BY j.job_title
    ORDER BY srednie_zarobki DESC
)
WHERE ROWNUM <= 5;

SELECT r.region_name, 
       COUNT(DISTINCT c.country_id) AS liczba_krajow, 
       COUNT(DISTINCT e.employee_id) AS liczba_pracownikow
FROM regions r
LEFT JOIN countries c ON r.region_id = c.region_id
LEFT JOIN locations l ON c.country_id = l.country_id
LEFT JOIN departments d ON l.location_id = d.location_id
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY r.region_name;

SELECT e.first_name, e.last_name
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;

SELECT EXTRACT(MONTH FROM hire_date) AS miesiac, 
       COUNT(*) AS liczba_pracownikow
FROM employees
GROUP BY EXTRACT(MONTH FROM hire_date)
ORDER BY miesiac;

SELECT department_name, srednie_zarobki
FROM (
    SELECT d.department_name, ROUND(AVG(e.salary), 2) AS srednie_zarobki
    FROM departments d
    JOIN employees e ON d.department_id = e.department_id
    GROUP BY d.department_name
    ORDER BY srednie_zarobki DESC
)
WHERE ROWNUM <= 3;