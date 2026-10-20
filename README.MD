# 🏦 FinGuard Bank — Digital Banking & Fraud Risk Analytics Engine

[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue.svg)](https://www.mysql.com/)
[![Python](https://img.shields.io/badge/Python-3.11+-yellow.svg)](https://www.python.org/)
[![Power BI](https://img.shields.io/badge/Power_BI-Desktop-F2C811.svg)](https://powerbi.microsoft.com/)
[![SQLAlchemy](https://img.shields.io/badge/SQLAlchemy-2.0-red.svg)](https://www.sqlalchemy.org/)

An enterprise-grade financial risk analytics platform simulating core transactional ledgers, compliance constraints, and automated fraud-detection engines for **FinGuard Bank**. This project models **30,000 customers**, **35,000 accounts**, and **100,000 transactions** with synthetic fraud anomaly injection, evaluated through advanced SQL queries and business intelligence reporting.

---

## 📌 Executive Summary & Business Objective

Modern retail banks process millions of electronic payments (UPI, Cards, Net Banking, POS) daily. The core challenge is **balancing transaction throughput with risk mitigation**—intercepting money laundering, bot drains, and compromised merchant transactions in real time without increasing false-positive friction for legitimate users.

This project delivers:
1. **Relational Schema Design:** Normalized DDL schema in MySQL with foreign key referential integrity constraints.
2. **Synthetic Data Generation (ETL):** Python data generation pipeline using `Faker`, `NumPy`, and `SQLAlchemy` that injects realistic statistical anomaly patterns.
3. **Diagnostic SQL Analytics:** Complex SQL queries utilizing Common Table Expressions (CTEs), rolling time-window analytical functions (`LAG`), and conditional aggregations.
4. **Semantic Reporting Layer:** Clean SQL reporting views tailored for direct consumption in Power BI dashboards.

---

## 🏗️ Data Architecture & Entity-Relationship Schema

### Table Definitions
* **`dim_customers`**: Master demographic and compliance records (Customer ID, Name, KYC Verification Status, Credit Score, Risk Profile).
* **`dim_accounts`**: Account-level financial records (Account Number, Type, Balance, Account Status).
* **`dim_merchants`**: Merchant catalog classified by **Merchant Category Codes (MCC)** and risk tiers (Low, Elevated, High-Risk).
* **`fact_transactions`**: Complete ledger capturing channel (UPI, Net Banking, Cards, ATM), transaction type, amount, status, and precise timestamps.
* **`fact_fraud_alerts`**: Automated fraud monitoring engine outputs linking flagged transactions to rules, risk scores, and investigation outcomes.

---

## 🚨 Injected Fraud Patterns (Analytical Core)

The dataset introduces 3 deliberate fraud scenarios representing ~4% of total traffic:
1. **Velocity Spikes (Rapid Succession Drains):** High-frequency transfers executed within 300 seconds of each other on the same account.
2. **Unusual High-Amount Anomalies:** Sudden outlier debits (₹2,50,000 – ₹7,50,000) that deviate significantly from individual account baselines.
3. **High-Risk MCC Exposure:** High-frequency payment routing toward risky merchant categories (MCC 7995: Online Gambling, MCC 6051: Crypto Exchanges, MCC 4829: Wire Transfers).

---

## 💻 Core SQL Analytical Queries

### 1. High-Risk Merchant Category Exposure & Block Rates
Isolates which merchant business sectors generate the highest transaction volumes and block frequencies.
```sql
SELECT 
    m.category AS merchant_category,
    m.risk_tier,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(SUM(t.amount), 2) AS total_volume_inr,
    SUM(CASE WHEN t.txn_status = 'BLOCKED' THEN 1 ELSE 0 END) AS blocked_count,
    ROUND(
        (SUM(CASE WHEN t.txn_status = 'BLOCKED' THEN 1 ELSE 0 END) / COUNT(t.transaction_id)) * 100, 
        2
    ) AS block_rate_pct
FROM dim_merchants m
JOIN fact_transactions t ON m.merchant_id = t.merchant_id
GROUP BY m.category, m.risk_tier
ORDER BY block_rate_pct DESC, total_volume_inr DESC;

### 2. Rolling Time-Window Velocity Spike Detection

WITH AccountTransactionSequence AS (
    SELECT 
        t.transaction_id,
        t.account_id,
        t.amount,
        t.channel,
        t.transaction_timestamp,
        LAG(t.transaction_timestamp) OVER (
            PARTITION BY t.account_id 
            ORDER BY t.transaction_timestamp
        ) AS previous_txn_timestamp,
        LAG(t.amount) OVER (
            PARTITION BY t.account_id 
            ORDER BY t.transaction_timestamp
        ) AS previous_txn_amount
    FROM fact_transactions t
)
SELECT 
    transaction_id,
    account_id,
    amount AS current_txn_amount,
    previous_txn_amount,
    channel,
    TIMESTAMPDIFF(SECOND, previous_txn_timestamp, transaction_timestamp) AS seconds_since_prior_txn
FROM AccountTransactionSequence
WHERE previous_txn_timestamp IS NOT NULL
  AND TIMESTAMPDIFF(SECOND, previous_txn_timestamp, transaction_timestamp) <= 300
ORDER BY seconds_since_prior_txn ASC;

### 3. Payment Vulnerability and Confirmed Loss

SELECT 
    t.channel,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(SUM(t.amount), 2) AS total_volume_inr,
    COUNT(fa.alert_id) AS total_fraud_alerts,
    ROUND((COUNT(fa.alert_id) / COUNT(t.transaction_id)) * 100, 2) AS alert_trigger_rate_pct,
    ROUND(SUM(CASE WHEN fa.review_status = 'CONFIRMED_FRAUD' THEN t.amount ELSE 0 END), 2) AS confirmed_fraud_loss_inr
FROM fact_transactions t
LEFT JOIN fact_fraud_alerts fa ON t.transaction_id = fa.transaction_id
GROUP BY t.channel
ORDER BY confirmed_fraud_loss_inr DESC;


---

## 👤 Author
**Gokul Aditya Mulasa**  
* LinkedIn: [linkedin.com/in/aditya-mulasa](https://linkedin.com/in/aditya-mulasa/)  
* GitHub: [github.com/adityamulasa-05](https://github.com/adityamulasa-05)

The database follows a **Star/Snowflake Hybrid Architecture**:
