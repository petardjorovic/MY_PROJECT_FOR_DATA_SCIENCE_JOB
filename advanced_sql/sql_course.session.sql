SELECT 
    skills_dim.skills,
    COUNT(skills_job_dim.skill_id) AS num_sk
FROM
    skills_dim
LEFT JOIN skills_job_dim ON skills_dim.skill_id = skills_job_dim.skill_id
GROUP BY
    skills_dim.skills
ORDER BY
    num_sk DESC
LIMIT 5

WITH skill_count AS (
SELECT 
    skill_id,
    COUNT(job_id) AS broj_oglasa
FROM
    skills_job_dim
GROUP BY
    skill_id
ORDER BY
    broj_oglasa DESC
)

SELECT 
    skills_dim.skills,
    skill_count.broj_oglasa
FROM
    skills_dim
LEFT JOIN skill_count ON skill_count.skill_id = skills_dim.skill_id
ORDER BY
    broj_oglasa DESC
    LIMIT 5

WITH count_per_company AS (
SELECT
    company_id,
    COUNT(job_id) AS num_jobs
FROM
    job_postings_fact
GROUP BY
    company_id
ORDER BY
    num_jobs DESC
)

SELECT
    company_dim.name,
    count_per_company.num_jobs,
    CASE
        WHEN count_per_company.num_jobs < 10 THEN 'Small'
        WHEN count_per_company.num_jobs <= 50 THEN 'Medium'
        ELSE 'Large'
    END AS size_category
FROM
    company_dim
LEFT JOIN count_per_company ON company_dim.company_id = count_per_company.company_id
ORDER BY
    count_per_company.num_jobs DESC

WITH num_of_ski AS (
SELECT 
    skills_job_dim.skill_id,
    COUNT(job_postings_fact.job_id) AS numb_jobs
FROM
    job_postings_fact
LEFT JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
WHERE
    job_postings_fact.job_work_from_home = TRUE AND
    job_postings_fact.job_title_short = 'Data Analyst'
GROUP BY
    skills_job_dim.skill_id
)

SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    num_of_ski.numb_jobs
FROM
    skills_dim
LEFT JOIN num_of_ski ON skills_dim.skill_id = num_of_ski.skill_id
WHERE
    num_of_ski.numb_jobs IS NOT NULL
ORDER BY
    num_of_ski.numb_jobs DESC
LIMIT 5

WITH q1 AS (
SELECT *
FROM
    january_jobs

UNION

SELECT *
FROM
    february_jobs

UNION

SELECT *
FROM
    march_jobs
)

WITH q1_salary AS (
SELECT *
FROM 
    q1
WHERE
    salary_year_avg > 70000
)

SELECT
    skills_job_dim.skill_id,
    q1_salary.job_title_short
FROM
    skills_job_dim
LEFT JOIN q1_salary ON skills_job_dim.job_id = q1_salary.job_id

WITH pero AS (
SELECT
    skills_job_dim.skill_id,
    COUNT(job_postings_fact.job_id) AS nu_post
FROM
    skills_job_dim
LEFT JOIN job_postings_fact ON skills_job_dim.job_id = job_postings_fact.job_id
WHERE
    EXTRACT(MONTH FROM job_postings_fact.job_posted_date) < 4 AND
    job_postings_fact.salary_year_avg > 70000
GROUP BY
    skills_job_dim.skill_id
)

SELECT 
    skills_dim.skills,
    skills_dim.type,
    pero.nu_post
FROM
    skills_dim
LEFT JOIN pero ON pero.skill_id = skills_dim.skill_id

WITH sve AS (
SELECT 
    peki.job_id,
    skills_job_dim.skill_id,
    peki.salary_year_avg,
    peki.job_posted_date
FROM (
    SELECT *
    FROM
        january_jobs
    
    UNION

    SELECT *
    FROM
        february_jobs

    UNION

    SELECT *
    FROM
        march_jobs
) AS peki
LEFT JOIN skills_job_dim ON peki.job_id = skills_job_dim.job_id
WHERE
    peki.salary_year_avg > 70000
)

SELECT
    sve.job_id,
    skills_dim.skills,
    skills_dim.type,
    sve.salary_year_avg,
    sve.job_posted_date
FROM
    skills_dim
LEFT JOIN sve ON skills_dim.skill_id = sve.skill_id

SELECT DISTINCT
    COUNT(job_id)
FROM
    job_postings_fact

SELECT DISTINCT
    job_id
FROM
    skills_job_dim
ORDER BY
    job_id

WITH privremeno AS (
SELECT
    q1.job_id,
    skills_job_dim.skill_id
FROM (
    
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
) AS q1
LEFT JOIN skills_job_dim ON skills_job_dim.job_id = q1.job_id
WHERE
    q1.salary_year_avg > 70000
)

SELECT
    privremeno.skills_job_dim.skill_id
    skills_dim.skills,
    skills_dim.type
FROM
    skills_dim
LEFT JOIN privremeno ON privremeno.skill_id = skills_dim.skill_id

WITH obrnuto AS (
SELECT
    skills_job_dim.job_id,
    skills_dim.skills,
    skills_dim.type
FROM
    skills_job_dim
LEFT JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
)

SELECT
    q1.job_id,
    obrnuto.skills,
    obrnuto.type
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
    ) AS q1
LEFT JOIN obrnuto ON obrnuto.job_id = q1.job_id
WHERE
    q1.salary_year_avg > 70000