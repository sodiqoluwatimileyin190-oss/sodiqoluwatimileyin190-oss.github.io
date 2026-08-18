# ============================================================
# IMPORTS
# ============================================================

import argparse
import glob
import os
import random
import shutil
import tempfile
from datetime import datetime, timedelta

import numpy as np
import pandas as pd


# ============================================================
# CONFIGURATION
# ============================================================

random.seed(42)
np.random.seed(42)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

OUTPUT_DIR = os.path.abspath(os.path.join(BASE_DIR, "..", "Output"))


def resolve_data_path(filename):

    candidate_paths = [
        filename,
        os.path.join(BASE_DIR, filename),
        os.path.join(OUTPUT_DIR, filename),
        os.path.join(BASE_DIR, "Output", filename),
    ]

    for candidate in candidate_paths:

        if os.path.exists(candidate):

            return os.path.abspath(candidate)

    # Fallback: copy from the sibling Output folder if present
    for candidate in [
        os.path.join(OUTPUT_DIR, filename),
        os.path.join(BASE_DIR, "Output", filename),
        os.path.join(BASE_DIR, filename),
    ]:

        if os.path.exists(candidate):

            try:

                shutil.copy2(candidate, os.path.join(BASE_DIR, filename))

                return os.path.abspath(os.path.join(BASE_DIR, filename))

            except Exception:

                continue

    return os.path.abspath(candidate_paths[0])


PRODUCT_FILE = resolve_data_path("JRAD_Product_Master_Final_Corrected.xlsx")

CUSTOMER_FILE = resolve_data_path("Customer_Master_2026.xlsx")

PRICING_FILE = resolve_data_path("JRAD_Pricing_History_2026.xlsx")

INVENTORY_FILE = resolve_data_path("JRAD_Inventory_Master.xlsx")

OUTPUT_FILE = resolve_data_path("JRAD_Sales_Transactions_2026.csv")

BUSINESS_EVENTS_FILE = resolve_data_path("JRAD_Business_Events_2026.xlsx")
# ============================================================
# BUSINESS RULES
# ============================================================

STORE_OPEN_HOUR = 8

STORE_CLOSE_HOUR = 21

NUMBER_OF_BRANCHES = 5

PAYMENT_METHODS = {

    "Transfer": 0.60,

    "POS": 0.35,

    "Cash": 0.05

}

REGISTERED_CUSTOMER_RATIO = 0.25

WALK_IN_CUSTOMER_RATIO = 0.75

MIN_ITEMS_PER_BASKET = 1

MAX_ITEMS_PER_BASKET = 15

TARGET_TRANSACTION_LINES = 200000
DEFAULT_MAX_CUSTOMERS_PER_DAY = None
DEFAULT_BATCH_SIZE = 3000


def parse_args():

    parser = argparse.ArgumentParser(

        description="Generate JRAD sales transaction data"

    )

    parser.add_argument(

        "--days",

        type=int,

        default=None,

        help="Number of days to generate. Defaults to the full year."

    )

    parser.add_argument(

        "--target-lines",

        type=int,

        default=TARGET_TRANSACTION_LINES,

        help="Stop once this many transaction lines are generated."

    )

    parser.add_argument(

        "--max-customers-per-day",

        type=int,

        default=DEFAULT_MAX_CUSTOMERS_PER_DAY,

        help="Cap the number of customers generated per day. Leave unset to use the original full-volume behavior."

    )

    parser.add_argument(

        "--batch-size",

        type=int,

        default=DEFAULT_BATCH_SIZE,

        help="Number of receipts to buffer before flushing a batch to disk."

    )

    parser.add_argument(

        "--day-sample-rate",

        type=float,

        default=1.0,

        help="Fraction of calendar days to generate. Use 0.25 for a quarter-year sample."

    )

    args = parser.parse_args()

    if args.batch_size <= 0:

        parser.error("--batch-size must be greater than zero")

    if not 0 < args.day_sample_rate <= 1.0:

        parser.error("--day-sample-rate must be between 0 and 1")

    return args


# ============================================================
# CUSTOMER PERSONAS
# ============================================================

CUSTOMER_PERSONAS = {

    "Family Shopper": {

        "weight": 30,

        "basket_multiplier": 1.40,

        "preferred_hours": [9,10,11,12,16,17,18]

    },

    "Busy Professional": {

        "weight": 18,

        "basket_multiplier": 0.90,

        "preferred_hours": [18,19,20]

    },

    "Student": {

        "weight": 14,

        "basket_multiplier": 0.75,

        "preferred_hours": [15,16,17,18]

    },

    "Health Conscious": {

        "weight": 12,

        "basket_multiplier": 1.10,

        "preferred_hours": [8,9,10]

    },

    "Premium Shopper": {

        "weight": 10,

        "basket_multiplier": 1.35,

        "preferred_hours": [16,17,18,19]

    },

    "Convenience Shopper": {

        "weight": 16,

        "basket_multiplier": 0.65,

        "preferred_hours": [7,12,18,19]

    }

}

# ============================================================
# PERSONA SHOPPING MISSIONS
# ============================================================

PERSONA_MISSIONS = {

    "Family Shopper": {

        "Weekly Grocery": 45,

        "Household Shopping": 20,

        "Top-Up Shopping": 15,

        "Baby Care": 10,

        "Emergency Shopping": 10

    },

    "Busy Professional": {

        "Convenience Shopping": 40,

        "Ready-To-Eat": 30,

        "Top-Up Shopping": 20,

        "Emergency Shopping": 10

    },

    "Student": {

        "Snacks & Drinks": 40,

        "Convenience Shopping": 30,

        "Top-Up Shopping": 20,

        "Emergency Shopping": 10

    },

    "Health Conscious": {

        "Healthy Grocery": 45,

        "Weekly Grocery": 25,

        "Top-Up Shopping": 20,

        "Convenience Shopping": 10

    },

    "Premium Shopper": {

        "Premium Grocery": 45,

        "Wine & Entertaining": 20,

        "Weekly Grocery": 20,

        "Household Shopping": 15

    },

    "Convenience Shopper": {

        "Convenience Shopping": 50,

        "Top-Up Shopping": 30,

        "Emergency Shopping": 20

    }

}

# ============================================================
# SHOPPING MISSIONS
# ============================================================

SHOPPING_MISSIONS = {

    "Weekly Grocery": {

        "basket_size": (10, 18),

        "spend_multiplier": 1.40

    },

    "Household Shopping": {

        "basket_size": (8, 15),

        "spend_multiplier": 1.25

    },

    "Top-Up Shopping": {

        "basket_size": (3, 7),

        "spend_multiplier": 0.75

    },

    "Emergency Shopping": {

        "basket_size": (1, 4),

        "spend_multiplier": 0.50

    },

    "Baby Care": {

        "basket_size": (5, 10),

        "spend_multiplier": 1.20

    },

    "Convenience Shopping": {

        "basket_size": (2, 5),

        "spend_multiplier": 0.65

    },

    "Healthy Grocery": {

        "basket_size": (6, 12),

        "spend_multiplier": 1.30

    },

    "Premium Grocery": {

        "basket_size": (8, 14),

        "spend_multiplier": 1.70

    },

    "Ready-To-Eat": {

        "basket_size": (2, 5),

        "spend_multiplier": 0.85

    },

    "Snacks & Drinks": {

        "basket_size": (2, 6),

        "spend_multiplier": 0.60

    },

    "Wine & Entertaining": {

        "basket_size": (4, 10),

        "spend_multiplier": 1.80

    }

}

def choose_customer_persona():

    personas = list(CUSTOMER_PERSONAS.keys())

    weights = [
        CUSTOMER_PERSONAS[p]["weight"]
        for p in personas
    ]

    return random.choices(
        personas,
        weights=weights,
        k=1
    )[0]

def assign_customer_personas(customers):

    customers = customers.copy()

    personas = list(CUSTOMER_PERSONAS.keys())

    weights = [
        CUSTOMER_PERSONAS[p]["weight"]
        for p in personas
    ]

    customers["Persona"] = random.choices(
        personas,
        weights=weights,
        k=len(customers)
    )

    return customers

# ============================================================
# MISSION CATEGORY MAP
# ============================================================

MISSION_CATEGORY_MAP = {

    # --------------------------------------------------------
    # WEEKLY GROCERY
    # --------------------------------------------------------

    "Weekly Grocery": [

        "Rice",
        "Pasta",
        "Instant Noodles",
        "Beans",
        "Garri",
        "Semovita",
        "Poundo Yam",
        "Flour",
        "Sugar",
        "Salt",
        "Seasoning",
        "Tomato Paste",
        "Cooking Oil",
        "Premium Cooking Oil",
        "Powdered Milk",
        "Evaporated Milk",
        "Breakfast Cereal",
        "Bread",
        "Eggs",
        "Water"

    ],

    # --------------------------------------------------------
    # HOUSEHOLD SHOPPING
    # --------------------------------------------------------

    "Household Shopping": [

        "Powder Detergent",
        "Liquid Detergent",
        "Fabric Conditioner",
        "Laundry Additive",
        "Stain Remover",
        "Bath Soap",
        "Body Care",
        "Oral Care",
        "Hair Care",
        "Deodorant",
        "Shaving",
        "Feminine Hygiene"

    ],

    # --------------------------------------------------------
    # TOP-UP SHOPPING
    # --------------------------------------------------------

    "Top-Up Shopping": [

        "Bread",
        "Eggs",
        "Water",
        "Carbonated Drink",
        "Juice",
        "Powdered Milk",
        "Instant Noodles",
        "Tomato Paste",
        "Seasoning"

    ],

    # --------------------------------------------------------
    # EMERGENCY SHOPPING
    # --------------------------------------------------------

    "Emergency Shopping": [

        "Bread",
        "Water",
        "Carbonated Drink",
        "Instant Noodles",
        "Bath Soap",
        "Oral Care"

    ],

    # --------------------------------------------------------
    # BABY CARE
    # --------------------------------------------------------

    "Baby Care": [

        "Baby Cereal",
        "Baby Puree",
        "Baby Wipes",
        "Baby Toiletries",
        "Formula Milk",
        "Feeding",
        "Diapers"

    ],

    # --------------------------------------------------------
    # CONVENIENCE SHOPPING
    # --------------------------------------------------------

    "Convenience Shopping": [

        "Bread",
        "Sweet Pastry",
        "Savoury Pastry",
        "Carbonated Drink",
        "Juice",
        "Water",
        "Candy",
        "Chocolate",
        "Chewing Gum",
        "Chips"

    ],

    # --------------------------------------------------------
    # HEALTHY GROCERY
    # --------------------------------------------------------

    "Healthy Grocery": [

        "Greek Yoghurt",
        "Spoonable Yoghurt",
        "Drinking Yoghurt",
        "Honey",
        "Oat Meal",
        "Nuts",
        "Juice",
        "Water"

    ],

    # --------------------------------------------------------
    # PREMIUM GROCERY
    # --------------------------------------------------------

    "Premium Grocery": [

        "Cheese",
        "Greek Yoghurt",
        "Premium Cooking Oil",
        "Chocolate Spread",
        "Peanut Butter",
        "Coffee",
        "Tea",
        "Ice Cream"

    ],

    # --------------------------------------------------------
    # READY TO EAT
    # --------------------------------------------------------

    "Ready-To-Eat": [

        "Ready-To-Eat",
        "Frozen Convenience Food",
        "Frozen Poultry",
        "Frozen Fish & Seafood",
        "Juice",
        "Water"

    ],

    # --------------------------------------------------------
    # SNACKS & DRINKS
    # --------------------------------------------------------

    "Snacks & Drinks": [

        "Sweet Pastry",
        "Savoury Pastry",
        "Cookies",
        "Candy",
        "Chocolate",
        "Chewing Gum",
        "Chips",
        "Carbonated Drink",
        "Juice",
        "Energy Drink",
        "Water"

    ],

    # --------------------------------------------------------
    # WINE & ENTERTAINING
    # --------------------------------------------------------

    "Wine & Entertaining": [

        "Wine",
        "Sparkling Wine",
        "Whisky",
        "Vodka",
        "Rum",
        "Gin",
        "Cream Liqueur",
        "Beer",
        "Stout",
        "Cheese",
        "Chips",
        "Chocolate"

    ]

}

CASHIERS = {

    "BR001": [
        "CSH001","CSH002","CSH003","CSH004",
        "CSH005","CSH006","CSH007","CSH008"
    ],

    "BR002": [
        "CSH009","CSH010","CSH011","CSH012",
        "CSH013","CSH014","CSH015","CSH016"
    ],

    "BR003": [
        "CSH017","CSH018","CSH019","CSH020",
        "CSH021","CSH022","CSH023","CSH024"
    ],

    "BR004": [
        "CSH025","CSH026","CSH027","CSH028",
        "CSH029","CSH030","CSH031","CSH032"
    ],

    "BR005": [
        "CSH033","CSH034","CSH035","CSH036",
        "CSH037","CSH038","CSH039","CSH040"
    ]
}
BRANCH_WEIGHTS = {

    "BR001": 18,   # Ajah

    "BR002": 28,   # Egbeda

    "BR003": 18,   # Abule Egba

    "BR004": 20,   # Ikorodu

    "BR005": 16    # Oju Ore
}

# ============================================================
# CATEGORY AFFINITY
# ============================================================

CATEGORY_AFFINITY = {

    "Bread": {
        "Powdered Milk": 0.70,
        "Eggs": 0.60,
        "Tea": 0.50,
        "Coffee": 0.30,
        "Margarine & Spread": 0.45,
        "Jam": 0.25,
        "Honey": 0.15,
        "Peanut Butter": 0.20
    },

    "Rice": {
        "Cooking Oil": 0.80,
        "Premium Cooking Oil": 0.20,
        "Seasoning": 0.90,
        "Salt": 0.75,
        "Tomato Paste": 0.60,
        "Beans": 0.45
    },

    "Instant Noodles": {
        "Eggs": 0.65,
        "Water": 0.45,
        "Seasoning": 0.55
    },

    "Formula Milk": {
        "Baby Wipes": 0.75,
        "Diapers": 0.80,
        "Baby Toiletries": 0.45,
        "Feeding": 0.40
    },

    "Feeding": {
        "Formula Milk": 0.60,
        "Baby Wipes": 0.70,
        "Diapers": 0.55
    },

    "Cake": {
        "Ice Cream": 0.55,
        "Juice": 0.50,
        "Carbonated Drink": 0.35
    },

    "Beer": {
        "Chips": 0.60,
        "Nuts": 0.50
    }

}
# ============================================================
# CUSTOMER VISIT RULES
# ============================================================

AVERAGE_DAILY_CUSTOMERS = {

    "Monday": 420,

    "Tuesday": 390,

    "Wednesday": 410,

    "Thursday": 430,

    "Friday": 550,

    "Saturday": 780,

    "Sunday": 620

}

WEEKEND_MULTIPLIER = 1.25

PAYDAY_MULTIPLIER = 1.20

PUBLIC_HOLIDAY_MULTIPLIER = 1.40

def get_day_name(transaction_date):

    return transaction_date.strftime("%A")

def generate_daily_customer_count(transaction_date):

    day = get_day_name(transaction_date)

    base = AVERAGE_DAILY_CUSTOMERS[day]

    # Payday Effect
    if transaction_date.day <= 5:

        base = round(base * PAYDAY_MULTIPLIER)

    # Weekend Effect
    if day in ["Saturday", "Sunday"]:

        base = round(base * WEEKEND_MULTIPLIER)

    variation = random.randint(-25, 25)

    return max(150, base + variation)

def choose_customer(customers):

    if random.random() <= REGISTERED_CUSTOMER_RATIO:

        if isinstance(customers, pd.DataFrame):

            customer = customers.sample(1).iloc[0]

            customer_record = customer.to_dict()

        else:

            customer_record = random.choice(customers)

        return {

            "Customer_ID": customer_record["Customer_ID"],

            "Persona": customer_record.get("Persona", choose_customer_persona()),

            "Customer_Type": "Registered"

        }

    else:

        return {

            "Customer_ID": None,

            "Persona": choose_customer_persona(),

            "Customer_Type": "Walk-In"

        }


# ============================================================
# SHOPPING MISSIONS
# ============================================================

PERSONA_MISSIONS = {

    "Family Shopper": {

        "Weekly Grocery": 45,

        "Household Shopping": 20,

        "Top-Up Shopping": 15,

        "Baby Care": 10,

        "Emergency Shopping": 10

    },

    "Student": {

        "Snacks & Drinks": 35,

        "Convenience Shopping": 30,

        "Top-Up Shopping": 20,

        "Emergency Shopping": 15

    },

    "Busy Professional": {

        "Convenience Shopping": 40,

        "Ready-To-Eat": 30,

        "Top-Up Shopping": 20,

        "Emergency Shopping": 10

    },

    "Health Conscious": {

        "Healthy Grocery": 45,

        "Weekly Grocery": 25,

        "Top-Up Shopping": 20,

        "Convenience Shopping": 10

    },

    "Premium Shopper": {

        "Premium Grocery": 40,

        "Weekly Grocery": 30,

        "Household Shopping": 15,

        "Wine & Entertaining": 15

    },

    "Convenience Shopper": {

        "Convenience Shopping": 50,

        "Top-Up Shopping": 30,

        "Emergency Shopping": 20

    }

}

# ============================================================
# CATEGORY RULES
# ============================================================



# ============================================================
# PRODUCT OVERRIDES
# ============================================================

PRODUCT_OVERRIDES = {

    "Bread": {

        "velocity": "Very High",

        "missions": [

            "Breakfast",

            "Weekly Grocery"

        ]

    },

    "Meat Pie": {

        "velocity": "Very High",

        "missions": [

            "Quick Snack"

        ]

    },

    "Chicken Pie": {

        "velocity": "Very High",

        "missions": [

            "Quick Snack"

        ]

    },

    "Fish Pie": {

        "velocity": "High",

        "missions": [

            "Quick Snack"

        ]

    }

}
# ============================================================
# SALES VELOCITY
# ============================================================

SALES_VELOCITY = {

    "Very High": 100,

    "High": 70,

    "Medium": 40,

    "Low": 20,

    "Very Low": 5

}

# ============================================================
# BAKERY BUSINESS RULES
# ============================================================

BAKERY_RULES = {

    "Bread": {

        "velocity": "Very High",

        "peak_hours": [8, 9, 10, 17, 18, 19],

        "mission": "Breakfast"

    },

    "Meat Pie": {

        "velocity": "Very High",

        "peak_hours": [9, 10, 12, 13, 17, 18],

        "mission": "Quick Snack"

    },

    "Chicken Pie": {

        "velocity": "Very High",

        "peak_hours": [9, 10, 12, 13, 17, 18],

        "mission": "Quick Snack"

    }

}


# ============================================================
# LOAD DATA
# ============================================================

def load_datasets():

    print("\nLoading Input Datasets...")

    # --------------------------------------------------------
    # MASTER DATASETS
    # --------------------------------------------------------

    products = pd.read_excel(PRODUCT_FILE)

    customers = pd.read_excel(CUSTOMER_FILE)

    pricing = pd.read_excel(PRICING_FILE)

    inventory = pd.read_excel(INVENTORY_FILE)

    # --------------------------------------------------------
    # BUSINESS RULE DATASETS
    # --------------------------------------------------------

    business_events = pd.read_excel(

        BUSINESS_EVENTS_FILE,

        sheet_name="Business_Events"

    )

    branch_behaviour = pd.read_excel(

        BUSINESS_EVENTS_FILE,

        sheet_name="Branch_Behaviour"

    )

    monthly_behaviour = pd.read_excel(

        BUSINESS_EVENTS_FILE,

        sheet_name="Monthly_Behaviour"

    )

    print(f"Products Loaded          : {len(products):,}")

    print(f"Customers Loaded         : {len(customers):,}")

    print(f"Pricing Records          : {len(pricing):,}")

    print(f"Inventory Records        : {len(inventory):,}")

    print(f"Business Events          : {len(business_events):,}")

    print(f"Branch Behaviour Records : {len(branch_behaviour):,}")

    print(f"Monthly Behaviour Rules  : {len(monthly_behaviour):,}")



# ============================================================
# BUILD PRODUCT CATEGORY CACHE
# ============================================================

    category_products = {}

    for category, group in products.groupby("Category", sort=False):

        category_products[category] = group.to_dict("records")

    # ============================================================
    # BUILD PRICE LOOKUP CACHE
    # ============================================================

    price_lookup = {}

    for _, row in pricing.iterrows():

        product_id = row["Product_ID"]

        effective_date = pd.Timestamp(row["Effective_Date"]).date()

        price_lookup.setdefault(product_id, []).append(

            (effective_date, float(row["New_Price"]))

        )

    for product_id in price_lookup:

        price_lookup[product_id].sort(key=lambda item: item[0])

    return (

    products,

    customers,

    pricing,

    inventory,

    business_events,

    branch_behaviour,

    monthly_behaviour,

    category_products,

    price_lookup

)
# ============================================================
# HELPER FUNCTIONS
# ============================================================

def generate_transaction_id(counter):

    return f"TRX{counter:08d}"

def generate_transaction_date():

    days = (END_DATE - START_DATE).days

    return START_DATE + timedelta(

        days=random.randint(0, days)

    )

def generate_transaction_time():

    hours = [

        8,

        9,

        10,

        11,

        12,

        13,

        14,

        15,

        16,

        17,

        18,

        19,

        20

    ]

    weights = [

        2,

        5,

        7,

        8,

        12,

        13,

        11,

        8,

        7,

        11,

        14,

        12,

        4

    ]

    hour = random.choices(

        hours,

        weights=weights,

        k=1

    )[0]

    minute = random.randint(0,59)

    second = random.randint(0,59)

    return f"{hour:02d}:{minute:02d}:{second:02d}"

def generate_payment_method():

    methods = [

        "Transfer",

        "POS",

        "Cash"

    ]

    weights = [

        60,

        35,

        5

    ]

    return random.choices(

        methods,

        weights=weights,

        k=1

    )[0]


# ============================================================
# WEEK OF MONTH
# ============================================================

def get_week_of_month(transaction_date):

    day = transaction_date.day

    if day <= 7:

        return 1

    elif day <= 14:

        return 2

    elif day <= 21:

        return 3

    else:

        return 4



# ============================================================
# CHOOSE SHOPPING MISSION
# ============================================================

def choose_shopping_mission(

    persona,

    transaction_date,

    business_events=None,
    monthly_behaviour=None,
    branch_behaviour=None,
    branch_code=None

):

    active_event = None

    if business_events is not None:

        active_event = get_active_business_event(

            business_events,

            transaction_date

        )

    event_name_normalized = ""

    if active_event is not None:

        event_name_normalized = str(active_event.get("Event_Name", "")).strip().lower()

    is_christmas_event = "christmas" in event_name_normalized

    week = get_week_of_month(

        transaction_date

    )

    missions = PERSONA_MISSIONS[persona].copy()

    # --------------------------------------------------------
    # SALARY WEEK
    # --------------------------------------------------------

    if week == 1:

        if "Weekly Grocery" in missions:

            missions["Weekly Grocery"] += 20

        if "Household Shopping" in missions:

            missions["Household Shopping"] += 10

    # --------------------------------------------------------
    # END OF MONTH
    # --------------------------------------------------------

    elif week == 4 and not is_christmas_event:

        if "Top-Up Shopping" in missions:

            missions["Top-Up Shopping"] += 20

        if "Emergency Shopping" in missions:

            missions["Emergency Shopping"] += 10

    # --------------------------------------------------------
    # MONTHLY BEHAVIOUR
    # --------------------------------------------------------

    monthly_rule = get_monthly_behaviour(
        monthly_behaviour,
        transaction_date
    )

    if monthly_rule is not None:

        primary_missions = monthly_rule.get("Primary_Missions", "")

        if isinstance(primary_missions, str):

            primary_missions = [item.strip() for item in primary_missions.split(",") if item.strip()]

        for mission_name in primary_missions:

            if is_christmas_event and mission_name in {
                "Top-Up Shopping",
                "Emergency Shopping",
                "Convenience Shopping"
            }:

                continue

            if mission_name in missions:

                missions[mission_name] += 15

    # --------------------------------------------------------
    # BUSINESS EVENTS
    # --------------------------------------------------------

    if active_event is not None:

            event_name = active_event["Event_Name"]
            event_categories = []

            if isinstance(active_event.get("Target_Categories"), str):

                event_categories = [
                    item.strip()
                    for item in active_event["Target_Categories"].split(",")
                    if item.strip()
                ]

            if event_name in ["Christmas Season", "Christmas"]:

                if "Weekly Grocery" in missions:

                    missions["Weekly Grocery"] += 30

                if "Premium Grocery" in missions:

                    missions["Premium Grocery"] += 20

                if "Household Shopping" in missions:

                    missions["Household Shopping"] += 15

                if "Snacks & Drinks" in missions:

                    missions["Snacks & Drinks"] += 12

                if "Ready-To-Eat" in missions:

                    missions["Ready-To-Eat"] += 8

                if "Top-Up Shopping" in missions:

                    missions["Top-Up Shopping"] += 5

                if "Wine & Entertaining" in missions:

                    missions["Wine & Entertaining"] += 35

                if "Emergency Shopping" in missions:

                    missions["Emergency Shopping"] = max(

                        1,

                        missions["Emergency Shopping"] - 8

                    )

            elif event_name in ["Eid Holiday", "Eid", "Ramadan"]:

                if "Weekly Grocery" in missions:

                    missions["Weekly Grocery"] += 25

                if "Snacks & Drinks" in missions:

                    missions["Snacks & Drinks"] += 15

                if "Ready-To-Eat" in missions:

                    missions["Ready-To-Eat"] += 10

            elif event_name in ["Black Friday", "Black Friday Promotion"]:

                if "Weekly Grocery" in missions:

                    missions["Weekly Grocery"] += 20

                if "Premium Grocery" in missions:

                    missions["Premium Grocery"] += 20

                if "Snacks & Drinks" in missions:

                    missions["Snacks & Drinks"] += 10

            elif event_name in ["Back To School", "Back to School"]:

                if "Top-Up Shopping" in missions:

                    missions["Top-Up Shopping"] += 15

            if event_categories:

                for category in event_categories:

                    if category in ["Drinks", "Drink", "Drinks, Snacks"]:

                        if "Snacks & Drinks" in missions:

                            missions["Snacks & Drinks"] += 10

                    if category in ["Rice", "Meat"]:

                        if "Weekly Grocery" in missions:

                            missions["Weekly Grocery"] += 10

    for mission_name in missions:

        missions[mission_name] = max(1, missions[mission_name])

    if branch_behaviour is not None and branch_code is not None:

        branch_rule = get_branch_behaviour(branch_behaviour, branch_code)

        if branch_rule is not None:

            if str(branch_rule.get("Family_Shopping", "")).lower() == "very high":

                if "Weekly Grocery" in missions:

                    missions["Weekly Grocery"] += 8

            if str(branch_rule.get("Premium_Demand", "")).lower() in {"high", "very high"}:

                if "Premium Grocery" in missions:

                    missions["Premium Grocery"] += 10

    return random.choices(

        list(missions.keys()),

        weights=list(missions.values()),

        k=1

    )[0]


def generate_receipt_number(counter):

    return f"RCT{counter:08d}"

def choose_cashier(branch_code):

    return random.choice(
        CASHIERS[branch_code]
    )

def choose_branch():

    branches = list(BRANCH_WEIGHTS.keys())

    weights = list(BRANCH_WEIGHTS.values())

    return random.choices(
        branches,
        weights=weights,
        k=1
    )[0]
# ============================================================
# RETAIL SIMULATION ENGINE
# ============================================================

def generate_basket_size(persona, mission):

    minimum, maximum = SHOPPING_MISSIONS[mission]["basket_size"]

    multiplier = CUSTOMER_PERSONAS[persona]["basket_multiplier"]

    basket = random.randint(minimum, maximum)

    basket = round(basket * multiplier)

    return max(1, basket)


def choose_anchor_category(mission):

    categories = MISSION_CATEGORY_MAP[mission]

    return random.choice(categories)

def get_products_by_category(products, category):

    category_products = products[
        products["Category"] == category
    ].copy()

    return category_products

def choose_anchor_product(products, category):

    eligible_products = products[
        products["Category"] == category
    ]

    if eligible_products.empty:
        return None

    return eligible_products.sample(1).iloc[0]

    if category_products.empty:

        return None

    selected_product = category_products.sample(

        n=1,

        random_state=None

    )

    return selected_product.iloc[0]

# ============================================================
# BASKET BUILDER
# ============================================================

# ============================================================
# BASKET BUILDER
# ============================================================

def build_basket_categories(
    anchor_category,
    mission,
    basket_size
):

    basket = [anchor_category]

    # --------------------------------------------
    # Add Affinity Categories
    # --------------------------------------------

    if anchor_category in CATEGORY_AFFINITY:

        for category, probability in CATEGORY_AFFINITY[anchor_category].items():

            if random.random() <= probability:

                if category not in basket:

                    basket.append(category)

    # --------------------------------------------
    # Remaining Mission Categories
    # --------------------------------------------

    available_categories = [

        category

        for category in MISSION_CATEGORY_MAP[mission]

        if category not in basket

    ]

    random.shuffle(available_categories)

    max_categories = min(

        basket_size,

        len(MISSION_CATEGORY_MAP[mission])

    )

    while len(basket) < max_categories and available_categories:

        basket.append(

            available_categories.pop()

        )

    return basket


def build_product_basket(

    category_products,

    basket_categories

):

    basket_products = []

    for category in basket_categories:

        products_for_category = category_products.get(category)

        if not products_for_category:

            continue

        product = random.choice(products_for_category)

        basket_products.append(product)

    return basket_products


def generate_quantity(category):

    if category in [

        "Bread",
        "Water",
        "Carbonated Drink",
        "Juice",
        "Instant Noodles"

    ]:

        return random.randint(1, 6)

    elif category in [

        "Rice",
        "Cooking Oil",
        "Premium Cooking Oil",
        "Powdered Milk"

    ]:

        return random.randint(1, 3)

    else:

        return random.randint(1, 2)

    # --------------------------------------------
    # Affinity Categories
    # --------------------------------------------

    if anchor_category in CATEGORY_AFFINITY:

        for category, probability in CATEGORY_AFFINITY[anchor_category].items():

            if random.random() <= probability:

                if category not in basket:

                    basket.append(category)

    # --------------------------------------------
    # Available Categories
    # --------------------------------------------

    available_categories = MISSION_CATEGORY_MAP[mission].copy()

    # Remove categories already selected

    available_categories = [

        category

        for category in available_categories

        if category not in basket

    ]

    # --------------------------------------------
    # Maximum possible basket size
    # --------------------------------------------

    max_categories = min(

        basket_size,

        len(MISSION_CATEGORY_MAP[mission])

    )

    # --------------------------------------------
    # Expand Basket
    # --------------------------------------------

    while len(basket) < max_categories:

        candidate = random.choice(

            available_categories

        )

        basket.append(candidate)

        available_categories.remove(candidate)

    return basket
# ============================================================
# SALES ENGINE
# ============================================================
def get_selling_price(

    price_lookup,

    product_id,

    transaction_date

):

    history = price_lookup.get(product_id)

    if not history:

        return None

    transaction_date = pd.Timestamp(transaction_date).date()

    for effective_date, price in reversed(history):

        if effective_date <= transaction_date:

            return price

    return None

def generate_discount():

    if random.random() <= 0.08:

        return random.choice(

            [5,10,15]

        )

    return 0

VAT_RATE = 0.075
def calculate_vat(

    subtotal

):

    return round(

        subtotal * VAT_RATE,

        2

    )

def calculate_line_total(

    quantity,

    unit_price,

    discount_percent

):

    subtotal = quantity * unit_price

    discount = subtotal * (

        discount_percent / 100

    )

    subtotal -= discount

    vat = calculate_vat(

        subtotal

    )

    total = subtotal + vat

    return (

        round(subtotal,2),

        round(discount,2),

        round(vat,2),

        round(total,2)

    )


# ============================================================
# CALENDAR ENGINE
# ============================================================
START_DATE = datetime(2026,1,1)

END_DATE = datetime(2026,12,31)

def generate_calendar(max_days=None, day_sample_rate=1.0):

    calendar = pd.date_range(

        start=START_DATE,

        end=END_DATE,

        freq="D"

    )

    if max_days is not None:

        calendar = calendar[:max_days]

    if day_sample_rate < 1.0:

        sample_size = max(1, int(len(calendar) * day_sample_rate))

        if sample_size < len(calendar):

            sampled_indices = sorted(

                random.sample(range(len(calendar)), sample_size)

            )

            calendar = calendar[sampled_indices]

    return calendar

def generate_daily_visits(transaction_date):

    customers_today = generate_daily_customer_count(

        transaction_date

    )

    return customers_today


# ============================================================
# BUSINESS EVENTS ENGINE
# ============================================================
def get_active_business_event(

    business_events,

    transaction_date

):

    events = business_events[

        (business_events["Start_Date"] <= transaction_date)

        &

        (business_events["End_Date"] >= transaction_date)

    ]

    if events.empty:

        return None

    ranked_events = events.copy()

    ranked_events["_Traffic"] = pd.to_numeric(
        ranked_events.get("Traffic_Multiplier", 1.0),
        errors="coerce"
    ).fillna(1.0)

    ranked_events["_Basket"] = pd.to_numeric(
        ranked_events.get("Basket_Multiplier", 1.0),
        errors="coerce"
    ).fillna(1.0)

    target_categories = ranked_events.get("Target_Categories", "")

    ranked_events["_Specificity"] = target_categories.astype(str).str.strip().str.lower().apply(
        lambda value: 0 if value in {"", "all", "nan"} else 1
    )

    ranked_events["_Start_Date"] = pd.to_datetime(
        ranked_events["Start_Date"],
        errors="coerce"
    )

    ranked_events = ranked_events.sort_values(
        by=["_Specificity", "_Traffic", "_Basket", "_Start_Date"],
        ascending=[False, False, False, False]
    )

    return ranked_events.iloc[0]


def get_monthly_behaviour(monthly_behaviour, transaction_date):

    if monthly_behaviour is None or monthly_behaviour.empty:

        return None

    week_number = get_week_of_month(transaction_date)

    matches = monthly_behaviour[
        monthly_behaviour["Week"] == week_number
    ]

    if matches.empty:

        return None

    return matches.iloc[0]


def get_branch_behaviour(branch_behaviour, branch_code):

    if branch_behaviour is None or branch_behaviour.empty:

        return None

    matches = branch_behaviour[
        branch_behaviour["Branch_Code"] == branch_code
    ]

    if matches.empty:

        return None

    return matches.iloc[0]

# ============================================================
# BRANCH ALLOCATION ENGINE
# ============================================================
def allocate_customers_to_branches(

    total_customers,

    branch_behaviour

):

    allocations = {}

    total_weight = branch_behaviour["Customer_Traffic"].sum()

    allocated = 0

    for i, row in branch_behaviour.iterrows():

        branch = row["Branch_Code"]

        weight = row["Customer_Traffic"]

        customers = round(

            total_customers *

            (weight / total_weight)

        )

        allocations[branch] = customers

        allocated += customers

    # --------------------------------------------------------
    # Adjust rounding difference
    # --------------------------------------------------------

    difference = total_customers - allocated

    if difference != 0:

        first_branch = branch_behaviour.iloc[0]["Branch_Code"]

        allocations[first_branch] += difference

    return allocations
# ============================================================
# SALES ENGINE
# ============================================================

def generate_sales_transactions(

    products,

    customers,

    pricing,

    inventory,

    business_events,

    branch_behaviour,

    monthly_behaviour

):

    print("=" * 60)

    print("JRAD SALES TRANSACTION GENERATOR")

    print("=" * 60)

    sales_records = []

    transaction_counter = 1

    receipt_counter = 1

    calendar = generate_calendar().head(7)

    print("\nGenerating Sales Transactions...")

    for transaction_date in calendar:
     active_event = get_active_business_event(
        business_events,
        transaction_date
    )

    # ======================================================
    # DAILY TRAFFIC
    # ======================================================

    customers_today = generate_daily_customer_count(
        transaction_date
    )

    if active_event is not None:

        customers_today = round(
            customers_today *
            active_event["Traffic_Multiplier"]
        )

    # ======================================================
    # BRANCH DISTRIBUTION
    # ======================================================

    branch_customers = allocate_customers_to_branches(
        customers_today,
        branch_behaviour
    )

    print(f"\n{transaction_date.date()}")

    print("-" * 60)

    for branch_code, total_branch_customers in branch_customers.items():

        print(

            f"{branch_code}: {total_branch_customers} customers"

        )
    sales = pd.DataFrame(sales_records)

    print(

        f"✓ {len(sales):,} sales records created."

    )

    return sales


# ============================================================
# GENERATE RECEIPT HEADER
# ============================================================

def generate_receipt_header(

    receipt_counter,

    transaction_date,

    branch_code,

    customer,

    shopping_mission,

    basket_size

):

    receipt = {

        "Receipt_No":
            generate_receipt_number(
                receipt_counter
            ),

        "Transaction_Date":
            transaction_date.date(),

        "Transaction_Time":
            generate_transaction_time(),

        "Branch_Code":
            branch_code,

        "Cashier_ID":
            choose_cashier(
                branch_code
            ),

        "Customer_ID":
            customer["Customer_ID"],

        "Customer_Type":
            customer["Customer_Type"],

        "Persona":
            customer["Persona"],

        "Shopping_Mission":
            shopping_mission,

        "Basket_Size":
            basket_size,

        "Payment_Method":
            generate_payment_method()

    }

    return receipt

# ============================================================
# GENERATE TRANSACTION LINES
# ============================================================

def generate_transaction_lines(

    receipt,

    category_products,

    price_lookup

):

    transaction_lines = []

    # --------------------------------------------------------
    # BUILD SHOPPING BASKET
    # --------------------------------------------------------

    anchor_category = choose_anchor_category(

        receipt["Shopping_Mission"]

    )

    basket_categories = build_basket_categories(

        anchor_category,

        receipt["Shopping_Mission"],

        receipt["Basket_Size"]

    )

    basket_products = build_product_basket(

        category_products,

        basket_categories

    )

    # --------------------------------------------------------
    # CREATE SALES LINES
    # --------------------------------------------------------

    line_number = 1

    for product in basket_products:

        quantity = generate_quantity(product["Category"])

        unit_price = get_selling_price(

            price_lookup,

            product["Product_ID"],

            receipt["Transaction_Date"]

        )

        if unit_price is None:

            continue

        discount_percent = generate_discount()

        (

            subtotal,

            discount,

            vat,

            total

        ) = calculate_line_total(

            quantity,

            unit_price,

            discount_percent

        )

        transaction_lines.append({

            "Receipt_No": receipt["Receipt_No"],

            "Line_Number": line_number,

            "Product_ID": product["Product_ID"],

            "Product_Name": product["Product_Name"],

            "Category": product["Category"],

            "Quantity": quantity,

            "Unit_Price": round(unit_price, 2),

            "Discount_Percent": discount_percent,

            "Discount_Amount": discount,

            "VAT": vat,

            "Line_Total": total

        })

        line_number += 1

    return transaction_lines

# ============================================================
# SALES SIMULATION ENGINE
# ============================================================
# ============================================================
# BUILD SALES DATASET
# ============================================================

def export_results(receipts, transactions, payments, output_file=OUTPUT_FILE):

    output_path = output_file

    output_dir = os.path.dirname(os.path.abspath(output_path))

    os.makedirs(output_dir, exist_ok=True)

    def write_dataframe_csv(frame, file_name):

        if frame is None or frame.empty:

            return

        output_file_path = os.path.join(output_dir, file_name)

        frame.to_csv(output_file_path, index=False)

    write_dataframe_csv(receipts, "JRAD_Receipts.csv")

    write_dataframe_csv(transactions, "JRAD_Transactions.csv")

    write_dataframe_csv(payments, "JRAD_Payments.csv")

    print(f"\nExported results to {output_dir}")


def write_batch_files(batch_records, prefix, temp_dir, batch_counter):

    if not batch_records:

        return

    output_path = os.path.join(temp_dir, f"{prefix}_{batch_counter:06d}.csv")

    pd.DataFrame(batch_records).to_csv(output_path, index=False)


def load_batch_files(temp_dir, prefix):

    files = sorted(glob.glob(os.path.join(temp_dir, f"{prefix}_*.csv")))

    if not files:

        return pd.DataFrame()

    frames = [pd.read_csv(path) for path in files]

    return pd.concat(frames, ignore_index=True) if frames else pd.DataFrame()


def build_sales_dataset(

    products,

    customers,

    pricing,

    inventory,

    business_events,

    branch_behaviour,

    monthly_behaviour,

    category_products,

    price_lookup,

    max_days=None,

    target_lines=None,

    output_file=OUTPUT_FILE,

    max_customers_per_day=None,

    batch_size=10000,

    day_sample_rate=1.0

):

    print("=" * 60)
    print("JRAD SALES SIMULATION ENGINE")
    print("=" * 60)

    receipt_records = []
    transaction_records = []
    payment_records = []

    receipt_counter = 1

    target_lines = TARGET_TRANSACTION_LINES if target_lines is None else target_lines

    customer_records = customers.to_dict("records")

    calendar = generate_calendar(max_days, day_sample_rate=day_sample_rate)

    output_dir = os.path.dirname(os.path.abspath(output_file))

    temp_dir = os.path.join(output_dir, ".sales_tmp")

    os.makedirs(temp_dir, exist_ok=True)

    batch_counter = 0

    print("\nGenerating Sales Dataset...\n")

    processed_days = 0

    for transaction_date in calendar:

        # =====================================================
        # BUSINESS EVENT
        # =====================================================

        active_event = get_active_business_event(

            business_events,

            transaction_date

        )

        # =====================================================
        # DAILY TRAFFIC
        # =====================================================

        customers_today = generate_daily_customer_count(

            transaction_date

        )

        monthly_rule = get_monthly_behaviour(
            monthly_behaviour,
            transaction_date
        )

        effective_traffic_multiplier = 1.0

        if monthly_rule is not None:

            effective_traffic_multiplier *= monthly_rule["Traffic_Multiplier"]

        if active_event is not None:

            effective_traffic_multiplier = max(

                effective_traffic_multiplier,

                active_event["Traffic_Multiplier"]

            )

        customers_today = round(

            customers_today * effective_traffic_multiplier

        )

        if max_customers_per_day is not None:

            customers_today = min(customers_today, max_customers_per_day)

        # =====================================================
        # BRANCH ALLOCATION
        # =====================================================

        branch_customers = allocate_customers_to_branches(

            customers_today,

            branch_behaviour

        )

        processed_days += 1

        if max_days is not None or transaction_date.day == 1:

            print(

                f"{transaction_date.date()} | {customers_today} customers"

            )

        # =====================================================
        # LOOP THROUGH BRANCHES
        # =====================================================

        for branch_code, customer_count in branch_customers.items():

            # =================================================
            # LOOP THROUGH CUSTOMERS
            # =================================================

            for _ in range(customer_count):

                customer = choose_customer(customer_records)
                
                shopping_mission = choose_shopping_mission(
                    customer["Persona"],
                    transaction_date,
                    business_events,
                    monthly_behaviour,
                    branch_behaviour,
                    branch_code
                )
        
                basket_size = generate_basket_size(
                    customer["Persona"],
                    shopping_mission
                )

                effective_basket_multiplier = 1.0

                if monthly_rule is not None:

                    effective_basket_multiplier *= monthly_rule["Basket_Multiplier"]

                if active_event is not None:

                    effective_basket_multiplier = max(
                        effective_basket_multiplier,
                        active_event["Basket_Multiplier"]
                    )

                basket_size = max(
                    1,
                    round(basket_size * effective_basket_multiplier)
                )
                
                receipt = generate_receipt_header(
                    receipt_counter,
                    transaction_date,
                    branch_code,
                    customer,
                    shopping_mission,
                    basket_size
                )
               
                # ============================================
                # SAVE RECEIPT
                # ============================================

                receipt_records.append(

                    receipt

                )

                # ============================================
                # GENERATE TRANSACTION LINES
                # ============================================

                transaction_lines = generate_transaction_lines(

                    receipt,

                    category_products,


                    price_lookup

                )

                if not transaction_lines:

                    continue

                transaction_records.extend(transaction_lines)

                # ============================================
                # PAYMENT RECORD
                # ============================================

                total_amount = round(

                    sum(line["Line_Total"] for line in transaction_lines),

                    2

                )

                payment_records.append({

                    "Payment_ID":

                        f"PAY{receipt_counter:08d}",

                    "Receipt_No":

                        receipt["Receipt_No"],

                    "Transaction_Date":

                        receipt["Transaction_Date"],

                    "Branch_Code":

                        receipt["Branch_Code"],

                    "Customer_ID":

                        receipt["Customer_ID"],

                    "Payment_Method":

                        receipt["Payment_Method"],

                    "Amount":

                        total_amount,

                    "Payment_Status":

                        "Successful"

                })

                if len(transaction_records) >= target_lines:

                    print(

                        f"Target reached at {len(transaction_records):,} transaction lines."

                    )

                    return (

                        pd.DataFrame(receipt_records),

                        pd.DataFrame(transaction_records),

                        pd.DataFrame(payment_records)

                    )

                if len(receipt_records) >= batch_size:

                    write_batch_files(receipt_records, "receipts", temp_dir, batch_counter)

                    write_batch_files(transaction_records, "transactions", temp_dir, batch_counter)

                    write_batch_files(payment_records, "payments", temp_dir, batch_counter)

                    receipt_records = []

                    transaction_records = []

                    payment_records = []

                    batch_counter += 1

                # ============================================
                # INVENTORY PLACEHOLDER
                # ============================================

                # Inventory deduction will be added here.

                receipt_counter += 1

    # ========================================================
    # FLUSH FINAL BATCH
    # ========================================================

    if receipt_records or transaction_records or payment_records:

        write_batch_files(receipt_records, "receipts", temp_dir, batch_counter)

        write_batch_files(transaction_records, "transactions", temp_dir, batch_counter)

        write_batch_files(payment_records, "payments", temp_dir, batch_counter)

    # ========================================================
    # CONVERT TO DATAFRAMES
    # ========================================================

    receipts = load_batch_files(temp_dir, "receipts")

    transactions = load_batch_files(temp_dir, "transactions")

    payments = load_batch_files(temp_dir, "payments")

    if receipts.empty and receipt_records:

        receipts = pd.DataFrame(receipt_records)

    if transactions.empty and transaction_records:

        transactions = pd.DataFrame(transaction_records)

    if payments.empty and payment_records:

        payments = pd.DataFrame(payment_records)

    print()

    print("=" * 60)

    print("SIMULATION COMPLETE")

    print("=" * 60)

    print()

    print(f"Receipts Generated      : {len(receipts):,}")

    print(f"Transaction Lines       : {len(transactions):,}")

    print(f"Payments Generated      : {len(payments):,}")

    shutil.rmtree(temp_dir, ignore_errors=True)

    return (

        receipts,

        transactions,

        payments

    )
# ============================================================
# MAIN PROGRAM
# ============================================================

if __name__ == "__main__":

    args = parse_args()

    (
        products,
        customers,
        pricing,
        inventory,
        business_events,
        branch_behaviour,
        monthly_behaviour,
        category_products,
        price_lookup
    ) = load_datasets()

    customers = assign_customer_personas(customers)

    receipts, transactions, payments = build_sales_dataset(

        products,
        customers,
        pricing,
        inventory,
        business_events,
        branch_behaviour,
        monthly_behaviour,
        category_products,
        price_lookup,
        max_days=args.days,
        target_lines=args.target_lines,
        output_file=OUTPUT_FILE,
        max_customers_per_day=args.max_customers_per_day,
        batch_size=args.batch_size,
        day_sample_rate=args.day_sample_rate
    )

    export_results(receipts, transactions, payments, OUTPUT_FILE)

if __name__ == "__main__":

    print()

    print("=" * 60)

    print("SIMULATION COMPLETE")

    print("=" * 60)

    print()

    print("Receipts Generated      :", len(receipts))

    print("Transactions Generated  :", len(transactions))

    print("Payments Generated      :", len(payments))