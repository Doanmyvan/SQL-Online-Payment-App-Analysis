/*check Payment history 2017 table*/
Select top 2* From payment_history_17;

/*check Payment history 2018 table*/
Select top 2* From payment_history_18;

/*check Paying method table*/
Select* From paying_method;

/*check product table*/
Select* From product;

/*check message table*/
Select* From table_message;

/* 1. Determine the total number of active users and the total number of transactions in 2018. */
Select count (distinct customer_ID) As number_uses
        , count (order_id) As number_orders
From payment_history_18;

/* 2. Calculate the total amount paid by each user during 2018. */
Select customer_ID
,sum(cast (final_price As bigint)) As total_paid
From payment_history_18
Group by customer_id
Order by total_paid Desc;

/* 3. Count the number of transactions made by each user in 2018. */
Select customer_ID
,count (order_id) As total_transactions
From payment_history_18
Group by customer_id
Order by total_transactions desc; 

/* 4. create a detailed report that calculates the total number of success transactions by month, by quarter in 2018.*/

With table_join AS (
Select customer_id, order_id, transaction_date
    , case when month (transaction_date) <= 3 then 'Q1'
        when month (transaction_date) <= 6 then 'Q2'
        when month (transaction_date) <= 9 then 'Q3'
        Else 'Q4'
        End AS [quarter]
    , month (transaction_date) as [month]    
from  payment_history_18 As his
    left join table_message AS mess
        on his.message_id = mess.message_id
    left join product as pro
     on his.product_id = pro.product_number
    where [description] = 'success'
)
Select distinct [quarter], [month]
    , count (order_id) Over (partition by [quarter]) As count_quarter
    , count (order_id) Over (partition by [month]) As count_month
from table_join
order by [quarter], [month];

/* 5. Compute the monthly total amount of customer transactions in 2018 and its percentage contribution to the annual total. */
With table_monthly_amount AS (
        Select month (transaction_date) as [month]
                , sum(cast (final_price As bigint)) As monthly_amount
        From payment_history_18
        Group by month (transaction_date)     
)
, table_annual_amount AS (
      Select * 
        ,(Select SUM(monthly_amount) from table_monthly_amount) AS annual_amount
      From table_monthly_amount
)
Select * 
, format (cast (monthly_amount As float)/annual_amount, 'p') As [percentage]
From table_annual_amount
 Order by [month];

/* 6.Identify product group received the highest total payment from customers in 2018. */
With table_product AS (
        Select   product_group
                , final_price
        From payment_history_18 AS his
        Left Join Product AS pro
        On his.product_id = pro.product_number
)
, Table_total_payment As (
        Select Product_group
        ,sum(cast (final_price AS bigint)) As payment_amount
        From table_product
        Group by product_group
)
 Select *
 , Rank() Over (order by payment_amount Desc) As Rank
 From Table_total_payment;

/* 7. Determine top 3 payment method was used most frequently in 2018 based on the number of transactions */
With table_join_method AS (
        Select order_id
                , his.payment_id
                , pay.[name]
        From payment_history_18 AS his
        Left Join paying_method AS pay
        On his.payment_id = pay.method_id
)
, table_transaction_count AS (
        Select [name]
                , count (order_id) AS number_transactions
        From table_join_method
        Group by [name]
)
, Table_rank AS (
        Select *
                , Rank () Over (order by number_transactions DESC) AS Rank
        From table_transaction_count
)
Select *
From Table_rank
Where Rank <= 3;

/* 8. Calculate the monthly total number of failed transaction, and the failed rate relative to the total transactions in 2018*/
With table_joined_mess as (
        Select month (transaction_date) AS [month]
                , order_id
                , description
        From payment_history_18 As his
        Left Join table_message AS mess
        On his.message_id=mess.message_id
        Where [description] != 'success'
)
, table_failed_transactions As (
        Select [month]
                , count (order_id) as number_failed_transaction
        From table_joined_mess
        Group by [month]
)
, table_total_failed_transaction AS (
        Select *
                , (select sum(number_failed_transaction) from table_failed_transactions) As total_failed_transaction
        From table_failed_transactions
)
Select *
        , format (Cast (number_failed_transaction AS float)/total_failed_transaction, 'p') As failure_rate
From table_total_failed_transaction;

/* 9. Measure growth in success transaction number in 2018 relative to the same period in 2017. */
With table_month AS (
        Select format (transaction_date, 'yyyyMM') AS [time] 
                , Customer_id
                ,order_id
                ,transaction_date
        from ( Select* from payment_history_17 Union Select * from payment_history_18) As his
        Left join table_message As mess
        On his.message_id = mess.message_id
        Where [Description] = 'success'
)
, table_monthly_transactions As (
        Select  distinct cast ([time] As int) as [time]
                , count (order_id) Over (partition by [time]) AS number_transaction_current_year
        from table_month
)
, Table_lag As (
        Select *
                , Lag (number_transaction_current_year, 12) Over (order by [time] Asc) As number_transaction_last_year
        From table_monthly_transactions
)
Select*
,  Format((number_transaction_current_year - number_transaction_last_year)/ cast (number_transaction_last_year as Decimal),'p') As [%_growth]
From table_lag
Where number_transaction_last_year is not null;

/* 10. List of new users in 2018 (who were not active in 2017). */
Select distinct customer_id
From payment_history_18
Where Year(transaction_date) = 2018
  and customer_id NOT IN (
      Select distinct customer_id
      From payment_history_17
     Where Year(transaction_date) = 2017
  )
ORDER BY customer_id;

/* 11. Customer retention rate broken down by month in 2018. */
With table_first As (
        Select customer_id
        , order_id
        , transaction_date
        , Min (Month(transaction_date)) Over (partition by customer_id) As First_month
        From payment_history_18
) 
, Table_month As (
        Select *
                , month (transaction_date) - first_month As month_n
        From table_first
)
, Retained_customer AS (
        Select first_month
                , month_n
                , count (distinct customer_id) As retained_customer
        From Table_month
        Group by first_month, month_n
        )
, Table_retention As (
        Select *
                , original_customer = Max(retained_customer) Over (partition by first_month) 
                , cast (retained_customer as decimal)/ Max(retained_customer) Over (partition by first_month) As pct
        From Retained_customer
        )

/* Bonus Query: Pivot table for customer retention Rate analysis by corhort*/

Select first_month
        , original_customer
        , [0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11]
From (
        Select first_month
        , month_n
        , original_customer
        , cast (pct as decimal (10,2)) as pct
        From Table_retention
) As source_table
Pivot (
        sum (pct)
        For month_n in ([0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11])
) As Pivot_logic
Order by first_month
