"""
JRAD Retail Analytics Platform
Production Data Generation Engine (PDGE)
Version 1.0
"""
from customer_generator import generate_name
from identity_loader import load_identity_library
from distribution_loader import load_distribution_library


print("=" * 60)
print("JRAD RETAIL ANALYTICS PLATFORM")
print("Production Data Generation Engine (PDGE)")
print("=" * 60)

# -------------------------
# Identity Library
# -------------------------

print("\nLoading Identity Library...\n")

identity_library = load_identity_library()

for sheet_name, sheet_data in identity_library.items():
    print(f"✓ {sheet_name:<35} {len(sheet_data):>5} records")

# -------------------------
# Distribution Library
# -------------------------

print("\nLoading Distribution Library...\n")

distribution_library = load_distribution_library()

for sheet_name, sheet_data in distribution_library.items():
    print(f"✓ {sheet_name:<35} {len(sheet_data):>5} records")

print("\n✅ System Ready.")
print("\nTesting Name Generator...\n")

customer = generate_name(
    identity_library,
    "Yoruba",
    "Male"
)

print(customer)