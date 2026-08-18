"""
JRAD Retail Analytics Platform
Customer Generator
Version: 1.0
"""
from customer_attributes import (
    generate_registration_status,
    generate_loyalty_member,
    generate_registration_date,
    generate_acquisition_source,
    generate_registration_channel,
    generate_marketing_opt_in
)
from utils import weighted_choice
from utils import generate_email
from utils import generate_phone_number
from utils import random_number
from utils import pick_random_name
from config import BRANCH_IDS
from identity_loader import get_available_ethnicities

def generate_customer_id(branch_name, customer_number):
    """
    Purpose:
        Creates a unique Customer ID.

    Inputs:
        branch_name (str)
        customer_number (int)

    Returns:
        Customer ID (str)
    """

    branch_code = BRANCH_IDS[branch_name]

    customer_id = f"CUS-{branch_code}-{customer_number:06d}"

    return customer_id

def generate_name(identity_library, ethnicity, gender):
    """
    Purpose:
        Generates a customer's first name,
        last name and full name.

    Inputs:
        identity_library
        ethnicity
        gender

    Returns:
        Dictionary containing the customer's name.
    """

    first_name_sheet = f"{ethnicity}_{gender}_First_Names"
    surname_sheet = f"{ethnicity}_Surnames"

    first_name = pick_random_name(
        identity_library[first_name_sheet]
    )

    last_name = pick_random_name(
        identity_library[surname_sheet]
    )

    return {
        "Ethnicity": ethnicity,
        "Gender": gender,
        "First_Name": first_name,
        "Last_Name": last_name,
        "Full_Name": f"{first_name} {last_name}"
    }

    """
    =====================================================
    Purpose:
        Generates a customer's age.

    Inputs:
        distribution_library
        branch_name

    Returns:
        int
            Customer age.
    =====================================================
    """

    branch_profile = distribution_library["Branch_Profile"]

    branch = branch_profile[
        branch_profile["Branch_Name"] == branch_name
    ].iloc[0]

    minimum_age = int(branch["Minimum_Age"])
    maximum_age = int(branch["Maximum_Age"])

    age = random_number(minimum_age, maximum_age)

    return age
def generate_age(distribution_library, branch_name):
    """
    =========================================================
    Purpose:
        Generates a customer's age using the
        JRAD Distribution Library.

    Inputs:
        distribution_library
            Loaded Distribution Library workbook.

        branch_name (str)
            Branch where the customer belongs.

    Returns:
        int
            Customer age.

    Business Rules:
        • Reads the branch age limits from the
          Distribution Library.
        • Never hardcodes age values.
        • Generates an age within the approved range.
    =========================================================
    """

    branch_profile = distribution_library["Branch_Profile"]

    branch = branch_profile[
        branch_profile["Branch_Name"] == branch_name
    ].iloc[0]

    minimum_age = int(branch["Minimum_Age"])
    maximum_age = int(branch["Maximum_Age"])

    return random_number(minimum_age, maximum_age)

def choose_gender(distribution_library, branch_name):
    """
    Selects gender using the Distribution Library.
    """

    gender_table = distribution_library["Gender_Distribution"]

    gender_table = gender_table[
        gender_table["Branch_Name"] == branch_name
    ]

    return weighted_choice(
        gender_table,
        "Gender",
        "Percentage"
    )

def choose_ethnicity(
    identity_library,
    distribution_library,
    branch_name
):
    """
    Selects an ethnicity using the Distribution Library,
    but only from ethnicities available in the
    Identity Library.
    """

    ethnicity_table = distribution_library["Ethnicity_Distribution"]

    ethnicity_table = ethnicity_table[
        ethnicity_table["Branch_Name"] == branch_name
    ]

    available = get_available_ethnicities(identity_library)

    ethnicity_table = ethnicity_table[
        ethnicity_table["Ethnicity"].isin(available)
    ]

    return weighted_choice(
        ethnicity_table,
        "Ethnicity",
        "Percentage"
    )

def generate_customer(
    identity_library,
    distribution_library,
    branch_name,
    customer_number
):
    """
    Creates one complete customer record.
    """

    ethnicity = choose_ethnicity(
        identity_library,
        distribution_library,
        branch_name
    )

    gender = choose_gender(
        distribution_library,
        branch_name
    )

    customer = generate_name(
        identity_library,
        ethnicity,
        gender
    )

    customer["Customer_ID"] = generate_customer_id(
        branch_name,
        customer_number
    )

    customer["Age"] = generate_age(
        distribution_library,
        branch_name
    )

    customer["Phone_Number"] = generate_phone_number()

    customer["Email"] = generate_email(
        customer["First_Name"],
        customer["Last_Name"]
    )

    customer["Branch"] = branch_name

        # -------------------------------
    # Customer Attributes
    # -------------------------------

    registration_status = generate_registration_status()

    loyalty_member = generate_loyalty_member()

    registration_date = generate_registration_date(
        distribution_library
    )

    acquisition_source = generate_acquisition_source(
        distribution_library,
        branch_name
    )
    registration_channel = generate_registration_channel(
    distribution_library,
    branch_name
)

    marketing_opt_in = generate_marketing_opt_in(
    distribution_library,
    branch_name
)
    customer["Registration_Status"] = registration_status
    customer["Loyalty_Member"] = loyalty_member
    customer["Registration_Date"] = registration_date
    customer["Acquisition_Source"] = acquisition_source
    customer["Registration_Channel"] = registration_channel
    customer["Marketing_Opt_In"] = marketing_opt_in
    return customer