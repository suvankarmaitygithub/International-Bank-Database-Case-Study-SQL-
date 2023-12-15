create database CASE_STUDY_3
use CASE_STUDY_3

SELECT * FROM [dbo].[Continent]
SELECT * FROM  [dbo].[CUSTOMERS]
SELECT * FROM  [dbo].[Transaction]

--1. Display the count of customers in each region who have done the transaction in the year 2020.

SELECT  C.[region_id],  C.[region_name]  , COUNT(*) AS COUNT_OF_CUSTOMERS  FROM [dbo].[CUSTOMERS] CS
JOIN [dbo].[Continent] C ON  CS.[region_id] = C.[region_id]
JOIN [dbo].[Transaction] T ON CS.[customer_id] = T.[customer_id]
WHERE YEAR([txn_date]) = 2020
GROUP BY C.[region_name] ,C.[region_id]

--2. Display the maximum and minimum transaction amount of each transaction type.

SELECT [txn_type] ,
      MIN([txn_amount]) AS MinimiumTransaction
    , MAX([txn_amount]) as Maximumtransaction
		from [dbo].[Transaction]
		group by [txn_type] ;

--3. Display the customer id, region name and transaction amount where transaction type is deposit and transaction amount > 2000.

select cs.[customer_id],c.[region_name] ,t. [txn_amount]    
from customers cs
join [dbo].[Continent] c on cs.[region_id] = c.[region_id]
join [dbo].[Transaction] t on cs.[customer_id] = t.[customer_id]
where t.[txn_type] = 'deposit' and [txn_amount] > 2000 ;

--4. Find duplicate records in the Customer table.

SELECT customer_id, COUNT(*) AS duplicate_count
FROM Customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

--5. Display the customer id, region name, transaction type and transaction amount for the minimum transaction amount in deposit.

SELECT C.customer_id, Co.region_name, T.txn_type, T.txn_amount
FROM Customers C
JOIN Continent Co ON C.region_id = Co.region_id
JOIN [Transaction] T ON C.customer_id = T.customer_id
WHERE T.txn_type = 'deposit'
AND T.txn_amount = (SELECT MIN(txn_amount) FROM [Transaction] WHERE txn_type = 'deposit');

--6. Create a stored procedure to display details of customers in the Transaction table where the transaction date is greater than Jun 2020.

 CREATE PROCEDURE GetCustomersAfterJun2020
AS
BEGIN
    SELECT C.customer_id, Co.region_name, T.txn_date, T.txn_type, T.txn_amount
    FROM Customers C
    JOIN Continent Co ON C.region_id = Co.region_id
    JOIN [Transaction] T ON C.customer_id = T.customer_id
    WHERE T.txn_date > '2020-06-01';
END;
 EXEC.GetCustomersAfterJun2020 ; ------- OUTPUT

--7. Create a stored procedure to insert a record in the Continent table.

CREATE PROCEDURE CO
@REGION_ID INT,
@REGION_NAME VARCHAR(30)
AS
BEGIN
  INSERT INTO [dbo].[Continent] (region_id,region_name)
  VALUES (@REGION_ID,@region_name);
  END;

  EXEC CO @REGION_ID = 4,@region_name = 'INDIA' ; --OUTPUT

  SELECT * FROM [dbo].[Continent]
--8. Create a stored procedure to display the details of transactions that happened on a specific day.

CREATE PROCEDURE GetTransactionsOnSpecificDay
    @search_date DATE
AS
BEGIN
    SELECT C.customer_id, Co.region_name, T.txn_date, T.txn_type, T.txn_amount
    FROM Customers C
    JOIN Continent Co ON C.region_id = Co.region_id
    JOIN [Transaction] T ON C.customer_id = T.customer_id
    WHERE T.txn_date = @search_date;
END;
EXEC GetTransactionsOnSpecificDay   @search_date = '2020-01-18' -- output  @search_date DATE
 select * from [dbo].[Transaction]

--9. Create a user defined function to add 10% of the transaction amount in a table.

create function add_ten_percent
(@amount int)
returns int
as
begin
     declare @newAmount int
	 set @newAmount =  @amount + (@amount * 0.10)
	 return @newAmount ;
	 end ;

--10. Create a user defined function to find the total transaction amount for a
--given transaction type.

CREATE FUNCTION total_transaction_amount(@transaction_type varchar(50)) 
RETURNS int
AS
BEGIN
    DECLARE @total_amount int;

    SELECT @total_amount = SUM(txn_amount) 

    FROM [dbo].[Transaction]
    WHERE txn_type = @transaction_type;

    RETURN @total_amount;
END;

select dbo.total_transaction_amount('deposit')

--11. Create a table value function which comprises the columns customer_id,
--region_id ,txn_date , txn_type , txn_amount which will retrieve data from
--the above table.

create function table_vakue(,@region_id int,)
--12. Create a TRY...CATCH block to print a region id and region name in a
--single column.

BEGIN TRY
    
    SELECT region_id, region_name FROM Continent;
END TRY
BEGIN CATCH
    
    SELECT 'Error occurred' AS RegionInfo;
END CATCH;

--13. Create a TRY...CATCH block to insert a value in the Continent table.

BEGIN TRY
    
    INSERT INTO Continent (region_id,region_name)
    VALUES (1, 'Asia'); -- Replace with your actual data
END TRY
BEGIN CATCH

    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

--14. Create a trigger to prevent deleting a table in a database.
--DDL TRIGGERS
create trigger trg_ddl_drop
on database
for drop_table
as
begin
  rollback; ---- undo the changes performed the tabe get dropped a trigger get rollbacl
  print('Table drop is not allowed')
end


drop trigger trg_ddl_drop on database

--15. Create a trigger to audit the data in a table.

Create table tblOrders
(
  OrderID integer Identity(1,1) primary key,
  OrderApprovalDateTime datetime,
  OrderStatus varchar(20)
)

create table tblOrdersAudit
(
  OrderAuditID integer Identity(1,1) primary key,
  OrderID integer,
  OrderApprovalDateTime datetime,
  OrderStatus varchar(20),
  UpdatedBy nvarchar(128),
  UpdatedOn datetime
)
go
  
create trigger tblTriggerAuditRecord on tblOrders
after update, insert
as
begin
  insert into tblOrdersAudit 
  (OrderID, OrderApprovalDateTime, OrderStatus, UpdatedBy, UpdatedOn )
  select i.OrderID, i.OrderApprovalDateTime, i.OrderStatus, SUSER_SNAME(), getdate() 
  from  tblOrders t 
  inner join inserted i on t.OrderID=i.OrderID 
end
go

insert into tblOrders values (NULL, 'Pending')
insert into tblOrders values (NULL, 'Pending')
insert into tblOrders values (NULL, 'Pending')
go

select * from tblOrders
select * from tblOrdersAudit

update tblOrders 
set OrderStatus='Approved', 
OrderApprovalDateTime=getdate()  
where OrderID=1
go

select * from tblOrders
select * from tblOrdersAudit order by OrderID, OrderAuditID
go

update tblOrders 
set OrderStatus='Approved', 
OrderApprovalDateTime=getdate()  
where OrderID=2

go

select * from tblOrders
select * from tblOrdersAudit order by OrderID, OrderAuditID
go

update tblOrders 
set OrderStatus='Cancelled'
where OrderID=1
go

select * from tblOrders
select * from tblOrdersAudit order by OrderID, OrderAuditID
go

--16. Create a trigger to prevent login of the same user id in multiple pages.

CREATE TABLE UserSessions (
    session_id INT PRIMARY KEY,
    user_id INT,
    login_time DATETIME
);

CREATE TABLE UserSessions (
    session_id INT PRIMARY KEY,
    user_id INT,
    login_time DATETIME
);

-- Create a trigger to prevent multiple logins
CREATE TRIGGER PreventMultipleLogins
ON UserSessions
AFTER INSERT
AS
BEGIN
    DECLARE @UserId INT, @SessionId INT;
    
    -- Get the user_id and session_id from the inserted row
    SELECT @UserId = user_id, @SessionId = session_id FROM INSERTED;

    -- Check if the user is already logged in 
    IF EXISTS (SELECT 1 FROM UserSessions WHERE user_id = @UserId AND session_id <> @SessionId)
    BEGIN
     
        ROLLBACK TRANSACTION;
    END
END;

--17. Display top n customers on the basis of transaction type.
WITH CustomerTransactionCounts AS (
    SELECT
        customer_id,
        COUNT(*) AS transaction_count
    FROM
        [dbo].[Transaction]
    WHERE
        txn_type = 'deposit'
    GROUP BY
        customer_id
)

SELECT
    customer_id,
    transaction_count
FROM
    CustomerTransactionCounts
ORDER BY
    transaction_count DESC


--18. Create a pivot table to display the total purchase, withdrawal and
--deposit for all the customers.
SELECT *
FROM (
    SELECT customer_id, txn_type, txn_amount
    FROM [Transaction]
) AS SourceTable
PIVOT (
    SUM(txn_amount)
    FOR txn_type IN ([Purchase], [Withdrawal], [Deposit])
) AS PivotTable;
