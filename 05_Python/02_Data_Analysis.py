import pandas as pd
import numpy as np

# Load the Python-generated transaction dataset
df = pd.read_csv("../02_Raw_Data/UPI_MDR_Transactions.csv")

# Basic dataset information
print("Dataset loaded successfully!")
print("Rows:", len(df))
print("Columns:", len(df.columns))

# Convert numeric fields
df["transaction_amount"] = pd.to_numeric(
    df["transaction_amount"],
    errors="coerce"
)

df["merchant_monthly_upi_receipts"] = pd.to_numeric(
    df["merchant_monthly_upi_receipts"],
    errors="coerce"
)

# Convert transaction date
df["transaction_date"] = pd.to_datetime(
    df["transaction_date"],
    errors="coerce"
)

print("\nFirst 5 rows:")
print(df.head())

print("\nMissing values:")
print(df.isnull().sum())

# --------------------------------------------------
# MDR POLICY CALCULATION
# --------------------------------------------------

def calculate_mdr(row):

    # P2P transactions have no MDR
    if row["transaction_type"] == "P2P":
        return 0

    # P2M transactions up to ₹2,000 have no MDR
    if row["transaction_amount"] <= 2000:
        return 0

    # Small merchants below/equal to ₹1 lakh monthly UPI receipts
    if row["merchant_monthly_upi_receipts"] <= 100000:
        return 0

    # Essential sectors
    if row["merchant_category"] in ["Fuel", "Telecom", "Railways"]:
        return 5

    # Capital market transactions
    if row["merchant_category"] == "Capital Markets":
        return min(row["transaction_amount"] * 0.0002, 300)

    # Standard P2M
    return min(row["transaction_amount"] * 0.004, 300)


df["estimated_mdr"] = df.apply(calculate_mdr, axis=1)

print("\nMDR calculation completed!")

print("\nTotal estimated MDR:")
print(round(df["estimated_mdr"].sum(), 2))


# --------------------------------------------------
# KPI ANALYSIS
# --------------------------------------------------

total_transactions = len(df)

p2m_transactions = (df["transaction_type"] == "P2M").sum()
p2p_transactions = (df["transaction_type"] == "P2P").sum()

p2m_value = df.loc[
    df["transaction_type"] == "P2M",
    "transaction_amount"
].sum()

p2m_above_2000 = df.loc[
    (df["transaction_type"] == "P2M") &
    (df["transaction_amount"] > 2000)
].shape[0]

p2m_volume_share = (
    p2m_transactions / total_transactions
) * 100

p2m_above_2000_share = (
    p2m_above_2000 / p2m_transactions
) * 100

print("\n----- KPI SUMMARY -----")

print("Total transactions:", total_transactions)
print("P2M transactions:", p2m_transactions)
print("P2P transactions:", p2p_transactions)

print(
    "P2M transaction value:",
    round(p2m_value, 2)
)

print(
    "P2M volume share:",
    round(p2m_volume_share, 2),
    "%"
)

print(
    "P2M transactions above ₹2,000:",
    p2m_above_2000
)

print(
    "P2M transactions above ₹2,000 share:",
    round(p2m_above_2000_share, 2),
    "%"
)

# --------------------------------------------------
# MDR BY MERCHANT CATEGORY
# --------------------------------------------------

category_analysis = (
    df[df["transaction_type"] == "P2M"]
    .groupby("merchant_category")
    .agg(
        transaction_count=("transaction_id", "count"),
        transaction_value=("transaction_amount", "sum"),
        estimated_mdr=("estimated_mdr", "sum")
    )
    .reset_index()
)

category_analysis["mdr_share"] = (
    category_analysis["estimated_mdr"]
    / category_analysis["estimated_mdr"].sum()
) * 100

category_analysis = category_analysis.sort_values(
    "estimated_mdr",
    ascending=False
)

print("\n----- MDR BY MERCHANT CATEGORY -----")
print(category_analysis.round(2))
category_analysis.to_csv(
    "../03_Clean_Data/category_analysis.csv",
    index=False
)

print("\nCategory analysis saved successfully!")
# --------------------------------------------------
# DAILY MDR TREND
# --------------------------------------------------

daily_analysis = (
    df[df["transaction_type"] == "P2M"]
    .groupby("transaction_date")
    .agg(
        transaction_count=("transaction_id", "count"),
        transaction_value=("transaction_amount", "sum"),
        estimated_mdr=("estimated_mdr", "sum")
    )
    .reset_index()
)

daily_analysis = daily_analysis.sort_values("transaction_date")

print("\n----- DAILY MDR TREND -----")
print(daily_analysis.round(2))
daily_analysis.to_csv(
    "../03_Clean_Data/daily_mdr_analysis.csv",
    index=False
)

print("\nDaily MDR analysis saved successfully!")

# --------------------------------------------------
# PYTHON CHART 1: MDR BY MERCHANT CATEGORY
# --------------------------------------------------

import matplotlib.pyplot as plt

plt.figure(figsize=(10, 6))

plt.barh(
    category_analysis["merchant_category"],
    category_analysis["estimated_mdr"]
)

plt.xlabel("Estimated MDR")
plt.ylabel("Merchant Category")
plt.title("Estimated MDR by Merchant Category")

plt.tight_layout()

plt.savefig(
    "charts/mdr_by_category.png",
    dpi=300
)

plt.show()

# --------------------------------------------------
# PYTHON CHART 2: DAILY MDR TREND
# --------------------------------------------------

plt.figure(figsize=(10, 6))

plt.plot(
    daily_analysis["transaction_date"],
    daily_analysis["estimated_mdr"],
    marker="o"
)

plt.xlabel("Transaction Date")
plt.ylabel("Estimated MDR")
plt.title("Daily Estimated MDR — October 2026")

plt.xticks(rotation=45)

plt.tight_layout()

plt.savefig(
    "charts/daily_estimated_mdr.png",
    dpi=300
)

plt.show()