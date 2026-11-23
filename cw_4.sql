SELECT employee_id,
       first_name,
       last_name,
       salary,
       RANK() OVER (ORDER BY salary DESC) AS ranking_pensji
FROM employees;

SELECT employee_id,
       first_name,
       last_name,
       salary,
       SUM(salary) OVER () AS suma_wszystkich_pensji
FROM employees;

SELECT e.last_name,
       p.product_name,
       SUM(s.quantity * s.price) OVER (
           PARTITION BY e.employee_id 
           ORDER BY s.sale_date, s.sale_id 
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS skumulowana_sprzedaz,
       RANK() OVER (ORDER BY (s.quantity * s.price) DESC) AS ranking_zamowien
FROM employees e
JOIN sales s ON e.employee_id = s.employee_id
JOIN products p ON s.product_id = p.product_id;

SELECT e.last_name,
       p.product_name,
       s.price,
       COUNT(*) OVER (PARTITION BY s.product_id, TRUNC(s.sale_date)) AS liczba_transakcji_dnia,
       SUM(s.quantity * s.price) OVER (PARTITION BY s.product_id, TRUNC(s.sale_date)) AS suma_dnia_produkt,
       LAG(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date, s.sale_id) AS poprzednia_cena,
       LEAD(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date, s.sale_id) AS kolejna_cena
FROM sales s
JOIN employees e ON s.employee_id = e.employee_id
JOIN products p ON s.product_id = p.product_id;

SELECT p.product_name,
       s.price,
       SUM(s.quantity * s.price) OVER (
           PARTITION BY s.product_id, TRUNC(s.sale_date, 'MM')
       ) AS suma_calkowita_miesiac,
       SUM(s.quantity * s.price) OVER (
           PARTITION BY s.product_id, TRUNC(s.sale_date, 'MM') 
           ORDER BY s.sale_date, s.sale_id 
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS suma_rosnaca_miesiac
FROM sales s
JOIN products p ON s.product_id = p.product_id;

SELECT product_name,
       product_category,
       dzien_miesiac,
       cena_2022,
       cena_2023,
       (cena_2023 - cena_2022) AS roznica_cen
FROM (
    SELECT product_name,
           product_category,
           dzien_miesiac,
           rok,
           price AS cena_2023,
           LAG(price) OVER (
               PARTITION BY product_id, dzien_miesiac 
               ORDER BY rok
           ) AS cena_2022
    FROM (
        SELECT DISTINCT s.product_id,
               p.product_name,
               p.product_category,
               TO_CHAR(s.sale_date, 'MM-DD') AS dzien_miesiac,
               EXTRACT(YEAR FROM s.sale_date) AS rok,
               s.price
        FROM sales s
        JOIN products p ON s.product_id = p.product_id
        WHERE EXTRACT(YEAR FROM s.sale_date) IN (2022, 2023)
    )
)
WHERE rok = 2023 AND cena_2022 IS NOT NULL;

SELECT p.product_category,
       p.product_name,
       s.price,
       MIN(s.price) OVER (PARTITION BY p.product_category) AS min_cena_kategoria,
       MAX(s.price) OVER (PARTITION BY p.product_category) AS max_cena_kategoria,
       MAX(s.price) OVER (PARTITION BY p.product_category) - MIN(s.price) OVER (PARTITION BY p.product_category) AS roznica_cen
FROM sales s
JOIN products p ON s.product_id = p.product_id;

SELECT p.product_name,
       s.sale_date,
       s.price,
       ROUND(AVG(s.price) OVER (
           PARTITION BY s.product_id 
           ORDER BY s.sale_date, s.sale_id 
           ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
       ), 2) AS srednia_kroczaca_ceny
FROM sales s
JOIN products p ON s.product_id = p.product_id;

SELECT p.product_name,
       p.product_category,
       s.price,
       RANK() OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS ranking_cen,
       ROW_NUMBER() OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS numer_wiersza,
       DENSE_RANK() OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS ranking_gesty
FROM sales s
JOIN products p ON s.product_id = p.product_id;

SELECT e.last_name,
       p.product_name,
       SUM(s.price * s.quantity) OVER (
           PARTITION BY s.employee_id 
           ORDER BY s.sale_date, s.sale_id 
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS wartosc_rosnaca_sprzedazy,
       RANK() OVER (ORDER BY (s.price * s.quantity) DESC) AS ranking_globalny
FROM sales s
JOIN employees e ON s.employee_id = e.employee_id
JOIN products p ON s.product_id = p.product_id;

SELECT DISTINCT e.first_name,
       e.last_name,
       j.job_title
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
JOIN sales s ON e.employee_id = s.employee_id;