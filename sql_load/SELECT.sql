SELECT 
    job_schedule_type,
    AVG(salary_year_avg) AS Average_yearly_Salary,
    AVG(salary_hour_avg) AS Average_hourly_Salary
FROM 
    job_postings_fact
WHERE
    job_posted_date ::date > '2023-06-01'
GROUP BY
    job_schedule_type
ORDER BY
    job_schedule_type;

SELECT 
    COUNT(job_id) AS job_posting_count,
    EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS month
FROM 
    job_postings_fact
GROUP BY
    month
ORDER BY
    month;

SELECT
    company_dim.name,
    COUNT(job_postings_fact.job_id) AS job_posting_count
FROM 
    job_postings_fact
INNER JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_postings_fact.job_health_insurance = 'TRUE'
    AND EXTRACT(QUARTER FROM job_postings_fact.job_posted_date) = 2
GROUP BY
    company_dim.name
HAVING
    COUNT(job_postings_fact.job_id) > 0
ORDER BY
    job_posting_count DESC;


CREATE TABLE january_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS
    SELECT * 
    FROM job_postings_fact 
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS
    SELECT * 
    FROM job_postings_fact 
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

SELECT *
    FROM march_jobs

SELECT 
        CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category,
    COUNT(job_id) AS number_of_jobs_count
FROM
    job_postings_fact
WHERE 
    job_title_short = 'Data Analyst'
GROUP BY
    location_category;

SELECT 
    job_id,
    job_title_short,
    salary_year_avg,
    CASE
        WHEN salary_year_avg > 100000 THEN 'high salary'
        WHEN salary_year_avg >= 60000 THEN 'Standard salary'
        ELSE 'Low salary'
    END AS Salary_category
FROM 
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC;

SELECT 
    COUNT(DISTINCT job_postings_fact.company_id) AS Count_of_companies,
    CASE
        WHEN job_postings_fact.job_work_from_home = 'TRUE' THEN 'WFH'
        ELSE 'Non WFH'
    END AS Job_type
FROM
    job_postings_fact
GROUP BY
    Job_type

SELECT
    COUNT(DISTINCT CASE WHEN job_work_from_home = 'TRUE' THEN company_id END) AS WFH_Jobs,
    COUNT(DISTINCT CASE WHEN job_work_from_home = 'FALSE' THEN company_id END) AS non_WFH_jobs
FROM
    job_postings_fact;

SELECT
    job_id,
    salary_year_avg,
    CASE
        WHEN job_title ILIKE '%Senior%' THEN 'Senior'
        WHEN job_title ILIKE '%Lead%' OR job_title ILIKE '%Manager%' THEN 'Lead/Manager'
        WHEN job_title ILIKE '%Junior%' OR job_title ILIKE '%Entry%' THEN 'Junior/Entry'
        ELSE 'Not Sepcified'
    END AS experience_level,
    CASE
        WHEN job_work_from_home = 'TRUE' THEN 'Yes'
        Else 'No'
    END AS remote_option
FROM
    job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
ORDER BY
    job_id;


SELECT
    skills_dim.skills
FROM
    skills_dim
INNER JOIN (
        SELECT
            skills_job_dim.skill_id,
            COUNT(job_id) AS Count_of_jobs
        FROM
            skills_job_dim
        GROUP BY
            skills_job_dim.skill_id
        ORDER BY
            Count_of_jobs DESC
        LIMIT 5) AS Top_Skills ON skills_dim.skill_id = Top_Skills.skill_id
ORDER BY
    Top_Skills.Count_of_jobs DESC;

SELECT
    company_dim.company_id,
    company_dim.name,
    CASE
        WHEN Top_Companies.Count_of_Jobs_Company < 10 THEN 'Small'
        WHEN Top_Companies.Count_of_Jobs_Company BETWEEN 10 AND 50 THEN 'Medium'
        ELSE 'Large'
    END AS Company_size
FROM
    company_dim 
INNER JOIN
        (        
        SELECT
        company_id,
        COUNT(job_id) AS Count_of_Jobs_Company
    FROM
        job_postings_fact
    GROUP BY
        company_id
    ORDER BY
        Count_of_Jobs_Company DESC
        ) AS Top_Companies ON company_dim.company_id = Top_Companies.company_id
WHERE
    Top_Companies.Count_of_Jobs_Company IS NOT NULL
ORDER BY
    company_dim.company_id
LIMIT 11;

SELECT
    company_dim.name
FROM
    company_dim
INNER JOIN
        (
        SELECT
            job_postings_fact.company_id,
            AVG(job_postings_fact.salary_year_avg) AS Avg_salary
        FROM
            job_postings_fact
        GROUP BY
            job_postings_fact.company_id
        ) AS Companies_Salary ON company_dim.company_id = Companies_Salary.company_id
WHERE
    Companies_Salary.Avg_salary >
    (SELECT
        AVG(job_postings_fact.salary_year_avg)
    FROM
        job_postings_fact);




WITH Unique_Jobs_Companies AS 
        (SELECT
            job_postings_fact.company_id,
            COUNT(DISTINCT job_postings_fact.job_title) AS Unique_job_title
        FROM
            job_postings_fact
        GROUP BY
            job_postings_fact.company_id)

SELECT 
    company_dim.name,
    Unique_job_title
FROM 
    company_dim
LEFT JOIN Unique_Jobs_Companies ON Unique_Jobs_Companies.company_id = company_dim.company_id
ORDER BY
    Unique_job_title DESC
LIMIT 10;


WITH Average_Salary AS 
        (SELECT
            job_postings_fact.job_country,
            AVG(job_postings_fact.salary_year_avg) AS Avg_Salary_Rate
        FROM
            job_postings_fact
        GROUP BY
            job_postings_fact.job_country)
SELECT
    job_postings_fact.job_id,
    job_postings_fact.job_title,
    company_dim.name,
    job_postings_fact.salary_year_avg AS Salary_rate,
    EXTRACT(MONTH FROM job_postings_fact.job_posted_date) AS Month,
    CASE
        WHEN job_postings_fact.salary_year_avg > Average_Salary.Avg_Salary_Rate THEN 'Above Average'
        ELSE 'Below Average'
    END AS Salary_category
FROM
    job_postings_fact
INNER JOIN company_dim ON company_dim.company_id = job_postings_fact.company_id
INNER JOIN Average_Salary ON Average_Salary.job_country = job_postings_fact.job_country
ORDER BY
    Month DESC;


WITH Demand AS
        (SELECT  
            skills_job_dim.skill_id,
            COUNT(skills_job_dim.job_id) AS Count_of_jobs
        FROM
            skills_job_dim
        INNER JOIN
            job_postings_fact on job_postings_fact.job_id = skills_job_dim.job_id
        WHERE
            job_postings_fact.job_work_from_home = 'TRUE' AND
            job_postings_fact.job_title_short = 'Data Analyst'
        GROUP BY
            skills_job_dim.skill_id)

SELECT DISTINCT
    skills_dim.skill_id,
    skills_dim.skills,
    Count_of_jobs
FROM
    skills_dim
INNER JOIN skills_job_dim ON skills_job_dim.skill_id = skills_dim.skill_id
INNER JOIN Demand ON Demand.skill_id = skills_dim.skill_id
ORDER BY
    Count_of_jobs DESC
LIMIT 5;

WITH CS AS
        (SELECT
            job_postings_fact.company_id,
            COUNT(DISTINCT skills_job_dim.skill_id) AS No_of_skills
        FROM
            job_postings_fact
        LEFT JOIN skills_job_dim ON skills_job_dim.job_id = job_postings_fact.job_id
        GROUP BY
            job_postings_fact.company_id),
CHS AS
        (SELECT
            job_postings_fact.company_id,
            MAX(job_postings_fact.salary_year_avg) AS H_SAl
        FROM
            job_postings_fact
        GROUP BY
            job_postings_fact.company_id)
SELECT
    company_dim.name,
    CS.No_of_skills,
    CHS.H_SAl
FROM
    company_dim
LEFT JOIN CS ON CS.company_id = company_dim.company_id
LEFT JOIN CHS ON CHS.company_id = company_dim.company_id
ORDER BY
    company_dim.name;



(SELECT
    job_id,
    job_title,
    'With Salary Info' AS Salary_Info
FROM
    job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
    OR
    salary_hour_avg IS NOT NULL

UNION ALL

SELECT
    job_id,
    job_title,
    'Without Salary Info' AS Salary_Info
FROM
    job_postings_fact
WHERE
    salary_year_avg IS NULL 
    AND
    salary_hour_avg IS NULL
ORDER BY
    Salary_info DESC,
    job_id







SELECT
    Job_postings_1Q.job_id,
    Job_postings_1Q.job_title_short,
    Job_postings_1Q.job_location,
    Job_postings_1Q.job_via,
    Job_postings_1Q.salary_year_avg,
    skills_dim.skill_id,
    skills_dim.skills
FROM
(SELECT *
FROM january_jobs
    UNION ALL
SELECT *
FROM february_jobs
    UNION ALL
SELECT *
FROM march_jobs) AS Job_postings_1Q
LEFT JOIN skills_job_dim ON skills_job_dim.job_id = Job_postings_1Q.job_id
LEFT JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE
    Job_postings_1Q.salary_year_avg > 70000
ORDER BY
    Job_postings_1Q.job_id;





WITH Job_Q1 AS 
       (SELECT *
        FROM january_jobs
            UNION ALL
        SELECT *
        FROM february_jobs
            UNION ALL
        SELECT *
        FROM march_jobs),
Monthly_Skill_Demand AS
        (SELECT
            skills_dim.skills,
            COUNT(Job_Q1.job_id) AS Job_count,
            EXTRACT(MONTH FROM Job_Q1.job_posted_date) AS Job_month,
            EXTRACT(YEAR FROM Job_Q1.job_posted_date) AS Job_year
        FROM 
            Job_Q1
        INNER JOIN skills_job_dim ON Job_Q1.job_id = skills_job_dim.job_id
        INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
        GROUP BY
            skills_dim.skills,
            Job_year,
            Job_month)

SELECT
    skills,
    Job_year,
    Job_month,
    Job_count
FROM
    Monthly_Skill_Demand
ORDER BY
    skills,
    Job_year,
    Job_month

