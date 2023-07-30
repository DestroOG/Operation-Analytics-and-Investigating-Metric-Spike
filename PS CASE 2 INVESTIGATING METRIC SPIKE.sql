-- CASE 2 INVESTIGATING METRIC SPIKE
-- Weekly User Enagement
select extract(week from occurred_at) as week_num,
count(distinct user_id) as user_count
from events where event_type='Engagement'
group by week_num
order by week_num;

-- User Grwoth
WITH weekly_user_counts AS (
  SELECT EXTRACT(year FROM created_at) AS year,
         EXTRACT(week FROM created_at) AS week_num,
         COUNT(DISTINCT user_id) AS user_count
  FROM users
  WHERE state = 'active'
  GROUP BY year, week_num
)
SELECT year, week_num, user_count, SUM(user_count) OVER (ORDER BY year, week_num) AS cumulative_users
FROM weekly_user_counts
ORDER BY year, week_num;

-- Weekly Retension
SELECT COUNT(user_id) AS total_users, SUM(CASE WHEN retention_week = 1 THEN 1 ELSE 0 END) AS per_week_retention
FROM (
    SELECT a.user_id, a.sign_up_week, b.engagement_week, b.engagement_week - a.sign_up_week AS retention_week
    FROM (
        (SELECT DISTINCT user_id, EXTRACT(week FROM occurred_at) AS sign_up_week
         FROM p2.events
         WHERE event_type = 'signup_flow' AND event_name = 'complete_signup' AND EXTRACT(week FROM occurred_at) = 18) a
        LEFT JOIN
        (SELECT DISTINCT user_id, EXTRACT(week FROM occurred_at) AS engagement_week
         FROM p2.events
         WHERE event_type = 'engagement') b
        ON a.user_id = b.user_id
    )
    GROUP BY a.user_id, a.sign_up_week, b.engagement_week 
    ORDER BY a.user_id, a.sign_up_week 
) subquery;


-- Weekly Enagement 
select 
extract(year from occurred_at) as year_num,
extract(week from occurred_at) as week_num,
device,
count(distinct user_id) as no_of_users
from p2.events
where event_type = 'Engagement'
group by 1,2,3
order by 1,2,3;


-- Email Engament 
SELECT
    100.0 * SUM(email_cat = 'email_opened') / SUM(email_cat = 'email_sent') AS email_opening_rate,
    100.0 * SUM(email_cat = 'email_clicked') / SUM(email_cat = 'email_sent') AS email_clicking_rate
FROM (
    SELECT *,
    CASE
        WHEN action IN ('sent_weekly_digest', 'sent_reengagement_email') THEN 'email_sent'
        WHEN action IN ('email_open') THEN 'email_opened'
        WHEN action IN ('email_clickthrough') THEN 'email_clicked'
    END AS email_cat
    FROM p2.email_events
) a;

