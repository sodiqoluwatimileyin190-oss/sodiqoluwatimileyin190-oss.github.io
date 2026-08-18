import pandas as pd

from pathlib import Path

from product_standardizer import (
    load_dataset,
    standardize_dataset
)

from validator import (
    validate_dataset,
    print_validation_summary,
    audit_duplicate_ids
)

# =========================================================
# APPEND PRODUCT MASTER
# =========================================================

def append_product_master(master, batch):
    """
    Appends new product records to the
    Product Master.
    """

    merged = pd.concat(
        [master, batch],
        ignore_index=True
    )

    return merged

# =========================================================
# REMOVE DUPLICATE PRODUCTS
# =========================================================

def remove_duplicate_products(dataset):
    """
    Removes duplicate products using
    Product_Name and Pack_Size.
    """

    before = len(dataset)

    dataset = dataset.drop_duplicates(
        subset=["Product_Name", "Pack_Size"],
        keep="first"
    )

    after = len(dataset)

    print("\nDuplicate Removal Summary")
    print("-" * 30)
    print(f"Products Before     : {before}")
    print(f"Products After      : {after}")
    print(f"Duplicates Removed  : {before - after}")

    return dataset

# =========================================================
# MERGE ENRICHMENT DATASET
# =========================================================

def merge_enrichment(product_master, enrichment):
    """
    Merges enrichment attributes into the
    consolidated Product Master.
    """

    enrichment = enrichment[
        [
            "Product_ID",
            "Cost_Price_Jan",
            "Popularity_Tier",
            "Purchase_Trigger",
            "Inflation_Sensitivity"
        ]
    ]

    merged = product_master.merge(
        enrichment,
        on="Product_ID",
        how="left"
    )

    return merged

# =========================================================
# EXPORT PRODUCT MASTER
# =========================================================

def export_product_master(dataset):
    """
    Exports the final Product Master
    to an Excel workbook.
    """

    output_dir = Path("../Output")
    output_dir.mkdir(exist_ok=True)

    output_file = output_dir / "JRAD_Product_Master_Final.xlsx"

    dataset.to_excel(
        output_file,
        index=False
    )

    print("\nProduct Master exported successfully.")
    print(f"Location: {output_file}")
    
# =========================================================
# BUILD PRODUCT MASTER PIPELINE
# =========================================================

def build_product_master():
    """
    Executes the complete Product Master ETL pipeline.
    """

    # Load datasets
    master = load_dataset(
        "../Datasets/JRAD_Product_Master_v1.xlsx"
    )

    beverage_batch = load_dataset(
        "../Datasets/JRAD_Product_Master_Batch_01_Beverages_v2.xlsx"
    )

    enrichment = load_dataset(
        "../Datasets/Product_Master_Enriched_513.xlsx"
    )

    # Standardize datasets
    master = standardize_dataset(master)
    beverage_batch = standardize_dataset(beverage_batch)
    enrichment = standardize_dataset(enrichment)

    # Append Product Masters
    merged = append_product_master(
        master,
        beverage_batch
    )

    # Remove duplicate products
    merged = remove_duplicate_products(merged)

    # Merge enrichment attributes
    merged = merge_enrichment(
    merged,
    enrichment
)

    # =========================================================
# VALIDATE PRODUCT MASTER
# =========================================================

    print("\nMerged Dataset Columns:")
    print(merged.columns.tolist())

    validation_report = validate_dataset(
    dataset=merged,
    duplicate_columns=[
        "Product_Name",
        "Pack_Size"
    ],
    id_column="Product_ID",
    required_columns=[
        "Product_ID",
        "Product_Name",
        "Department",
        "Category",
        "Brand",
        "Base_Price_Jan"
    ],
    numeric_columns=[
        "Base_Price_Jan",
        "Cost_Price_Jan"
    ]
)

    print_validation_summary(validation_report)
    duplicate_ids = audit_duplicate_ids(
    merged,
    "Product_ID"
)

    print("\n")
    print("=" * 70)
    print("DUPLICATE PRODUCT IDs")
    print("=" * 70)

    print(duplicate_ids.head(25))

# =========================================================
# EXPORT PRODUCT MASTER
# =========================================================

    export_product_master(merged)

    return merged


# =========================================================
# MAIN PROGRAM
# =========================================================

if __name__ == "__main__":

    product_master = build_product_master()

    print("\nFinal Product Master Shape:")
    print(product_master.shape)