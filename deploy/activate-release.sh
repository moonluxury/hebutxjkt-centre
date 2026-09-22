#!/usr/bin/env bash
set -euo pipefail

# Executed as hebut-deploy after files are fully uploaded to a new directory.
site_root=/var/www/hebutxjkt-centre
version="${1:?A release ID is required}"
[[ "$version" =~ ^[a-f0-9]{40}-[0-9]+-[0-9]+$ ]] || { echo 'Invalid release ID.' >&2; exit 1; }
release="$site_root/releases/$version"
test -d "$release"
test ! -L "$release"
[[ "$(realpath "$release")" == "$release" ]] || { echo 'Unexpected release path.' >&2; exit 1; }
for path in index.html js/main.js js/data.js js/team.js styles/index.css styles/overlay.css styles/ui.css; do
  test -s "$release/$path"
done
test -d "$release/assets"
[[ -z "$(find "$release" -type l -print -quit)" ]] || { echo 'Release contains a symlink.' >&2; exit 1; }
[[ "$(cat "$release/deployment-version.txt")" == "$version" ]] || { echo 'Release marker mismatch.' >&2; exit 1; }

exec 9>"$site_root/.deploy.lock"
flock -w 60 9
previous=''
if [[ -L "$site_root/current" ]]; then
  previous=$(readlink "$site_root/current")
  [[ "$previous" =~ ^releases/[a-zA-Z0-9-]+$ ]] || { echo 'Unexpected current release target.' >&2; exit 1; }
elif [[ -e "$site_root/current" ]]; then
  echo 'current must be a symlink, not a directory.' >&2
  exit 1
fi

link="$site_root/.current-$version"
ln -s "releases/$version" "$link"
mv -Tf "$link" "$site_root/current"

healthy=false
for attempt in 1 2 3; do
  served=$(curl --noproxy '*' --fail --silent --show-error --max-time 10 \
    -H 'Host: 81.70.80.234' -H 'Cache-Control: no-cache' \
    "http://127.0.0.1/deployment-version.txt?release=$version") || served=''
  if [[ "$served" == "$version" ]] && curl --noproxy '*' --fail --silent --show-error --max-time 10 \
    -H 'Host: 81.70.80.234' http://127.0.0.1/ > /dev/null; then
    healthy=true
    break
  fi
  sleep 2
done

if [[ "$healthy" != true ]]; then
  if [[ -n "$previous" ]]; then
    ln -s "$previous" "$link"
    mv -Tf "$link" "$site_root/current"
  else
    rm -- "$site_root/current"
  fi
  echo 'Website check failed; restored the previous release selection.' >&2
  exit 1
fi
echo "Verified release $version. Previous releases are retained."
