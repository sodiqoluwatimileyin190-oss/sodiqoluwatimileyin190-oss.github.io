import pandas as pd

path = r'../Output/JRAD_Business_Events_2026.xlsx'

for sheet in ['Business_Events', 'Branch_Behaviour', 'Monthly_Behaviour']:
    df = pd.read_excel(path, sheet_name=sheet)
    print('SHEET', sheet)
    print(df.head().to_string(index=False))
    print('Columns:', list(df.columns))
    print('Rows:', len(df))
    print('---')
