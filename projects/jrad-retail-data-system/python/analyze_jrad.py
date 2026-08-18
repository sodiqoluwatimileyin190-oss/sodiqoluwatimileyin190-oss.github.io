import pandas as pd

# Load key files
receipts = pd.read_csv('PROJECT JRAD/JRAD_Receipts.csv')
transactions = pd.read_csv('PROJECT JRAD/JRAD_Transactions.csv')
products = pd.read_csv('PROJECT JRAD/JRAD_Product_Master_2026.csv')

print('=== ENTITY COUNTS ===\n')
print(f'Number of Customers: {receipts["Customer_ID"].nunique():,}')
print(f'Number of Transactions (Receipts): {len(receipts):,}')
print(f'Number of Transaction Lines: {len(transactions):,}')
print(f'Number of Products/SKUs: {products["Product_ID"].nunique():,}')
print(f'Number of Tables/Files: 6')
print(f'Number of Branches: {receipts["Branch_Code"].nunique()}')
print(f'\n=== ADDITIONAL INSIGHTS ===')
print(f'Date Range: {receipts["Transaction_Date"].min()} to {receipts["Transaction_Date"].max()}')
print(f'Unique Product Categories: {products["Category"].nunique()}')
print(f'Unique Product Departments: {products["Department"].nunique()}')
print(f'Unique Brands: {products["Brand"].nunique()}')
print(f'Unique Payment Methods: {receipts["Payment_Method"].nunique()}')
print(f'Unique Customer Types: {receipts["Customer_Type"].nunique()}')
print(f'Unique Shopping Missions: {receipts["Shopping_Mission"].nunique()}')
