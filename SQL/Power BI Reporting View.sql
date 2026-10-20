-- Power BI Reporting View

CREATE OR REPLACE VIEW vw_fraud_analysis_master AS
SELECT 
    t.transaction_id,
    t.transaction_timestamp,
    DATE(t.transaction_timestamp) AS txn_date,
    t.account_id,
    a.account_type,
    a.account_status,
    c.customer_id,
    c.risk_profile AS customer_risk_profile,
    c.kyc_status,
    c.city AS customer_city,
    c.credit_score,
    t.channel,
    t.transaction_type,
    t.amount,
    t.txn_status,
    t.failure_reason,
    m.merchant_id,
    COALESCE(m.merchant_name, 'Direct Transfer / P2P') AS merchant_name,
    COALESCE(m.category, 'P2P / Non-Merchant') AS merchant_category,
    COALESCE(m.risk_tier, 'LOW') AS merchant_risk_tier,
    CASE WHEN fa.alert_id IS NOT NULL THEN 1 ELSE 0 END AS is_flagged,
    fa.rule_triggered,
    fa.risk_score,
    fa.review_status
FROM fact_transactions t
JOIN dim_accounts a 
    ON t.account_id = a.account_id
JOIN dim_customers c 
    ON a.customer_id = c.customer_id
LEFT JOIN dim_merchants m 
    ON t.merchant_id = m.merchant_id
LEFT JOIN fact_fraud_alerts fa 
    ON t.transaction_id = fa.transaction_id;