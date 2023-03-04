import os
from pathlib import Path
from plsqlunwrap import unwrap

BASE_DIR = Path(__file__).parent.resolve()


def test_unwrap():
    for dir, _, files in os.walk(BASE_DIR / "samples"):
        for file in files:
            if file.endswith(".sql"):
                continue

            before = Path(f"{dir}/{file}").read_text()
            after = Path(f"{dir}/{file.replace('.plb', '.sql')}").read_text()
            assert unwrap(before) == after
