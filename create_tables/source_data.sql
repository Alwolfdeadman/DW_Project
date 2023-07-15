if EXISTS (SELECT * FROM sys.databases where UPPER(name) like UPPER('Source'))
ALTER DATABASE Source SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DROP DATABASE IF EXISTS Source
GO

CREATE DATABASE [Source]
GO
USE [Source]

--------TABLES----------
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
CONSTRAINT pk_dd PRIMARY KEY (district_id),
);

CREATE TABLE account(
account_id INT,
district_id INT,
Date_of_creation DATE,
frequency VARCHAR(20),
CONSTRAINT ch_frequency check (frequency in ('POPLATEK MESICNE','POPLATEK TYDNE','POPLATEK PO OBRATU')),
CONSTRAINT pk_a PRIMARY KEY (account_id),
CONSTRAINT fk_add FOREIGN KEY (district_id) REFERENCES demographic_data
);


CREATE TABLE client(
client_id INT,
birth_number VARCHAR(8),
district_id INT,
CONSTRAINT pk_c PRIMARY KEY (client_id),
CONSTRAINT fk_cdd FOREIGN KEY (district_id) REFERENCES demographic_data
);

CREATE TABLE disposition(
disp_id INT,
account_id INT,
client_id INT,
type_of_disposition VARCHAR(20),
CONSTRAINT pk_d PRIMARY KEY (disp_id),
CONSTRAINT fk_da FOREIGN KEY (account_id) REFERENCES account(account_id),
CONSTRAINT fk_dc FOREIGN KEY (client_id) REFERENCES client(client_id)
);

CREATE TABLE permanent_order(
order_id INT,
account_id INT,
bank_to VARCHAR(5),
account_to VARCHAR(30),
amount FLOAT,
K_symbol VARCHAR(10),
CONSTRAINT ch_K_symbol CHECK ( K_symbol in ('POJISTNE','SIPO','LEASING','UVER',' ', '')),
CONSTRAINT pk_po PRIMARY KEY (order_id),
CONSTRAINT fk_poa1 FOREIGN KEY (account_id) REFERENCES account(account_id)
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
CONSTRAINT ch_K_symbol_t check ( K_symbol in ('POJISTNE', 'SIPO', 'SLUZBY', 'UVER', 'UROK', 'SANKC. UROK', 'DUCHOD', '', ' ')),
CONSTRAINT ch_type_of_trans check ( type_of_trans in ('PRIJEM', 'VYDAJ', 'VYBER')),
CONSTRAINT ch_operation_mode check ( operation_mode_t in ('VYBER KARTOU', 'VKLAD', 'PREVOD Z UCTU', 'VYBER', 'PREVOD NA UCET', '',' ')),
CONSTRAINT pk_t PRIMARY KEY (trans_id),
CONSTRAINT fk_ta1 FOREIGN KEY (account_id) REFERENCES account(account_id),
);

CREATE TABLE loan(
loan_id INT,
account_id INT,
date_of_creation DATE,
amount INT,
duration INT,
payment FLOAT,
l_status VARCHAR(4),
CONSTRAINT ch_status check ( l_status in ('A', 'B', 'C', 'D')),
CONSTRAINT pk_l PRIMARY KEY (loan_id),
CONSTRAINT fk_la FOREIGN KEY (account_id) REFERENCES account(account_id)
);


CREATE TABLE credit_card(
card_id INT,
disp_id INT,
type_of_card VARCHAR(12),
issued DATE,
CONSTRAINT pk_cc PRIMARY KEY (card_id),
CONSTRAINT fk_ccd FOREIGN KEY (disp_id) REFERENCES disposition(disp_id)
);

------------------Insert---------------------
BULK INSERT account
FROM 'C:\Users\ACER\Desktop\uni\DW\Insert_data\account.asc'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    FORMATFILE = 'C:\Users\ACER\Desktop\uni\DW\Insert_data\format_account.fmt'
)
UPDATE account
SET frequency = REPLACE(frequency, '"', '')

BULK INSERT credit_card
FROM 'C:\Users\ACER\Desktop\uni\DW\Insert_data\card.asc'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    FORMATFILE = 'C:\Users\ACER\Desktop\uni\DW\Insert_data\format_card.fmt'
)

BULK INSERT client
FROM 'C:\Users\ACER\Desktop\uni\DW\Insert_data\client.asc'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    FORMATFILE = 'C:\Users\ACER\Desktop\uni\DW\Insert_data\format_client.fmt'
)

BULK INSERT disposition
FROM 'C:\Users\ACER\Desktop\uni\DW\Insert_data\disp.asc'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    FORMATFILE = 'C:\Users\ACER\Desktop\uni\DW\Insert_data\format_disp.fmt'
)

BULK INSERT loan
FROM 'C:\Users\ACER\Desktop\uni\DW\Insert_data\loan.asc'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    FORMATFILE = 'C:\Users\ACER\Desktop\uni\DW\Insert_data\format_loan.fmt'
)
UPDATE loan
SET l_status = REPLACE(l_status, '"', '')


BULK INSERT permanent_order
FROM 'C:\Users\ACER\Desktop\uni\DW\Insert_data\order.asc'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    FORMATFILE = 'C:\Users\ACER\Desktop\uni\DW\Insert_data\format_order.fmt'
);
UPDATE permanent_order
SET account_to = CONVERT(INT, SUBSTRING(account_to, 2, LEN(account_to) - 2));
UPDATE permanent_order
SET K_symbol = REPLACE(K_symbol, '"', '')
ALTER TABLE permanent_order
ALTER COLUMN account_to INT


BULK INSERT transactions
FROM 'C:\Users\ACER\Desktop\uni\DW\Insert_data\trans.asc'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    FORMATFILE = 'C:\Users\ACER\Desktop\uni\DW\Insert_data\format_trans.fmt'
)
UPDATE transactions
SET account = CONVERT(INT, SUBSTRING(account, 2, LEN(account) - 2));
UPDATE transactions
SET K_symbol = REPLACE(K_symbol, '"', '')
UPDATE transactions
SET type_of_trans = REPLACE(type_of_trans, '"', '')
UPDATE transactions
SET operation_mode_t = REPLACE(operation_mode_t, '"', '')
ALTER TABLE transactions
ALTER COLUMN account INT


BULK INSERT demographic_data
FROM 'C:\Users\ACER\Desktop\uni\DW\Insert_data\district.asc'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    FORMATFILE = 'C:\Users\ACER\Desktop\uni\DW\Insert_data\format_district.fmt',
	ERRORFILE = 'C:\Users\ACER\Desktop\uni\DW\Insert_data\Error.txt',
	MAXERRORS = 4
)