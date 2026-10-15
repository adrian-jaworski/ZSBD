CREATE TABLE REGIONS (
    region_id NUMBER PRIMARY KEY,
    region_name VARCHAR2(50)
);

CREATE TABLE COUNTRIES (
    country_id CHAR(2) PRIMARY KEY,
    country_name VARCHAR2(50)
);

CREATE TABLE LOCATIONS (
    location_id NUMBER PRIMARY KEY,
    street_address VARCHAR2(100),
    postal_code VARCHAR2(20),
    city VARCHAR2(50),
    state_province VARCHAR2(50)
);

CREATE TABLE DEPARTMENTS (
    department_id NUMBER PRIMARY KEY,
    department_name VARCHAR2(50) NOT NULL,
    location_id NUMBER
);

CREATE TABLE JOBS (
    job_id VARCHAR2(10) PRIMARY KEY,
    job_title VARCHAR2(50) NOT NULL,
    min_salary NUMBER
);

CREATE TABLE EMPLOYEES (
    employee_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(50) UNIQUE NOT NULL,
    phone_number VARCHAR2(20),
    hire_date DATE NOT NULL,
    salary NUMBER,
    commission_pct NUMBER
);

CREATE TABLE JOB_HISTORY (
    employee_id NUMBER,
    start_date DATE,
    end_date DATE,
    job_id VARCHAR2(10),
    department_id NUMBER,
    PRIMARY KEY (employee_id, start_date)
);

ALTER TABLE COUNTRIES ADD region_id NUMBER;
ALTER TABLE COUNTRIES ADD CONSTRAINT fk_countr_reg FOREIGN KEY (region_id) REFERENCES REGIONS(region_id);

ALTER TABLE LOCATIONS ADD country_id CHAR(2);
ALTER TABLE LOCATIONS ADD CONSTRAINT fk_loc_countr FOREIGN KEY (country_id) REFERENCES COUNTRIES(country_id);

ALTER TABLE DEPARTMENTS ADD manager_id NUMBER;
ALTER TABLE DEPARTMENTS ADD CONSTRAINT fk_dept_loc FOREIGN KEY (location_id) REFERENCES LOCATIONS(location_id);

ALTER TABLE JOBS ADD max_salary NUMBER;
ALTER TABLE JOBS ADD CONSTRAINT chk_salary_diff CHECK (max_salary - min_salary >= 2000);

ALTER TABLE EMPLOYEES ADD job_id VARCHAR2(10);
ALTER TABLE EMPLOYEES ADD manager_id NUMBER;
ALTER TABLE EMPLOYEES ADD department_id NUMBER;

ALTER TABLE EMPLOYEES ADD CONSTRAINT fk_emp_job FOREIGN KEY (job_id) REFERENCES JOBS(job_id) ON DELETE SET NULL;
ALTER TABLE EMPLOYEES ADD CONSTRAINT fk_emp_mgr FOREIGN KEY (manager_id) REFERENCES EMPLOYEES(employee_id) ON DELETE SET NULL;
ALTER TABLE EMPLOYEES ADD CONSTRAINT fk_emp_dept FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id) ON DELETE SET NULL;

ALTER TABLE DEPARTMENTS ADD CONSTRAINT fk_dept_mgr FOREIGN KEY (manager_id) REFERENCES EMPLOYEES(employee_id) ON DELETE SET NULL;

ALTER TABLE JOB_HISTORY ADD CONSTRAINT fk_jh_emp FOREIGN KEY (employee_id) REFERENCES EMPLOYEES(employee_id);
ALTER TABLE JOB_HISTORY ADD CONSTRAINT fk_jh_job FOREIGN KEY (job_id) REFERENCES JOBS(job_id);
ALTER TABLE JOB_HISTORY ADD CONSTRAINT fk_jh_dept FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id);

INSERT INTO REGIONS VALUES (1, 'Europe');
INSERT INTO COUNTRIES VALUES ('PL', 'Poland', 1);
INSERT INTO LOCATIONS VALUES (1000, 'Wiejska 1', '00-001', 'Warsaw', 'Mazowieckie', 'PL');
INSERT INTO DEPARTMENTS (department_id, department_name, location_id, manager_id) VALUES (60, 'IT', 1000, NULL);
INSERT INTO DEPARTMENTS (department_id, department_name, location_id, manager_id) VALUES (90, 'Executive', 1000, NULL);

INSERT INTO JOBS (job_id, job_title, min_salary, max_salary) VALUES ('IT_PROG', 'Programmer', 4000, 10000);
INSERT INTO JOBS (job_id, job_title, min_salary, max_salary) VALUES ('SA_MAN', 'Sales Manager', 10000, 20000);
INSERT INTO JOBS (job_id, job_title, min_salary, max_salary) VALUES ('ST_CLERK', 'Stock Clerk', 2000, 5000);
INSERT INTO JOBS (job_id, job_title, min_salary, max_salary) VALUES ('AD_PRES', 'President', 20000, 40000);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, salary, commission_pct, job_id, manager_id, department_id) 
VALUES (1, 'Steven', 'King', 'SKING', '515.123.4567', TO_DATE('2003-06-17', 'YYYY-MM-DD'), 24000, NULL, 'AD_PRES', NULL, 90);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, salary, commission_pct, job_id, manager_id, department_id) 
VALUES (2, 'Neena', 'Kochhar', 'NKOCHHAR', '515.123.4568', TO_DATE('2005-09-21', 'YYYY-MM-DD'), 17000, NULL, 'IT_PROG', NULL, 60);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, salary, commission_pct, job_id, manager_id, department_id) 
VALUES (3, 'Lex', 'De Haan', 'LDEHAAN', '515.123.4569', TO_DATE('2001-01-13', 'YYYY-MM-DD'), 17000, NULL, 'SA_MAN', NULL, 90);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, salary, commission_pct, job_id, manager_id, department_id) 
VALUES (4, 'Alexander', 'Hunold', 'AHUNOLD', '590.423.4567', TO_DATE('2006-01-03', 'YYYY-MM-DD'), 9000, NULL, 'ST_CLERK', NULL, 60);
COMMIT;

UPDATE EMPLOYEES 
SET manager_id = 1 
WHERE employee_id IN (2, 3);
COMMIT;

UPDATE JOBS 
SET min_salary = min_salary + 500, 
    max_salary = max_salary + 500 
WHERE LOWER(job_title) LIKE '%b%' OR LOWER(job_title) LIKE '%s%';
COMMIT;

DELETE FROM JOBS 
WHERE max_salary > 9000;
COMMIT;

DROP TABLE DEPARTMENTS;

FLASHBACK TABLE DEPARTMENTS TO BEFORE DROP;

SELECT * FROM DEPARTMENTS;