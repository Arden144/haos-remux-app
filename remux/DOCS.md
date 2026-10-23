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

This app pins Remux `0.35.1`. Updating Remux requires a corresponding app release that changes `version`; Home Assistant will then pull the matching versioned image tag.
