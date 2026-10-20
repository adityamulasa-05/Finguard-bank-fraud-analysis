-- Customer Risk Tier vs. Confirmed Fraud Exposure

SELECT 
    c.risk_profile AS customer_risk_tier,
    c.kyc_status,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT t.transaction_id) AS total_transactions,
    ROUND(SUM(t.amount), 2) AS total_volume_inr,
    COUNT(fa.alert_id) AS total_alerts_triggered,
    ROUND(
        SUM(CASE WHEN fa.review_status = 'CONFIRMED_FRAUD' THEN t.amount ELSE 0 END), 
        2
    ) AS confirmed_fraud_loss_inr,
    ROUND(
        (SUM(CASE WHEN fa.review_status = 'CONFIRMED_FRAUD' THEN t.amount ELSE 0 END) / NULLIF(SUM(t.amount), 0)) * 100,
        3
    ) AS fraud_loss_rate_pct
FROM dim_customers c
JOIN dim_accounts a 
    ON c.customer_id = a.customer_id
JOIN fact_transactions t 
    ON a.account_id = t.account_id
LEFT JOIN fact_fraud_alerts fa 
    ON t.transaction_id = fa.transaction_id
GROUP BY c.risk_profile, c.kyc_status
ORDER BY confirmed_fraud_loss_inr DESC;