if EXISTS (SELECT * FROM sys.databases where UPPER(name) like UPPER('Vault'))
ALTER DATABASE Vault SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DROP DATABASE IF EXISTS Vault
GO

CREATE DATABASE [Vault]
GO
USE [Vault]

--------TABLES----------
CREATE TABLE H_Permanent_order(
H_Permanent_order_ID INT IDENTITY(1,1),
order_id INT,
Load_in_date DATE,
Record_source VARCHAR(40),
CONSTRAINT pk_h_po PRIMARY KEY (H_Permanent_order_ID)
);

CREATE TABLE H_Account(
H_Account_ID  INT IDENTITY(1,1),
account_id INT,
Load_in_date DATE,
Record_source VARCHAR(40),
CONSTRAINT pk_h_a PRIMARY KEY (H_Account_ID)
);

CREATE TABLE H_Loan(
H_Loan_ID INT IDENTITY(1,1),
loan_ID INT,
Load_in_date DATE,
Record_source VARCHAR(40),
CONSTRAINT pk_h_l PRIMARY KEY (H_Loan_ID)
);

CREATE TABLE H_Transaction(
H_Transaction_ID INT IDENTITY(1,1),
transaction_ID INT,
Load_in_date DATE,
Record_source VARCHAR(40),
CONSTRAINT pk_h_t PRIMARY KEY (H_Transaction_ID)
);

CREATE TABLE H_Demographic_data(
H_Demographic_data_ID INT IDENTITY(1,1),
district_id INT,
Load_in_date DATE,
Record_source VARCHAR(40),
CONSTRAINT pk_h_dd PRIMARY KEY (H_Demographic_data_ID)
);

CREATE TABLE H_Disposition (
H_Disposition_ID INT IDENTITY(1,1),
disp_id INT,
Load_in_date DATE,
Record_source VARCHAR(40),
CONSTRAINT pk_h_d PRIMARY KEY (H_Disposition_ID)
);

CREATE TABLE H_Client(
H_Client_ID INT IDENTITY(1,1),
client_id INT,
Load_in_date DATE,
Record_source VARCHAR(40),
CONSTRAINT pk_h_c PRIMARY KEY (H_Client_ID)
);

CREATE TABLE H_Credit_card(
H_Credit_card_ID INT IDENTITY(1,1),
Card_id INT,
Load_in_date DATE,
Record_source VARCHAR(40),
CONSTRAINT pk_h_cc PRIMARY KEY (H_Credit_card_ID)
);





CREATE TABLE S_Permanent_order(
H_Permanent_order_ID INT,
Load_in_date DATE,
account_id INT,
bank_to VARCHAR(5),
account_to VARCHAR(30),
amount FLOAT,
K_symbol VARCHAR(10),
Record_source VARCHAR(40),
CONSTRAINT ch_K_symbol check ( K_symbol in ('POJISTNE','SIPO','LEASING','UVER',' ', '')),
CONSTRAINT pk_s_po PRIMARY KEY (H_Permanent_order_ID,Load_in_date),
CONSTRAINT fk_s_po_h FOREIGN KEY (H_Permanent_order_ID) REFERENCES H_Permanent_order(H_Permanent_order_ID)
);

CREATE TABLE S_Account(
H_Account_ID INT,
Load_in_date DATE,
district_id INT,
Date_of_creation DATE,
frequency VARCHAR(20),
Record_source VARCHAR(40),
CONSTRAINT ch_frequency check (frequency in ('POPLATEK MESICNE','POPLATEK TYDNE','POPLATEK PO OBRATU')),
CONSTRAINT pk_s_a PRIMARY KEY (H_Account_ID,Load_in_date),
CONSTRAINT fk_s_a_h FOREIGN KEY (H_Account_ID) REFERENCES H_Account(H_Account_ID)
);

CREATE TABLE S_Loan(
H_Loan_ID INT,
Load_in_date DATE,
account_id INT,
date_of_creation DATE,
amount INT,
duration INT,
payment FLOAT,
l_status VARCHAR(4),
Record_source VARCHAR(40),
CONSTRAINT ch_status check ( l_status in ('A', 'B', 'C', 'D')),
CONSTRAINT pk_s_l PRIMARY KEY (H_Loan_ID, Load_in_date),
CONSTRAINT fk_s_l_h FOREIGN KEY (H_Loan_ID) REFERENCES H_Loan(H_Loan_ID)
);

CREATE TABLE S_Transaction(
H_Transaction_ID INT,
Load_in_date DATE,
account_id INT,
date_of_trans DATE,
type_of_trans VARCHAR(10),
operation_mode_t VARCHAR(20),
amount FLOAT,
balance FLOAT,
K_symbol VARCHAR(20),
bank VARCHAR(5),
account VARCHAR(30),
Record_source VARCHAR(40),
CONSTRAINT ch_K_symbol_t check ( K_symbol in ('POJISTNE', 'SIPO', 'SLUZBY', 'UVER', 'UROK', 'SANKC. UROK', 'DUCHOD', '', ' ')),
CONSTRAINT ch_type_of_trans check ( type_of_trans in ('PRIJEM', 'VYDAJ', 'VYBER', '', ' ')),
CONSTRAINT ch_operation_mode check ( operation_mode_t in ('VYBER KARTOU', 'VKLAD', 'PREVOD Z UCTU', 'VYBER', 'PREVOD NA UCET', '', ' ')),
CONSTRAINT pk_s_t PRIMARY KEY (H_Transaction_ID, Load_in_date),
CONSTRAINT fk_s_t_h FOREIGN KEY (H_Transaction_ID) REFERENCES H_Transaction(H_Transaction_ID)
);

CREATE TABLE S_Demographic_data(
H_Demographic_data_ID INT,
Load_in_date DATE,
A2 VARCHAR(30),
A3 VARCHAR(30),
A4 INT,
A5 INT,
A6 INT,
A7 INT,
A8 INT,
A9 INT,
A10 FLOAT,
A11 INT,
A12 FLOAT CONSTRAINT df_A12 DEFAULT 0.0,
A13 FLOAT,
A14 INT,
A15 INT CONSTRAINT df_A15 DEFAULT 0,
A16 INT,
Record_source VARCHAR(40),
CONSTRAINT pk_s_dd PRIMARY KEY (H_Demographic_data_ID, Load_in_date),
CONSTRAINT fk_s_dd_h FOREIGN KEY (H_Demographic_data_ID) REFERENCES H_Demographic_data(H_Demographic_data_ID)
);

CREATE TABLE S_Disposition (
H_Disposition_ID INT,
Load_in_date DATETIME,
account_id INT,
client_id INT,
type_of_disposition VARCHAR(20),
Record_source VARCHAR(40),
CONSTRAINT pk_s_d PRIMARY KEY (H_Disposition_ID, Load_in_date),
CONSTRAINT fk_s_d_h FOREIGN KEY (H_Disposition_ID) REFERENCES H_Disposition(H_Disposition_ID)
);

CREATE TABLE S_Client(
H_Client_ID INT,
Load_in_date DATETIME,
district_id INT,
birth_number VARCHAR(8),
Record_source VARCHAR(40),
CONSTRAINT pk_s_c PRIMARY KEY (H_Client_ID, Load_in_date),
CONSTRAINT fk_s_c_h FOREIGN KEY (H_Client_ID) REFERENCES H_Client(H_Client_ID)
);

CREATE TABLE S_Credit_card(
H_Credit_card_ID INT,
Load_in_date DATETIME,
disp_id INT,
type_of_card VARCHAR(12),
issued DATE,
Record_source VARCHAR(40),
CONSTRAINT pk_s_cc PRIMARY KEY (H_Credit_card_ID, Load_in_date),
CONSTRAINT fk_s_cc_h FOREIGN KEY (H_Credit_card_ID) REFERENCES H_Credit_card(H_Credit_card_ID)
);




CREATE TABLE L_Account_Permanent_order(
L_Account_Permanent_order_ID INT IDENTITY(1,1),
H_Permanent_order_ID INT,
H_Account_ID INT,
Load_in_date DATETIME,
Record_source VARCHAR(40),
CONSTRAINT pk_l_apo PRIMARY KEY (L_Account_Permanent_order_ID),
CONSTRAINT fk_l_a_po FOREIGN KEY (H_Permanent_order_ID) REFERENCES H_Permanent_order(H_Permanent_order_ID),
CONSTRAINT fk_l_po_a FOREIGN KEY (H_Account_ID)REFERENCES H_Account(H_Account_ID)
);

CREATE TABLE L_Account_Loan(
L_Account_Loan_ID INT IDENTITY(1,1),
H_Loan_ID INT,
H_Account_ID INT,
Load_in_date DATETIME,
Record_source VARCHAR(40),
CONSTRAINT pk_l_al PRIMARY KEY (L_Account_Loan_ID),
CONSTRAINT fk_l_l_a FOREIGN KEY (H_Account_ID) REFERENCES H_Account(H_Account_ID),
CONSTRAINT fk_l_a_l FOREIGN KEY (H_Loan_ID) REFERENCES H_Loan(H_Loan_ID)
);

CREATE TABLE L_Account_Transaction(
L_Account_Transaction_ID INT IDENTITY(1,1),
H_Transaction_ID INT,
H_Account_ID INT,
Load_in_date DATETIME,
Record_source VARCHAR(40),
CONSTRAINT pk_l_at PRIMARY KEY (L_Account_Transaction_ID),
CONSTRAINT fk_l_t_a FOREIGN KEY (H_Account_ID) REFERENCES H_Account(H_Account_ID),
CONSTRAINT fk_l_a_t FOREIGN KEY (H_Transaction_ID) REFERENCES H_Transaction(H_Transaction_ID)
);

CREATE TABLE L_Account_Demographic_data(
L_Account_Demographic_data_ID INT IDENTITY(1,1),
H_Demographic_data_ID INT,
H_Account_ID INT,
Load_in_date DATETIME,
Record_source VARCHAR(40),
CONSTRAINT pk_l_add PRIMARY KEY (L_Account_Demographic_data_ID),
CONSTRAINT fk_l_dd_a FOREIGN KEY (H_Account_ID) REFERENCES H_Account(H_Account_ID),
CONSTRAINT fk_l_a_dd FOREIGN KEY (H_Demographic_data_ID) REFERENCES H_Demographic_data(H_Demographic_data_ID)
);

CREATE TABLE L_Account_Disposition(
L_Account_Disposition_ID INT IDENTITY(1,1),
H_Disposition_ID INT,
H_Account_ID INT,
Load_in_date DATETIME,
Record_source VARCHAR(40),
CONSTRAINT pk_l_ad PRIMARY KEY (L_Account_Disposition_ID),
CONSTRAINT fk_l_d_a FOREIGN KEY (H_Account_ID) REFERENCES H_Account(H_Account_ID),
CONSTRAINT fk_l_a_d FOREIGN KEY (H_Disposition_ID) REFERENCES H_Disposition(H_Disposition_ID)
);

CREATE TABLE L_Disposition_Client (
L_Disposition_Client_ID INT IDENTITY(1,1),
H_Disposition_ID INT,
H_Client_ID INT,
Load_in_date DATETIME,
Record_source VARCHAR(40),
CONSTRAINT pk_l_dc PRIMARY KEY (L_Disposition_Client_ID),
CONSTRAINT fk_l_d_c FOREIGN KEY (H_Client_ID) REFERENCES H_Client(H_Client_ID),
CONSTRAINT fk_l_c_d FOREIGN KEY (H_Disposition_ID) REFERENCES H_Disposition(H_Disposition_ID)
);

CREATE TABLE L_Client_Demographic_data(
L_Client_Demographic_data_ID INT IDENTITY(1,1),
H_Demographic_data_ID INT,
H_Client_ID INT,
Load_in_date DATETIME,
Record_source VARCHAR(40),
CONSTRAINT pk_l_ddc PRIMARY KEY (L_Client_Demographic_data_ID),
CONSTRAINT fk_l_dd_c FOREIGN KEY (H_Client_ID) REFERENCES H_Client(H_Client_ID),
CONSTRAINT fk_l_c_dd FOREIGN KEY (H_Demographic_data_ID) REFERENCES H_Demographic_data(H_Demographic_data_ID)
);

CREATE TABLE L_Disposition_Credit_card(
L_Disposition_Credit_card_ID INT IDENTITY(1,1),
H_Disposition_ID INT,
H_Credit_card_ID INT,
Load_in_date DATETIME,
Record_source VARCHAR(40),
CONSTRAINT pk_l_dcc PRIMARY KEY (L_Disposition_Credit_card_ID),
CONSTRAINT fk_l_d_cc FOREIGN KEY (H_Credit_card_ID) REFERENCES H_Credit_card(H_Credit_card_ID),
CONSTRAINT fk_l_cc_d FOREIGN KEY (H_Disposition_ID) REFERENCES H_Disposition(H_Disposition_ID)
);

-----------------INSERTS----------------------

INSERT INTO H_Permanent_order (order_id, Load_in_date, Record_source)
SELECT order_id, Load_in_date, Record_source FROM Staging_area.dbo.permanent_order;

INSERT INTO H_Account (account_id, Load_in_date, Record_source)
SELECT account_id, Load_in_date, Record_source FROM Staging_area.dbo.account;

INSERT INTO H_Loan (loan_ID, Load_in_date, Record_source)
SELECT loan_ID, Load_in_date, Record_source FROM Staging_area.dbo.loan;

INSERT INTO H_Transaction (transaction_ID, Load_in_date, Record_source)
SELECT trans_id as transaction_ID, Load_in_date, Record_source FROM Staging_area.dbo.transactions;

INSERT INTO H_Demographic_data (district_id, Load_in_date, Record_source)
SELECT  district_id, Load_in_date, Record_source FROM Staging_area.dbo.demographic_data;

INSERT INTO H_Disposition (disp_id, Load_in_date, Record_source)
SELECT disp_id, Load_in_date, Record_source FROM Staging_area.dbo.disposition;

INSERT INTO H_Client (client_id, Load_in_date, Record_source)
SELECT client_id, Load_in_date, Record_source FROM Staging_area.dbo.client;

INSERT INTO H_Credit_card (Card_id, Load_in_date, Record_source)
SELECT Card_id, Load_in_date, Record_source FROM Staging_area.dbo.credit_card;



INSERT INTO S_Permanent_order (H_Permanent_order_ID, Load_in_date, account_id, bank_to, account_to, amount, K_symbol, Record_source)
SELECT B.H_Permanent_order_ID, A.load_in_date, A.account_id, A.bank_to, A.account_to, A.amount, A.K_symbol, A.Record_source
FROM Staging_area.dbo.permanent_order as A, H_Permanent_order as B
WHERE A.order_id = B.order_id;

INSERT INTO S_Account (H_Account_ID, Load_in_date, district_id, Date_of_creation, frequency, Record_source)
SELECT B.H_Account_ID, B.Load_in_date, A.district_id, A.Date_of_creation, A.frequency, A.Record_source
FROM Staging_area.dbo.account as A, H_Account as B
WHERE B.account_id = A.account_id;

INSERT INTO S_Loan (H_Loan_ID, Load_in_date, account_ID, date_of_creation, amount, duration, payment, l_status, Record_source)
SELECT B.H_Loan_ID, B.Load_in_date, A.account_ID, A.date_of_creation, A.amount, A.duration, A.payment, A.l_status, A.Record_source
FROM Staging_area.dbo.loan as A, H_Loan as B
WHERE B.loan_ID = A.loan_id;

INSERT INTO S_Transaction (H_Transaction_ID, Load_in_date, account_id, type_of_trans, date_of_trans, operation_mode_t, amount, balance, K_symbol, bank, account, Record_source)
SELECT B.H_Transaction_ID, B.Load_in_date, A.account_ID, A.type_of_trans, A.date_of_trans, A.operation_mode_t, A.amount, A.balance, A.K_symbol, A.bank, A.account, A.Record_source
FROM Staging_area.dbo.transactions as A, H_Transaction as B
WHERE B.transaction_ID = A.trans_id;

INSERT INTO S_Demographic_data (H_Demographic_data_ID, Load_in_date, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, Record_source)
SELECT B.H_Demographic_data_ID, B.Load_in_date, A.A2, A.A3, A.A4, A.A5, A.A6, A.A7, A.A8, A.A9, A.A10, A.A11, A.A12, A.A13, A.A14, A.A15, A.A16, A.Record_source
FROM Staging_area.dbo.demographic_data as A, H_Demographic_data as B
WHERE B.district_id = A.district_id;

INSERT INTO S_Disposition (H_Disposition_ID, Load_in_date, account_id, client_id, type_of_disposition, Record_source)
SELECT B.H_Disposition_ID, B.Load_in_date, A.account_id, A.client_id, A.type_of_disposition, A.Record_source
FROM Staging_area.dbo.disposition as A, H_Disposition as B
WHERE B.disp_id = A.disp_id;

INSERT INTO S_Client (H_Client_ID, Load_in_date, district_id, birth_number, Record_source)
SELECT B.H_Client_ID, B.Load_in_date, A.district_id, A.birth_number, A.Record_source
FROM Staging_area.dbo.client as A, H_Client as B
WHERE B.client_id = A.client_id;

INSERT INTO S_Credit_card (H_Credit_card_ID, Load_in_date, disp_id, type_of_card, issued, Record_source)
SELECT B.H_Credit_card_ID, B.Load_in_date, A.disp_id, A.type_of_card, A.issued, A.Record_source
FROM Staging_area.dbo.credit_card as A, H_Credit_card as B
WHERE B.Card_id = A.card_id;





INSERT INTO L_Account_Permanent_order(H_Permanent_order_ID, H_Account_ID, Load_in_date, Record_source)
SELECT B.H_Permanent_order_ID, C.H_Account_ID, B.Load_in_date, B.Record_source 
FROM H_Permanent_order as A, S_Permanent_order as B, H_Account as C
WHERE B.H_Permanent_order_ID = A.H_Permanent_order_ID AND C.account_id = B.account_id;

INSERT INTO L_Account_Loan(H_Loan_ID, H_Account_ID, Load_in_date, Record_source)
SELECT A.H_Loan_ID, C.H_Account_ID, B.Load_in_date, B.Record_source
FROM H_Loan as A, S_Loan as B, H_Account as C
WHERE B.H_Loan_ID = A.H_Loan_ID AND C.account_id = B.account_id;

INSERT INTO L_Account_Transaction(H_Transaction_ID, H_Account_ID, Load_in_date, Record_source)
SELECT A.H_Transaction_ID, C.H_Account_ID, B.Load_in_date, B.Record_source
FROM H_Transaction as A, S_Transaction as B, H_Account as C
WHERE B.H_Transaction_ID = A.H_Transaction_ID AND C.account_id = B.account_id;

INSERT INTO L_Account_Demographic_data(H_Demographic_data_ID, H_Account_ID, Load_in_date, Record_source)
SELECT A.H_Demographic_data_ID, C.H_Account_ID, B.Load_in_date, B.Record_source
FROM H_Demographic_data as A, S_Account as B, H_Account as C
WHERE B.H_Account_ID = C.H_Account_ID AND A.district_id = B.district_id;

INSERT INTO L_Account_Disposition(H_Disposition_ID, H_Account_ID, Load_in_date, Record_source)
SELECT A.H_Disposition_ID, C.H_Account_ID, B.Load_in_date, B.Record_source
FROM H_Disposition as A, S_Disposition as B, H_Account as C
WHERE B.H_Disposition_ID = A.H_Disposition_ID AND C.account_id = B.account_id;

INSERT INTO L_Disposition_Client(H_Disposition_ID, H_Client_ID, Load_in_date, Record_source)
SELECT A.H_Disposition_ID, C.H_Client_ID, B.Load_in_date, B.Record_source
FROM H_Disposition as A, S_Disposition as B, H_Client as C
WHERE B.H_Disposition_ID = A.H_Disposition_ID AND C.client_id = B.client_id;

INSERT INTO L_Client_Demographic_data(H_Demographic_data_ID, H_Client_ID, Load_in_date, Record_source)
SELECT A.H_Demographic_data_ID, C.H_Client_ID, B.Load_in_date, B.Record_source
FROM H_Demographic_data as A, S_Client as B, H_Client as C
WHERE B.H_Client_ID = C.H_Client_ID AND A.district_id = B.district_id;

INSERT INTO L_Disposition_Credit_card(H_Disposition_ID, H_Credit_card_ID, Load_in_date, Record_source)
SELECT A.H_Disposition_ID, C.H_Credit_card_ID, B.Load_in_date, B.Record_source
FROM H_Disposition as A, S_Credit_card as B, H_Credit_card as C
WHERE B.H_Credit_card_ID = C.H_Credit_card_ID AND B.disp_id = A.disp_id;