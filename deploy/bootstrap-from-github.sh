#!/usr/bin/env bash
# First installation from the verified, currently flattened public repository.
set -euo pipefail
umask 022
[[ "$EUID" == 0 ]] || { echo 'Run with sudo bash.' >&2; exit 1; }

commit=a09bf5a6cefdda03c20a0b5bb67935fbe374473d
site=/var/www/hebutxjkt-centre
available=/etc/nginx/sites-available/hebutxjkt-centre
enabled=/etc/nginx/sites-enabled/hebutxjkt-centre
old=/etc/nginx/sites-enabled/zgmf
version="bootstrap-$commit"

for path in "$site" "$available" "$enabled"; do
  if [[ -e "$path" || -L "$path" ]]; then
    echo "Already exists; stopped without replacing it: $path" >&2
    exit 1
  fi
done
test -f "$old" || { echo 'Old homepage configuration not found; stopped.' >&2; exit 1; }
test -f /etc/nginx/sites-enabled/zgmf-8080 || { echo 'Set up the old site on port 8080 first.' >&2; exit 1; }
nginx -t
curl --noproxy '*' --fail --silent --show-error --max-time 15 \
  -H 'Host: 81.70.80.234:8080' http://127.0.0.1:8080/ > /dev/null

work=$(mktemp -d /tmp/hebut-download.XXXXXX)
echo 'Downloading the new website from GitHub...'
curl --fail --location --retry 2 --connect-timeout 15 --max-time 180 \
  "https://codeload.github.com/moonluxury/hebutxjkt-centre/zip/$commit" -o "$work/source.zip"
python3 -m zipfile -t "$work/source.zip"
python3 -m zipfile -e "$work/source.zip" "$work"
source_dir="$work/hebutxjkt-centre-$commit"
release="$site/releases/$version"

# Validate all inputs before creating the new site's directory.
for file in index.html main.js data.js team.js index.css overlay.css ui.css \
  member-01.jpg member-02.png member-03.png member-04.png \
  member-placeholder.svg qin-boyuan.jpg wang-shuaixuan.jpg; do
  test -s "$source_dir/$file"
done
install -d -m 755 "$site" "$site/releases" "$release" \
  "$release/js" "$release/styles" "$release/assets" "$release/assets/team"
install -m 644 "$source_dir/index.html" "$release/index.html"
for file in main.js data.js team.js; do install -m 644 "$source_dir/$file" "$release/js/"; done
for file in index.css overlay.css ui.css; do install -m 644 "$source_dir/$file" "$release/styles/"; done
for file in member-01.jpg member-02.png member-03.png member-04.png \
  member-placeholder.svg qin-boyuan.jpg wang-shuaixuan.jpg; do
  install -m 644 "$source_dir/$file" "$release/assets/team/"
done
printf '%s\n' "$version" > "$release/deployment-version.txt"
ln -s "releases/$version" "$site/current"

backup=$(mktemp -d /etc/nginx/hebut-backup.XXXXXX)
cp -L -- "$old" "$backup/zgmf-original.conf"
cat > "$backup/new-site.conf" <<'NGINX'
server {
    listen 80;
    server_name 81.70.80.234;
    root /var/www/hebutxjkt-centre/current;
    index index.html;
    add_header Cache-Control "no-cache" always;
    location / { try_files $uri $uri/ =404; }
    location ~ /\. { deny all; }
}
NGINX
echo "Old configuration backup: $backup"

moved=false
created=false
linked=false
rollback() {
  status=$?
  if (( status != 0 )); then
    set +e
    if [[ "$linked" == true ]]; then rm -- "$enabled"; fi
    if [[ "$moved" == true && ! -e "$old" && ! -L "$old" ]]; then mv -T -- "$backup/zgmf-entry" "$old"; fi
    if [[ "$created" == true ]]; then rm -- "$available"; fi
    if nginx -t; then systemctl reload nginx || true; fi
    echo "Switch failed; attempted to restore the old homepage. Backup: $backup" >&2
  fi
}
trap rollback EXIT
ln -- "$backup/new-site.conf" "$available"
created=true
mv -T -- "$old" "$backup/zgmf-entry"
moved=true
ln -s "$available" "$enabled"
linked=true
nginx -t
systemctl reload nginx

verified=false
for attempt in 1 2 3; do
  marker=$(curl --noproxy '*' --fail --silent --show-error --max-time 15 \
    -H 'Host: 81.70.80.234' "http://127.0.0.1/deployment-version.txt?check=$version") || marker=''
  if [[ "$marker" == "$version" ]]; then verified=true; break; fi
  sleep 2
done
[[ "$verified" == true ]]
curl --noproxy '*' --fail --silent --show-error --max-time 15 \
  -H 'Host: 81.70.80.234' http://127.0.0.1/ > /dev/null
curl --noproxy '*' --fail --silent --show-error --max-time 15 \
  -H 'Host: 81.70.80.234:8080' http://127.0.0.1:8080/ > /dev/null
trap - EXIT
echo 'New website: http://81.70.80.234/'
echo 'Old website: http://81.70.80.234:8080/'
echo "SUCCESS. Keep the backup: $backup"
