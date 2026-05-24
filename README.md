# zone-server-image

V-Sekai zone-server VM image: headless Godot zone server runtime, run
as a podman quadlet on top of `linux-base-image`. Built once per
release via packer; consumed by the `infra` repo as the qcow2 for
`harvester_virtualmachine.zone_server`.

## What's in the image

Inherits everything from `linux-base-image` (AlmaLinux 9 + podman +
chrony + qemu-guest-agent), and adds:

- `/etc/containers/systemd/zone-server.container` — podman quadlet
  running `ghcr.io/v-sekai-multiplayer-fabric/zone-server`
- `/var/lib/zone-server` — mountpoint for baked zone assets the server
  loads at boot (populated by infra-side cloud-init or pulled from
  the baker's S3 output)

zone-server is `FROM zone-godot-runtime` (built by `godot-images`) and
runs the multiplayer zone server. The container image is pre-pulled
into podman's local store so first boot is fast. Tag pinned in
`configs/quadlets/zone-server.container`; bumping is a deliberate
edit + re-bake.

Listener ports are TBD pending the multiplayer transport choice
(WebTransport on UDP/443 like the gateway? a dedicated UDP port per
zone? something else?). The quadlet exposes nothing for now; uncomment
PublishPort once the protocol is settled.

## Build

CI on push to main + weekly schedule. Local:

```sh
cd packer
bash scripts/prepare-cidata.sh
packer init build.pkr.hcl
packer build build.pkr.hcl
ls ../output/
```

## Inheritance

Pin the parent version explicitly in `build.pkr.hcl`:

```hcl
variable "source_image_url" {
  default = "https://github.com/v-sekai-multiplayer-fabric/linux-base-image/releases/download/v0.1.0/linux-base-image.qcow2"
}
```
