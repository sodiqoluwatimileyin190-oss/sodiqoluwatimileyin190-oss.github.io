"""
JRAD Retail Analytics Platform
Distribution Loader
Version: 1.0
"""

from pathlib import Path
import pandas as pd


def load_distribution_library():
    """
    Loads the Distribution Library workbook.
    """

    base_folder = Path(__file__).resolve().parent.parent

    file_path = (
        base_folder
        / "Reference Data"
        / "JRAD_Distribution_Library_v1.xlsx"
    )

    if not file_path.exists():
        raise FileNotFoundError(
            f"Distribution Library not found:\n{file_path}"
        )

    workbook = pd.read_excel(
        file_path,
        sheet_name=None
    )

    return workbook