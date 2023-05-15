SELECT COUNT(*)
FROM company
WHERE status = 'closed'
___________________________________________
SELECT  funding_total
FROM company
WHERE country_code  = 'USA' 
        AND category_code = 'news'
ORDER BY funding_total desc; 
___________________________________________
SELECT sum(price_amount)
FROM acquisition
WHERE term_code='cash'
and extract(year from cast(acquired_at as date)) between 2011 and 2013;
___________________________________________
SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username like 'Silver%';
___________________________________________
select *
from people
where twitter_username like '%money%'
and last_name like 'K%'
___________________________________________
select sum(funding_total),
       country_code 
from company
group by country_code
ORDER BY sum(funding_total) DESC
___________________________________________
SELECT CAST (funded_at AS date),
       MIN (raised_amount),
       MAX (raised_amount)
FROM funding_round
GROUP BY CAST (funded_at AS date)
HAVING MIN (raised_amount) !=0
       AND MIN (raised_amount) != MAX (raised_amount)
___________________________________________
SELECT 
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 and invested_companies < 100 THEN 'middle_activity'
           ELSE 'low_activity'
       END,
       *
FROM fund
___________________________________________
SELECT
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity,
       ROUND(AVG(investment_rounds)) as avg_round
FROM fund
GROUP BY activity
ORDER BY avg_round
___________________________________________
SELECT
country_code,
MIN(invested_companies),
MAX(invested_companies),
AVG(invested_companies)
FROM fund
WHERE founded_at  BETWEEN '2010-01-01' AND '2012-12-31'

GROUP BY country_code
HAVING MIN(invested_companies) != 0
ORDER BY AVG(invested_companies) DESC,country_code ASC
LIMIT 10;
___________________________________________
SELECT
    first_name,
    last_name,
    instituition
FROM people AS i
left OUTER JOIN education AS e ON i.id = e.person_id
___________________________________________
SELECT k.name,
       count(distinct(instituition)) AS tot
FROM company AS k
JOIN people AS pe ON k.id=pe.company_id 
JOIN education AS ed ON pe.id=ed.person_id 
GROUP BY k.name 
ORDER BY tot DESC
LIMIT 5;
___________________________________________
SELECT DISTINCT name
FROM 
     (SELECT *
      FROM company AS c
      INNER JOIN funding_round AS fr ON c.id=fr.company_id
      WHERE is_first_round = 1 AND is_last_round = 1) AS t1
WHERE status = 'closed'
___________________________________________
WITH

c AS (SELECT 
      id,
      name
     FROM company
     WHERE status='closed'
     AND id IN (SELECT 
     company_id
     FROM funding_round
     WHERE is_first_round=1 
     AND is_last_round=1)
     GROUP BY id, name),
     
p as (SELECT 
      id,
      company_id
     FROM people)
     
SELECT
    p.id
FROM c
INNER JOIN p ON p.company_id=c.id
GROUP BY p.id
___________________________________________
SELECT DISTINCT p.id, e.instituition
FROM people AS p
JOIN education AS e
ON p.id = e.person_id
WHERE p.company_id IN (SELECT DISTINCT c.id
    FROM company AS c
    JOIN funding_round AS fr
    ON c.id = fr.company_id
    WHERE c.status = 'closed'
    AND is_first_round = 1
    AND is_last_round = 1)
___________________________________________
select p.id,
       count(e.instituition)
from people as p
join education as e on e.person_id = p.id
where p.company_id in (select distinct c.id
                      from company as c
                      join funding_round as fr on c.id = fr.company_id
                      where fr.is_first_round = 1 and fr. is_last_round = 1
                      and c.status = 'closed')
GROUP BY p.id
___________________________________________
select avg(total)
from (
       select p.id,
              count(e.instituition) as total
       from people as p
       join education as e
       on p.id = e.person_id
       where p.company_id in (SELECT DISTINCT c.id
                             from company AS c
                             JOIN funding_round AS fr
                             ON c.id = fr.company_id
                             WHERE c.status = 'closed'
                             AND is_first_round = 1
                             AND is_last_round = 1)
       GROUP BY p.id
) AS sq1
___________________________________________
select avg(total)
from (
       select p.id,
              count(e.instituition) as total
       from people as p
       join education as e
       on p.id = e.person_id
       where p.company_id in (SELECT DISTINCT c.id
                             from company AS c
                             JOIN funding_round AS fr
                             ON c.id = fr.company_id
                             where c.name like '***')
       GROUP BY p.id
) AS sq1
___________________________________________
select f.name as name_of_fund,
       c.name as name_of_company,
       fr.raised_amount as amount
from investment as i
    inner join company as c on i.company_id = c.id
       inner join fund as f on i.fund_id = f.id
       inner join funding_round as fr on fr.id = i.funding_round_id
where c.milestones > 6
  and fr.funded_at between '2012-01-01' and '2013-12-31'
 ___________________________________________
SELECT c.name,
      a.price_amount,
      c_1.name,
      c_1.funding_total,
      ROUND(a.price_amount/c_1.funding_total)
      
FROM acquisition AS a 
LEFT JOIN company AS c ON a.acquiring_company_id = c.id
LEFT JOIN company AS c_1 ON a.acquired_company_id = c_1.id
 
 WHERE a.price_amount != 0 
       AND c_1.funding_total != 0

ORDER BY a.price_amount DESC,
         c_1.name
LIMIT 10; 
 ___________________________________________
SELECT c.name AS social_co,
EXTRACT (MONTH FROM fr.funded_at) AS funding_month
FROM company AS c 
LEFT JOIN funding_round AS fr ON c.id = fr.company_id 
WHERE c.category_code = 'social' AND fr.funded_at 
BETWEEN '2010-01-01' AND '2013-12-31' AND fr.raised_amount <> 0;
 ___________________________________________
WITH
i1 AS
(SELECT EXTRACT(MONTH FROM CAST(acquired_at AS timestamp)) AS month,
       COUNT(acquired_company_id) AS acquired_company_count,
       SUM(price_amount) AS amount_sum
FROM acquisition
WHERE EXTRACT(YEAR FROM CAST(acquired_at AS timestamp)) IN (2010, 2011, 2012, 2013)
GROUP BY month
ORDER BY month),

i2 AS
(SELECT EXTRACT(MONTH FROM CAST(fr.funded_at AS timestamp)) AS month,
       COUNT(DISTINCT i.fund_id) AS fund_count
FROM funding_round AS fr
INNER JOIN investment AS i ON fr.id=i.funding_round_id
WHERE EXTRACT(YEAR FROM CAST(fr.funded_at AS timestamp)) IN (2010, 2011, 2012, 2013)
AND i.fund_id IN (SELECT id
                    FROM fund
                    WHERE country_code = 'USA')
GROUP BY month
ORDER BY month)

SELECT i1.month,
       i2.fund_count,
       i1.acquired_company_count,
       i1.amount_sum
FROM i1 INNER JOIN i2 ON i1.month=i2.month
 ___________________________________________
WITH
y_2011 AS (
           SELECT country_code,
                  AVG(funding_total) AS year_2011
           FROM company
           WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) = 2011
           GROUP BY country_code
           ),
y_2012 AS (
           SELECT country_code,
                  AVG(funding_total) AS  year_2012
           FROM company
           WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) = 2012
           GROUP BY country_code
           ), 
y_2013 AS (
           SELECT country_code,
                 AVG(funding_total) AS year_2013
           FROM company
           WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) = 2013
           GROUP BY country_code
           )

SELECT y_2011.country_code,
       year_2011,
       year_2012,
       year_2013
FROM  y_2011 JOIN y_2012  
ON y_2011.country_code=y_2012.country_code
INNER JOIN y_2013 
ON y_2011.country_code=y_2013.country_code
ORDER BY year_2011 DESC;
 ___________________________________________
