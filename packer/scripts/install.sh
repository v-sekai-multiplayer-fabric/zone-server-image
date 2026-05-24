#!/usr/bin/env bash
# Provisioner: layers zone-server bits on top of linux-base-image.
# Runs as root via `sudo -E bash`.
set -euo pipefail

install -d -m 0755 /etc/containers/systemd
install -m 0644 /tmp/quadlets/*.container /etc/containers/systemd/
rm -rf /tmp/quadlets

# Mountpoint for baked zone assets; populated by infra-side cloud-init
# or pulled from the baker's S3 output.
install -d -m 0755 /var/lib/zone-server

# Pre-pull the zone-server image. Tag pinned in the quadlet; bumping
# is a deliberate change to this repo (and re-bake).
podman pull ghcr.io/v-sekai-multiplayer-fabric/zone-server:latest || \
  echo "Warning: zone-server:latest pull failed; first boot will pull on demand"

dnf clean all
cloud-init clean --logs
: > /etc/machine-id
rm -f /var/lib/dbus/machine-id || true
fstrim -av || true
