from pathlib import Path
from plsqlunwrap import unwrap


def test_unwrap_with_source():
    for path in Path("samples/").glob("*.plb"):
        before = path.read_text()
        after = path.with_suffix(".sql").read_text()
        assert unwrap(before) == after


def test_unwrap_with_paths():
    for path in Path("samples/").glob("*.plb"):
        unwrapped = path.with_suffix(".sql").read_text()
        assert unwrap(str(path)) == unwrapped
