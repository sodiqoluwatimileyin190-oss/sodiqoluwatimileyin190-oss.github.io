"""
customer_attributes.py

JRAD Retail Analytics Platform
Sprint 12 – Customer Master Enrichment

This module generates customer attributes based on approved
JRAD business rules.
"""
from utils import choose_branch_distribution
import random
from datetime import datetime, timedelta


# ---------------------------------------------------------
# Registration Status
# ---------------------------------------------------------


def generate_registration_status():
    """
    Every record in the Customer Master represents a
    registered customer.
    """

    return "Registered"


# ---------------------------------------------------------
# Loyalty Membership
# ---------------------------------------------------------

def generate_loyalty_member():
    """
    Every customer in the Customer Master belongs
    to the loyalty programme.
    """

    return "Yes"


# ---------------------------------------------------------
# Registration Date
# ---------------------------------------------------------

import random
import calendar
from datetime import datetime


def generate_registration_date(distribution_library):
    """
    Generates a registration date based on the
    Registration_Growth_Distribution worksheet.

    Business Rule:
    - Customer registrations increase gradually
      throughout 2026.
    """

    registration_df = distribution_library[
       "Registration_Distribution"
    ]

    months = registration_df["Month"].tolist()

    weights = registration_df["Weight"].tolist()

    selected_month = random.choices(
        population=months,
        weights=weights,
        k=1
    )[0]

    month_number = datetime.strptime(
        selected_month,
        "%B"
    ).month

    last_day = calendar.monthrange(
        2026,
        month_number
    )[1]

    random_day = random.randint(
        1,
        last_day
    )

    registration_date = datetime(
        2026,
        month_number,
        random_day
    )

    return registration_date.strftime("%Y-%m-%d")

import random


def generate_acquisition_source(
    distribution_library,
    branch_name
):
    """
    =====================================================
    Purpose:
        Generates a customer's acquisition source based
        on the branch-specific distribution.
    =====================================================
    """

    acquisition = choose_branch_distribution(
        distribution_library,
        "Acquisition_Source",
        branch_name,
        [
            "Walk_in",
            "Referral",
            "Social",
            "Banner",
            "Flyer",
            "Event"
        ]
    )

    if acquisition == "Walk_in":
        return "Walk-in"

    return acquisition

def generate_registration_channel(
    distribution_library,
    branch_name
):
    """
    Generates a customer's registration channel.
    """

    channel = choose_branch_distribution(
        distribution_library,
        "Registration_Channel",
        branch_name,
        [
            "Cashier",
            "Customer_Request",
            "Promotion"
        ]
    )

    if channel == "Customer_Request":
        return "Customer Request"

    return channel

def generate_marketing_opt_in(
    distribution_library,
    branch_name
):
    """
    Generates a customer's marketing preference
    based on the branch distribution.
    """

    return choose_branch_distribution(
        distribution_library,
        "Marketing_Opt_In",
        branch_name,
        [
            "Yes",
            "No"
        ]
    )