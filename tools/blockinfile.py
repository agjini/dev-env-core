#!/usr/bin/env python3
"""Insert or update a marked managed block in a target file.

Usage: blockinfile.py <block-source-file> <target-file>
"""

import pathlib
import sys

BEGIN = "# BEGIN dev-env-core MANAGED BLOCK"
END = "# END dev-env-core MANAGED BLOCK"


def main() -> int:
    if len(sys.argv) != 3:
        print(
            f"usage: {sys.argv[0]} <block-source-file> <target-file>", file=sys.stderr
        )
        return 1

    src, dst = sys.argv[1], sys.argv[2]
    block = pathlib.Path(src).read_text().rstrip()
    managed = f"{BEGIN}\n{block}\n{END}\n"

    target = pathlib.Path(dst).expanduser()
    target.parent.mkdir(parents=True, exist_ok=True)

    if not target.exists():
        target.write_text(managed)
        return 0

    content = target.read_text()
    if BEGIN in content and END in content:
        pre = content.split(BEGIN)[0]
        post = content.split(END, 1)[1]
        new = pre.rstrip() + "\n" + managed + post.lstrip()
    else:
        new = content.rstrip() + "\n\n" + managed

    if new != content:
        target.write_text(new)

    return 0


if __name__ == "__main__":
    sys.exit(main())
