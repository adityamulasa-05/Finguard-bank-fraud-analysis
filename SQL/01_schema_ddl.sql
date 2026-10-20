-- Create database with UTF-8 support
CREATE DATABASE IF NOT EXISTS finguard_bank_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE finguard_bank_db;

-- -------------------------------------------------------------
-- 1. DIMENSION: CUSTOMERS
-- -------------------------------------------------------------
CREATE TABLE dim_customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    kyc_status ENUM('PENDING', 'VERIFIED', 'REJECTED') DEFAULT 'PENDING',
    risk_profile ENUM('LOW', 'MEDIUM', 'HIGH') DEFAULT 'LOW',
    credit_score INT CHECK (credit_score BETWEEN 300 AND 850),
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) DEFAULT 'India',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
-- 2. DIMENSION: ACCOUNTS
-- -------------------------------------------------------------
CREATE TABLE dim_accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    account_type ENUM('SAVINGS', 'CHECKING', 'CREDIT', 'INVESTMENT') NOT NULL,
    current_balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'INR',
    account_status ENUM('ACTIVE', 'DORMANT', 'FROZEN', 'CLOSED') DEFAULT 'ACTIVE',
    opened_date DATE NOT NULL,
    CONSTRAINT fk_accounts_customer FOREIGN KEY (customer_id) 
        REFERENCES dim_customers(customer_id) ON DELETE RESTRICT
);

-- -------------------------------------------------------------
-- 3. DIMENSION: MERCHANTS
-- -------------------------------------------------------------
CREATE TABLE dim_merchants (
    merchant_id INT AUTO_INCREMENT PRIMARY KEY,
    merchant_name VARCHAR(100) NOT NULL,
    mcc_code VARCHAR(10) NOT NULL COMMENT 'Merchant Category Code',
    category VARCHAR(50) NOT NULL,
    risk_tier ENUM('LOW', 'ELEVATED', 'HIGH_RISK') DEFAULT 'LOW',
    merchant_country VARCHAR(50) DEFAULT 'India',
    is_active BOOLEAN DEFAULT TRUE
);

-- -------------------------------------------------------------
-- 4. FACT: TRANSACTIONS (CORE LEDGER)
-- -------------------------------------------------------------
CREATE TABLE fact_transactions (
    transaction_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    merchant_id INT NULL COMMENT 'NULL for P2P/ATM withdrawals',
    transaction_type ENUM('DEBIT', 'CREDIT', 'TRANSFER_OUT', 'TRANSFER_IN') NOT NULL,
    channel ENUM('UPI', 'POS', 'NET_BANKING', 'ATM', 'CARD_ONLINE') NOT NULL,
    amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(3) DEFAULT 'INR',
    txn_status ENUM('SUCCESS', 'FAILED', 'REVERSED', 'BLOCKED') DEFAULT 'SUCCESS',
    failure_reason VARCHAR(100) NULL,
    transaction_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_txn_account FOREIGN KEY (account_id) 
        REFERENCES dim_accounts(account_id) ON DELETE RESTRICT,
    CONSTRAINT fk_txn_merchant FOREIGN KEY (merchant_id) 
        REFERENCES dim_merchants(merchant_id) ON DELETE SET NULL,
    INDEX idx_account_time (account_id, transaction_timestamp),
    INDEX idx_txn_time (transaction_timestamp)
);

-- -------------------------------------------------------------
-- 5. FACT: AUTHENTICATION & ACCESS LOGS (TELEMETRY)
-- -------------------------------------------------------------
CREATE TABLE fact_auth_logs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    device_fingerprint VARCHAR(64) NOT NULL,
    auth_channel ENUM('MOBILE_APP', 'WEB_PORTAL', 'API') NOT NULL,
    is_success BOOLEAN NOT NULL,
    failure_code VARCHAR(30) NULL COMMENT 'e.g., INVALID_OTP, BAD_PASSWORD',
    location_city VARCHAR(50) NOT NULL,
    attempt_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_auth_customer FOREIGN KEY (customer_id) 
        REFERENCES dim_customers(customer_id) ON DELETE CASCADE,
    INDEX idx_cust_auth_time (customer_id, attempt_timestamp)
);

-- -------------------------------------------------------------
-- 6. FACT: FRAUD ALERTS & INVESTIGATIONS
-- -------------------------------------------------------------
CREATE TABLE fact_fraud_alerts (
    alert_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    transaction_id BIGINT NOT NULL UNIQUE,
    rule_triggered ENUM(
        'VELOCITY_SPIKE', 
        'GEOGRAPHIC_IMPOSSIBILITY', 
        'UNUSUAL_HIGH_AMOUNT', 
        'HIGH_RISK_MCC', 
        'MULTIPLE_AUTH_FAILURES'
    ) NOT NULL,
    risk_score INT CHECK (risk_score BETWEEN 0 AND 100),
    review_status ENUM('OPEN', 'UNDER_INVESTIGATION', 'CONFIRMED_FRAUD', 'FALSE_POSITIVE') DEFAULT 'OPEN',
    analyst_notes TEXT NULL,
    flagged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    CONSTRAINT fk_fraud_txn FOREIGN KEY (transaction_id) 
        REFERENCES fact_transactions(transaction_id) ON DELETE CASCADE
);