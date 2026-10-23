# Home Assistant App: Remux

Run [Remux](https://github.com/lostb1t/remux), a Jellyfin-compatible media server, on Home Assistant.

Home Assistant builds a minimal wrapper around the upstream multi-architecture Remux image. The app exposes port 3000 for the Remux dashboard and Jellyfin-compatible clients, mounts Home Assistant media read-only at `/media`, and enables Docker init for signal forwarding and child-process reaping.

See [DOCS.md](DOCS.md) for setup and account behavior.
