/*
Answer: What are the top skills based on salary?
- Look at the average salary associated with each skill for Data Analyst positions
Focuses on roles with specified salaries, regardless of location
Why? It reveals how different skills impact salary levels for Data Analysts and helps identify the most financially rewarding skills to acquire or improve
*/

SELECT 
    skills,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS Avg_salary
FROM 
    job_postings_fact
INNER JOIN skills_job_dim ON skills_job_dim.job_id = job_postings_fact.job_id
INNER JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home ='TRUE'
GROUP BY
    skills
ORDER BY
    Avg_salary DESC
LIMIT 25

/*

Here are some key trends based on the top-paying data analyst skills:

1. Big Data & Cloud Skills Dominate: High-paying skills like PySpark ($208K), Databricks ($141K), and GCP ($122K) suggest a demand for cloud-based data processing and big data frameworks.
Companies seem to prioritize professionals who can work with distributed computing and cloud services.
2. Version Control & DevOps Influence Salaries: Bitbucket ($189K), GitLab ($154K), and Jenkins ($125K) suggest that version control and CI/CD pipelines are becoming crucial for data analysts.
Knowledge of DevOps and automation is increasingly valuable.
3. AI & Machine Learning Skills Stand Out: Tools like Watson ($160K), DataRobot ($155K), Scikit-Learn ($125K), and Airflow ($126K) show a strong demand for machine learning and MLOps.
Companies are willing to pay more for analysts who can build, deploy, and automate AI models.
4. Programming Languages & Data Science Libraries Matter: Swift ($153K), Golang ($145K), and Scala ($124K) indicate that knowledge beyond Python/R is valuable.
Python libraries like Pandas ($151K), NumPy ($143K), and Scikit-Learn ($125K) highlight the necessity of strong data manipulation and ML skills.
5. Search & Data Storage Technologies Are Lucrative:Elasticsearch ($145K), Couchbase ($160K), and PostgreSQL ($123K) suggest that expertise in database management and search engines is highly valued.
Companies dealing with large datasets are investing in professionals who understand indexing, querying, and optimization.


[
  {
    "skills": "pyspark",
    "avg_salary": "208172"
  },
  {
    "skills": "bitbucket",
    "avg_salary": "189155"
  },
  {
    "skills": "couchbase",
    "avg_salary": "160515"
  },
  {
    "skills": "watson",
    "avg_salary": "160515"
  },
  {
    "skills": "datarobot",
    "avg_salary": "155486"
  },
  {
    "skills": "gitlab",
    "avg_salary": "154500"
  },
  {
    "skills": "swift",
    "avg_salary": "153750"
  },
  {
    "skills": "jupyter",
    "avg_salary": "152777"
  },
  {
    "skills": "pandas",
    "avg_salary": "151821"
  },
  {
    "skills": "elasticsearch",
    "avg_salary": "145000"
  },
  {
    "skills": "golang",
    "avg_salary": "145000"
  },
  {
    "skills": "numpy",
    "avg_salary": "143513"
  },
  {
    "skills": "databricks",
    "avg_salary": "141907"
  },
  {
    "skills": "linux",
    "avg_salary": "136508"
  },
  {
    "skills": "kubernetes",
    "avg_salary": "132500"
  },
  {
    "skills": "atlassian",
    "avg_salary": "131162"
  },
  {
    "skills": "twilio",
    "avg_salary": "127000"
  },
  {
    "skills": "airflow",
    "avg_salary": "126103"
  },
  {
    "skills": "scikit-learn",
    "avg_salary": "125781"
  },
  {
    "skills": "jenkins",
    "avg_salary": "125436"
  },
  {
    "skills": "notion",
    "avg_salary": "125000"
  },
  {
    "skills": "scala",
    "avg_salary": "124903"
  },
  {
    "skills": "postgresql",
    "avg_salary": "123879"
  },
  {
    "skills": "gcp",
    "avg_salary": "122500"
  },
  {
    "skills": "microstrategy",
    "avg_salary": "121619"
  }
]




*/