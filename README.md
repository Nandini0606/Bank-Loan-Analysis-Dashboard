<!--
  ╔══════════════════════════════════════════════════════╗
  ║  BEFORE PUBLISHING: Replace the two placeholders:   ║
  ║  YOUR_USERNAME  →  your GitHub username              ║
  ║  YOUR_REPO      →  your repository name              ║
  ╚══════════════════════════════════════════════════════╝
-->

<h1 align="center">🏦 Bank Loan Analysis Dashboard</h1>

<p align="center">
  <b>An end-to-end Data Analytics project using MySQL · Excel · Power BI · Tableau</b><br/>
  <i>Transforming raw loan data into powerful business intelligence</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/MySQL-Data%20Engineering-orange?style=for-the-badge&logo=mysql&logoColor=white"/>
  <img src="https://img.shields.io/badge/Microsoft%20Excel-Dashboard-217346?style=for-the-badge&logo=microsoftexcel&logoColor=white"/>
  <img src="https://img.shields.io/badge/Power%20BI-Single%20Canvas-F2C811?style=for-the-badge&logo=powerbi&logoColor=black"/>
  <img src="https://img.shields.io/badge/Tableau-3%20Page%20Report-1F4E79?style=for-the-badge&logo=tableau&logoColor=white"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Domain-Banking%20%26%20Finance-blue?style=flat-square"/>
  <img src="https://img.shields.io/badge/Records-39%2C717%20Loans-green?style=flat-square"/>
  <img src="https://img.shields.io/badge/Portfolio%20Value-446M-red?style=flat-square"/>
  <img src="https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square"/>
</p>

---

## 📑 Table of Contents

| # | Section |
|---|---------|
| 1 | [Project Overview](#-project-overview) |
| 2 | [Tools & Tech Stack](#-tools--tech-stack) |
| 3 | [Dataset Description](#-dataset-description) |
| 4 | [Data Pipeline & SQL](#-data-pipeline--sql) |
| 5 | [Excel Dashboard](#-excel-dashboard) |
| 6 | [Power BI Dashboard](#-power-bi-dashboard) |
| 7 | [Tableau Dashboard](#-tableau-dashboard) |
| 8 | [Key KPIs at a Glance](#-key-kpis-at-a-glance) |
| 9 | [Business Insights](#-business-insights) |
| 10 | [Project Structure](#-project-structure) |
| 11 | [How to Run](#-how-to-run) |

---

## 📌 Project Overview

> **Objective:** Analyze a bank's loan portfolio to uncover trends in loan applications, repayment behavior, risk segmentation, and portfolio health — and present findings through interactive multi-tool dashboards.

This project follows a **complete end-to-end analytics pipeline**:

```
  finance1.csv ──┐
                  ├──► MySQL (Join + Clean + KPIs) ──► Excel Dashboard
  finance2.csv ──┘                                ──► Power BI Dashboard (single canvas)
                                                  ──► Tableau Report (3 pages)
```

**Key questions answered:**
- 📈 How has loan volume grown year over year?
- ⚠️ What percentage of loans are "bad" (Charged Off)?
- 🏠 How does home ownership affect loan patterns?
- 🌎 Which states have the highest loan concentration?
- ✅ How does income verification impact repayment?
- 💳 What is the most common loan purpose?

---

## 🛠 Tools & Tech Stack

<table>
  <tr>
    <th>Tool</th>
    <th>Version / Type</th>
    <th>Purpose</th>
  </tr>
  <tr>
    <td>🗄️ <b>MySQL</b></td>
    <td>MySQL Workbench</td>
    <td>Database setup, Full Outer Join, Date parsing, All KPI queries</td>
  </tr>
  <tr>
    <td>📊 <b>Microsoft Excel</b></td>
    <td>Excel 2019+</td>
    <td>Interactive single-page dashboard with slicers & pivot charts</td>
  </tr>
  <tr>
    <td>📊 <b>Power BI</b></td>
    <td>Power BI Desktop</td>
    <td>Single-canvas dashboard with 8 KPIs and multiple chart types</td>
  </tr>
  <tr>
    <td>📊 <b>Tableau</b></td>
    <td>Tableau Desktop / Public</td>
    <td>3-page interactive report (Summary · Details · Overview)</td>
  </tr>
</table>

---

## 📂 Dataset Description

Two source tables (`finance1` and `finance2`) were merged into a unified `finance_all` table via SQL.

<details>
<summary><b>📋 Click to expand — Field Reference</b></summary>

| Field | Description |
|-------|-------------|
| `loan_amnt` | Total requested loan amount |
| `funded_amnt` | Amount actually funded by the bank |
| `int_rate` | Annual interest rate on the loan |
| `installment` | Fixed monthly payment amount |
| `grade` / `sub_grade` | Credit risk classification (A1–G5) |
| `loan_status` | *Fully Paid* · *Charged Off* · *Current* |
| `revol_bal` | Borrower's revolving credit balance |
| `revol_util` | Revolving line utilization rate |
| `annual_inc` | Borrower's self-reported annual income |
| `dti` | Debt-to-income ratio |
| `addr_state` | Borrower's US state |
| `home_ownership` | RENT · OWN · MORTGAGE · OTHER · NONE |
| `purpose` | Loan purpose (e.g., debt_consolidation, credit_card) |
| `verification_status` | Verified · Not Verified · Source Verified |
| `emp_length` | Employment length (< 1 year to 10+ years) |
| `issue_d` | Loan issue month/year |
| `last_pymnt_d` | Most recent payment date |
| `last_credit_pull_d` | Date of most recent credit inquiry |
| `total_pymnt` | Total amount received to date |
| `total_rec_int` | Total interest received |
| `collection_recovery_fee` | Post-charge-off recovery fee |

</details>

---

### Step 1 — Database & Table Setup
```sql
CREATE DATABASE finance;
USE finance;
```

### Step 2 — Full Outer Join (finance1 + finance2)

> MySQL doesn't support `FULL OUTER JOIN` natively.  
> **Solution:** `LEFT JOIN` + `RIGHT JOIN` combined with `UNION` captures all records from both tables.

```sql
CREATE TABLE finance_all AS
-- Keep all records from finance1 (LEFT JOIN)
SELECT f1.id AS loan_id, f1.*, f2.revol_bal, f2.loan_status ...
FROM finance1 f1
LEFT JOIN finance2 f2 ON f1.id = f2.id

UNION

-- Keep all records from finance2 (RIGHT JOIN)
SELECT f2.id AS loan_id, f1.*, f2.revol_bal, f2.loan_status ...
FROM finance1 f1
RIGHT JOIN finance2 f2 ON f1.id = f2.id;
```

### Step 3 — Date Column Fix
```sql
-- Convert "Jan-14" text field into a proper DATE column
ALTER TABLE finance1 ADD COLUMN issue_date DATE;

UPDATE finance1
SET issue_date = STR_TO_DATE(CONCAT('01-', issue_d), '%d-%b-%y');
```

### Step 4 — KPI Queries

<details>
<summary><b>📊 Click to expand — All KPI Queries</b></summary>

```sql
-- Total Loan Amount
SELECT CONCAT(ROUND(SUM(loan_amnt)/1000000, 2), 'M') AS Total_Loan_Amount FROM finance_all;

-- Total Funded Amount
SELECT CONCAT(ROUND(SUM(funded_amnt)/1000000, 2), 'M') AS Total_Funded_Amount FROM finance_all;

-- Total Payment Received
SELECT CONCAT(ROUND(SUM(total_pymnt)/1000000, 2), 'M') AS Total_Payment FROM finance_all;

-- Total Revolving Balance
SELECT CONCAT(ROUND(SUM(revol_bal)/1000000, 2), 'M') AS Total_Revol_Balance FROM finance_all;

-- Average Interest Rate
SELECT CONCAT(ROUND(AVG(int_rate), 2), '%') AS Avg_Int_Rate FROM finance_all;

-- Yearwise Loan Amount
SELECT YEAR(issue_date) AS Loan_Year,
       CONCAT(ROUND(SUM(loan_amnt)/1000000, 2), 'M') AS Loan_Amount
FROM finance_all
WHERE issue_date IS NOT NULL
GROUP BY YEAR(issue_date)
ORDER BY Loan_Year;

-- Grade & Subgrade Revolving Balance
SELECT grade, sub_grade,
       CONCAT(ROUND(SUM(revol_bal)/1000000, 2), 'M') AS Revol_Balance
FROM finance_all
WHERE grade IS NOT NULL
GROUP BY grade, sub_grade
ORDER BY grade, sub_grade;

-- Verification Status vs Total Payment
SELECT verification_status,
       CONCAT(ROUND(SUM(total_pymnt)/1000000, 2), 'M') AS Total_Payment
FROM finance_all
WHERE verification_status IS NOT NULL
GROUP BY verification_status;

-- Statewise Loan Status
SELECT addr_state, YEAR(last_credit_pull_d) AS Year, loan_status, COUNT(*)
FROM finance_all
WHERE last_credit_pull_d IS NOT NULL
GROUP BY addr_state, YEAR(last_credit_pull_d), loan_status
ORDER BY addr_state;

-- Home Ownership vs Last Payment
SELECT home_ownership,
       CONCAT(ROUND(SUM(last_pymnt_amnt)/1000000, 2), 'M') AS Last_Pymnt_Amount,
       YEAR(last_pymnt_d) AS Last_Payment_Year
FROM finance_all
WHERE last_pymnt_d IS NOT NULL
GROUP BY home_ownership, YEAR(last_pymnt_d);

-- Top 10 Borrowers by Loan Amount
SELECT DISTINCT id AS Emp_ID, loan_amnt AS Loan_Amount
FROM finance_all
WHERE id IS NOT NULL
ORDER BY Loan_Amount DESC
LIMIT 10;

-- Purpose-wise Loan Status
SELECT purpose, loan_status FROM finance_all GROUP BY purpose, loan_status;

-- Loan Status Count
SELECT loan_status, COUNT(*) FROM finance_all
WHERE loan_status IS NOT NULL
GROUP BY loan_status;
```

</details>

---

## 📊 Excel Dashboard

![ ](https://github.com/Nandini0606/Bank-Loan-Analysis-Dashboard/blob/main/Excel%20Dashboard%20Screenshot.jpeg))



A **single-page interactive dashboard** with dynamic slicers for Year, Grade, Loan Status, and Verification Status.

| Visual | Type | Description |
|--------|------|-------------|
| KPI Cards | Metric tiles | Total Applications · Loan Amount · Payment · Revol Balance · Avg Rate |
| YearWise Loan Amount | Line chart | Loan growth trend from 2007–2016 |
| Grade & SubGrade Revolving Balance | Bar chart | Risk-grade breakdown of revolving balances |
| Verification Status | Donut chart | 54% Verified vs 46% Non-Verified |
| Statewise Loan Status | US Map | Choropleth map with loan counts per state |
| Home Ownership vs Last Payment | Grouped bar | Year-over-year payment by housing type |
| Top 5 Purpose Loan Amount | Horizontal bar | Debt consolidation leads at 237M |

**Interactive Slicers:** `Year` · `Grade (A–G)` · `Loan Status` · `Verification Status`

---

## 📊 Power BI Dashboard

<summary><b>📊 Summary Analysis Page</b></summary>

![Overview Page](https://github.com/Nandini0606/Bank-Loan-Analysis-Dashboard/blob/main/PowerBi%20Dashboard%20Screenshot.png)



A **single-canvas dashboard** combining 8 KPI metrics and multiple visualizations with a Year filter on the left panel.

**8 KPI Metrics in header banner:**

| Total Payment | Total Customers | Total Loan Amount | Avg Loan Amount | Avg Interest Rate | Total Revol Balance | Total Funded Amount | Total Interest Earned |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 483M | 40K | 446M | 11K | 12% | 532M | 435M | 90M |

**Visualizations:**

| Visual | Type | Insight |
|--------|------|---------|
| Verified vs Not Verified | Donut chart | 59% unverified borrowers — a portfolio risk signal |
| Grade & Subgrade Revolving Balance | Line/area chart | Peak at Grade B; sharp decline from Grade D onward |
| Loan Status wise Home Ownership | Donut chart | RENT: 48% · MORTGAGE: 44% |
| Top 10 Statewise Loan Status | Stacked bar | CA, NY, TX, FL, NJ are the top 5 states |
| Year-wise Loan Amount | Line chart | Exponential growth: 2M (2007) → 261M (2011) |
| Employee Length-wise Customers | Horizontal bar | 10+ years: 8.9K customers (largest segment) |

**Filters:** `Year`

---

## 📊 Tableau Dashboard

A **3-page interactive report** with cross-page navigation, consistent KPI cards, and drill-down filters.

---

### 📄 Page 1 — Summary

![ ](https://github.com/Nandini0606/Bank-Loan-Analysis-Dashboard/blob/main/Tableau%20Summary%20Dashboard%20Screenshot.png))

Focus: **Good Loan vs Bad Loan** segmentation

| Metric | 🟢 Good Loans | 🔴 Bad Loans |
|--------|--------------|-------------|
| Applications | 34,090 | 5,627 |
| Funded Amount | 377.5M | 68.1M |
| Amount Received | 444.2M | 38.5M |
| Portfolio Share | **85.8%** | **14.2%** |

Includes a **Loan Status breakdown table** with: Total Amount Received · Loan Amount · Applications · Revolving Balance · Funded Amount · Annual Income · DTI

**Filters:** `Grade` · `Purpose` · `Verification Status`

---

### 📄 Page 2 — Details

![ ](https://github.com/Nandini0606/Bank-Loan-Analysis-Dashboard/blob/main/Tableau%20Overview%20Dashboard%20Screenshot.png))

| Visual | Insight |
|--------|---------|
| Yearwise Loan Amount | Peak at 103.9M in 2013; declined post-2014 |
| Grade & Subgrade Revolving Balance | Grade B carries highest risk balance (~40M) |
| Top 5 Statewise Loan Applications | CA: 5,824 · NY: 3,203 · TX: 2,343 · FL: 2,277 · NJ: 1,512 |
| Home Ownership Bubble Chart | MORTGAGE: 224.1M · RENT: 189.1M · OWN: 31.4M |
| Verification Status Pie | 68.19% Verified |
| Purpose-wise Loan Table | Debt Consolidation: 236.6M (largest category) |

**Filters:** `Grade` · `Purpose` · `Year of Last Payment`

---

### 📄 Page 3 — Overview

![ ](https://github.com/Nandini0606/Bank-Loan-Analysis-Dashboard/blob/main/Tableau%20Overview%20Dashboard%20Screenshot.png))

| Visual | Description |
|--------|-------------|
| Loan Amount by Month | Seasonal trend — peaks in April (54M) |
| Loan Amount by State | US map — darker shading = higher loan volume |
| Loan Amount by Term | 60 months: **62.64%** vs 36 months: **37.36%** |
| Loan Amount by Emp Length | 10+ years leads at **116.2M** |
| Loan Amount by Purpose | Debt consolidation: 232.7M |
| Loan Amount by Home Ownership | Treemap: MORTGAGE > RENT > OWN |

**Filters:** `Grade` · `Purpose` · `Verification Status` · `Year of Last Payment`

---

## 📈 Key KPIs at a Glance

<table align="center">
  <tr>
    <td align="center"><b>Total Applications</b><br/><h2>39,717</h2></td>
    <td align="center"><b>Total Loan Amount</b><br/><h2>446M</h2></td>
    <td align="center"><b>Total Payment</b><br/><h2>483M</h2></td>
    <td align="center"><b>Revol Balance</b><br/><h2>532M</h2></td>
    <td align="center"><b>Avg Interest Rate</b><br/><h2>12.02%</h2></td>
  </tr>
  <tr>
    <td align="center"><b>Good Loan Rate</b><br/><h2>85.8%</h2></td>
    <td align="center"><b>Bad Loan Rate</b><br/><h2>14.2%</h2></td>
    <td align="center"><b>Fully Paid</b><br/><h2>33K</h2></td>
    <td align="center"><b>Charged Off</b><br/><h2>5.6K</h2></td>
    <td align="center"><b>Interest Earned</b><br/><h2>90M</h2></td>
  </tr>
</table>

---

## 💡 Business Insights

<details>
<summary><b>1️⃣ Rapid Loan Growth (2007–2013), then Decline</b></summary>
<br/>
Loan disbursements grew from just <b>0.6M in 2007</b> to a peak of <b>103.9M in 2013</b> — a 173× increase in 6 years. Post-2014, volume declined sharply to 32.7M in 2016, possibly indicating tighter credit policies or market saturation.
<br/><br/>
</details>

<details>
<summary><b>2️⃣ Debt Consolidation Dominates — Over 50% of Loan Volume</b></summary>
<br/>
Debt consolidation accounts for <b>237M+</b> in loan volume — more than the next 5 purposes combined. This signals a core customer need and represents the single largest strategic product category for the bank.
<br/><br/>
</details>

<details>
<summary><b>3️⃣ Geographic Concentration Risk in California</b></summary>
<br/>
California accounts for <b>5,824 applications</b> — nearly <b>3× New York (3,203)</b> and <b>2.5× Texas (2,343)</b>. This geographic concentration should be evaluated in portfolio stress testing and regional risk frameworks.
<br/><br/>
</details>

<details>
<summary><b>4️⃣ Borrowers Prefer 60-Month Terms (62.64%)</b></summary>
<br/>
The majority of borrowers choose 60-month repayment terms over 36-month, accepting higher total interest for lower monthly payments. This benefits bank revenue through extended interest collection.
<br/><br/>
</details>

<details>
<summary><b>5️⃣ Experienced Employees Are the Largest Borrower Segment</b></summary>
<br/>
Borrowers with <b>10+ years employment</b> represent the largest segment: <b>8.9K customers</b> and <b>116.2M</b> in loan volume — nearly 3× the next employment tier. Employment stability is a strong predictor of loan demand.
<br/><br/>
</details>

<details>
<summary><b>6️⃣ Verification Gap is a Hidden Risk</b></summary>
<br/>
59% of total payment volume comes from <i>unverified</i> borrowers. This suggests income verification may not be consistently enforced, and could be masking default risk within the portfolio.
<br/><br/>
</details>

<details>
<summary><b>7️⃣ Mortgage Holders Carry the Largest Loan Volume</b></summary>
<br/>
Borrowers with a MORTGAGE home status account for <b>224.1M</b> in loan volume vs <b>189.1M</b> for renters. Homeowners access larger credit lines, likely leveraging perceived asset stability.
<br/><br/>
</details>

<details>
<summary><b>8️⃣ Grade B = Highest-Risk High-Volume Segment</b></summary>
<br/>
Grade B carries the <b>highest revolving balance (~40M)</b>, sitting just below prime (Grade A) in credit quality. This segment warrants close monitoring as the largest mass of borderline-credit borrowers in the portfolio.
<br/><br/>
</details>

---

## 📁 Project Structure

```
📦 YOUR_REPO/
│
├── 📄 README.md
│
├── 🗄️ Bank_Analytics.sql               ← DB setup, joins, date fix, all KPI queries
│
├── 📊 Bank_Analytics_Excel.xlsx         ← Single-page interactive Excel dashboard
│
├── 📊 Bank_Loan_Dashboard.pbix          ← Single-canvas Power BI dashboard
│
├── 📊 Bank_Loan_Analysis.twbx           ← 3-page Tableau report
│
└── 🖼️ Screenshots/
    ├── excel_dashboard.png              ← Excel dashboard preview
    ├── powerbi_dashboard.png            ← Power BI dashboard preview
    ├── tableau_summary.png              ← Tableau Summary page
    ├── tableau_details.png              ← Tableau Details page
    └── tableau_overview.png             ← Tableau Overview page
```

---

## 🚀 How to Run

### 🗄️ SQL
1. Open **MySQL Workbench** and create a new schema.
2. Import `finance1.csv` and `finance2.csv` as tables.
3. Run `Bank_Analytics.sql` — it creates the `finance_all` merged table and executes all KPI queries.

### 📊 Excel
1. Open `Bank_Analytics_Excel.xlsx` in **Excel 2016+**.
2. Use the **slicers** (Year · Grade · Loan Status · Verification) on the left panel to filter all visuals dynamically.

### 📊 Power BI
1. Open `Bank_Loan_Dashboard.pbix` in **Power BI Desktop**.
2. Use the **Year filter** on the left panel to adjust data across all visuals.
3. Hover over charts for detailed tooltips.

### 📊 Tableau
1. Open `Bank_Loan_Analysis.twbx` in **Tableau Desktop** or **Tableau Public**.
2. Navigate between **Summary → Details → Overview** pages using the tab navigation.
3. Use the filter panel to slice by Grade, Purpose, or Verification Status.

---

<h3 align="center">⭐ If this project helped you, please consider giving it a star! ⭐</h3>

<p align="center">
  <a href="https://linkedin.com/in/YOUR_LINKEDIN">
    <img src="https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white"/>
  </a>
  &nbsp;
  <a href="https://github.com/YOUR_USERNAME">
    <img src="https://img.shields.io/badge/GitHub-Follow-181717?style=for-the-badge&logo=github&logoColor=white"/>
  </a>
  &nbsp;
  <a href="mailto:YOUR_EMAIL@gmail.com">
    <img src="https://img.shields.io/badge/Gmail-Contact-D14836?style=for-the-badge&logo=gmail&logoColor=white"/>
  </a>
</p>
