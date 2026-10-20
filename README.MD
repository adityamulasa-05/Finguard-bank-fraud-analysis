\# 🏦 FinGuard Bank — Digital Banking \& Fraud Risk Analytics Engine



\[!\[MySQL](https://img.shields.io/badge/MySQL-8.0-blue.svg)](https://www.mysql.com/)

\[!\[Python](https://img.shields.io/badge/Python-3.11+-yellow.svg)](https://www.python.org/)

\[!\[Power BI](https://img.shields.io/badge/Power\_BI-Desktop-F2C811.svg)](https://powerbi.microsoft.com/)

\[!\[SQLAlchemy](https://img.shields.io/badge/SQLAlchemy-2.0-red.svg)](https://www.sqlalchemy.org/)



An enterprise-grade financial risk analytics platform simulating core transactional ledgers, compliance constraints, and automated fraud-detection engines for \*\*FinGuard Bank\*\*. This project models \*\*30,000 customers\*\*, \*\*35,000 accounts\*\*, and \*\*100,000 transactions\*\* with synthetic fraud anomaly injection, evaluated through advanced SQL queries and business intelligence reporting.



\---



\## 📌 Executive Summary \& Business Objective



Modern retail banks process millions of electronic payments (UPI, Cards, Net Banking, POS) daily. The core challenge is \*\*balancing transaction throughput with risk mitigation\*\*—intercepting money laundering, bot drains, and compromised merchant transactions in real time without increasing false-positive friction for legitimate users.



This project delivers:

1\. \*\*Relational Schema Design:\*\* Normalized DDL schema in MySQL with foreign key referential integrity constraints.

2\. \*\*Synthetic Data Generation (ETL):\*\* Python data generation pipeline using `Faker`, `NumPy`, and `SQLAlchemy` that injects realistic statistical anomaly patterns.

3\. \*\*Diagnostic SQL Analytics:\*\* Complex SQL queries utilizing Common Table Expressions (CTEs), rolling time-window analytical functions (`LAG`), and conditional aggregations.

4\. \*\*Semantic Reporting Layer:\*\* Clean SQL reporting views tailored for direct consumption in Power BI dashboards.



\---



\## 🏗️ Data Architecture \& Entity-Relationship Schema



The database follows a \*\*Star/Snowflake Hybrid Architecture\*\*:

