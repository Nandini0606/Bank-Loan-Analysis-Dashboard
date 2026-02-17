SHOW databases;
DROP DATABASE if exists finance_analytics;

CREATE DATABASE finance;      # DATABASE CREATE #
USE finance;

SELECT * FROM finance1;
SELECT * FROM finance2;      # Show all values from both table #

CREATE TABLE finance_all AS        # 'LEFT JOIN' for Keep all finance_1 #
SELECT                        
    f1.id AS loan_id,
    f1.*,
    f2.delinq_2yrs,
    f2.earliest_cr_line,
    f2.inq_last_6mths,
    f2.mths_since_last_delinq,
    f2.mths_since_last_record,
    f2.open_acc,
    f2.pub_rec,
    f2.revol_bal,
    f2.revol_util,
    f2.total_acc,
    f2.initial_list_status,
    f2.out_prncp,
    f2.out_prncp_inv,
    f2.total_pymnt,
    f2.total_pymnt_inv,
    f2.total_rec_prncp,
    f2.total_rec_int,
    f2.total_rec_late_fee,
    f2.recoveries,
    f2.collection_recovery_fee,
    f2.last_pymnt_d,
    f2.last_pymnt_amnt,
    f2.next_pymnt_d,
    f2.last_credit_pull_d
FROM finance1 f1
LEFT JOIN finance2 f2 ON f1.id = f2.id
UNION                            # 'Union' use for taking all common matching records
SELECT                           # 'RIGHT JOIN' for Keep all finance_2 #
    f2.id AS loan_id,
    f1.*,
    f2.delinq_2yrs,
    f2.earliest_cr_line,
    f2.inq_last_6mths,
    f2.mths_since_last_delinq,
    f2.mths_since_last_record,
    f2.open_acc,
    f2.pub_rec,
    f2.revol_bal,
    f2.revol_util,
    f2.total_acc,
    f2.initial_list_status,
    f2.out_prncp,
    f2.out_prncp_inv,
    f2.total_pymnt,
    f2.total_pymnt_inv,
    f2.total_rec_prncp,
    f2.total_rec_int,
    f2.total_rec_late_fee,
    f2.recoveries,
    f2.collection_recovery_fee,
    f2.last_pymnt_d,
    f2.last_pymnt_amnt,
    f2.next_pymnt_d,
    f2.last_credit_pull_d
FROM finance1 f1
RIGHT JOIN finance2 f2
ON f1.id = f2.id;

ALTER TABLE finance1               # Add correct data type column issue date #
ADD COLUMN issue_date DATE;
UPDATE finance1 
SET issue_date = STR_TO_DATE(CONCAT('01-', issue_d),'%d-%b-%y');

------------------------------- KPIs --------------------------------------------------
# calculate Total loan amount in million #
SELECT concat(round(SUM(loan_amnt)/1000000,2),'M') AS Total_Loan_Amount
FROM finance_all;

# calculat Total Revol Balance in million #
SELECT concat(round(SUM(revol_bal)/1000000,2),'M') AS Total_Revol_Balance
FROM finance_all;

# calculate Total Funded Amount in million #
SELECT concat(round(SUM(funded_amnt)/1000000,2),'M') AS Total_Funded_Amount
FROM finance_all;

# calculate Total Installment in million #
SELECT concat(round(SUM(installment)/1000000,2),'M') AS Total_Installment
FROM finance_all;

# calculate Total Annual Income in million #
SELECT concat(round(SUM(annual_inc)/1000000,2),'M') AS Total_Annual_Income
FROM finance_all;

# calculate Total Open Account in million #
SELECT concat(round(SUM(open_acc)/1000000,2),'M') AS Total_Open_Acc
FROM finance_all;

# calculate Total_rec_late_fee in million #
SELECT concat(round(SUM(total_rec_late_fee)/1000000,2),'M') AS Total_Rec_Late_Fee
FROM finance_all;

# calculate Total Recovery Collection Amount in million #
SELECT concat(round(SUM(collection_recovery_fee)/1000000,2),'M') AS Total_Collection_Recovery_Fee
FROM finance_all;

# calculate Total Recovery Interest Amount in million #
SELECT concat(round(SUM(total_rec_int)/1000000,2),'M') AS Total_Rec_Int
FROM finance_all;

# calculate Total Last Payment Amount #
SELECT concat(round(SUM(last_pymnt_amnt)/1000000,2),'M') AS Total_Last_Payment
FROM finance_all;

# calculate Total Payment Amount #
SELECT concat(round(SUM(total_pymnt)/1000000,2),'M') As Total_Payment
FROM finance_all;

# calculate Total Acc #
SELECT concat(round(SUM(total_acc)/1000000,2),'M') AS Total_Acc
FROM finance_all;

# calculate Avg interest rate
SELECT concat(round(avg(int_rate),2),'%') AS Avg_Int_Rate 
FROM finance_all;

--------------------- Yearwise Loan Amount Stats ----------------------------------

# Show issue_date_year,loan amount and loan status from finance all table #
SELECT YEAR(issue_date) AS Loan_Year,loan_amnt AS Loan_Amount,loan_status AS Loan_Status 
FROM finance_all;     

# Yearwise Loan Amount in million #
SELECT YEAR(issue_date) AS Loan_Year,concat(round(SUM(loan_amnt)/1000000,2),'M') AS Loan_Amount
FROM finance_all
WHERE issue_date IS NOT NULL
GROUP BY YEAR(issue_date)
ORDER BY Loan_Year;

------------------------- grade and subgradewise revol balance -------------------------

# show grade,sub-grade and revol balance #
SELECT grade AS Grade,sub_grade AS Sub_Grade,concat(round(SUM(revol_bal)/1000000,2),'M') AS Revol_Balance
FROM finance_all
WHERE grade IS NOT NULL
GROUP BY grade,sub_grade
ORDER BY grade,sub_grade;

# gradewise revol balance in million
SELECT grade AS Grade,concat(round(SUM(revol_bal)/1000000,2),'M') AS Revol_Balance
FROM finance_all
WHERE grade IS NOT NULL
GROUP BY grade
ORDER BY grade ASC;

# subgradewise revol balance in million
SELECT sub_grade AS Sub_Grade,concat(round(SUM(revol_bal)/1000000,2),'M') AS Revol_Balance
FROM finance_all
WHERE sub_grade IS NOT NULL
GROUP BY sub_grade
ORDER BY sub_grade ASC;

--------------------- Total Payment for verified and not verified status --------------------

# Show all verification status and Total Payment 
SELECT verification_status AS Verification_Status,concat(round(SUM(total_pymnt)/1000000,2),'M') AS Total_Payment
FROM finance_all
WHERE verification_status IS NOT NULL
GROUP BY verification_status;

# Show only verified status
SELECT verification_status AS Verification_Status,concat(round(SUM(total_pymnt)/1000000,2),'M') AS Total_Payment
FROM finance_all
WHERE verification_status='verified';

# Show only non-verified status
SELECT verification_status AS Verification_Status,concat(round(SUM(total_pymnt)/1000000,2),'M') AS Total_Payment
FROM finance_all
WHERE verification_status='not verified';

------------------- statewise and last credit pull datewise loan status ---------------------

# statewise and last credit pull datewsie loan status 
SELECT addr_state AS Address_state,YEAR(last_credit_pull_d) AS _Last_Credit_Pull_Year,loan_status AS Loan_Status,count(*)
FROM finance_all
WHERE last_credit_pull_d IS NOT NULL
GROUP BY addr_state,YEAR(last_credit_pull_d),loan_status
ORDER BY addr_state,YEAR(last_credit_pull_d),loan_status;

#show addr state,last credit pull date only for fully paid loan status
SELECT addr_state AS Address_State,YEAR(last_credit_pull_d) AS Last_Credit_Pull_Year,loan_status As Loan_Status
FROM finance_all
WHERE loan_status='fully paid';

#show addr state,last credit pull date only for charded off loan status
SELECT addr_state AS Address_state,YEAR(last_credit_pull_d) AS last_credit_pull_year,loan_status AS Loan_Status
FROM finance_all
WHERE loan_status='charged off';

------------------ Home ownership Vs Last payment date stats ----------------------------------
# Show home ownership,last paymnet amount,last payment date 
SELECT home_ownership AS Home_Ownership,concat(round(SUM(last_pymnt_amnt)/1000000,2),'M') AS Last_Pymnt_Amount,YEAR(last_pymnt_d) AS Last_Payment_Year
FROM finance_all
WHERE last_pymnt_d IS NOT NULL
GROUP BY home_ownership,YEAR(last_pymnt_d);

# Show home ownership wise loan amount and installment
SELECT home_ownership AS Home_Ownership,concat(round(SUM(loan_amnt)/1000000,2),'M') AS Total_Loan,concat(round(SUM(installment)/1000000,2),'M') AS Total_Installment
FROM finance_all
WHERE home_ownership IS NOT NULL
GROUP BY home_ownership;
select * from finance1;
select * from finance2;

------------------------- Some additional KPIs ------------------------------------
# Show statewise dti and loan amount
SELECT addr_state AS Address_State,round(AVG(dti),2) As AVG_DTI,YEAR(issue_date) AS Issue_Date_Year
FROM finance_all
WHERE addr_state IS NOT NULL
GROUP BY addr_state,YEAR(issue_date)
ORDER BY Issue_Date_Year;

# Calculate Top 10 id by loan amount
SELECT DISTINCT id AS Emp_ID,loan_amnt As Loan_Amount
FROM finance_all
WHERE id IS NOT NULL
ORDER BY loan_amount DESC 
LIMIT 10;

# Calculate Bottom 10 id by loan amount
SELECT DISTINCT id AS Emp_ID,loan_amnt AS Loan_Amount
FROM finance_all
WHERE id IS NOT NULL
ORDER BY loan_amnt ASC 
LIMIT 10;

# Calculate Top 20 id wise funded amount,installment and employee length
SELECT DISTINCT id AS Emp_ID,emp_length AS Emp_Length,concat(round(SUM(funded_amnt)/1000,2),'K') AS Funded_Amount,concat(round(SUM(installment)/1000,2),'K') As Total_Installment
FROM finance_all
WHERE id IS NOT NULL
GROUP BY id,emp_length,funded_amnt,installment
ORDER BY Emp_Length desc
LIMIT 20;

#Show Purpose wise Loan Status
SELECT purpose AS Purpose,loan_status AS Loan_Status
FROM finance_all
GROUP BY purpose,loan_status;
----------------------------------------------------------------------------------------------

 
 
 
 
 
 
 
 
 
 
 
 
 
 

select loan_status,count(*) from finance_all
WHERE loan_status IS NOT NULL
GROUP BY loan_status;