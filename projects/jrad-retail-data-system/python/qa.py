"""
=========================================================
JRAD Retail Analytics Platform
Module: Quality Assurance (QA)
File: qa.py
Version: 1.0

Purpose:
    Performs validation checks on generated customer data.
=========================================================
"""


def check_duplicate_customer_ids(customers):
    """
    Checks for duplicate Customer IDs.
    """

    ids = [customer["Customer_ID"] for customer in customers]

    return len(ids) == len(set(ids))


def check_duplicate_phones(customers):
    """
    Checks for duplicate phone numbers.
    """

    phones = [customer["Phone_Number"] for customer in customers]

    return len(phones) == len(set(phones))


def check_duplicate_emails(customers):
    """
    Checks for duplicate emails.
    """

    emails = [customer["Email"] for customer in customers]

    return len(emails) == len(set(emails))
def check_age_range(customers, minimum_age, maximum_age):
    """
    Ensures all customer ages fall within
    the approved range.
    """

    for customer in customers:

        if not (
            minimum_age
            <= customer["Age"]
            <= maximum_age
        ):

            return False

    return True
def run_qa(customers):
    """
    Runs all QA checks.
    """

    print("\n==============================")
    print(" JRAD QA REPORT")
    print("==============================\n")

    print(
        "Customer IDs:",
        "PASS"
        if check_duplicate_customer_ids(customers)
        else "FAIL"
    )

    print(
        "Phone Numbers:",
        "PASS"
        if check_duplicate_phones(customers)
        else "FAIL"
    )

    print(
        "Emails:",
        "PASS"
        if check_duplicate_emails(customers)
        else "FAIL"
    )

    print(
        "Age Validation:",
        "PASS"
        if check_age_range(customers, 22, 36)
        else "FAIL"
    )