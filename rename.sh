#!/bin/bash
# Rename the distro everywhere: ./rename.sh "Aurora" aurora
# First argument = display name, second = lowercase id (no spaces).
set -euo pipefail
cd "$(dirname "$0")"
[[ $# -eq 2 ]] || { echo 'Usage: ./rename.sh "Display Name" lowercaseid'; exit 1; }
NAME="$1"; ID="$2"
grep -rlI --exclude=rename.sh -e MyDistro -e mydistro . | while read -r f; do
  sed -i -e "s/MyDistro/$NAME/g" -e "s/mydistro/$ID/g" "$f"
done
find . -depth -name '*mydistro*' -not -path './.git/*' | while read -r p; do
  mv "$p" "$(dirname "$p")/$(basename "$p" | sed "s/mydistro/$ID/g")"
done
echo "Renamed to $NAME ($ID)."
