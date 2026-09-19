import pandas as pd
import numpy as np

n = 100000

transaction_type = np.random.choice(
    ["P2M", "P2P"],
    size=n,
    p=[0.63, 0.37]
)

transaction_date = pd.to_datetime(
    np.random.choice(
        pd.date_range("2026-10-15", "2026-10-31"),
        size=n
    )
)
# Create an empty amount column
transaction_amount = np.zeros(n)

# Find which rows are P2M
p2m_rows = np.where(transaction_type == "P2M")[0]

# Divide P2M transactions into 3 amount groups
p2m_bucket = np.random.choice(
    ["Low", "Medium", "High"],
    size=len(p2m_rows),
    p=[0.86, 0.10, 0.04]
)

# Low-value P2M: ₹50–₹500
low_rows = p2m_rows[p2m_bucket == "Low"]

transaction_amount[low_rows] = np.random.uniform(
    50,
    500,
    size=len(low_rows)
)

# Medium-value P2M: ₹501–₹2,000
medium_rows = p2m_rows[p2m_bucket == "Medium"]

transaction_amount[medium_rows] = np.random.uniform(
    501,
    2000,
    size=len(medium_rows)
)

# High-value P2M: above ₹2,000
high_rows = p2m_rows[p2m_bucket == "High"]

transaction_amount[high_rows] = np.random.lognormal(
    mean=np.log(7000),
    sigma=1.05,
    size=len(high_rows)
)

# Keep high-value transactions within a reasonable range
transaction_amount[high_rows] = np.clip(
    transaction_amount[high_rows],
    2001,
    150000
)
# Find which rows are P2P
p2p_rows = np.where(transaction_type == "P2P")[0]

# Generate P2P transaction amounts
transaction_amount[p2p_rows] = np.clip(
    np.random.lognormal(
        mean=np.log(1500),
        sigma=0.9,
        size=len(p2p_rows)
    ),
    50,
    100000
)

# Round amounts to 2 decimal places
transaction_amount = np.round(
    transaction_amount,
    2
)

print("Number of transactions:", len(transaction_amount))
print("First 10 transaction amounts:", transaction_amount[:10])

# Create a merchant ID for each transaction
merchant_id = np.array([
    f"M{np.random.randint(1, 12001):05d}"
    for _ in range(n)
])
# Round amounts to 2 decimal places
transaction_amount = np.round(
    transaction_amount,
    2
)

# Create a merchant ID for each transaction
merchant_id = np.array([
    f"M{np.random.randint(1, 12001):05d}"
    for _ in range(n)
])
# Assign each merchant a size
merchant_size = np.random.choice(
    ["Small", "Medium", "Large"],
    size=n,
    p=[0.55, 0.30, 0.15]
)

# Estimate each merchant's monthly UPI QR receipts
merchant_monthly_upi_receipts = np.where(
    merchant_size == "Small",
    np.random.uniform(10000, 100000, n),
    np.where(
        merchant_size == "Medium",
        np.random.uniform(100001, 1000000, n),
        np.random.uniform(1000001, 10000000, n)
    )
)

merchant_monthly_upi_receipts = np.round(
    merchant_monthly_upi_receipts,
    2
)
print("Number of transactions:", len(transaction_amount))
print("First 10 transaction amounts:", transaction_amount[:10])
print("First 10 merchant IDs:", merchant_id[:10])

# Define merchant categories and their MCC codes
merchant_categories = [
    ("5411", "Grocery"),
    ("5812", "Restaurant"),
    ("5814", "Fast Food"),
    ("5541", "Fuel"),
    ("4814", "Telecom"),
    ("4112", "Railways"),
    ("6211", "Capital Markets"),
    ("5732", "Electronics"),
    ("5311", "Department Stores"),
    ("5999", "Other Retail")
]

# Probability of each merchant category
category_probability = [
    0.22,
    0.14,
    0.08,
    0.08,
    0.06,
    0.03,
    0.03,
    0.08,
    0.10,
    0.18
]

# Randomly assign a category to every transaction
category_index = np.random.choice(
    len(merchant_categories),
    size=n,
    p=category_probability
)

# Create MCC column
mcc = np.array([
    merchant_categories[i][0]
    for i in category_index
])

# Create merchant category column
merchant_category = np.array([
    merchant_categories[i][1]
    for i in category_index
])

# P2P transactions do not have merchant-specific information
p2p_rows = np.where(transaction_type == "P2P")[0]

merchant_id[p2p_rows] = None
mcc[p2p_rows] = None
merchant_category[p2p_rows] = None
merchant_size[p2p_rows] = None
merchant_monthly_upi_receipts[p2p_rows] = np.nan

# Geographic regions
regions = [
    "North",
    "South",
    "West",
    "East",
    "Central"
]

merchant_region = np.random.choice(
    regions,
    size=n
)

# Banks
banks = [
    "HDFC Bank",
    "ICICI Bank",
    "SBI",
    "Axis Bank",
    "Kotak Mahindra Bank",
    "IndusInd Bank"
]

payer_bank = np.random.choice(
    banks,
    size=n
)

acquirer_bank = np.random.choice(
    banks,
    size=n
)

# UPI applications
upi_apps = [
    "PhonePe",
    "Google Pay",
    "Paytm",
    "BHIM",
    "Other"
]

upi_app = np.random.choice(
    upi_apps,
    size=n,
    p=[0.42, 0.38, 0.12, 0.03, 0.05]
)

# Transaction status
transaction_status = np.random.choice(
    ["Success", "Failed", "Reversed"],
    size=n,
    p=[0.96, 0.03, 0.01]
)

# Policy version applicable to these transactions
policy_version = np.array(
    ["MDR_2026"] * n
)


# Clearly identify that this is synthetic data
source_type = np.array(
    ["Synthetic_Calibrated"] * n
)

# Create the final transaction table
df = pd.DataFrame({
    "transaction_id": [
        f"TX{str(i).zfill(8)}"
        for i in range(1, n + 1)
    ],
    "transaction_date": transaction_date.strftime("%Y-%m-%d"),
    "transaction_amount": transaction_amount,
    "transaction_type": transaction_type,
    "merchant_id": merchant_id,
    "mcc": mcc,
    "merchant_category": merchant_category,
    "merchant_size": merchant_size,
    "merchant_monthly_upi_receipts": merchant_monthly_upi_receipts,
    "merchant_region": merchant_region,
    "payer_bank": payer_bank,
    "acquirer_bank": acquirer_bank,
    "transaction_status": transaction_status,
    "upi_app": upi_app,
    "policy_version": policy_version,
    "source_type": source_type
})

print(df.head())
print("Rows:", len(df))
print("Columns:", len(df.columns))
# Save the generated dataset
output_path = "../02_Raw_Data/UPI_MDR_Transactions.csv"

df.to_csv(
    output_path,
    index=False
)

print("Dataset saved successfully!")
