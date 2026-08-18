# E-commerce Data Analysis

E-commerce data analysis project using SQL in BigQuery and data visualization in Tableau and Looker Studio.

## Project Overview

The project focuses on analyzing e-commerce data to identify key business metrics and customer behavior patterns.

The analysis was performed using SQL in BigQuery, with the resulting data used to create interactive dashboards and visualizations.

## Tools & Technologies

- SQL
- Google BigQuery
- Tableau Public
- Looker Studio

## SQL Analysis

A SQL query was created to prepare and analyze the e-commerce dataset.

The query combines the required data, calculates relevant metrics, and creates a dataset for further analysis and visualization.

SQL query:

[`ecommerce_analysis.sql`](sql/ecommerce_analysis.sql)

## Data Visualization

### Tableau Public

The results of the analysis were visualized in three interactive Tableau dashboards:

- [Session Analysis](https://public.tableau.com/app/profile/mariia.mykolenko/viz/SessionAnalysis_17683333756460/SessionAnalysis)
- [Sales Dashboard](https://public.tableau.com/app/profile/mariia.mykolenko/viz/Sales_17684490311720/sales)
- [Email Metrics](https://public.tableau.com/app/profile/mariia.mykolenko/viz/EmailMetrics_17685183524240/Dashboard1)

### Looker Studio

A dashboard was also created in Looker Studio as part of the original educational project.

The original BigQuery dataset was provided through the educational environment and is no longer accessible. Therefore, the completed Looker Studio dashboard is included in the repository as a screenshot for reference.

## Key Insights

The analysis provides insights into:

- user sessions and customer behavior;
- sales performance;
- email marketing metrics;
- key e-commerce performance indicators.

## Project Structure

```text
sql-ecommerce-analysis/
│
├── README.md
├── sql/
│   └── ecommerce_analysis.sql
│
└── screenshots/
    └── looker_studio_dashboard.png
