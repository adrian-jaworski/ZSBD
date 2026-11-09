BEGIN EXECUTE IMMEDIATE 'DROP VIEW v_wysokie_pensje'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW v_finance_emp'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW v_srednie_pensje'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW v_dzialy_stat'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW v_wysokie_pensje_check'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW v_managerowie'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW v_najlepiej_oplacani'; EXCEPTION WHEN OTHERS THEN NULL; END;
/


CREATE OR REPLACE VIEW v_wysokie_pensje AS 
SELECT * FROM employees WHERE salary > 6000;


CREATE OR REPLACE VIEW v_wysokie_pensje AS 
SELECT * FROM employees WHERE salary > 12000;


DROP VIEW v_wysokie_pensje;


CREATE OR REPLACE VIEW v_finance_emp AS 
SELECT e.employee_id, e.last_name, e.first_name 
FROM employees e 
JOIN departments d ON e.department_id = d.department_id 
WHERE d.department_name = 'Finance';


CREATE OR REPLACE VIEW v_srednie_pensje AS 
SELECT employee_id, last_name, first_name, salary, job_id, email, hire_date 
FROM employees 
WHERE salary BETWEEN 5000 AND 12000;


INSERT INTO v_srednie_pensje (employee_id, last_name, first_name, salary, job_id, email, hire_date) 
VALUES (999, 'Kowalski', 'Jan', 6000, 'IT_PROG', 'JKOWALSK', SYSDATE);


UPDATE v_srednie_pensje SET salary = 6500 WHERE employee_id = 999;


DELETE FROM v_srednie_pensje WHERE employee_id = 999;
COMMIT;


CREATE OR REPLACE VIEW v_dzialy_stat AS 
SELECT d.department_id, d.department_name, COUNT(e.employee_id) AS liczba_pracownikow, ROUND(AVG(e.salary), 2) AS srednia_pensja, MAX(e.salary) AS najwyzsza_pensja 
FROM departments d 
JOIN employees e ON d.department_id = e.department_id 
GROUP BY d.department_id, d.department_name 
HAVING COUNT(e.employee_id) >= 4;

-- Próba dodania danych do widoku agregującego (zwraca błąd ORA-01732)
-- INSERT INTO v_dzialy_stat (department_id, department_name, liczba_pracownikow, srednia_pensja, najwyzsza_pensja) VALUES (999, 'Test', 5, 5000, 6000);


CREATE OR REPLACE VIEW v_wysokie_pensje_check AS 
SELECT * 
FROM employees 
WHERE salary > 12000 
WITH CHECK OPTION;

-- Próba dodania pracownika 5000-12000 (Zwróci błąd ORA-01402 z powodu naruszenia CHECK OPTION)
-- INSERT INTO v_wysokie_pensje_check (employee_id, last_name, email, hire_date, job_id, salary) VALUES (998, 'Nowak', 'ANOWAK', SYSDATE, 'IT_PROG', 6000);

-- Próba dodania pracownika > 12000 (Operacja wykona się poprawnie)
INSERT INTO v_wysokie_pensje_check (employee_id, first_name, last_name, email, hire_date, job_id, salary) 
VALUES (997, 'Jan', 'Bogaty', 'JBOGATY', SYSDATE, 'IT_PROG', 13000);


DELETE FROM employees WHERE employee_id = 997;
COMMIT;


CREATE MATERIALIZED VIEW v_managerowie AS 
SELECT DISTINCT m.employee_id, m.first_name, m.last_name, d.department_name 
FROM employees m 
JOIN employees e ON m.employee_id = e.manager_id 
JOIN departments d ON m.department_id = d.department_id;


CREATE OR REPLACE VIEW v_najlepiej_oplacani AS 
SELECT * FROM (
    SELECT * FROM employees ORDER BY salary DESC
) WHERE ROWNUM <= 10;