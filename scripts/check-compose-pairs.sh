#!/bin/sh
# Verifies that each <service>.docker.yml / <service>.qnap.yml pair only differs by the
# QNAP-only network block (qnet-dhcp-eth0-6d6da6 external network + mac_address), so the two
# variants don't silently drift apart (e.g. image tag or volume changed in only one of them).
# Usage: scripts/check-compose-pairs.sh [service-dir ...]  (defaults to all dirs with a pair)
set -eu

repo_root=$(cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

# Lines that are expected to exist only in the *.qnap.yml file of a pair.
strip_qnap_only_lines() {
  grep -v -E '^(# QNAP |networks:|  qnet-dhcp-eth0-6d6da6:|    external: true|      qnet-dhcp-eth0-6d6da6:|        mac_address:)' "$1"
}

status=0

if [ "$#" -gt 0 ]; then
  dirs="$*"
else
  dirs=$(find . -mindepth 1 -maxdepth 1 -type d -name '[!.]*')
fi

for dir in $dirs; do
  service=$(basename "$dir")
  docker_file="$dir/$service.docker.yml"
  qnap_file="$dir/$service.qnap.yml"

  [ -f "$docker_file" ] || continue
  [ -f "$qnap_file" ] || continue

  docker_stripped=/tmp/compose-pair-docker.$$
  qnap_stripped=/tmp/compose-pair-qnap.$$
  strip_qnap_only_lines "$docker_file" >"$docker_stripped"
  strip_qnap_only_lines "$qnap_file" >"$qnap_stripped"

  if ! diff -u "$docker_stripped" "$qnap_stripped" >/tmp/compose-pair-diff.$$; then
    echo "Drift detected between $docker_file and $qnap_file (beyond the QNAP network block):"
    cat /tmp/compose-pair-diff.$$
    status=1
  fi
  rm -f "$docker_stripped" "$qnap_stripped" /tmp/compose-pair-diff.$$
done

exit $status
