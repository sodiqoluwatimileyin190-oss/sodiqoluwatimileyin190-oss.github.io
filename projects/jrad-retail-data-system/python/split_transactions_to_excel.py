from pathlib import Path
import pandas as pd


def split_transactions_to_excel():
    root = Path(__file__).resolve().parent
    output_dir = root.parent / "Output"

    input_csv = output_dir / "JRAD_Transactions.csv"
    output_xlsx = output_dir / "JRAD_Transactions_split.xlsx"

    if not input_csv.exists():
        raise FileNotFoundError(f"Input CSV not found: {input_csv}")

    sheet1_limit = 1_000_000
    sheet2_limit = 1_048_575  # Excel max data rows per sheet (header uses one row)

    rows_written = {"Transaction 1": 0, "Transaction 2": 0}
    sheet_order = ["Transaction 1", "Transaction 2"]
    sheet_caps = {"Transaction 1": sheet1_limit, "Transaction 2": sheet2_limit}
    sheet_index = 0

    with pd.ExcelWriter(output_xlsx, engine="openpyxl") as writer:
        for chunk in pd.read_csv(input_csv, chunksize=200_000):
            start = 0
            while start < len(chunk):
                if sheet_index >= len(sheet_order):
                    raise ValueError(
                        "JRAD_Transactions.csv has more rows than two Excel sheets can hold."
                    )

                sheet_name = sheet_order[sheet_index]
                used_rows = rows_written[sheet_name]
                remaining = sheet_caps[sheet_name] - used_rows

                if remaining <= 0:
                    sheet_index += 1
                    continue

                part = chunk.iloc[start:start + remaining]
                part.to_excel(
                    writer,
                    sheet_name=sheet_name,
                    index=False,
                    header=(used_rows == 0),
                    startrow=(0 if used_rows == 0 else used_rows + 1),
                )

                rows_written[sheet_name] += len(part)
                start += len(part)

    print(f"Created: {output_xlsx}")
    print(f"Transaction 1 rows: {rows_written['Transaction 1']:,}")
    print(f"Transaction 2 rows: {rows_written['Transaction 2']:,}")


if __name__ == "__main__":
    split_transactions_to_excel()
