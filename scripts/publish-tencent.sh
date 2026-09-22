#!/usr/bin/env bash
set -euo pipefail

# Run on the GitHub runner; SSH uses a dedicated account without sudo.
[[ "${GITHUB_REF:-}" == refs/heads/main ]] || { echo 'Only main can deploy.' >&2; exit 1; }
: "${TENCENT_SSH_KEY:?Set the TENCENT_SSH_KEY repository secret}"
: "${TENCENT_KNOWN_HOSTS:?Set the TENCENT_KNOWN_HOSTS repository secret}"
: "${RUNNER_TEMP:?Run this script in GitHub Actions}"

version="${GITHUB_SHA:?}-${GITHUB_RUN_ID:?}-${GITHUB_RUN_ATTEMPT:?}"
[[ "$version" =~ ^[a-f0-9]{40}-[0-9]+-[0-9]+$ ]] || { echo 'Invalid release ID.' >&2; exit 1; }
for path in index.html js/main.js js/data.js js/team.js styles/index.css styles/overlay.css styles/ui.css; do
  test -s "_site/$path"
done
test -d _site/assets
printf '%s\n' "$version" > _site/deployment-version.txt

umask 077
ssh_dir=$(mktemp -d "$RUNNER_TEMP/tencent-ssh.XXXXXX")
cleanup() {
  rm -f -- "$ssh_dir/key" "$ssh_dir/known_hosts" "$ssh_dir/config"
  rmdir -- "$ssh_dir"
}
trap cleanup EXIT
printf '%s\n' "$TENCENT_SSH_KEY" | tr -d '\r' > "$ssh_dir/key"
printf '%s\n' "$TENCENT_KNOWN_HOSTS" | tr -d '\r' > "$ssh_dir/known_hosts"
unset TENCENT_SSH_KEY TENCENT_KNOWN_HOSTS
ssh-keygen -y -P '' -f "$ssh_dir/key" > /dev/null
ssh-keygen -F 81.70.80.234 -f "$ssh_dir/known_hosts" > /dev/null
cat > "$ssh_dir/config" <<EOF
Host hebut-production
  HostName 81.70.80.234
  Port 22
  User hebut-deploy
  IdentityFile "$ssh_dir/key"
  UserKnownHostsFile "$ssh_dir/known_hosts"
  StrictHostKeyChecking yes
  IdentitiesOnly yes
  BatchMode yes
  ConnectTimeout 15
  ServerAliveInterval 15
  ServerAliveCountMax 3
EOF

release="/var/www/hebutxjkt-centre/releases/$version"
ssh -F "$ssh_dir/config" hebut-production "test -d /var/www/hebutxjkt-centre/releases && mkdir '$release'"
printf -v rsync_ssh 'ssh -F %q' "$ssh_dir/config"
rsync -rtpz --chmod=D755,F644 -e "$rsync_ssh" _site/ "hebut-production:$release/"
ssh -F "$ssh_dir/config" hebut-production "bash -s -- '$version'" < deploy/activate-release.sh
printf 'Published %s to http://81.70.80.234/\n' "$version"
