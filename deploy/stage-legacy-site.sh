#!/usr/bin/env bash
set -euo pipefail

# Add a second entry for the old site. Its port 80 configuration is untouched.
[[ "$EUID" == 0 ]] || { echo 'Run this script with sudo bash.' >&2; exit 1; }
source_config=/etc/nginx/sites-enabled/zgmf
available=/etc/nginx/sites-available/zgmf-8080
enabled=/etc/nginx/sites-enabled/zgmf-8080
test -f "$source_config"
for path in "$available" "$enabled"; do
  if [[ -e "$path" || -L "$path" ]]; then
    echo "Already exists; nothing changed: $path" >&2
    exit 1
  fi
done
[[ -z "$(ss -H -ltn 'sport = :8080')" ]] || { echo 'Port 8080 is already in use.' >&2; exit 1; }
nginx -t

# Exclusive creation ensures a pre-existing file cannot be overwritten.
python3 - "$source_config" "$available" <<'PY'
from pathlib import Path
import re
import sys
source, target = map(Path, sys.argv[1:])
text = source.read_text()
text, count = re.subn(r'(?m)^(\s*)listen\s+80\s*;', r'\1listen 8080;', text)
if count != 1:
    raise SystemExit('Expected exactly one listen 80 directive; nothing changed.')
# Preserve the public port when the application creates absolute URLs.
text = re.sub(r'proxy_set_header\s+Host\s+\$host\s*;', 'proxy_set_header Host $http_host;', text)
with target.open('x') as output:
    output.write(text)
PY
cleanup() {
  status=$?
  if (( status != 0 )); then
    rm -f -- "$enabled" "$available"
    if nginx -t; then systemctl reload nginx || true; fi
  fi
}
trap cleanup EXIT
ln -s "$available" "$enabled"
nginx -t
systemctl reload nginx
trap - EXIT

if command -v ufw > /dev/null && LC_ALL=C ufw status | grep -q '^Status: active'; then
  ufw allow 8080/tcp
fi

echo 'The old site still serves port 80 and now also serves port 8080.'
curl --noproxy '*' --silent --show-error --max-time 15 -o /dev/null \
  -w 'Old site on port 8080: HTTP %{http_code}\n' \
  -H 'Host: 81.70.80.234:8080' http://127.0.0.1:8080/
