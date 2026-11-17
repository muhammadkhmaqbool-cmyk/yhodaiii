#!/usr/bin/env sh
# YHOD launcher.
# Starts the server with a Node.js that has SQLite built in (Node 22.13 or newer).
# If the installed Node.js is older and the better-sqlite3 package is not installed,
# a portable Node.js LTS is downloaded once into your cache folder and used instead.
set -e
cd "$(dirname "$0")"

has_sqlite() { "$1" -e "require('node:sqlite')" >/dev/null 2>&1; }

NODE_BIN="$(command -v node 2>/dev/null || true)"
if [ -n "$NODE_BIN" ] && has_sqlite "$NODE_BIN"; then
  exec "$NODE_BIN" --disable-warning=ExperimentalWarning server.js
fi
if [ -n "$NODE_BIN" ] && [ -d node_modules/better-sqlite3 ]; then
  exec "$NODE_BIN" server.js
fi

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/yhod-node"
if [ ! -x "$CACHE/bin/node" ] || ! has_sqlite "$CACHE/bin/node"; then
  case "$(uname -s)" in Linux) OS=linux ;; Darwin) OS=darwin ;; *) echo "Please install Node.js 22.13 or newer (https://nodejs.org), then run: node server.js" >&2; exit 1 ;; esac
  case "$(uname -m)" in x86_64|amd64) ARCH=x64 ;; aarch64|arm64) ARCH=arm64 ;; *) echo "Please install Node.js 22.13 or newer (https://nodejs.org), then run: node server.js" >&2; exit 1 ;; esac
  BASE="https://nodejs.org/dist/latest-v24.x"
  echo "YHOD: fetching a portable Node.js (one time)..." >&2
  SUMS="$(curl -fsSL --max-time 30 "$BASE/SHASUMS256.txt")"
  FILE="$(printf '%s\n' "$SUMS" | grep -o "node-v[0-9.]*-$OS-$ARCH.tar.gz" | head -n 1)"
  [ -n "$FILE" ] || { echo "Could not find a Node.js build for $OS-$ARCH." >&2; exit 1; }
  TMP="$(mktemp -d)"
  curl -fsSL --max-time 300 -o "$TMP/node.tar.gz" "$BASE/$FILE"
  WANT="$(printf '%s\n' "$SUMS" | grep " $FILE\$" | cut -d ' ' -f 1)"
  if command -v sha256sum >/dev/null 2>&1; then GOT="$(sha256sum "$TMP/node.tar.gz" | cut -d ' ' -f 1)"; else GOT="$(shasum -a 256 "$TMP/node.tar.gz" | cut -d ' ' -f 1)"; fi
  [ "$WANT" = "$GOT" ] || { echo "Node.js download failed its checksum; not using it." >&2; rm -rf "$TMP"; exit 1; }
  rm -rf "$CACHE"; mkdir -p "$CACHE"
  tar -xzf "$TMP/node.tar.gz" -C "$CACHE" --strip-components=1
  rm -rf "$TMP"
fi
exec "$CACHE/bin/node" --disable-warning=ExperimentalWarning server.js
