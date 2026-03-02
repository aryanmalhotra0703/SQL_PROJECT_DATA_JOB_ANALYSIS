# 📌 Introduction
📊 This project focuses on analyzing job postings in the data analytics field using SQL and PostgreSQL. The goal is to explore salary trends, identify in-demand skills, and understand which factors influence higher-paying Data Analytuc roles.

By querying a structured relational database, this project demonstrates how SQL can be used to extract meaningful insights from real-world job market data.

🔍 SQL queries? Check them out here: [project_sql folder](/project_sql/)
# 🎯 Background
The demand for Data Analysts continues to grow as organizations rely more on data-driven decision-making. Understanding which skills are required and which roles offer higher salaries can help guide career development.

This project analyzes job posting data to identify trends in salaries, skills, and hiring patterns.
# 🛠 Tools I Used
- **SQL (PostgreSQL)** – Data querying and analysis

- **Visual Studio Code** – Writing and executing SQL scripts

- **Git & GitHub** – Version control and project management
# The Analysis
Each query for this project aimed at investigating specific aspects of the data analyst job market. Here’s how I approached each question:
### 1. Top Paying Data Analyst Jobs
To identify the highest-paying roles, I filtered data analyst positions by average yearly salary and location, focusing on remote jobs. This query highlights the high paying opportunities in the field.
```sql
    SELECT
        job_id,
        job_title,
        job_location,
        job_schedule_type,
        salary_year_Avg,
        job_posted_date,
        name AS company_name
    FROM 
        job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id=company_dim.company_id
    WHERE 
        job_title_short='Data Analyst' AND 
        job_location='Anywhere' AND
        salary_year_avg IS NOT NULL
    ORDER BY salary_year_avg DESC
    LIMIT 10;
```
Here's the breakdown of the top data analyst jobs in 2023:

- **Wide Salary Range:** Top 10 paying data analyst roles span from $184,000 to $650,000, indicating significant salary potential in the field.
- **Diverse Employers:** Companies like SmartAsset, Meta, and AT&T are among those offering high salaries, showing a broad interest across different industries.
- **Job Title Variety:** There's a high diversity in job titles, from Data Analyst to Director of Analytics, reflecting varied roles and specializations within data analytics.
### 2. Skills for Top Paying Jobs
To understand what skills are required for the top-paying jobs, I joined the job postings with the skills data, providing insights into what employers value for high-compensation roles.
```sql
WITH top_paying_jobs AS(
    SELECT
    job_id,
    job_title,
    salary_year_avg,
    name AS company_name
FROM 
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id=company_dim.company_id
WHERE 
    job_title_short='Data Analyst' AND 
    job_location='Anywhere' AND
    salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10
)
SELECT top_paying_jobs.*,
        skills_dim.skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id=skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id=skills_dim.skill_id
ORDER BY salary_year_avg DESC;
```
Here's the breakdown of the most demanded skills for the top 10 highest paying data analyst jobs in 2023:

- SQL is leading with a bold count of 8.
- Python follows closely with a bold count of 7.
- Tableau is also highly sought after, with a bold count of 6. 
- Other skills like R, Snowflake, Pandas, and Excel show varying degrees of demand.
### 3. In-Demand Skills for Data Analysts
This query helped identify the skills most frequently requested in job postings, directing focus to areas with high demand.
```sql
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
```
Here's the breakdown of the most demanded skills for data analysts in 2023

- SQL and Excel remain fundamental, emphasizing the need for strong foundational skills in data processing and spreadsheet manipulation.
- Programming and Visualization Tools like Python, Tableau, and Power BI are essential, pointing towards the increasing importance of technical skills in data storytelling and decision support.

### 4. Skills Based on Salary
Exploring the average salaries associated with different skills revealed which skills are the highest paying.
```sql
SELECT 
    skills_dim.skills AS skill,
    ROUND(AVG(salary_year_avg),0) AS average_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id=skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id=skills_dim.skill_id
WHERE job_title_short='Data Analyst' AND salary_year_avg IS NOT NULL
GROUP BY
    skill
ORDER BY 
    average_salary DESC
LIMIT 25
```
Here's a breakdown of the results for top paying skills for Data Analysts:

- **High Demand for Big Data & ML Skills:** Top salaries are commanded by analysts skilled in big data technologies (PySpark, Couchbase), machine learning tools (DataRobot, Jupyter), and Python libraries (Pandas, NumPy), reflecting the industry's high valuation of data processing and predictive modeling capabilities.
- **Software Development & Deployment Proficiency:** Knowledge in development and deployment tools (GitLab, Kubernetes, Airflow) indicates a lucrative crossover between data analysis and engineering, with a premium on skills that facilitate automation and efficient data pipeline management.
- **Cloud Computing Expertise:** Familiarity with cloud and data engineering tools (Elasticsearch, Databricks, GCP) underscores the growing importance of cloud-based analytics environments, suggesting that cloud proficiency significantly boosts earning potential in data analytics.
### 5. Most Optimal Skills to Learn
Combining insights from demand and salary data, this query aimed to pinpoint skills that are both in high demand and have high salaries, offering a strategic focus for skill development.
```sql
    WITH skill_demand AS (
        SELECT 
            skills_dim.skill_id,
            skills_dim.skills,
            COUNT(*) AS skill_count
        FROM job_postings_fact
        INNER JOIN skills_job_dim ON job_postings_fact.job_id=skills_job_dim.job_id
        INNER JOIN skills_dim ON skills_job_dim.skill_id=skills_dim.skill_id
        
        WHERE job_title_short='Data Analyst' AND salary_year_avg IS NOT NULL AND job_work_from_home=True
        GROUP BY skills_dim.skill_id
    ),average_salary AS(
        SELECT 
            skills_dim.skill_id,
            ROUND(AVG(salary_year_avg),0) AS average_salary
        FROM job_postings_fact
        INNER JOIN skills_job_dim ON job_postings_fact.job_id=skills_job_dim.job_id
        INNER JOIN skills_dim ON skills_job_dim.skill_id=skills_dim.skill_id
        WHERE job_title_short='Data Analyst' AND salary_year_avg IS NOT NULL AND job_work_from_home=True
        GROUP BY
            skills_dim.skill_id
    )
    SELECT 
        skill_demand.skill_id,
        skill_demand.skills,
        skill_count,
        average_salary
    FROM skill_demand
    INNER JOIN average_salary ON skill_demand.skill_id=average_salary.skill_id
    ORDER BY skill_count DESC
    LIMIT 25
```
Here's a breakdown of the most optimal skills for Data Analysts in 2023:

- **High-Demand Programming Languages:** Python and R stand out for their high demand, with demand counts of 236 and 148 respectively. Despite their high demand, their average salaries are around $101,397 for Python and $100,499 for R, indicating that proficiency in these languages is highly valued but also widely available.
- **Cloud Tools and Technologies:** Skills in specialized technologies such as Snowflake, Azure, AWS, and BigQuery show significant demand with relatively high average salaries, pointing towards the growing importance of cloud platforms and big data technologies in data analysis.
- **Business Intelligence and Visualization Tools:** Tableau and Looker, with demand counts of 230 and 49 respectively, and average salaries around $99,288 and $103,795, highlight the critical role of data visualization and business intelligence in deriving actionable insights from data.
- **Database Technologies:** The demand for skills in traditional and NoSQL databases (Oracle, SQL Server, NoSQL) with average salaries ranging from $97,786 to $104,534, reflects the enduring need for data storage, retrieval, and management expertise.
# What I Learned
Throughout this adventure, I've turbocharged my SQL toolkit with some serious firepower:

- 🧩 Complex Query Crafting: Mastered the art of advanced SQL, merging tables like a pro and wielding WITH clauses for ninja-level temp table maneuvers.
- 📊 Data Aggregation: Got cozy with GROUP BY and turned aggregate functions like COUNT() and AVG() into my data-summarizing sidekicks.
- 💡 Analytical Wizardry: Leveled up my real-world puzzle-solving skills, turning questions into actionable, insightful SQL queries.
# Conclusions
**Insights**

From the analysis, several general insights emerged:

- **Top-Paying Data Analyst Jobs:** The highest-paying jobs for data analysts that allow remote work offer a wide range of salaries, the highest at $650,000!
- **Skills for Top-Paying Jobs:** High-paying data analyst jobs require advanced proficiency in SQL, suggesting it’s a critical skill for earning a top salary.
- **Most In-Demand Skills:** SQL is also the most demanded skill in the data analyst job market, thus making it essential for job seekers.
- **Skills with Higher Salaries:** Specialized skills, such as SVN and Solidity, are associated with the highest average salaries, indicating a premium on niche expertise.
- **Optimal Skills for Job Market Value:** SQL leads in demand and offers for a high average salary, positioning it as one of the most optimal skills for data analysts to learn to maximize their market value.

**Closing Thoughts**

This project enhanced my SQL skills and provided valuable insights into the data analyst job market. The findings from the analysis serve as a guide to prioritizing skill development and job search efforts. Aspiring data analysts can better position themselves in a competitive job market by focusing on high-demand, high-salary skills. This exploration highlights the importance of continuous learning and adaptation to emerging trends in the field of data analytics.