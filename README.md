
# UPI MDR 2026 — Payment Economics, Data Risk & Card Network Impact Analytics

## Why I built this

India's UPI ecosystem is enormous, but a relatively small change in merchant payment economics can create very different effects depending on transaction size, merchant type and payment behavior.

I wanted to explore a simple question:

> **What happens when MDR rules change — and can we build a data framework that is reliable enough to monitor the impact?**
> This project analyzes the announced **2026 UPI Merchant Discount Rate (MDR) framework** and models its potential impact on:

- Merchant payment economics
- Transaction-level MDR exposure
- Payment transaction mix
- Merchant/category-level impact
- Data quality and governance requirements
- Potential payment-method substitution relevant to card networks

This project combines **Python, SQL, Excel and data governance** to model the 2026 UPI MDR framework and explore its potential implications for merchants, payment participants and card-network payment mix.

---

## What I actually built

This wasn't just a dashboard project.

I built the workflow from the ground up:

**Python**
→ generated 100,000 synthetic UPI transactions

**MySQL**
→ created the transaction data layer and MDR rule engine

**SQL**
→ analyzed transaction mix, MDR exposure, thresholds and merchant categories

**Python**
→ independently recalculated KPIs, MDR and daily/category trends

**Data Governance**
→ added completeness, validity, uniqueness, policy-version and lineage controls

**Excel**
→ converted the analysis into a management dashboard

---UPI has historically operated with very limited merchant MDR in many transaction categories.

The 2026 framework introduces differentiated MDR treatment based on:

- Transaction type
- Transaction amount
- Merchant size / monthly receipts
- Merchant category
- Sector
- Capital-market transaction status
- MDR caps and fixed charges

That creates a data problem as well as a payment-economics problem.

A payments organization would need to answer:

### Payment Economics
- Which transactions become MDR-bearing?
- How much MDR could be generated under the modeled rules?
- Which merchant categories contribute most?
- How concentrated is MDR exposure?

### Data & Governance
- Can every transaction be correctly classified?
- Are merchant attributes complete?
- Are MDR rules applied consistently?
- Can every calculated MDR amount be traced back to a policy rule?
- Can the analysis be reproduced when the policy changes?

### Card Network Relevance
If merchant economics change, could payment-method mix also change?

The project therefore connects **payment economics + analytics + data governance + card-network strategy** rather than looking at MDR as only a pricing calculation.

# The interesting part — what did the data show?

### 1. A small share of transactions can represent a huge share of payment value

In the modeled dataset:

- **63.25%** of transactions are P2M
- Only around **4% of P2M transactions** are above ₹2,000
- Yet those >₹2,000 transactions represent approximately **57% of P2M transaction value**

That was one of the most interesting patterns in the analysis.

**Transaction volume alone doesn't tell the whole payment-economics story.**

---

### 2. Modeled MDR is highly concentrated

The MDR engine produced approximately **₹41,035 of modeled MDR** across the synthetic dataset.

The distribution was highly concentrated:

| MDR Rule | Modeled MDR |
|---|---:|
| Standard P2M – 0.4% | ₹39,850 |
| Essential Sector – Flat ₹5 | ₹1,100 |
| Capital Market – 0.02% | ₹84 |
| Other modeled transactions | ₹0 |

The **Standard P2M rule accounts for roughly 97% of modeled MDR**.

This means that monitoring the overall MDR number without understanding **which policy rule generated it** could hide important changes in the underlying payment mix.

---

### 3. Merchant category matters

Within the modeled successful P2M population, MDR exposure was not evenly distributed.

The largest modeled contributors included:

- Grocery — **27.04%**
- Other Retail — **21.50%**
- Restaurants — **14.90%**
- Electronics — **13.12%**
- Department Stores — **10.47%**

Together, **Grocery + Other Retail account for roughly 48.5% of modeled MDR**.

This makes merchant-category classification an important data-governance dependency: if the category or MCC mapping is wrong, the downstream MDR calculation can also be wrong.

---

### 4. Data quality is part of the business problem

The project didn't treat data quality as an afterthought.

The transaction dataset was tested for:

- Missing P2M merchant IDs
- Missing P2M MCCs
- Duplicate transaction IDs
- Invalid transaction amounts
- Policy-version traceability
- Synthetic-source classification

The current modeled dataset passed these basic controls.

The bigger takeaway is that **a correct MDR formula is only useful when the data feeding that formula is trustworthy.**

---

# Why this matters for payment networks

The project does **not** attempt to predict American Express or Mastercard revenue.

Instead, it creates a framework for thinking about a potential second-order effect:

**Merchant economics**
→ payment-method economics  
→ merchant/consumer payment preferences  
→ transaction mix  
→ potential card-network activity

The interesting analytical question is therefore not simply:

> "Will UPI hurt cards?"

Instead:

> **"Under what merchant, transaction-value and payment-behavior scenarios could changes in UPI economics influence payment-method mix?"**

That is the scenario-analysis layer I would build next using actual payment-method data.

---

# Data & assumptions

The transaction-level dataset is **synthetic**, generated using Python.

It was calibrated using documented UPI ecosystem and policy assumptions.

It is **not actual NPCI, bank, American Express or Mastercard transaction data**.

The purpose of the synthetic dataset is to demonstrate the analytical and governance framework without representing private transaction information as real market data.

---

# Project architecture

```text
Python Data Generation
        ↓
Synthetic Transaction Dataset
        ↓
MySQL Raw Data Layer
        ↓
SQL MDR Rule Engine
        ↓
Data Quality & Governance Controls
        ↓
Python Independent Analysis
        ↓
Excel Management Dashboard
        ↓
Payment Economics & Scenario Analysis
