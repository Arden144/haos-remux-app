# Remux

Remux is a Jellyfin-compatible media server. Configure content sources, libraries, and Remux users in the Remux dashboard.

## Network

- **Dashboard**: use `http://<home-assistant-ip>:3000/admin/` to configure Remux.
- **Jellyfin clients**: use `http://<home-assistant-ip>:3000/web/` in applications such as Jellyfin for Android, Swiftfin, or Infuse.

If port 3000 is already in use, change its host port in the app's **Network** settings and use that port in dashboard and client URLs.

Remux owns its authentication. Home Assistant does not authenticate direct dashboard or Jellyfin client connections.

## Storage

- `/data` is persistent, writable Remux state managed by Home Assistant. It contains the Remux database, logs, metadata, torrent data, users, and playback history.
- `/media` is a read-only mount of Home Assistant's media directory. Configure local-file sources in Remux with paths below `/media`.

Do not configure Remux to write media under `/media`; import or create files with another Home Assistant service instead.

## Accounts

Manage Remux users in Remux. Home Assistant accounts are not synchronized with Remux accounts. This preserves authentication for ordinary Jellyfin clients, which do not have a Home Assistant browser session.

See [`../RESEARCH.md`](../RESEARCH.md) for the implementation constraints and the work required for Home Assistant-owned Remux accounts.

## Upgrades

App version `0.37.0.1` uses Remux `0.37.0`. The fourth dot-separated number is a packaging revision, supported by Home Assistant's version comparator, so packaging fixes can be released independently of upstream Remux releases. This is a four-component version rather than strict SemVer; unlike a hyphen suffix, it sorts after the corresponding upstream version.

Home Assistant builds a minimal wrapper from `Dockerfile`, which pins `ghcr.io/lostb1t/remux:0.37.0`. This downloads the upstream image without compiling Remux. Updating upstream Remux requires changing that image tag and releasing a new app version.

Docker init is enabled to forward termination signals to Remux and reap child processes. It does not add application-level graceful shutdown handling to Remux.
