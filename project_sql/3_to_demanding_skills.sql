/*
Question: What are the most in-demand skills for data analysts?
- Join job postings to inner join table similar to query 2
- Identify the top 5 in-demand skills for a data analyst.
- Focus on all job postings.
- Why? Retrieves the top 5 skills with the highest demand in the job market, 
    providing insights into the most valuable skills for job seekers.
*/

WITH remote_jobs_skills AS (
    SELECT skill_id,
        COUNT(*) AS skill_count
    FROM 
        skills_job_dim AS skills_to_job
    INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id=skills_to_job.job_id
    WHERE 
        job_postings.job_work_from_home=True AND job_postings.job_title_Short='Data Analyst'
    GROUP BY 
        skill_id
)
SELECT 
    skill.skill_id,
    skills AS skill_name,
    skill_count
FROM remote_jobs_skills
INNER JOIN skills_dim AS skill ON skill.skill_id=remote_jobs_skills.skill_id
ORDER BY skill_count DESC
LIMIT 5
