#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="/var/www/html"

: "${OMEKA_DB_HOST:=db}"
: "${OMEKA_DB_NAME:=omekatest}"
: "${OMEKA_DB_USER:=omeka}"
: "${OMEKA_DB_PASSWORD:=omeka}"

cat > "$ROOT_DIR/config/database.ini" <<EOF
user     = "$OMEKA_DB_USER"
password = "$OMEKA_DB_PASSWORD"
dbname   = "$OMEKA_DB_NAME"
host     = "$OMEKA_DB_HOST"
EOF

mkdir -p "$ROOT_DIR/files" "$ROOT_DIR/logs"
chown -R www-data:www-data "$ROOT_DIR/files" "$ROOT_DIR/logs" || true

exec "$@"
