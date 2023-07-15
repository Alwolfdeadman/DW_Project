


--- Give me the number of unpayed loans --- 
SELECT COUNT (*)
FROM Dimentions.dbo.Loan_fact as LF, Dimentions.dbo.Loan_Dimention as LD
WHERE (LF.loan = LD.Loan_key and (LD.l_status LIKE 'B' or LD.l_status LIKE 'D'));



---Give me the number of tranactions to every bank---
SELECT BD.Bank_ident, COUNT(*) as count
FROM Dimentions.dbo.Transaction_fact as TF, Dimentions.dbo.Bank_Dimention as BD
WHERE BD.Bank_key = TF.bank_receiver
GROUP BY BD.Bank_ident;



---Give me the id of the account with the most loans---
SELECT TOP 1 account, COUNT(loan) as loan_count
FROM Dimentions.dbo.Loan_fact
GROUP BY account
ORDER BY loan_count DESC;