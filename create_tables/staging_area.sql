if EXISTS (SELECT * FROM sys.databases where UPPER(name) like UPPER('Staging_area'))
ALTER DATABASE Staging_area SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DROP DATABASE IF EXISTS Staging_area
GO

CREATE DATABASE [Staging_area]
GO
USE [Staging_area]

--------TABLES----------
CREATE TABLE account(
account_id INT,
district_id INT,
Date_of_creation DATE,
frequency VARCHAR(20),
load_in_date DATE,
Record_source VARCHAR(40),
CONSTRAINT ch_frequency check (frequency in ('POPLATEK MESICNE','POPLATEK TYDNE','POPLATEK PO OBRATU')),
CONSTRAINT pk_a PRIMARY KEY (account_id, load_in_date)
);

CREATE TABLE client(
client_id INT,
birth_number VARCHAR(8),
district_id INT,
load_in_date DATE,
Record_source VARCHAR(40),
CONSTRAINT pk_c PRIMARY KEY (client_id, load_in_date)
);


CREATE TABLE disposition(
disp_id INT,
account_id INT,
client_id INT,
type_of_disposition VARCHAR(20),
load_in_date DATE,
Record_source VARCHAR(40),
CONSTRAINT pk_d PRIMARY KEY (disp_id, load_in_date)
);

CREATE TABLE permanent_order(
order_id INT,
account_id INT,
bank_to VARCHAR(5),
account_to VARCHAR(30),
amount FLOAT,
K_symbol VARCHAR(10),
load_in_date DATE,
Record_source VARCHAR(40),
CONSTRAINT ch_K_symbol check ( K_symbol in ('POJISTNE','SIPO','LEASING','UVER',' ', '')),
CONSTRAINT pk_po PRIMARY KEY (order_id, load_in_date)
);


CREATE TABLE transactions(
trans_id INT,
account_id INT,
date_of_trans DATE,
type_of_trans VARCHAR(10),
operation_mode_t VARCHAR(20),
amount FLOAT,
balance FLOAT,
K_symbol VARCHAR(20),
bank VARCHAR(5),
account VARCHAR(30),
load_in_date DATE,
Record_source VARCHAR(40),
CONSTRAINT ch_K_symbol_t check ( K_symbol in ('POJISTNE', 'SIPO', 'SLUZBY', 'UVER', 'UROK', 'SANKC. UROK', 'DUCHOD', '', ' ')),
CONSTRAINT ch_type_of_trans check ( type_of_trans in ('PRIJEM', 'VYDAJ', 'VYBER', '', ' ')),
CONSTRAINT ch_operation_mode check ( operation_mode_t in ('VYBER KARTOU', 'VKLAD', 'PREVOD Z UCTU', 'VYBER', 'PREVOD NA UCET', '', ' ')),
CONSTRAINT pk_t PRIMARY KEY (trans_id, load_in_date)
);

CREATE TABLE loan(
loan_id INT,
account_id INT,
date_of_creation DATE,
amount INT,
duration INT,
payment FLOAT,
l_status VARCHAR(4),
load_in_date DATE,
Record_source VARCHAR(40),
CONSTRAINT ch_status check ( l_status in ('A', 'B', 'C', 'D')),
CONSTRAINT pk_l PRIMARY KEY (loan_id, load_in_date)
);


CREATE TABLE credit_card(
card_id INT,
disp_id INT,
type_of_card VARCHAR(12),
issued DATE,
load_in_date DATE,
Record_source VARCHAR(40),
CONSTRAINT pk_cc PRIMARY KEY (card_id, load_in_date)
);


CREATE TABLE demographic_data(
district_id INT,
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
load_in_date DATE,
Record_source VARCHAR(40),
CONSTRAINT pk_dd PRIMARY KEY (district_id, load_in_date)
);

-----------------INSERTS----------------------
INSERT INTO account (account_id, district_id, Date_of_creation, frequency, Record_source, load_in_date)
SELECT account_id, district_id, Date_of_creation, frequency, 'sourse_data' as Record_source, GETDATE() as load_in_date FROM Source.dbo.account;

INSERT INTO demographic_data ( district_id, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, Record_source, load_in_date)
SELECT district_id, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, 'sourse_data' as Record_source, GETDATE() as load_in_date FROM Source.dbo.demographic_data;

INSERT INTO client (client_id, birth_number, district_id, Record_source, load_in_date)
SELECT client_id, birth_number, district_id, 'sourse_data' as Record_source, GETDATE() as load_in_date FROM Source.dbo.client;

INSERT INTO disposition (disp_id, account_id, client_id, type_of_disposition, Record_source, load_in_date)
SELECT disp_id, account_id, client_id, type_of_disposition, 'sourse_data' as Record_source, GETDATE() as load_in_date FROM Source.dbo.disposition;
UPDATE disposition
SET type_of_disposition = REPLACE(type_of_disposition, '"', '')

INSERT INTO permanent_order (order_id, account_id, bank_to, account_to, amount, K_symbol, Record_source, load_in_date)
SELECT order_id, account_id, bank_to, account_to, amount, K_symbol, 'sourse_data' as Record_source, GETDATE() as load_in_date FROM Source.dbo.permanent_order;
UPDATE permanent_order
SET bank_to = REPLACE(bank_to, '"', '')

INSERT INTO transactions (trans_id, account_id, date_of_trans, type_of_trans, operation_mode_t, amount, balance, K_symbol, bank, account, Record_source, load_in_date)
SELECT trans_id, account_id, date_of_trans, type_of_trans, operation_mode_t, amount, balance, K_symbol, bank, account, 'sourse_data' as Record_source, GETDATE() as load_in_date FROM Source.dbo.transactions;
UPDATE transactions
SET bank = REPLACE(bank, '"', '')

INSERT INTO loan (loan_id, account_id, date_of_creation, amount, duration, payment, l_status, Record_source, load_in_date)
SELECT loan_id, account_id, date_of_creation, amount, duration, payment, l_status, 'sourse_data' as Record_source, GETDATE() as load_in_date FROM Source.dbo.loan;

INSERT INTO credit_card (card_id, disp_id, type_of_card, issued, Record_source, load_in_date)
SELECT card_id, disp_id, type_of_card, issued, 'Source' as Record_source, GETDATE() as load_in_date FROM Source.dbo.credit_card;
UPDATE credit_card
SET type_of_card = REPLACE(type_of_card, '"', '')