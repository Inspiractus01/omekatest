#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${OMEKA_ENV_FILE:-$ROOT_DIR/.env}"

if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
fi

: "${OMEKA_DB_HOST:=127.0.0.1}"
: "${OMEKA_DB_NAME:=omekatest}"
: "${OMEKA_DB_USER:=omeka}"
: "${OMEKA_DB_PASSWORD:=omeka}"

if [ -z "$OMEKA_DB_HOST" ] || [ -z "$OMEKA_DB_NAME" ] || [ -z "$OMEKA_DB_USER" ]; then
  echo "Missing required DB settings. Provide OMEKA_DB_HOST, OMEKA_DB_NAME, OMEKA_DB_USER, OMEKA_DB_PASSWORD."
  exit 1
fi

cat > "$ROOT_DIR/config/database.ini" <<EOF
user     = "$OMEKA_DB_USER"
password = "$OMEKA_DB_PASSWORD"
dbname   = "$OMEKA_DB_NAME"
host     = "$OMEKA_DB_HOST"
EOF

mkdir -p "$ROOT_DIR/files" "$ROOT_DIR/logs"

if [ -n "${OMEKA_WEB_USER:-}" ] && [ -n "${OMEKA_WEB_GROUP:-}" ]; then
  chown -R "$OMEKA_WEB_USER":"$OMEKA_WEB_GROUP" "$ROOT_DIR/files" "$ROOT_DIR/logs" || true
fi

if [ -n "${OMEKA_DB_ROOT_USER:-}" ]; then
  if command -v mysql >/dev/null 2>&1; then
    MYSQL_PWD="${OMEKA_DB_ROOT_PASSWORD:-}" \
      mysql -u "$OMEKA_DB_ROOT_USER" -h "$OMEKA_DB_HOST" \
      -e "CREATE DATABASE IF NOT EXISTS $OMEKA_DB_NAME; GRANT ALL PRIVILEGES ON $OMEKA_DB_NAME.* TO '$OMEKA_DB_USER'@'%' IDENTIFIED BY '$OMEKA_DB_PASSWORD'; FLUSH PRIVILEGES;" \
      || true
  fi
fi

echo "Omeka S config generated at config/database.ini"
echo "Next: open your site in the browser to run the installer."
