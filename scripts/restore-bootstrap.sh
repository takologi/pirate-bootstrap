#!/bin/bash
# Join the downloaded parts, verify checksums and extract the bootstrap into
# the Pirate data directory. Stop pirated before running this.
#
# Usage: restore-bootstrap.sh <download-dir> <datadir>
set -euo pipefail
DL="${1:?download dir with *.part* and SHA256SUMS}"
DATADIR="${2:?datadir, e.g. ~/.komodo/PIRATE}"
cd "$DL"
sha256sum -c --ignore-missing SHA256SUMS
NAME=$(ls *.tar.gz.part00 | sed 's/\.part00$//')
mkdir -p "$DATADIR"
for d in blocks chainstate notarisations; do rm -rf "$DATADIR/$d"; done
rm -f "$DATADIR"/komodoevents "$DATADIR"/komodoevents.ind "$DATADIR"/signedmasks
cat "$NAME".part* | tar -xz -C "$DATADIR"
echo "Bootstrap extracted into $DATADIR"
