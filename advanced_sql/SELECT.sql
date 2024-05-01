SELECT 
    q1.job_title_short,
    q1.job_location,
    q1.job_via,
    q1.job_posted_date::date,
    q1.salary_year_avg
    FROM
(
    SELECT *
    FROM 
        january_jobs
    UNION ALL
    SELECT *
    FROM
        february_jobs
    UNION ALL
    SELECT *
    FROM 
        march_jobs
    ) AS Q1
WHERE
    q1.salary_year_avg > 70000 AND 
    q1.job_title_short = 'Data Analyst'
ORDER BY
    q1.salary_year_avg DESC
