"""
JRAD Retail Analytics Platform
Identity Loader
Version: 1.0
"""

from pathlib import Path
import pandas as pd


def load_identity_library():
    """
    Loads the Nigerian Identity Library workbook.
    """

    base_folder = Path(__file__).resolve().parent.parent

    file_path = (
        base_folder
        / "Reference Data"
        / "JRAD_Nigerian_Identity_Library_v1_FINAL.xlsx"
    )

    if not file_path.exists():
        raise FileNotFoundError(
            f"Identity Library not found:\n{file_path}"
        )

    workbook = pd.read_excel(
        file_path,
        sheet_name=None
    )

    return workbook


def get_available_ethnicities(identity_library):
    """
    Returns all ethnicities that have complete
    male, female and surname worksheets.
    """

    ethnicities = []

    for sheet in identity_library.keys():

        if sheet.endswith("_Male_First_Names"):

            ethnicity = sheet.replace(
                "_Male_First_Names",
                ""
            )

            female_sheet = f"{ethnicity}_Female_First_Names"
            surname_sheet = f"{ethnicity}_Surnames"

            if (
                female_sheet in identity_library
                and surname_sheet in identity_library
            ):
                ethnicities.append(ethnicity)

    return sorted(ethnicities)