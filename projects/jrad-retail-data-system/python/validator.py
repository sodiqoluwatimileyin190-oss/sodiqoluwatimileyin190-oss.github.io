import pandas as pd


# =========================================================
# CHECK DUPLICATES
# =========================================================

def check_duplicates(dataset, columns):
    """
    Checks duplicate records based on
    one or more business key columns.
    """

    duplicates = dataset.duplicated(
        subset=columns,
        keep=False
    )

    duplicate_rows = dataset[duplicates]

    return duplicate_rows


# =========================================================
# CHECK MISSING VALUES
# =========================================================

def check_missing_values(dataset, columns):
    """
    Checks missing values in selected columns.
    """

    report = {}

    for column in columns:

        report[column] = dataset[column].isna().sum()

    return report


# =========================================================
# CHECK UNIQUE IDS
# =========================================================

def check_unique_ids(dataset, id_column):
    """
    Validates the integrity of an ID column.
    """

    total_records = len(dataset)

    missing_ids = dataset[id_column].isna().sum()

    duplicate_ids = dataset[id_column].duplicated().sum()

    unique_ids = dataset[id_column].nunique()

    return {
        "Total Records": total_records,
        "Unique IDs": unique_ids,
        "Duplicate IDs": duplicate_ids,
        "Missing IDs": missing_ids
    }

# =========================================================
# AUDIT DUPLICATE IDS
# =========================================================

def audit_duplicate_ids(dataset, id_column):
    """
    Returns duplicated IDs and
    their occurrence count.
    """

    duplicate_report = (
        dataset[id_column]
        .value_counts()
        .loc[lambda x: x > 1]
        .reset_index()
    )

    duplicate_report.columns = [
        id_column,
        "Occurrences"
    ]

    return duplicate_report

# =========================================================
# CHECK NUMERIC COLUMNS
# =========================================================

def check_numeric_columns(dataset, columns):
    """
    Validates numeric business columns.
    """

    report = {}

    for column in columns:

        report[column] = {
            "Missing": dataset[column].isna().sum(),
            "Negative": (dataset[column] < 0).sum(),
            "Zero": (dataset[column] == 0).sum()
        }

    return report


# =========================================================
# VALIDATION PIPELINE
# =========================================================

def validate_dataset(
    dataset,
    duplicate_columns,
    id_column,
    required_columns,
    numeric_columns
):
    print("\n========== DEBUG ==========")
    print("Dataset Type:", type(dataset))
    print("\nColumns:")
    print(dataset.columns.tolist())
    print("\nDuplicate Columns:")
    print(duplicate_columns)
    print("===========================\n")

    report = {

        "Duplicate Records": check_duplicates(
            dataset,
            duplicate_columns
        ),

        "Missing Values": check_missing_values(
            dataset,
            required_columns
        ),

        "Unique IDs": check_unique_ids(
            dataset,
            id_column
        ),

        "Numeric Validation": check_numeric_columns(
            dataset,
            numeric_columns
        )
    }

    return report


# =========================================================
# PRINT VALIDATION SUMMARY
# =========================================================

def print_validation_summary(report):
    """
    Prints a validation summary.
    """

    print("\n")
    print("=" * 70)
    print("VALIDATION SUMMARY")
    print("=" * 70)

    for section, results in report.items():

        print(f"\n{section}")

        if isinstance(results, pd.DataFrame):

            print(f"Records Found: {len(results)}")

        elif isinstance(results, dict):

            for key, value in results.items():

                if isinstance(value, dict):

                    print(f"\n{key}")

                    for metric, metric_value in value.items():
                        print(f"    {metric}: {metric_value}")

                else:

                    print(f"{key}: {value}")

        else:

            print(results)