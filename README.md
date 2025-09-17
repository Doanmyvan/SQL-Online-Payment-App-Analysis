# 📊 2018 Customer Transaction & Retention Analysis
## 🔍 Overview

This project analyzes customer behavior and transactions of an online payment app in 2018, including user activity, payment totals, product performance, transaction success/failure, and retention rates. The goal is to provide insights for marketing, product teams.

## 🎯 Objectives
Key analyses include:
- Total active users and transactions in 2018.
- Total amount and transaction count per user.
- Monthly and quarterly successful transactions.
- Monthly transaction totals and percentage of annual total.
- Top product groups and payment methods.
- Failed transactions and failure rates per month.
- Transaction growth vs 2017.
- New users in 2018.
- Customer retention rates and cohort pivot table.
  
## 🗄️ Data Source
**Local Host Database** – All data is stored on a local SQL Server instance.

## 🗂️ Dataset
1. **payment_history_18**: Customer transactions in 2018
2. **payment_history_17**: Transactions in 2017 
3. **Product**: Product details
4. **Paying_method**: Available payment methods
5. **table_message**: description of transaction

## 🛠️ Tools
- **T-SQL** – For data extraction, aggregation, and cohort analysis.
- **Excel** – For pivot tables, visualization.

## 🔑 Key Insights
1. **Active Users & Transactions**: 10.432 users completed 245.709 transactions in 2018.
2. **High-Value users**: The top-spending user paid a total of 3,102,506,000 VND, while the lowest-spending user paid just 1,000 VND.
3. **Active users**: The most active user completed 1,460 transactions, while the least active users made just 1 transaction
4. **Top Products**: the product group with the highest total payments was “Top-up Account”
5. **Top 3 Payment Methods**: money in app, local card and banking account
6. **Transaction Failure**: The failure rate was lowest in April at 4.98%, and highest in December, reaching 13.28%.
   
## 📊 Corhort Analysis - Visualizations
<img width="1643" height="732" alt="Screenshot 2025-09-17 213821" src="https://github.com/user-attachments/assets/49bd5ff7-3ce7-4f4e-b634-0d3486de8636" />
