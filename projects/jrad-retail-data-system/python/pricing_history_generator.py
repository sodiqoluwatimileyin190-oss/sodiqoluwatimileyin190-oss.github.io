# ============================================================
# IMPORTS
# ============================================================

import random
from datetime import datetime, timedelta

import numpy as np
import pandas as pd

# ============================================================
# CONFIGURATION
# ============================================================

# Reproducible Results
random.seed(42)
np.random.seed(42)

# Input File
PRODUCT_FILE = "../Output/JRAD_Product_Master_Final_Corrected.xlsx"

# Output File
OUTPUT_FILE = "../Output/JRAD_Pricing_History_2026.xlsx"

# ============================================================
# BUSINESS RULES
# ============================================================

# Number of price changes per product
PRICE_CHANGE_FREQUENCY = {

    "High": (6, 10),

    "Medium": (4, 6),

    "Low": (2, 4)

}

# Price Change Reasons
PRICE_CHANGE_REASONS = [

    "Inflation",

    "Supplier Cost Increase",

    "Promotion",

    "Seasonal Demand",

    "Clearance"

]

# Price Change Percentage Ranges
PRICE_CHANGE_RULES = {

    "Inflation": (0.03, 0.08),

    "Supplier Cost Increase": (0.05, 0.12),

    "Promotion": (-0.15, -0.05),

    "Seasonal Demand": (0.04, 0.10),

    "Clearance": (-0.25, -0.10)

}

START_DATE = datetime(2026, 1, 1)

END_DATE = datetime(2026, 12, 31)

# ============================================================
# LOAD DATA
# ============================================================

def load_product_master():

    """
    Load the Product Master dataset.
    """

    print("Loading Product Master...")

    products = pd.read_excel(PRODUCT_FILE)

    print(f"✓ {len(products)} products loaded")

    return products

# ============================================================
# HELPER FUNCTIONS
# ============================================================

def generate_pricing_id(counter):

    """
    Generate unique Pricing IDs.

    Example:
    PRC000001
    PRC000002
    """

    return f"PRC{counter:06d}"

def generate_change_dates(num_changes):

    """
    Generate unique pricing dates
    throughout 2026.

    The first date is always
    January 1, 2026.
    """

    dates = set()

    while len(dates) < num_changes:

        random_days = random.randint(1, 364)

        dates.add(
            START_DATE + timedelta(days=random_days)
        )

    return sorted(dates)

def generate_change_reason():

    """
    Randomly select a reason
    for the price change.
    """

    return random.choice(PRICE_CHANGE_REASONS)

def generate_new_price(

    current_price,

    cost_price,

    change_reason

):

    """
    Generate a new selling price
    based on the change reason.
    """

    minimum_change, maximum_change = PRICE_CHANGE_RULES[
        change_reason
    ]

    change_percent = random.uniform(
        minimum_change,
        maximum_change
    )

    new_price = current_price * (1 + change_percent)

    # Never sell below cost
    minimum_price = cost_price * 1.10

    if new_price < minimum_price:

        new_price = minimum_price

    return round(new_price, 2), round(change_percent * 100, 2)

def calculate_price_change(

    previous_price,

    new_price

):

    """
    Calculate the absolute
    price difference.
    """

    return round(

        new_price - previous_price,

        2

    )

# ============================================================
# BUILD PRICING HISTORY
# ============================================================

def build_pricing_history():

    print("=" * 60)
    print("JRAD PRICING HISTORY GENERATOR")
    print("=" * 60)

    # --------------------------------------------------------
    # LOAD DATA
    # --------------------------------------------------------

    products = load_product_master()

    pricing_records = []

    pricing_counter = 1

    print("\nGenerating Pricing History...")


    # --------------------------------------------------------
    # LOOP THROUGH PRODUCTS
    # --------------------------------------------------------

    for _, product in products.iterrows():

        product_id = product["Product_ID"]

        base_price = product["Base_Price_Jan"]

        cost_price = product["Cost_Price_Jan"]

        sensitivity = product["Inflation_Sensitivity"]

        minimum_changes, maximum_changes = \
            PRICE_CHANGE_FREQUENCY.get(

                sensitivity,

                (3, 5)

            )

        number_of_changes = random.randint(

            minimum_changes,

            maximum_changes

        )

        # Generate remaining price-change dates
        change_dates = generate_change_dates(

        number_of_changes - 1

        )

        current_price = base_price

# ----------------------------------------------------
# INITIAL PRICE RECORD
# ----------------------------------------------------

        pricing_records.append({

    "Pricing_ID":
        generate_pricing_id(pricing_counter),

    "Product_ID":
        product_id,

    "Effective_Date":
        START_DATE,

    "Previous_Price":
        round(base_price, 2),

    "New_Price":
        round(base_price, 2),

    "Price_Change":
        0,

    "Change_Percent":
        0,

    "Change_Reason":
        "Initial Price"

})

        pricing_counter += 1

# ----------------------------------------------------
# REMAINING PRICE CHANGES
# ----------------------------------------------------

        for effective_date in change_dates:

            previous_price = current_price

            change_reason = generate_change_reason()

            (
                new_price,
                change_percent
            ) = generate_new_price(

                current_price,

                cost_price,

                change_reason

            )

            price_change = calculate_price_change(

                previous_price,

                new_price

            )

            current_price = new_price

            pricing_records.append({

                "Pricing_ID":
                    generate_pricing_id(pricing_counter),

                "Product_ID":
                    product_id,

                "Effective_Date":
                    effective_date,

                "Previous_Price":
                    round(previous_price, 2),

                "New_Price":
                    round(new_price, 2),

                "Price_Change":
                    round(price_change, 2),

                "Change_Percent":
                    round(change_percent, 2),

                "Change_Reason":
                    change_reason

            })

            pricing_counter += 1

    pricing_history = pd.DataFrame(

        pricing_records

    )

    print(

        f"✓ {len(pricing_history):,} pricing records created."

    )

    return pricing_history

# ============================================================
# VALIDATE PRICING HISTORY
# ============================================================

def validate_pricing_history(pricing_history):

    print("\nRunning Validation...")

    # Unique Pricing IDs
    assert pricing_history["Pricing_ID"].is_unique, \
        "Duplicate Pricing IDs found."

    # Missing Product IDs
    assert pricing_history["Product_ID"].notna().all(), \
        "Missing Product IDs."

    # Missing Effective Dates
    assert pricing_history["Effective_Date"].notna().all(), \
        "Missing Effective Dates."

    # Missing Prices
    assert pricing_history["New_Price"].notna().all(), \
        "Missing New Prices."

    # No Negative Prices
    assert (pricing_history["New_Price"] > 0).all(), \
        "Negative or zero prices found."

    print("✓ Validation Passed")

# ============================================================
# EXPORT PRICING HISTORY
# ============================================================

def export_pricing_history(pricing_history):

    pricing_history.to_excel(

        OUTPUT_FILE,

        index=False

    )

    print(f"\nPricing History exported to:\n{OUTPUT_FILE}")

# ============================================================
# SUMMARY REPORT
# ============================================================

def print_summary(pricing_history):

    print("\n" + "=" * 60)

    print("JRAD PRICING HISTORY SUMMARY")

    print("=" * 60)

    print(f"Products              : {pricing_history['Product_ID'].nunique()}")

    print(f"Pricing Records       : {len(pricing_history):,}")

    print("\nPrice Change Reasons")

    print("-" * 35)

    print(

        pricing_history["Change_Reason"]

        .value_counts()

    )

    print("\nDate Range")

    print("-" * 35)

    print(

        pricing_history["Effective_Date"].min(),

        "to",

        pricing_history["Effective_Date"].max()

    )


# ============================================================
# MAIN PROGRAM
# ============================================================

if __name__ == "__main__":

    pricing_history = build_pricing_history()

    validate_pricing_history(pricing_history)

    export_pricing_history(pricing_history)

    print_summary(pricing_history)

    print("\nPricing History Shape:")

    print(pricing_history.shape)

    print("\nPreview:")

    print(pricing_history.head())