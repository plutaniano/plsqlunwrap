import os
from pathlib import Path
from plsqlunwrap import unwrap

BASE_DIR = Path(__file__).parent.resolve()


def test_unwrap():
    for path in Path("samples/").glob("*.plb"):
        before = path.read_text()
        after = path.with_suffix(".sql").read_text()
        assert unwrap(before) == after
