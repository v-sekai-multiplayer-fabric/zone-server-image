#!/usr/bin/env bash
# Install the zone-server podman quadlet onto this host.
#
# Copies the quadlet unit(s) in ./quadlets into the system quadlet
# directory, creates the asset mountpoint, optionally pre-pulls the
# image, and reloads systemd.
#
# Service env file is NOT created here; deployments drop it at runtime:
#   /etc/zone-server/env
#
# Run as root:  sudo ./install.sh
# Skip the pre-pull with:  PULL=0 sudo -E ./install.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
QUADLET_DST=/etc/containers/systemd
PULL="${PULL:-1}"

[ "$(id -u)" -eq 0 ] || { echo "must run as root" >&2; exit 1; }

install -d -m 0755 "$QUADLET_DST"
install -m 0644 "$REPO_DIR"/quadlets/*.container "$QUADLET_DST"/

# Directory for the per-deployment env file referenced by the quadlet.
install -d -m 0755 /etc/zone-server
# Mountpoint for baked zone assets the server loads at boot.
install -d -m 0755 /var/lib/zone-server

if [ "$PULL" = "1" ]; then
  # Tag pinned in quadlets/zone-server.container.
  podman pull ghcr.io/v-sekai-multiplayer-fabric/zone-server:latest || \
    echo "Warning: zone-server pull failed; first start will pull on demand"
fi

systemctl daemon-reload
echo "Installed. Write /etc/zone-server/env, then: systemctl start zone-server.service"
