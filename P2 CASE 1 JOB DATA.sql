-- CASE 1: JOB DATA
-- Jobs Per Day 
select count(distinct job_id)/(30*24)
as 'Jobs Per Day' from job_data;

-- no of events happening per second.
select * from job_data;
with CTE as (
select ds, count(job_id) as num_jobs, sum(time_spent) as total_time
from job_data
where event IN('transfer','decision')
AND ds between '2020-11-01' AND '2020-11-30'
GROUP BY ds)
select ds, ROUND(1.0*SUM(num_jobs) 
OVER (ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) / SUM(total_time) 
OVER (ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS throughput_7d
FROM CTE;

-- Language Share Analysis
use jobs;
select language, 
count(language) as "Language Count",
count(*)*100/sum(count(*))
over() as percentage
from job_data
group by language;

-- Duplicate Rows Detection
WITH cte AS 
(
    SELECT *, ROW_NUMBER() OVER (PARTITION BY job_id) AS row_numb
    FROM job_data
)
SELECT * FROM cte WHERE row_numb > 1;
