#!/bin/bash
# Pack Pirate (ARRR) chain data into a bootstrap archive and split it into
# parts small enough for GitHub release assets (2 GB limit per asset).
#
# Usage: pack-bootstrap.sh <datadir> <outdir>
# Run only while pirated is stopped and after a clean shutdown
# ("Shutdown: done" in debug.log).
set -euo pipefail
DATADIR="${1:?datadir}"
OUT="${2:?outdir}"
STAMP=$(date -u +%Y%m%dT%H%MZ)
HEIGHT=$(grep -a 'UpdateTip: new best' "$DATADIR/debug.log" | tail -1 | grep -oP 'height=\K\d+')
NAME="arrr-bootstrap-${STAMP}-h${HEIGHT}.tar.gz"
mkdir -p "$OUT/parts"
# --owner/--group/--numeric-owner strip local user names from the archive.
tar -C "$DATADIR" --owner=0 --group=0 --numeric-owner -cf - \
  blocks chainstate notarisations komodoevents komodoevents.ind signedmasks \
  | pigz -6 > "$OUT/$NAME"
cd "$OUT"
sha256sum "$NAME" > SHA256SUMS
split -b 1900M -d -a 2 "$NAME" "parts/$NAME.part"
( cd parts && sha256sum "$NAME".part* ) >> SHA256SUMS
cat SHA256SUMS
