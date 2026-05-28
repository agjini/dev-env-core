#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v comtrya &>/dev/null; then
    echo "Installing comtrya..."
    cargo install comtrya
fi

if [[ ! -f vars.yml ]]; then
    echo "vars.yml not found — run: cp vars_example.yml vars.yml && \$EDITOR vars.yml"
    exit 1
fi

defines=()
while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_]*):[[:space:]]*\"?([^\"]*)\"?[[:space:]]*$ ]]; then
        defines+=(-D "${BASH_REMATCH[1]}=${BASH_REMATCH[2]}")
    fi
done < vars.yml

comtrya -v "${defines[@]}" apply
