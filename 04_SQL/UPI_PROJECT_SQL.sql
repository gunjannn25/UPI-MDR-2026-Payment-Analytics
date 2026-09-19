CREATE DATABASE upi_mdr_2026;
USE upi_mdr_2026;
CREATE TABLE upi_transactions (
    transaction_id VARCHAR(50),
    transaction_date DATE,
    transaction_amount DECIMAL(12,2),
    transaction_type VARCHAR(10),
    merchant_id VARCHAR(50),
    mcc INT,
    merchant_category VARCHAR(100),
    merchant_size VARCHAR(20),
    merchant_monthly_upi_receipts DECIMAL(12,2),
    merchant_region VARCHAR(50),
    payer_bank VARCHAR(100),
    acquirer_bank VARCHAR(100),
    transaction_status VARCHAR(20),
    upi_app VARCHAR(50),
    policy_version VARCHAR(50),
    source_type VARCHAR(50)
);

USE upi_mdr_2026;
ALTER TABLE upi_transactions
MODIFY COLUMN mcc VARCHAR(10);
TRUNCATE TABLE upi_transactions;

USE upi_mdr_2026;
DROP TABLE IF EXISTS upi_transactions;
CREATE TABLE upi_transactions (
    transaction_id VARCHAR(20),
    transaction_date VARCHAR(20),
    transaction_amount VARCHAR(30),
    transaction_type VARCHAR(10),
    merchant_id VARCHAR(20),
    mcc VARCHAR(10),
    merchant_category VARCHAR(100),
    merchant_size VARCHAR(20),
    merchant_monthly_upi_receipts VARCHAR(30),
    merchant_region VARCHAR(30),
    payer_bank VARCHAR(50),
    acquirer_bank VARCHAR(50),
    transaction_status VARCHAR(20),
    upi_app VARCHAR(50),
    policy_version VARCHAR(50),
    source_type VARCHAR(50)
);
USE upi_mdr_2026;
TRUNCATE TABLE upi_transactions;
LOAD DATA LOCAL INFILE 'C:/Users/lenovo/Desktop/UPI_MDR_2026/02_Raw_Data/UPI_MDR_Transactions.csv'
INTO TABLE upi_transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
USE upi_mdr_2026;

LOAD DATA LOCAL INFILE 'C:/Users/lenovo/Desktop/UPI_MDR_2026/02_Raw_Data/UPI_MDR_Transactions.csv'
INTO TABLE upi_transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

USE upi_mdr_2026;

TRUNCATE TABLE upi_transactions;
LOAD DATA LOCAL INFILE 'C:/Users/lenovo/Desktop/UPI_MDR_2026/02_Raw_Data/UPI_MDR_Transactions.csv'
INTO TABLE upi_transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_transactions
FROM upi_transactions;
SELECT *
FROM upi_transactions
LIMIT 10;
SELECT
    transaction_type,
    COUNT(*) AS transaction_count
FROM upi_transactions
GROUP BY transaction_type;

SELECT
    CASE
        WHEN CAST(transaction_amount AS DECIMAL(15,2)) <= 2000
            THEN 'Up to 2000'
        ELSE 'Above 2000'
    END AS amount_bucket,
    COUNT(*) AS transaction_count,
    ROUND(SUM(CAST(transaction_amount AS DECIMAL(15,2))), 2) AS total_value
FROM upi_transactions
WHERE transaction_type = 'P2M'
GROUP BY
    CASE
        WHEN CAST(transaction_amount AS DECIMAL(15,2)) <= 2000
            THEN 'Up to 2000'
        ELSE 'Above 2000'
    END;
    
    SELECT
    COUNT(*) AS eligible_transactions,
    ROUND(SUM(CAST(transaction_amount AS DECIMAL(15,2))), 2) AS eligible_value,
    ROUND(
        SUM(
            LEAST(
                CAST(transaction_amount AS DECIMAL(15,2)) * 0.004,
                300
            )
        ),
        2
    ) AS estimated_mdr
FROM upi_transactions
WHERE transaction_type = 'P2M'
  AND CAST(transaction_amount AS DECIMAL(15,2)) > 2000
  AND merchant_monthly_upi_receipts > 100000;

SELECT
    ROUND(
        SUM(
            LEAST(
                CAST(transaction_amount AS DECIMAL(15,2)) * 0.004,
                300
            )
        ),
        2
    ) AS estimated_mdr,

    ROUND(
        SUM(
            LEAST(
                CAST(transaction_amount AS DECIMAL(15,2)) * 0.004,
                300
            )
        ) * 0.05,
        2
    ) AS small_merchant_support_fund
FROM upi_transactions
WHERE transaction_type = 'P2M'
  AND CAST(transaction_amount AS DECIMAL(15,2)) > 2000
  AND merchant_monthly_upi_receipts > 100000;

SELECT
    COUNT(*) AS transactions_above_75000,
    ROUND(SUM(CAST(transaction_amount AS DECIMAL(15,2))), 2) AS transaction_value,
    ROUND(
        SUM(
            LEAST(
                CAST(transaction_amount AS DECIMAL(15,2)) * 0.004,
                300
            )
        ),
        2
    ) AS capped_mdr
FROM upi_transactions
WHERE transaction_type = 'P2M'
  AND CAST(transaction_amount AS DECIMAL(15,2)) >= 75000;


SELECT
    COUNT(*) AS p2m_transactions,
    SUM(
        CASE
            WHEN merchant_id IS NULL OR merchant_id = '' OR merchant_id = 'None'
            THEN 1
            ELSE 0
        END
    ) AS missing_merchant_id,
    SUM(
        CASE
            WHEN mcc IS NULL OR mcc = '' OR mcc = 'None'
            THEN 1
            ELSE 0
        END
    ) AS missing_mcc
FROM upi_transactions
WHERE transaction_type = 'P2M';

SELECT
    COUNT(*) AS duplicate_transaction_ids
FROM (
    SELECT transaction_id
    FROM upi_transactions
    GROUP BY transaction_id
    HAVING COUNT(*) > 1
) AS duplicates;

SELECT
    COUNT(*) AS invalid_amounts
FROM upi_transactions
WHERE transaction_amount IS NULL
   OR transaction_amount = ''
   OR CAST(transaction_amount AS DECIMAL(15,2)) <= 0;
   
   CREATE TABLE upi_transactions_clean AS
SELECT
    transaction_id,
    CAST(transaction_date AS DATE) AS transaction_date,
    CAST(transaction_amount AS DECIMAL(15,2)) AS transaction_amount,
    transaction_type,
    
    NULLIF(NULLIF(merchant_id, ''), 'None') AS merchant_id,
    NULLIF(NULLIF(mcc, ''), 'None') AS mcc,
    NULLIF(NULLIF(merchant_category, ''), 'None') AS merchant_category,
    NULLIF(NULLIF(merchant_size, ''), 'None') AS merchant_size,
    
    CAST(
        NULLIF(merchant_monthly_upi_receipts, '')
        AS DECIMAL(15,2)
    ) AS merchant_monthly_upi_receipts,
    
    merchant_region,
    payer_bank,
    acquirer_bank,
    transaction_status,
    upi_app,
    policy_version,
    source_type

FROM upi_transactions;


SELECT COUNT(*) AS clean_rows
FROM upi_transactions_clean;

SELECT
    transaction_id,
    transaction_type,
    transaction_amount,
    merchant_category,
    merchant_monthly_upi_receipts,

    CASE
        WHEN transaction_type = 'P2P'
            THEN 0

        WHEN transaction_amount <= 2000
            THEN 0

        WHEN merchant_monthly_upi_receipts <= 100000
            THEN 0

        WHEN merchant_category IN ('Fuel', 'Telecom', 'Railways')
            THEN 5

        WHEN merchant_category = 'Capital Markets'
            THEN LEAST(transaction_amount * 0.0002, 300)

        ELSE
            LEAST(transaction_amount * 0.004, 300)
    END AS estimated_mdr

FROM upi_transactions_clean;

SELECT
    transaction_type,
    COUNT(*) AS transaction_count,
    ROUND(SUM(transaction_amount), 2) AS transaction_value,
    ROUND(SUM(
        CASE
            WHEN transaction_type = 'P2P'
                THEN 0
            WHEN transaction_amount <= 2000
                THEN 0
            WHEN merchant_monthly_upi_receipts <= 100000
                THEN 0
            WHEN merchant_category IN ('Fuel', 'Telecom', 'Railways')
                THEN 5
            WHEN merchant_category = 'Capital Markets'
                THEN LEAST(transaction_amount * 0.0002, 300)
            ELSE
                LEAST(transaction_amount * 0.004, 300)
        END
    ), 2) AS estimated_mdr
FROM upi_transactions_clean
GROUP BY transaction_type;


SELECT
    merchant_category,
    COUNT(*) AS transaction_count,
    ROUND(SUM(transaction_amount), 2) AS transaction_value,
    ROUND(SUM(
        CASE
            WHEN transaction_amount <= 2000
                THEN 0
            WHEN merchant_monthly_upi_receipts <= 100000
                THEN 0
            WHEN merchant_category IN ('Fuel', 'Telecom', 'Railways')
                THEN 5
            WHEN merchant_category = 'Capital Markets'
                THEN LEAST(transaction_amount * 0.0002, 300)
            ELSE
                LEAST(transaction_amount * 0.004, 300)
        END
    ), 2) AS estimated_mdr
FROM upi_transactions_clean
WHERE transaction_type = 'P2M'
GROUP BY merchant_category
ORDER BY estimated_mdr DESC;


SELECT
    COUNT(*) AS transactions_affected_by_cap,
    ROUND(SUM(transaction_amount), 2) AS transaction_value,
    ROUND(
        SUM(transaction_amount * 0.004),
        2
    ) AS mdr_without_cap,
    ROUND(
        SUM(LEAST(transaction_amount * 0.004, 300)),
        2
    ) AS mdr_with_cap,
    ROUND(
        SUM(transaction_amount * 0.004)
        - SUM(LEAST(transaction_amount * 0.004, 300)),
        2
    ) AS revenue_reduction_from_cap
FROM upi_transactions_clean
WHERE transaction_type = 'P2M'
  AND transaction_amount >= 75000
  AND merchant_category NOT IN ('Fuel', 'Telecom', 'Railways', 'Capital Markets')
  AND merchant_monthly_upi_receipts > 100000;
  
  SELECT
    policy_version,
    source_type,
    COUNT(*) AS transaction_count
FROM upi_transactions_clean
GROUP BY
    policy_version,
    source_type
ORDER BY
    policy_version,
    source_type;
    
    P2M transaction/value mix
    SELECT
    COUNT(*) AS total_p2m_transactions,
    ROUND(SUM(transaction_amount), 2) AS total_p2m_value,

    ROUND(
        100.0 * SUM(
            CASE WHEN transaction_amount > 2000 THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS pct_p2m_txns_above_2000,

    ROUND(
        100.0 * SUM(
            CASE WHEN transaction_amount > 2000
                 THEN transaction_amount ELSE 0 END
        ) / SUM(transaction_amount),
        2
    ) AS pct_p2m_value_above_2000

FROM upi_transactions_clean
WHERE transaction_type = 'P2M';
    
MDR by region
SELECT
    merchant_region,
    COUNT(*) AS transaction_count,
    ROUND(SUM(transaction_amount), 2) AS transaction_value,

    ROUND(
        SUM(
            CASE
                WHEN transaction_amount <= 2000 THEN 0
                WHEN merchant_monthly_upi_receipts <= 100000 THEN 0
                WHEN merchant_category IN ('Fuel', 'Telecom', 'Railways') THEN 5
                WHEN merchant_category = 'Capital Markets'
                    THEN LEAST(transaction_amount * 0.0002, 300)
                ELSE LEAST(transaction_amount * 0.004, 300)
            END
        ),
        2
    ) AS estimated_mdr

FROM upi_transactions_clean
WHERE transaction_type = 'P2M'
GROUP BY merchant_region
ORDER BY estimated_mdr DESC;


MDR by UPI app
SELECT
    upi_app,
    COUNT(*) AS transaction_count,
    ROUND(SUM(transaction_amount), 2) AS transaction_value,

    ROUND(
        SUM(
            CASE
                WHEN transaction_type = 'P2P' THEN 0
                WHEN transaction_amount <= 2000 THEN 0
                WHEN merchant_monthly_upi_receipts <= 100000 THEN 0
                WHEN merchant_category IN ('Fuel', 'Telecom', 'Railways') THEN 5
                WHEN merchant_category = 'Capital Markets'
                    THEN LEAST(transaction_amount * 0.0002, 300)
                ELSE LEAST(transaction_amount * 0.004, 300)
            END
        ),
        2
    ) AS estimated_mdr

FROM upi_transactions_clean
GROUP BY upi_app
ORDER BY estimated_mdr DESC;

Transaction status analysis
SELECT
    transaction_status,
    COUNT(*) AS transaction_count,

    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM upi_transactions_clean),
        2
    ) AS percentage_of_transactions,

    ROUND(SUM(transaction_amount), 2) AS transaction_value

FROM upi_transactions_clean
GROUP BY transaction_status
ORDER BY transaction_count DESC;


--Potential MDR should exclude failed/reversed transactions
SELECT
    transaction_status,

    COUNT(*) AS eligible_transactions,

    ROUND(SUM(transaction_amount), 2) AS eligible_value,

    ROUND(
        SUM(
            CASE
                WHEN merchant_category IN ('Fuel', 'Telecom', 'Railways')
                    THEN 5
                WHEN merchant_category = 'Capital Markets'
                    THEN LEAST(transaction_amount * 0.0002, 300)
                ELSE LEAST(transaction_amount * 0.004, 300)
            END
        ),
        2
    ) AS estimated_mdr

FROM upi_transactions_clean

WHERE transaction_type = 'P2M'
  AND transaction_amount > 2000
  AND merchant_monthly_upi_receipts > 100000

GROUP BY transaction_status
ORDER BY estimated_mdr DESC;






CREATE TABLE kpi_summary AS

SELECT
    COUNT(*) AS total_transactions,

    SUM(CASE
        WHEN transaction_type = 'P2M' THEN 1
        ELSE 0
    END) AS p2m_transactions,

    SUM(CASE
        WHEN transaction_type = 'P2P' THEN 1
        ELSE 0
    END) AS p2p_transactions,

    ROUND(SUM(transaction_amount), 2) AS total_transaction_value,

    ROUND(SUM(CASE
        WHEN transaction_type = 'P2M'
        THEN transaction_amount
        ELSE 0
    END), 2) AS p2m_transaction_value,

    ROUND(
        100.0 *
        SUM(CASE WHEN transaction_type = 'P2M' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS p2m_volume_share,

    ROUND(
        100.0 *
        SUM(CASE
            WHEN transaction_type = 'P2M'
             AND transaction_amount > 2000
            THEN 1 ELSE 0
        END)
        /
        SUM(CASE
            WHEN transaction_type = 'P2M'
            THEN 1 ELSE 0
        END),
        2
    ) AS p2m_above_2000_share;

SELECT * FROM kpi_summary;

DESCRIBE upi_transactions_clean;


SELECT
    COUNT(*) AS total_transactions,

    SUM(CASE
        WHEN transaction_type = 'P2M' THEN 1
        ELSE 0
    END) AS p2m_transactions,

    SUM(CASE
        WHEN transaction_type = 'P2P' THEN 1
        ELSE 0
    END) AS p2p_transactions,

    ROUND(SUM(transaction_amount), 2) AS total_transaction_value,

    ROUND(
        SUM(
            CASE
                WHEN transaction_type = 'P2M'
                THEN transaction_amount
                ELSE 0
            END
        ),
        2
    ) AS p2m_transaction_value,

    ROUND(
        100.0 *
        SUM(CASE
            WHEN transaction_type = 'P2M' THEN 1
            ELSE 0
        END) / COUNT(*),
        2
    ) AS p2m_volume_share,

    ROUND(
        100.0 *
        SUM(CASE
            WHEN transaction_type = 'P2M'
             AND transaction_amount > 2000
            THEN 1
            ELSE 0
        END)
        /
        SUM(CASE
            WHEN transaction_type = 'P2M' THEN 1
            ELSE 0
        END),
        2
    ) AS p2m_above_2000_share

FROM upi_transactions_clean;

SELECT
    merchant_size,
    COUNT(*) AS transaction_count,
    ROUND(SUM(transaction_amount), 2) AS transaction_value,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*)
         FROM upi_transactions_clean
         WHERE transaction_type = 'P2M'),
        2
    ) AS transaction_share
FROM upi_transactions_clean
WHERE transaction_type = 'P2M'
GROUP BY merchant_size
ORDER BY transaction_count DESC;


SELECT
    merchant_category,
    COUNT(*) AS transaction_count,
    ROUND(SUM(transaction_amount), 2) AS transaction_value,

    ROUND(
        SUM(
            CASE
                WHEN transaction_amount <= 2000 THEN 0
                WHEN merchant_monthly_upi_receipts <= 100000 THEN 0
                WHEN merchant_category IN ('Fuel', 'Telecom', 'Railways') THEN 5
                WHEN merchant_category = 'Capital Markets'
                    THEN LEAST(transaction_amount * 0.0002, 300)
                ELSE
                    LEAST(transaction_amount * 0.004, 300)
            END
        ),
        2
    ) AS estimated_mdr

FROM upi_transactions_clean
WHERE transaction_type = 'P2M'

GROUP BY merchant_category
ORDER BY estimated_mdr DESC;

SELECT
    merchant_region,
    COUNT(*) AS transaction_count,
    ROUND(SUM(transaction_amount), 2) AS transaction_value,

    ROUND(
        SUM(
            CASE
                WHEN transaction_amount <= 2000 THEN 0
                WHEN merchant_monthly_upi_receipts <= 100000 THEN 0
                WHEN merchant_category IN ('Fuel', 'Telecom', 'Railways') THEN 5
                WHEN merchant_category = 'Capital Markets'
                    THEN LEAST(transaction_amount * 0.0002, 300)
                ELSE
                    LEAST(transaction_amount * 0.004, 300)
            END
        ),
        2
    ) AS estimated_mdr

FROM upi_transactions_clean
WHERE transaction_type = 'P2M'

GROUP BY merchant_region
ORDER BY estimated_mdr DESC;

SELECT
    transaction_status,
    COUNT(*) AS transaction_count,
    ROUND(SUM(transaction_amount), 2) AS transaction_value,

    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM upi_transactions_clean),
        2
    ) AS transaction_share

FROM upi_transactions_clean

GROUP BY transaction_status
ORDER BY transaction_count DESC;


SELECT
    COUNT(*) AS successful_eligible_transactions,

    ROUND(
        SUM(transaction_amount),
        2
    ) AS successful_transaction_value,

    ROUND(
        SUM(
            CASE
                WHEN merchant_category IN ('Fuel', 'Telecom', 'Railways')
                    THEN 5

                WHEN merchant_category = 'Capital Markets'
                    THEN LEAST(transaction_amount * 0.0002, 300)

                ELSE
                    LEAST(transaction_amount * 0.004, 300)
            END
        ),
        2
    ) AS successful_estimated_mdr

FROM upi_transactions_clean

WHERE transaction_type = 'P2M'
  AND transaction_status = 'Success'
  AND transaction_amount > 2000
  AND merchant_monthly_upi_receipts > 100000;
  
  
  
  SELECT
    acquirer_bank,
    COUNT(*) AS transaction_count,
    ROUND(SUM(transaction_amount), 2) AS transaction_value,

    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*)
         FROM upi_transactions_clean
         WHERE transaction_type = 'P2M'),
        2
    ) AS transaction_share

FROM upi_transactions_clean

WHERE transaction_type = 'P2M'

GROUP BY acquirer_bank
ORDER BY transaction_count DESC;

Executive KPI summary
SELECT
    COUNT(*) AS total_transactions,

    SUM(transaction_type = 'P2M') AS p2m_transactions,

    SUM(transaction_type = 'P2P') AS p2p_transactions,

    ROUND(SUM(transaction_amount), 2) AS total_transaction_value,

    ROUND(
        SUM(CASE
            WHEN transaction_type = 'P2M'
            THEN transaction_amount
            ELSE 0
        END),
        2
    ) AS p2m_transaction_value,

    ROUND(
        100 * SUM(transaction_type = 'P2M') / COUNT(*),
        2
    ) AS p2m_volume_share,

    SUM(
        transaction_type = 'P2M'
        AND transaction_amount > 2000
    ) AS p2m_above_2000_transactions,

    ROUND(
        100 *
        SUM(
            transaction_type = 'P2M'
            AND transaction_amount > 2000
        )
        /
        SUM(transaction_type = 'P2M'),
        2
    ) AS p2m_above_2000_share

FROM upi_transactions_clean;


SELECT

    COUNT(*) AS eligible_transactions,

    ROUND(
        SUM(transaction_amount),
        2
    ) AS eligible_transaction_value,

    ROUND(
        SUM(
            CASE
                WHEN merchant_category IN ('Fuel', 'Telecom', 'Railways')
                    THEN 5

                WHEN merchant_category = 'Capital Markets'
                    THEN LEAST(transaction_amount * 0.0002, 300)

                ELSE
                    LEAST(transaction_amount * 0.004, 300)
            END
        ),
        2
    ) AS estimated_mdr,

    ROUND(
        SUM(
            CASE
                WHEN merchant_category IN ('Fuel', 'Telecom', 'Railways')
                    THEN 5

                WHEN merchant_category = 'Capital Markets'
                    THEN LEAST(transaction_amount * 0.0002, 300)

                ELSE
                    LEAST(transaction_amount * 0.004, 300)
            END
        ) * 0.05,
        2
    ) AS support_fund_5pct

FROM upi_transactions_clean

WHERE transaction_type = 'P2M'
  AND transaction_status = 'Success'
  AND transaction_amount > 2000
  AND merchant_monthly_upi_receipts > 100000;
  
  
  SELECT

    COUNT(*) AS total_records,

    COUNT(DISTINCT transaction_id) AS unique_transaction_ids,

    SUM(
        CASE
            WHEN transaction_id IS NULL
              OR transaction_id = ''
            THEN 1 ELSE 0
        END
    ) AS missing_transaction_ids,

    SUM(
        CASE
            WHEN transaction_amount IS NULL
              OR transaction_amount <= 0
            THEN 1 ELSE 0
        END
    ) AS invalid_amounts,

    SUM(
        CASE
            WHEN transaction_type = 'P2M'
             AND (merchant_id IS NULL OR merchant_id = '')
            THEN 1 ELSE 0
        END
    ) AS missing_p2m_merchant_ids,

    SUM(
        CASE
            WHEN transaction_type = 'P2M'
             AND (mcc IS NULL OR mcc = '')
            THEN 1 ELSE 0
        END
    ) AS missing_p2m_mccs

FROM upi_transactions_clean;


DROP TABLE IF EXISTS transaction_mdr_analysis;

CREATE TABLE transaction_mdr_analysis AS
SELECT
    transaction_id,
    transaction_date,
    transaction_amount,
    transaction_type,
    merchant_id,
    mcc,
    merchant_category,
    merchant_size,
    merchant_monthly_upi_receipts,
    merchant_region,
    payer_bank,
    acquirer_bank,
    transaction_status,
    upi_app,
    policy_version,
    source_type,

    CASE
        WHEN transaction_type = 'P2P'
            THEN 0

        WHEN transaction_amount <= 2000
            THEN 0

        WHEN merchant_monthly_upi_receipts <= 100000
            THEN 0

        WHEN merchant_category IN ('Fuel', 'Telecom', 'Railways')
            THEN 5

        WHEN merchant_category = 'Capital Markets'
            THEN LEAST(transaction_amount * 0.0002, 300)

        ELSE
            LEAST(transaction_amount * 0.004, 300)
    END AS estimated_mdr,

    CASE
        WHEN transaction_type = 'P2P'
            THEN 'P2P - No MDR'

        WHEN transaction_amount <= 2000
            THEN 'P2M <= 2000 - No MDR'

        WHEN merchant_monthly_upi_receipts <= 100000
            THEN 'Small Merchant - No MDR'

        WHEN merchant_category IN ('Fuel', 'Telecom', 'Railways')
            THEN 'Essential Sector - Flat 5'

        WHEN merchant_category = 'Capital Markets'
            THEN 'Capital Market - 0.02%'

        ELSE
            'Standard P2M - 0.4%'
    END AS mdr_rule_applied

FROM upi_transactions_clean;


SELECT
    mdr_rule_applied,
    COUNT(*) AS transaction_count,
    ROUND(SUM(transaction_amount), 2) AS transaction_value,
    ROUND(SUM(estimated_mdr), 2) AS estimated_mdr
FROM transaction_mdr_analysis
GROUP BY mdr_rule_applied
ORDER BY estimated_mdr DESC;


--MDR rule summary--

SELECT
    mdr_rule_applied,
    COUNT(*) AS transaction_count,
    ROUND(SUM(transaction_amount), 2) AS transaction_value,
    ROUND(SUM(estimated_mdr), 2) AS estimated_mdr,

    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM transaction_mdr_analysis),
        2
    ) AS transaction_share

FROM transaction_mdr_analysis

GROUP BY mdr_rule_applied

ORDER BY estimated_mdr DESC;

--Category-level business findings--
SELECT
    merchant_category,
    COUNT(*) AS transaction_count,
    ROUND(SUM(transaction_amount), 2) AS transaction_value,
    ROUND(SUM(estimated_mdr), 2) AS estimated_mdr,

    ROUND(
        100.0 * SUM(estimated_mdr) /
        NULLIF(
            (SELECT SUM(estimated_mdr)
             FROM transaction_mdr_analysis
             WHERE transaction_type = 'P2M'
               AND transaction_status = 'Success'),
            0
        ),
        2
    ) AS mdr_share

FROM transaction_mdr_analysis

WHERE transaction_type = 'P2M'
  AND transaction_status = 'Success'

GROUP BY merchant_category

ORDER BY estimated_mdr DESC;


--Daily MDR trend--
SELECT
    transaction_date,
    COUNT(*) AS transaction_count,

    ROUND(
        SUM(transaction_amount),
        2
    ) AS transaction_value,

    ROUND(
        SUM(estimated_mdr),
        2
    ) AS estimated_mdr

FROM transaction_mdr_analysis

WHERE transaction_type = 'P2M'
  AND transaction_status = 'Success'

GROUP BY transaction_date

ORDER BY transaction_date;

--Management Findings output--
SELECT
    'P2M concentration' AS finding_area,
    'P2M represents approximately 63% of transactions' AS finding,
    'Merchant payment activity is the primary transaction type in the synthetic dataset' AS business_implication

UNION ALL

SELECT
    '₹2,000 threshold',
    'Approximately 4% of P2M transactions are above ₹2,000',
    'A relatively small transaction count can represent a much larger share of payment value'

UNION ALL

SELECT
    'MDR cap',
    'Transactions at or above ₹75,000 are subject to the ₹300 cap',
    'A cap prevents MDR from increasing proportionally with transaction value above the cap'

UNION ALL

SELECT
    'Data governance',
    'Transaction IDs, P2M merchant IDs, P2M MCCs and transaction amounts passed the basic controls',
    'Clean and validated transaction data reduces the risk of incorrect policy calculations';


--Governance Findings--
SELECT
    'Completeness' AS control_area,
    'P2M merchant ID completeness' AS control,
    '0 missing records' AS result,
    'PASS' AS status

UNION ALL

SELECT
    'Completeness',
    'P2M MCC completeness',
    '0 missing records',
    'PASS'

UNION ALL

SELECT
    'Uniqueness',
    'Transaction ID uniqueness',
    '0 duplicate transaction IDs',
    'PASS'

UNION ALL

SELECT
    'Validity',
    'Transaction amount validation',
    '0 invalid or non-positive amounts',
    'PASS'

UNION ALL

SELECT
    'Lineage',
    'Policy version and source type',
    'MDR_2026 / Synthetic_Calibrated',
    'TRACEABLE';
    
    SELECT
    acquirer_bank,
    COUNT(*) AS transaction_count,
    ROUND(SUM(transaction_amount), 2) AS transaction_value,
    ROUND(SUM(estimated_mdr), 2) AS estimated_mdr
FROM transaction_mdr_analysis
WHERE transaction_type = 'P2M'
  AND transaction_status = 'Success'
GROUP BY acquirer_bank
ORDER BY transaction_value DESC;

SELECT
    upi_app,
    COUNT(*) AS transaction_count,
    ROUND(SUM(transaction_amount), 2) AS transaction_value,
    ROUND(SUM(estimated_mdr), 2) AS estimated_mdr
FROM transaction_mdr_analysis
WHERE transaction_status = 'Success'
GROUP BY upi_app
ORDER BY transaction_value DESC;