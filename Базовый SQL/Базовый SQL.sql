1.Посчитайте, сколько компаний закрылось.
SELECT COUNT(*)
FROM company
WHERE status = 'closed'
___________________________________________
2.Отобразите количество привлечённых средств для новостных компаний США. Используйте данные из таблицы company. Отсортируйте таблицу по убыванию значений в поле funding_total .
SELECT  funding_total
FROM company
WHERE country_code  = 'USA' 
        AND category_code = 'news'
ORDER BY funding_total desc; 
___________________________________________
3.Найдите общую сумму сделок по покупке одних компаний другими в долларах. Отберите сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.
SELECT sum(price_amount)
FROM acquisition
WHERE term_code='cash'
and extract(year from cast(acquired_at as date)) between 2011 and 2013;
___________________________________________
4.Отобразите имя, фамилию и названия аккаунтов людей в твиттере, у которых названия аккаунтов начинаются на 'Silver'.
SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username like 'Silver%';
___________________________________________
5.Выведите на экран всю информацию о людях, у которых названия аккаунтов в твиттере содержат подстроку 'money', а фамилия начинается на 'K'.
select *
from people
where twitter_username like '%money%'
and last_name like 'K%'
___________________________________________
6.Для каждой страны отобразите общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране. Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируйте данные по убыванию суммы.
select sum(funding_total),
       country_code 
from company
group by country_code
ORDER BY sum(funding_total) DESC
___________________________________________
7.Составьте таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату.
Оставьте в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.
SELECT CAST (funded_at AS date),
       MIN (raised_amount),
       MAX (raised_amount)
FROM funding_round
GROUP BY CAST (funded_at AS date)
HAVING MIN (raised_amount) !=0
       AND MIN (raised_amount) != MAX (raised_amount)
___________________________________________
8.Создайте поле с категориями:
Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.
Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.
Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.
Отобразите все поля таблицы fund и новое поле с категориями.
SELECT 
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 and invested_companies < 100 THEN 'middle_activity'
           ELSE 'low_activity'
       END,
       *
FROM fund
___________________________________________
9.Для каждой из категорий, назначенных в предыдущем задании, посчитайте округлённое до ближайшего целого числа среднее количество инвестиционных раундов, в которых фонд принимал участие. Выведите на экран категории и среднее число инвестиционных раундов. Отсортируйте таблицу по возрастанию среднего.
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
10.Проанализируйте, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. 
Для каждой страны посчитайте минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год включительно. Исключите страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю. 
Выгрузите десять самых активных стран-инвесторов: отсортируйте таблицу по среднему количеству компаний от большего к меньшему. Затем добавьте сортировку по коду страны в лексикографическом порядке.
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
11.Отобразите имя и фамилию всех сотрудников стартапов. Добавьте поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна.
SELECT
    first_name,
    last_name,
    instituition
FROM people AS i
left OUTER JOIN education AS e ON i.id = e.person_id
___________________________________________
12.Для каждой компании найдите количество учебных заведений, которые окончили её сотрудники. Выведите название компании и число уникальных названий учебных заведений. Составьте топ-5 компаний по количеству университетов.
SELECT k.name,
       count(distinct(instituition)) AS tot
FROM company AS k
JOIN people AS pe ON k.id=pe.company_id 
JOIN education AS ed ON pe.id=ed.person_id 
GROUP BY k.name 
ORDER BY tot DESC
LIMIT 5;
___________________________________________
13.Составьте список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.
SELECT DISTINCT name
FROM 
     (SELECT *
      FROM company AS c
      INNER JOIN funding_round AS fr ON c.id=fr.company_id
      WHERE is_first_round = 1 AND is_last_round = 1) AS t1
WHERE status = 'closed'
___________________________________________
14.Составьте список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.
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
15.Составьте таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник.
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
16.Посчитайте количество учебных заведений для каждого сотрудника из предыдущего задания. При подсчёте учитывайте, что некоторые сотрудники могли окончить одно и то же заведение дважды.
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
17.Дополните предыдущий запрос и выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники разных компаний. Нужно вывести только одну запись, группировка здесь не понадобится.
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
18.Напишите похожий запрос: выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники ***
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
19.Составьте таблицу из полей:
name_of_fund — название фонда;
name_of_company — название компании;
amount — сумма инвестиций, которую привлекла компания в раунде.
В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно.
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
 20.Выгрузите таблицу, в которой будут такие поля:
название компании-покупателя;
сумма сделки;
название компании, которую купили;
сумма инвестиций, вложенных в купленную компанию;
доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
Не учитывайте те сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы. 
Отсортируйте таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке. Ограничьте таблицу первыми десятью записями.
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
 21.Выгрузите таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно. Проверьте, что сумма инвестиций не равна нулю. Выведите также номер месяца, в котором проходил раунд финансирования.
SELECT c.name AS social_co,
EXTRACT (MONTH FROM fr.funded_at) AS funding_month
FROM company AS c 
LEFT JOIN funding_round AS fr ON c.id = fr.company_id 
WHERE c.category_code = 'social' AND fr.funded_at 
BETWEEN '2010-01-01' AND '2013-12-31' AND fr.raised_amount <> 0;
 ___________________________________________
 22.Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. Сгруппируйте данные по номеру месяца и получите таблицу, в которой будут поля:
номер месяца, в котором проходили раунды;
количество уникальных названий фондов из США, которые инвестировали в этом месяце;
количество компаний, купленных за этот месяц;
общая сумма сделок по покупкам в этом месяце.
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
 23.Составьте сводную таблицу и выведите среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. Данные за каждый год должны быть в отдельном поле. Отсортируйте таблицу по среднему значению инвестиций за 2011 год от большего к меньшему.
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
