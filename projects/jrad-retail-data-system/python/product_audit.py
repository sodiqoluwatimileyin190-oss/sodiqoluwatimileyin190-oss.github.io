
import pandas as pd


# =========================================================
# LOAD DATASET
# =========================================================

def load_dataset(file_path):
    """
    Loads an Excel or CSV dataset.
    """

    if file_path.endswith(".csv"):
        return pd.read_csv(file_path)

    return pd.read_excel(file_path)


# =========================================================
# AUDIT DATASET
# =========================================================

def audit_dataset(dataset, dataset_name):
    """
    Displays a basic audit summary.
    """

    print("\n" + "=" * 60)
    print(dataset_name.upper())
    print("=" * 60)

    print(f"Rows: {dataset.shape[0]}")
    print(f"Columns: {dataset.shape[1]}")

    print("\nMissing Values:")
    print(dataset.isnull().sum())

    # =====================================================
    # DUPLICATE CHECK
    # =====================================================

    print("\nDuplicate Products:")

    if {"Product_Name", "Pack_Size"}.issubset(dataset.columns):

        duplicates = dataset.duplicated(
            subset=["Product_Name", "Pack_Size"]
        ).sum()

    elif "Product_Name" in dataset.columns:

        duplicates = dataset.duplicated(
            subset=["Product_Name"]
        ).sum()

    else:

        duplicates = "N/A"

    print(duplicates)

    # =====================================================
    # DEPARTMENT SUMMARY
    # =====================================================

    if "Department" in dataset.columns:

        print("\n" + "=" * 60)
        print("DEPARTMENT SUMMARY")
        print("=" * 60)

        print(dataset["Department"].value_counts())

    # =====================================================
    # CATEGORY SUMMARY
    # =====================================================

    if "Category" in dataset.columns:

        print("\n" + "=" * 60)
        print("CATEGORY SUMMARY")
        print("=" * 60)

        print(dataset["Category"].value_counts())

    # =====================================================
    # COLUMN NAMES
    # =====================================================

    print("\nColumn Names:")

    for column in dataset.columns:
        print(f"- {column}")

# =========================================================
# PRODUCT SOURCES
# =========================================================

product_sources = {
    "JRAD Product Master":
        "../Datasets/JRAD_Product_Master_v1.xlsx",

    "Beverages Batch":
        "../Datasets/JRAD_Product_Master_Batch_01_Beverages_v2.xlsx",

    "Enriched Products":
        "../Datasets/Product_Master_Enriched_513.xlsx",

    "Complete Catalogue":
        "../Datasets/Nigerian_SuperStore_Complete_2026_With_Prices.csv"
}
# =========================================================
# MAIN PROGRAM
# =========================================================

for dataset_name, file_path in product_sources.items():

    dataset = load_dataset(file_path)

    audit_dataset(
        dataset,
        dataset_name
    )