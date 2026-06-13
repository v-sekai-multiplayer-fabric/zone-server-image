# zone-server-quadlet

Podman [quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
source for zone-server — the headless Godot multiplayer zone runtime
(`FROM zone-godot-runtime`). Run by systemd on an AlmaLinux host.

This repo is the source of truth for the unit; it is installed onto a
host rather than baked into a VM image.

## Layout

- `quadlets/zone-server.container` — the quadlet. Tag pinned here.
  Listener port is TBD pending the multiplayer transport choice;
  uncomment `PublishPort` once it's settled.
- `install.sh` — installs the unit, creates `/var/lib/zone-server`
  (baked zone assets the server loads at boot), pre-pulls the image,
  reloads systemd.

## Install

```sh
sudo ./install.sh
# write /etc/zone-server/env if the deployment needs it
sudo systemctl start zone-server.service
```

## Configuration (per-deployment, NOT in this repo)

- `/etc/zone-server/env` — per-deployment config.
- `/var/lib/zone-server` — baked zone assets (populated by deployment
  cloud-init or pulled from the baker's S3 output).

## CI

`.github/workflows/lint.yml` validates the unit via podman's systemd
generator on every push/PR.
