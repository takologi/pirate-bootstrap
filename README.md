# Pirate Chain (ARRR) bootstrap

A snapshot of the Pirate Chain block data, taken from a fully synced `pirated`
node after a clean shutdown. Restoring it saves the days of initial block
download and index building on a fresh node.

## Current snapshot

| | |
|---|---|
| Snapshot time (UTC) | 2026-10-28 13:31 |
| Block height | 4187945 |
| Best block hash | `0000000ced66dda47a963fe761bb886b01871c6c01f44b96d5232ad5576f1470` |
| Node version | Pirate `v6.0.14` (`Komodo Daemon version v6.0.14-ga86845f3dc`) |
| Archive | `arrr-bootstrap-20261028T1331Z-h4187945.tar.gz` |
| Size | 32 GB compressed, 40 GB extracted |

The archive is published as a [GitHub release](../../releases). GitHub limits a
release asset to 2 GB, so the archive is split into 1.9 GB parts
(`*.tar.gz.part00`, `.part01`, ...). `SHA256SUMS` lists the checksum of every
part and of the joined archive.

## What is inside

Only chain data, as it lies in the Pirate data directory:

- `blocks/` (block files and the block index, which also holds the address,
  spent and timestamp indexes)
- `chainstate/` (UTXO set and Sapling tree state)
- `notarisations/`
- `komodoevents`, `komodoevents.ind`, `signedmasks` (dPoW notarization data)

Not included: wallet, keys, TLS certificates, I2P/Tor identities, `peers.dat`,
logs and configuration. File ownership in the archive is set to `0/0`, so it
extracts cleanly as any user.

## Node parameters used

The node that produced the snapshot ran with these settings in `pirate.conf`.
They matter because the extra indexes live inside `blocks/index`:

```
txindex=1
addressindex=1
spentindex=1
timestampindex=1
experimentalfeatures=1
```

If your node does not need the address, spent and timestamp indexes, you can
still use the snapshot: the extra indexes are simply carried along. If you do
need them (for example for a lightwalletd or an explorer backend), set the same
options before the first start, otherwise `pirated` will ask for a reindex.

## Restore

1. Stop `pirated` and make a backup of your `wallet.dat`.
2. Download all parts and `SHA256SUMS` from the release into one directory.
3. Run the helper script (or the equivalent commands by hand):

```
./scripts/restore-bootstrap.sh <download-dir> <datadir>
```

By hand:

```
cd <download-dir>
sha256sum -c --ignore-missing SHA256SUMS
cat arrr-bootstrap-20261028T1331Z-h4187945.tar.gz.part* \
  | tar -xz -C <datadir>
```

`<datadir>` is the Pirate data directory, by default `~/.komodo/PIRATE` on
Linux. Remove any existing `blocks/`, `chainstate/` and `notarisations/`
directories there first, then start `pirated`. It verifies the last blocks on
startup and continues syncing from height 4187945.

## Building a snapshot

`scripts/pack-bootstrap.sh <datadir> <outdir>` packs, checksums and splits the
data directory of a stopped node. Run it only after `pirated` logged
`Shutdown: done`, otherwise the chainstate may lag behind the block files.

## License

The scripts and this documentation are released under the MIT License, the same
license as the [Pirate node](https://github.com/PirateNetwork/pirate) (see
`LICENSE`). The chain data itself is public blockchain data and carries no
license claim.
