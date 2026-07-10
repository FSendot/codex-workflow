#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SOURCE="$SCRIPT_DIR/.codex/bin/cursor-agent-codex"
DESTINATION="$CODEX_HOME/bin/cursor-agent-codex"

if [ ! -f "$SOURCE" ]; then
  printf 'Missing wrapper: %s\n' "$SOURCE" >&2
  exit 1
fi

install -d -m 700 "$CODEX_HOME/bin" "$CODEX_HOME/secrets"
install -m 700 "$SOURCE" "$DESTINATION"

printf 'Installed %s\n' "$DESTINATION"
printf 'Set CURSOR_API_KEY, or store it with mode 600 in %s\n' "$CODEX_HOME/secrets/cursor_api_key"
