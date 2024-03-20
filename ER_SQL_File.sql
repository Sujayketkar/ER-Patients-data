create table ER_Data(
patient_id VARCHAR(50),
department_referral VARCHAR(50),
admission_Date DATE,
admission_Time TIME,
patient_waittime NUMERIC,
Dischaerge_Date DATE,
Discharge_Time TIME
)

SELECT * from er_data;

--data as per the department admissions--

select COUNT(patient_id) AS num_patients, department_referral
FROM ER_Data
GROUP BY department_referral
ORDER BY num_patients DESC;

--Q. What is the average number of patients admitted to the ER each day?

 SELECT
     ROUND(AVG(daily_admissions), 2) AS avg_daily_admissions
FROM
    (
        SELECT
            admission_date,
            COUNT(patient_id) AS daily_admissions
       FROM ER_Data
        GROUP BY
            admission_date
    ) AS daily_counts;



--Q. How many average admissions do we see on weekly basis.
 
SELECT
    ROUND(AVG(weekly_admissions), 2) AS avg_weekly_admissions
FROM
    (
        SELECT
            DATE_TRUNC('week', CAST(admission_date AS DATE)) AS week_start,
            COUNT(patient_id) AS weekly_admissions
        FROM
           ER_Data
        GROUP BY
            week_start
    ) AS weekly_counts;
	
	
	
--Q. what’s the average weekday vs weekend break up



SELECT
    ROUND(AVG(CASE WHEN is_weekend THEN daily_admissions END), 2) AS avg_weekend_admissions,
    ROUND(AVG(CASE WHEN NOT is_weekend THEN daily_admissions END), 2) AS avg_weekday_admissions
FROM
    (
        SELECT
            admission_date,
            COUNT(patient_id) AS daily_admissions,
            CASE
                WHEN EXTRACT(ISODOW FROM admission_date) IN (6, 7) THEN true
                ELSE false
            END AS is_weekend
        FROM
            ER_Data
        GROUP BY
            admission_date
    ) AS daily_counts;


--avg monthly admissions


select round(avg(monthly_admissions),2) as avg_monthly_admissions

FROM (
select DATE_TRUNC('Month',admission_date)  as month_start, count(patient_id) as monthly_admissions
FROM ER_Data
GROUP BY month_start
ORDER BY month_start) AS monhtly_count
 
 



--admissions we get based on time of the day

with CTE AS (

SELECT
    patient_id,
    admission_date,
    admission_time,
    CASE
        WHEN admission_time >= '04:00:00' AND admission_time < '08:00:00' THEN 'Early Morning'
        WHEN admission_time >= '08:00:00' AND admission_time < '11:30:00' THEN 'Morning'
        WHEN admission_time >= '11:30:00' AND admission_time < '16:00:00' THEN 'Afternoon'
        WHEN admission_time >= '16:00:00' AND admission_time < '19:00:00' THEN 'Late Afternoon'
        WHEN admission_time >= '19:00:00' AND admission_time < '22:00:00' THEN 'Evening'
        WHEN admission_time >= '22:00:00' OR admission_time < '01:00:00' THEN 'Night'
        ELSE 'Late Night'
    END AS admission_period
FROM
    ER_Data)

SELECT Admission_period, count(admission_period) as num_patients
FROM CTE
GROUP BY admission_period
ORDER BY Admission_period;

--whats the average patient wait time?

select round(avg(patient_waittime),2) FROM ER_Data;

--we need to find cases where average wait time is 
--less than 10 mins- excellent
--10-20 mins - very good
-- 20-30 mins- good
--30 to 50 mins --probe why?
--50 and above - review cases with panel


SELECT wait_period, count(patient_id) as cases

FROM(select patient_id,patient_waittime,
CASE 
 WHEN patient_waittime<= 10 THEN 'Excellent'
 WHEN patient_waittime<= 20 THEN 'very good'
 WHEN  patient_waittime<= 30 THEN 'probe'
 ELSE 'Review cases'
END AS wait_period
FROM ER_Data) AS waiting_time_buckets
GROUP BY wait_period
ORDER BY cases;


--now we wish to see review_cases are from which department referral

with CTE AS(

SELECT wait_period, count(patient_id) as cases

FROM(select er.patient_id,er.patient_waittime,er.department_referral,
CASE 
 WHEN patient_waittime<= 10 THEN 'Excellent'
 WHEN patient_waittime<= 20 THEN 'very_good'
 WHEN  patient_waittime<= 30 THEN 'probe'
 ELSE 'Review_cases'
END AS wait_period
FROM ER_Data er) AS waiting_time_buckets
GROUP BY wait_period
ORDER BY cases)

select er.department_referral,COUNT('Review_cases') AS review_case_count
FROM ER_Data er
GROUP BY er.department_referral
ORDER BY review_case_count desc


--LETS CALCULATE DAILY AVERAGE WAIT TIME

SELECT * FROM ER_Data;



select admission_date, round(avg(patient_waittime),2) as daily_avg_waittime
FROM ER_Data
GROUP BY Admission_date
ORDER BY Admission_date;

--nowlets calculate the weekday and weekend avgs

SELECT
    ROUND(AVG(CASE WHEN is_weekend THEN daily_avg_waittime END), 2) AS avg_weekend_waittime,
    ROUND(AVG(CASE WHEN NOT is_weekend THEN daily_avg_waittime END), 2) AS avg_weekday_waittime
FROM
    (
        SELECT
            admission_date,
           round(avg(patient_waittime),2) as daily_avg_waittime,
            CASE
                WHEN EXTRACT(ISODOW FROM admission_date) IN (6, 7) THEN true
                ELSE false
            END AS is_weekend
        FROM
            ER_Data
        GROUP BY
            admission_date
    ) AS daily_counts;
	
	
	
	
	
	---lets group daily waitime data
	
select admission_date, 
CASE 
 WHEN daily_avg_waittime<= 10 THEN 'Excellent'
 WHEN daily_avg_waittime<= 20 THEN 'very good'
 WHEN  daily_avg_waittimee<= 30 THEN 'probe'
 ELSE 'Review cases'
END AS wait_period
 
 
--we count days with wait time


SELECT wait_period, count(admission_date)as count_DAYS
FROM(
select waits_daily.admission_date,
CASE 
WHEN waits_daily.daily_avg_waittime<= 20 THEN 'Excellent'
WHEN waits_daily.daily_avg_waittime<= 30 THEN 'very good'
WHEN waits_daily.daily_avg_waittime<= 40 THEN 'probe'
ELSE 'Review cases'
END AS wait_period
FROM (select admission_date, round(avg(patient_waittime),2) as daily_avg_waittime
FROM ER_Data
GROUP BY Admission_date
ORDER BY Admission_date) as waits_daily)
GROUP BY wait_period
ORDER BY count_DAYS desc


select * FROM ER_Data
ORDER BY Admission_date ASC;

--footfall for every half an hour

SELECT
    CONCAT(EXTRACT(HOUR FROM bucket_start), ':', LPAD(EXTRACT(MINUTE FROM bucket_start)::TEXT, 2, '0'), ':00') AS bucket_start,
    CONCAT(EXTRACT(HOUR FROM bucket_end), ':', LPAD(EXTRACT(MINUTE FROM bucket_end)::TEXT, 2, '0'), ':00') AS bucket_end,
    COUNT(patient_id) AS patient_count
FROM (
    SELECT
        (admission_time::time - MOD(EXTRACT(MINUTE FROM admission_time)::INT, 30) * INTERVAL '1 minute') AS bucket_start,
        (admission_time::time - MOD(EXTRACT(MINUTE FROM admission_time)::INT, 30) * INTERVAL '1 minute' + INTERVAL '30 minutes') AS bucket_end,
        patient_id
    FROM
        ER_Data
) AS buckets
GROUP BY
    bucket_start,
    bucket_end
ORDER BY
    bucket_start;
	
	
select count(patient_id) FROM ER_Data
