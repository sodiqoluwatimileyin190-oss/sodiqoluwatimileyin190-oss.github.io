"""
=========================================================
JRAD Retail Analytics Platform
Module: Utility Functions
File: utils.py
Version: 1.0

Purpose:
    Contains reusable helper functions used throughout
    the JRAD Production Data Generation Engine.
=========================================================
"""

import random
# ==========================================
# JRAD Unique Value Registry
# ==========================================

used_phone_numbers = set()
used_emails = set()

def pick_random_name(sheet):
    """
    Purpose:
        Randomly selects one name from a worksheet.

    Input:
        sheet (DataFrame)

    Returns:
        str
            A randomly selected name.
    """

    random_row = sheet.sample(n=1)

    return random_row.iloc[0]["Name"]
def random_number(minimum, maximum):
    """
    Returns a random integer within a range.
    """

    import random

    return random.randint(minimum, maximum)
def random_number(minimum, maximum):
    """
    =========================================================
    Purpose:
        Generates a random integer within a specified range.

    Inputs:
        minimum (int)
            Lowest possible value.

        maximum (int)
            Highest possible value.

    Returns:
        int
            Random integer between minimum and maximum.

    Example:
        random_number(22, 36)

        Returns:
        29
    =========================================================
    """

    return random.randint(minimum, maximum)

import random

def generate_phone_number():
    """
    =====================================================
    Purpose:
        Generates a realistic Nigerian phone number.

    Returns:
        str
            11-digit Nigerian phone number.
    =====================================================
    """

    prefixes = [
        "070",
        "080",
        "081",
        "090",
        "091"
    ]

    prefix = random.choice(prefixes)

    remaining_digits = random.randint(10000000, 99999999)

    return f"{prefix}{remaining_digits}"

def generate_email(first_name, last_name):
    """
    =====================================================
    Purpose:
        Generates a realistic email address.

    Returns:
        str
            Customer email.
    =====================================================
    """

    import random

    providers = [
        "gmail.com",
        "yahoo.com",
        "hotmail.com"
    ]

    provider = random.choice(providers)

    number = random.randint(1, 99)

    email = (
        f"{first_name[0].lower()}."
        f"{last_name.lower()}"
        f"{number}"
        f"@{provider}"
    )

    return email

def weighted_choice(dataframe, value_column, weight_column):
    """
    =====================================================
    Purpose:
        Selects a random value based on weighted percentages.

    Inputs:
        dataframe
            DataFrame containing values and percentages.

        value_column
            Column containing the values to return.

        weight_column
            Column containing the percentages.

    Returns:
        Selected value.
    =====================================================
    """

    import random

    values = dataframe[value_column].tolist()
    weights = dataframe[weight_column].tolist()

    return random.choices(values, weights=weights, k=1)[0]

def choose_branch_distribution(
    distribution_library,
    worksheet_name,
    branch_name,
    output_values
):
    """
    Returns a weighted value from a branch-specific
    distribution worksheet.
    """

    distribution = distribution_library[
        worksheet_name
    ]

    branch_row = distribution[
        distribution["Branch"] == branch_name
    ].iloc[0]

    weights = [
        branch_row[value]
        for value in output_values
    ]

    return random.choices(
        population=output_values,
        weights=weights,
        k=1
    )[0]