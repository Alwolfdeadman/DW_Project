if EXISTS (SELECT * FROM sys.databases where UPPER(name) like UPPER('Dimentions'))
ALTER DATABASE Dimentions SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DROP DATABASE IF EXISTS Dimentions
GO

CREATE DATABASE [Dimentions]
GO
USE [Dimentions]


-----TABLE-----

CREATE TABLE Date_Dimention(
Date_key DATE,
Year_num INT NOT NULL,
Month_num INT NOT NULL,
Day_num INT NOT NULL,
CONSTRAINT pk_dd PRIMARY KEY (Date_key)
);

CREATE TABLE Account_Dimention(
Account_key INT,
frequency VARCHAR(20) NOT NULL,
Date_of_creation DATE,
Balance FLOAT NOT NULL,
CONSTRAINT ch_frequency check (frequency in ('POPLATEK MESICNE','POPLATEK TYDNE','POPLATEK PO OBRATU')),
CONSTRAINT pk_ad PRIMARY KEY (Account_key)
);

CREATE TABLE Bank_Dimention(
Bank_key INT IDENTITY(1,1),
Bank_ident VARCHAR(5) NOT NULL,
CONSTRAINT pk_bd PRIMARY KEY (Bank_key)
);

CREATE TABLE Transaction_Type_Dimention(
Transaction_Type_key INT,
Trans_type VARCHAR(10) NOT NULL,
Res_for_trans VARCHAR(20),
CONSTRAINT ch_Res_for_trans check ( Res_for_trans in ('POJISTNE', 'SIPO', 'SLUZBY', 'UVER', 'UROK', 'SANKC. UROK', 'DUCHOD', '', ' ')),
CONSTRAINT ch_type_of_trans check ( Trans_type in ('PRIJEM', 'VYDAJ', 'VYBER', '', ' ')),
CONSTRAINT pk_ttd PRIMARY KEY (Transaction_Type_key)
);

CREATE TABLE Loan_Dimention(
Loan_key INT IDENTITY(1,1),
payment FLOAT NOT NULL,
duration INT NOT NULL,
l_status VARCHAR(4) NOT NULL,
CONSTRAINT ch_status check ( l_status in ('A', 'B', 'C', 'D', '', ' ')),
CONSTRAINT pk_ld PRIMARY KEY (Loan_key)
);

CREATE TABLE Permanent_order_type_dimension(
Permanent_Order_type_key INT,
PO_type VARCHAR(10) NOT NULL,
CONSTRAINT ch_PO_type check ( PO_type in ('POJISTNE','SIPO','LEASING','UVER', '', ' ')),
CONSTRAINT pk_pot PRIMARY KEY (Permanent_Order_type_key)
);

CREATE TABLE Transaction_fact(
Trans_ID INT IDENTITY(1,1),
date_of_trans DATE NOT NULL,
account_from INT NOT NULL,
bank_receiver INT NOT NULL,
transaction_type INT NOT NULL,
account_to INT NOT NULL,
amount FLOAT NOT NULL,
CONSTRAINT pk_t PRIMARY KEY (Trans_ID),
CONSTRAINT fk_tf_dd FOREIGN KEY (date_of_trans) REFERENCES Date_Dimention(Date_key),
CONSTRAINT fk_tf_ad FOREIGN KEY (account_from) REFERENCES Account_Dimention(Account_key),
CONSTRAINT fk_tf_bd FOREIGN KEY (bank_receiver) REFERENCES Bank_Dimention(Bank_key),
CONSTRAINT fk_tf_ttd FOREIGN KEY (transaction_type) REFERENCES Transaction_Type_Dimention(Transaction_Type_key),
);

CREATE TABLE Loan_fact(
Loan_ID INT IDENTITY(1,1),
date_of_loan DATE NOT NULL,
account INT NOT NULL,
loan INT NOT NULL,
amount INT NOT NULL,
payment FLOAT NOT NULL,
CONSTRAINT pk_l PRIMARY KEY (Loan_ID),
CONSTRAINT fk_lf_dd FOREIGN KEY (date_of_loan) REFERENCES Date_Dimention(Date_key),
CONSTRAINT fk_lf_ad FOREIGN KEY (account) REFERENCES Account_Dimention(Account_key),
CONSTRAINT fk_lf_ld FOREIGN KEY (loan) REFERENCES Loan_Dimention(Loan_key)
);

CREATE TABLE Permanent_order_fact(
Po_ID INT IDENTITY(1,1),
account_from INT NOT NULL,
account_to INT NOT NULL,
bank_receiver INT NOT NULL,
Permanent_Order_type INT NOT NULL,
amount FLOAT NOT NULL,
CONSTRAINT pk_po PRIMARY KEY (Po_ID),
CONSTRAINT fk_pof_ad FOREIGN KEY (account_from) REFERENCES Account_Dimention(Account_key),
CONSTRAINT fk_pof_bd FOREIGN KEY (bank_receiver) REFERENCES Bank_Dimention(Bank_key),
CONSTRAINT fk_pof_ld FOREIGN KEY (Permanent_Order_type) REFERENCES Permanent_order_type_dimension(Permanent_Order_type_key)
);



-----------------INSERTS----------------------
--only these dont work
INSERT INTO Date_Dimention(Date_key, Year_num, Month_num, Day_num)
SELECT DISTINCT A.date_of_trans as Date_key, YEAR(A.date_of_trans) as Year_num, MONTH(A.date_of_trans) as Month_num, DAY(A.date_of_trans) as Day_num
FROM Vault.dbo.S_Transaction as A;


INSERT INTO Date_Dimention(Date_key, Year_num, Month_num, Day_num)
SELECT DISTINCT A.date_of_creation as Date_key, YEAR(A.date_of_creation) as Year_num, MONTH(A.date_of_creation) as Month_num, DAY(A.date_of_creation) as Day_num
FROM Vault.dbo.S_Loan as A
WHERE NOT EXISTS (SELECT 1 FROM Date_Dimention as dd WHERE dd.Date_key = A.date_of_creation);


INSERT INTO Bank_Dimention(Bank_ident)
SELECT DISTINCT bank as Bank_ident
FROM Vault.dbo.S_Transaction
WHERE bank IS NOT NULL;

INSERT INTO Bank_Dimention(Bank_ident)
SELECT DISTINCT bank_to as Bank_ident
FROM Vault.dbo.S_Permanent_order
WHERE  bank_to NOT IN (SELECT Bank_ident FROM Bank_Dimention);



INSERT INTO Transaction_Type_Dimention(Transaction_Type_key, Trans_type, Res_for_trans)
VALUES(1, 'PRIJEM', 'POJISTNE'), (2, 'VYDAJ', 'POJISTNE'),
	  (3, 'PRIJEM', 'SIPO'), (4, 'VYDAJ', 'SIPO'),
	  (5, 'PRIJEM', 'SLUZBY'), (6, 'VYDAJ', 'SLUZBY'),
	  (7, 'PRIJEM', 'UVER'), (8, 'VYDAJ', 'UVER'),
	  (9, 'PRIJEM', 'UROK'), (10, 'VYDAJ', 'UROK'),
	  (11, 'PRIJEM', 'SANKC. UROK'), (12, 'VYDAJ', 'SANKC. UROK'),
	  (13, 'PRIJEM', 'DUCHOD'),(14, 'VYDAJ', 'DUCHOD');



INSERT INTO Account_Dimention(Account_key, Date_of_creation, frequency, Balance)
SELECT HA.account_id as Account_key, SA.Date_of_creation as Date_of_creation, SA.frequency as frequency, 0 as Balance
FROM Vault.dbo.H_Account as HA, Vault.dbo.S_Account as SA
WHERE HA.H_Account_ID = SA.H_Account_ID;

UPDATE Account_Dimention
SET Balance = ST.amount + ST.balance
FROM Account_Dimention as A, Vault.dbo.S_Transaction as ST
WHERE A.account_key = ST.account_id;



INSERT INTO Loan_Dimention(payment, duration, l_status)
SELECT L.payment as payment, L.duration as duration, L.l_status as l_status
FROM Vault.dbo.S_Loan as L;



INSERT INTO Permanent_order_type_dimension(Permanent_Order_type_key, PO_type)
VALUES (1, 'POJISTNE'),(2, 'SIPO'),(3, 'LEASING'),(4, 'UVER');





INSERT INTO Transaction_fact (date_of_trans, account_from, account_to, bank_receiver, transaction_type, amount)
SELECT A.date_of_trans,A.account_id as account_from, A.account as account_to, B.Bank_key as bank_receiver, T.Transaction_Type_key as transaction_type, A.amount as amount
FROM Vault.dbo.S_Transaction as A, Bank_Dimention as B, Transaction_Type_Dimention as T
WHERE B.Bank_ident = A.bank AND T.Trans_type = A.type_of_trans AND T.Res_for_trans = A.K_symbol;

INSERT INTO Loan_fact (date_of_loan, account, loan, amount, payment)
SELECT DISTINCT A.date_of_creation as date_of_loan, A.account_id as account, L.Loan_key as loan, A.amount as amount, A.payment as payment
FROM Vault.dbo.S_Loan as A, Loan_Dimention as L
WHERE A.payment = L.payment AND A.duration = L.duration AND A.l_status = L.l_status;

INSERT INTO Permanent_order_fact (account_from, account_to, bank_receiver, Permanent_Order_type, amount)
SELECT PO.account_id as account_from,  PO.account_to as account_to,  B.Bank_key as bank_receiver, P.Permanent_Order_type_key as Permanent_Order_type,  PO.amount as amount
FROM Vault.dbo.S_Permanent_order as PO, Permanent_order_type_dimension as P, Bank_Dimention as B
WHERE PO.K_symbol = P.PO_type AND B.Bank_ident = PO.bank_to;