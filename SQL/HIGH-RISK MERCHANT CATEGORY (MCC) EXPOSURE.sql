-- HIGH-RISK MERCHANT CATEGORY (MCC) EXPOSURE

SELECT 
    m.category AS merchant_category,
    m.risk_tier,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(SUM(t.amount), 2) AS total_volume_inr,
    ROUND(AVG(t.amount), 2) AS avg_txn_value_inr,
    SUM(CASE WHEN t.txn_status = 'BLOCKED' THEN 1 ELSE 0 END) AS blocked_count,
    ROUND(
        (SUM(CASE WHEN t.txn_status = 'BLOCKED' THEN 1 ELSE 0 END) / COUNT(t.transaction_id)) * 100, 
        2
    ) AS block_rate_pct
FROM dim_merchants m
JOIN fact_transactions t ON m.merchant_id = t.merchant_id
GROUP BY m.category, m.risk_tier
ORDER BY block_rate_pct DESC, total_volume_inr DESC;