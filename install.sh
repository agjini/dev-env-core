#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v comtrya &>/dev/null; then
    echo "Installing comtrya..."
    if command -v pacman &>/dev/null; then
        if command -v paru &>/dev/null; then
            paru -S --needed --noconfirm comtrya-bin
        elif command -v yay &>/dev/null; then
            yay -S --needed --noconfirm comtrya-bin
        else
            echo "No AUR helper found (paru/yay). Install one, or install comtrya-bin manually from the AUR." >&2
            exit 1
        fi
    elif command -v cargo &>/dev/null; then
        cargo install comtrya
    else
        echo "Cannot install comtrya: install an AUR helper (Arch) or cargo." >&2
        exit 1
    fi
fi

if [[ ! -f vars.yml ]]; then
    echo "vars.yml not found — run: cp vars_example.yml vars.yml && \$EDITOR vars.yml"
    exit 1
fi

defines=()
missing=()
while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_]*):[[:space:]]*\"?([^\"]*)\"?[[:space:]]*$ ]]; then
        key="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"
        if [[ -z "$value" ]]; then
            missing+=("$key")
        else
            defines+=(-D "$key=$value")
        fi
    fi
done < vars.yml

if (( ${#missing[@]} > 0 )); then
    echo "vars.yml is missing values for: ${missing[*]}" >&2
    echo "Edit vars.yml and fill in every variable before re-running." >&2
    exit 1
fi

comtrya -v "${defines[@]}" apply
