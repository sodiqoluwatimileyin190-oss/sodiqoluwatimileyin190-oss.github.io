from config import DEPARTMENT_MAPPING
# =========================================================
# STANDARDIZE TEXT
# =========================================================

def standardize_text(dataset):
    """
    Cleans all text columns in the dataset.
    """

    text_columns = dataset.select_dtypes(
    include=["object", "string"]
).columns

    for column in text_columns:

        dataset[column] = (
            dataset[column]
            .str.strip()
            .str.replace(r"\s+", " ", regex=True)
            .str.title()
        )

    return dataset

import pandas as pd

# =========================================================
# STANDARDIZE DEPARTMENTS
# =========================================================

def standardize_departments(dataset):
    """
    Standardizes department names using the
    JRAD department mapping.
    """

    if "Department" in dataset.columns:

        dataset["Department"] = (
            dataset["Department"]
            .replace(DEPARTMENT_MAPPING)
        )

    return dataset


# =========================================================
# STANDARDIZE DATASET
# =========================================================

def standardize_dataset(dataset):
    """
    Runs the complete JRAD standardization pipeline.
    """

    dataset = standardize_column_names(dataset)
    dataset = standardize_text(dataset)
    dataset = standardize_departments(dataset)

    return dataset

# =========================================================
# PROFILE COLUMN
# =========================================================

def profile_column(dataset, column_name):
    """
    Displays all unique values in a column.
    """

    if column_name not in dataset.columns:
        print(f"\n{column_name} does not exist.")
        return

    print("\n" + "=" * 60)
    print(column_name.upper())
    print("=" * 60)

    values = sorted(dataset[column_name].dropna().unique())

    print(f"Unique Values: {len(values)}\n")

    for value in values:
        print(f"- {value}")

# =========================================================
# PROFILE DATASET
# =========================================================

def profile_dataset(dataset, dataset_name):

    print("\n" + "#" * 70)
    print(dataset_name.upper())
    print("#" * 70)

    profile_column(dataset, "Department")
    profile_column(dataset, "Category")
    profile_column(dataset, "Package_Type")
    profile_column(dataset, "Unit_of_Measure")
    profile_column(dataset, "VAT_Status")
    profile_column(dataset, "Storage_Type")

# =========================================================
# COMPARE SCHEMAS
# =========================================================

def compare_schemas(datasets):
    """
    Creates a schema comparison table showing
    which datasets contain each column.
    """

    all_columns = set()

    for dataset in datasets.values():
        all_columns.update(dataset.columns)

    all_columns = sorted(all_columns)

    comparison = pd.DataFrame(index=all_columns)

    for dataset_name, dataset in datasets.items():

        comparison[dataset_name] = [
            "✓" if column in dataset.columns else ""
            for column in all_columns
        ]

    comparison.index.name = "Column"

    return comparison
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
# STANDARDIZE COLUMN NAMES
# =========================================================

def standardize_column_names(dataset):
    """
    Standardizes column names.
    """

    dataset.columns = (
        dataset.columns
        .str.strip()
        .str.replace(" ", "_")
        .str.replace("-", "_")
    )

    return dataset

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

if __name__ == "__main__":

    datasets = {}

    for dataset_name, file_path in product_sources.items():

        dataset = load_dataset(file_path)

        dataset = standardize_dataset(dataset)

        datasets[dataset_name] = dataset

        profile_dataset(
            dataset,
            dataset_name
        )

    schema = compare_schemas(datasets)

    print("\n")
    print("=" * 70)
    print("SCHEMA COMPARISON")
    print("=" * 70)

    print(schema)
