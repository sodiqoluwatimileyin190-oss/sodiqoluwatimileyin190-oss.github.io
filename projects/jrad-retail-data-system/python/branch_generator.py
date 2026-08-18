"""
JRAD Retail Analytics Platform
Branch Generator
Version: 1.0
"""

from customer_generator import generate_customer


def generate_branch_customers(
    identity_library,
    distribution_library,
    branch_name,
    total_customers,
    starting_customer_number=1
):
    """
    =====================================================
    Purpose:
        Generates all customers for a branch.

    Returns:
        list
            List of customer dictionaries.
    =====================================================
    """

    customers = []

   
    for customer_number in range(
        starting_customer_number,
        starting_customer_number + total_customers
    ):

        customer = generate_customer(
            identity_library,
            distribution_library,
            branch_name,
            customer_number
        )

        customers.append(customer)

    return customers