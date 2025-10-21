# Shopping-Mall-Sales-Analysis-MySQL

➤ Project Overview  
This MySQL project analyzes shopping mall sales data to uncover top-performing malls, category trends, payment method preferences, demographic insights, and time-based sales patterns using advanced SQL queries.  

The goal is to transform raw retail data into meaningful business insights that help understand overall performance and customer behavior across different shopping malls.

---

## 📁 Repository Contents
This repository contains all the necessary files to replicate and understand the analysis:

* `customer_shopping_data.csv`: The raw dataset used for the analysis.
* `shopping_project.sql`: The complete set of SQL queries, including data cleaning, CTEs, window functions, and the final analytical queries.
* `README.md`: This document detailing the project's scope and findings.

---

## 📊 Data Schema Overview (Key Fields)
The analysis is based on a transactional dataset, where the key fields used for deriving insights include:

• Mall Name (`shopping_mall`): The location of the purchase (e.g., Kanyon, Istinye Park).
• Category (`category`): The product category purchased (e.g., Clothing, Technology).
• Payment Method (`payment_method`): The method used for the transaction (Cash, Credit Card, or Debit Card).
• Customer Demographics:
    • Customer Age (`age`): Age of the customer at the time of transaction.
    • Customer Gender (`gender`): Gender of the customer.
• Sales Amount (`price`): The transaction amount/unit price.
• Transaction Date (`invoice_date`): The date of the transaction, used for time-series analysis.

---

➤ Objectives  
• Identify top-performing shopping malls based on total sales  
• Discover the most and least selling product categories  
• Analyze gender and age-based spending patterns  
• Study payment method preferences and their contribution to total sales  
• Evaluate yearly and monthly sales performance to identify seasonal trends  

---

➤ SQL Concepts & Skills Demonstrated 
• Data Cleaning 
• Common Table Expressions (CTEs)  
• Window Functions   
• Aggregate Functions
• Subqueries & Joins  
• Business Insights through Analytical Query Writing  

---

➤ Tools & Technologies  
• Database: MySQL  
• Environment: MySQL Workbench  
• Language: SQL  

---

➤ Key Insights (From Analysis)  
• Kanyon achieved the highest total sales, while Istinye Park recorded the lowest  
• Kanyon, Metropol AVM, and Mall of Istanbul have above-average total sales among all malls  
• Clothing is the most purchased category, especially by the 26–35 age group  
• However, the 36–45 age group generates the highest revenue from the Technology category  
• Food and Beverages is the least-selling category every year  
• Cash is the most preferred payment method by both genders; debit card is used the least  
• Female customers contribute 57.6 percent to total sales, while male customers contribute 42.4 percent  
• Monthly sales of each mall were analyzed to understand seasonal sales performance and trends over time  
  

---

