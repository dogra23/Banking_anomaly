create database paysim;
use paysim;

CREATE TABLE transactions (
    step INT,
    type VARCHAR(20),
    amount DECIMAL(18,2),
    nameOrig VARCHAR(20),
    oldBalanceOrg DECIMAL(18,2),
    newBalanceOrig DECIMAL(18,2),
    nameDest VARCHAR(20),
    oldBalanceDest DECIMAL(18,2),
    newBalanceDest DECIMAL(18,2),
    isFraud INT,
    isFlaggedFraud INT
);


CREATE OR REPLACE VIEW suspicious_transactions AS
SELECT *
FROM transactions
WHERE (type IN ('TRANSFER', 'CASH_OUT') AND amount > 100000)
   OR oldbalanceOrg < amount
   OR isFlaggedFraud = 1;

CREATE OR REPLACE VIEW user_risk_scores AS
SELECT nameOrig,
       SUM(CASE WHEN type IN ('TRANSFER','CASH_OUT') AND amount>100000 THEN 2 ELSE 0 END
           + CASE WHEN oldbalanceOrg < amount THEN 3 ELSE 0 END
           + CASE WHEN isFlaggedFraud = 1 THEN 2 ELSE 0 END
           + CASE WHEN txn_count > 5 THEN 1 ELSE 0 END) AS risk_score
FROM (
    SELECT t.*, COUNT(*) OVER (PARTITION BY nameOrig, step) AS txn_count
    FROM transactions t
) t
GROUP BY nameOrig;










