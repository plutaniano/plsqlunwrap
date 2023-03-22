import sys
from plsqlunwrap.unwrap import unwrap


def main() -> None:
    with open("".join(sys.argv[1:])) as f:
        print(unwrap(f.read()))


if __name__ == "__main__":
    main()
