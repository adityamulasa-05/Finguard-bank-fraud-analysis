-- Rapid Velocity Spike Detection (Window Functions & CTE)

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
    transaction_timestamp AS current_txn_time,
    previous_txn_timestamp,
    TIMESTAMPDIFF(SECOND, previous_txn_timestamp, transaction_timestamp) AS seconds_since_prior_txn
FROM AccountTransactionSequence
WHERE previous_txn_timestamp IS NOT NULL
  AND TIMESTAMPDIFF(SECOND, previous_txn_timestamp, transaction_timestamp) <= 300
ORDER BY seconds_since_prior_txn ASC;