#!/usr/bin/env python3
"""Strip the DEBUG scaffolding from .cmd file

usage: 
    python strip_debug.py <src> <dst>

- without the second argument the result goes to stdout
- line endings of the input are preserved
"""

import re
import sys

KEEP_HEADER_LINES = 2  # leading '::' lines to keep
DBG_SETUP = [  # lines that define the dbg switch
    re.compile(r'set\s+"dbg=rem"', re.IGNORECASE),
    re.compile(r'if\s+defined\s+DEBUG\s+set\s+"dbg=echo"', re.IGNORECASE),
]


def clean(text):
    out = []
    header_seen = 0
    in_header = True
    drop_blank = False  # last line was removed -> swallow blank lines after it

    for line in text.splitlines(keepends=True):
        body = line.strip()

        # leading '::' header: keep only the first KEEP_HEADER_LINES lines
        if in_header:
            if body.startswith("::"):
                header_seen += 1
                if header_seen <= KEEP_HEADER_LINES:
                    out.append(line)
                continue
            in_header = False

        if body.startswith("!dbg!") or any(p.fullmatch(body) for p in DBG_SETUP):
            drop_blank = True
            continue

        if body:
            drop_blank = False
        elif drop_blank or (out and not out[-1].strip()):
            continue  # blank after a removed line, or a run of blanks

        out.append(line)

    # no blank line directly before a closing ')'
    return "".join(
        l
        for i, l in enumerate(out)
        if l.strip() or i + 1 == len(out) or out[i + 1].strip() != ")"
    )


def main():
    if len(sys.argv) not in (2, 3):
        sys.exit(__doc__)

    # utf-8-sig: tolerate (and drop) a BOM, which would break the first cmd line
    with open(sys.argv[1], encoding="utf-8-sig", newline="") as f:
        result = clean(f.read())

    for l in result.splitlines():
        if re.search(r"dbg|DEBUG", l, re.IGNORECASE):
            print("warning: leftover debug-looking line:", l.strip(), file=sys.stderr)

    if len(sys.argv) == 3:
        with open(sys.argv[2], "w", encoding="utf-8", newline="") as f:
            f.write(result)
    else:
        sys.stdout.buffer.write(result.encode("utf-8"))


if __name__ == "__main__":
    main()
