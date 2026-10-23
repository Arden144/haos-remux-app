# Home Assistant App Research

Research completed 2026-10-02 against the current Home Assistant developer documentation and the repositories named below. No source repositories were cloned; GitHub's API and raw files were sufficient and no local dependency storage was added.

## Current Conventions

- An app repository has a root `repository.yaml`; each app has its own directory and `config.yaml`.
- `config.yaml` declares the app identity, supported architectures, image, storage mounts, network ports, ingress, watchdog, startup behavior, and any validated options.
- Prebuilt multi-architecture images are preferred. The `image` field should name a generic OCI image with a multi-architecture manifest; `version` selects its image tag.
- Containers should remain protected. Avoid host networking, devices, capabilities, and Home Assistant/Supervisor API access unless a required feature cannot work without them. Mount data read-only when writes are unnecessary.
- `/data` is persistent writable app state. Home Assistant path mappings are explicit; `media` is mounted at `/media`.
- Ingress is appropriate only when the upstream web application supports it. A direct port remains appropriate for software that cannot use Home Assistant Ingress, such as Jellyfin clients.
- `init: false` is required for an image that supplies its own command rather than the Home Assistant S6 init system.
- Configuration and port labels belong in `translations/en.yaml` when the app exposes them in the UI.

Sources:

- [App configuration](https://developers.home-assistant.io/docs/apps/configuration/)
- [App repository](https://developers.home-assistant.io/docs/apps/repository/)
- [Publishing](https://developers.home-assistant.io/docs/apps/publishing/)
- [Security](https://developers.home-assistant.io/docs/apps/security/)
- [Communication](https://developers.home-assistant.io/docs/apps/communication/)
- [Official app example](https://github.com/home-assistant/apps-example)

## Comparable Apps Reviewed

| App | Relevant pattern | Applied here |
| --- | --- | --- |
| [Mosquitto](https://github.com/home-assistant/addons/tree/master/mosquitto) | Requests `auth_api` only because its MQTT authentication implementation uses it; exposes a service and starts as a system component. | Remux has no such integration, so this app does not request `auth_api` or define services. |
| [Matter Server](https://github.com/home-assistant/addons/tree/master/matter_server) | Uses Ingress, a health-oriented service role, a narrow persistent app-config mount, and host access only where Matter requires it. | Remux gets persistent `/data`, but no host network, D-Bus, or IPC because it does not require them. |
| [Tailscale](https://github.com/hassio-addons/app-tailscale) | Explicitly declares its exceptional host network, D-Bus, TUN device, and capabilities. | No exceptional access is requested: Remux works on the protected app network. |
| [Zigbee2MQTT](https://github.com/zigbee2mqtt/hassio-zigbee2mqtt) | Uses a published image, Ingress, clearly scoped mounts, service declarations, and hardware access only for the radio. | Uses a published multi-architecture Remux image and a read-only `media` mount; no hardware or service dependency applies. |
| [Music Assistant](https://github.com/music-assistant/home-assistant-addon) | Maintains a dedicated app repository around a media server and separates stable, beta, and development variants. | This repository starts with a single stable Remux app. A separate nightly app should be added only after a supported Remux nightly image and update policy are established. |

## Remux Runtime Review

Remux release `v0.35.1` publishes `ghcr.io/lostb1t/remux:0.35.1` as an OCI image index with Linux `amd64` and `arm64` manifests. Its image declares:

- Persistent data at `/data`, including SQLite state, logs, and torrent data.
- HTTP/Jellyfin API on port `3000`.
- `GET /health` for health checks.
- Jellyfin FFmpeg included in the image.

The app pins that release in `remux/config.yaml`, maps Home Assistant media read-only at `/media`, exposes the Remux dashboard at `/admin/`, publishes TCP 3000 for Jellyfin clients, and checks `/health` through the Supervisor watchdog. Ingress is deliberately disabled: Remux performs absolute redirects from `/` to its Jellyfin client UI at `/web/`, which cannot retain the Home Assistant ingress prefix. `legacy: true` is intentional: the upstream image is not a Home Assistant-built image and does not provide Home Assistant image labels. It allows Supervisor to use this repository's app configuration while retaining the upstream prebuilt image.

Sources:

- [Remux release v0.35.1](https://github.com/lostb1t/remux/releases/tag/v0.35.1)
- [Remux Dockerfile](https://github.com/lostb1t/remux/blob/v0.35.1/docker/Dockerfile)
- [Remux README](https://github.com/lostb1t/remux/tree/v0.35.1)

## Account Management Decision

Home Assistant-managed Remux accounts are **not implemented**. The upstream server authenticates `POST /Users/AuthenticateByName` against a Remux-owned SQLite `users` table. It creates its own Argon2 password hashes, device rows, and Jellyfin access tokens. User creation, deletion, passwords, policies, and per-user playback state are all implemented directly against that database.

Home Assistant's `auth_api` is intended for an app that already implements Home Assistant's user-backend protocol. Remux currently has no Home Assistant authentication client, no trusted ingress-header identity mapping, and no lifecycle synchronization API. Enabling `auth_api` in this app would grant access that the upstream process cannot use.

A real implementation requires upstream Remux changes, not only app configuration:

1. Add a Home Assistant authentication provider that validates credentials through the Supervisor auth API.
2. Define deterministic user provisioning, deletion, rename, role, and password-change behavior.
3. Map immutable Home Assistant user IDs to Remux user IDs and preserve existing Jellyfin tokens, devices, and playback records.
4. Decide how native Jellyfin clients authenticate, because they cannot send a Home Assistant browser session or Ingress identity headers.
5. Test Home Assistant account changes and token revocation end-to-end.

Remux authentication remains the source of truth for both its dashboard and media clients. Until an upstream-supported identity provider exists, this is the only behavior that preserves Jellyfin client compatibility without maintaining a fork.

Relevant upstream code:

- [Authentication and session extraction](https://github.com/lostb1t/remux/blob/v0.35.1/crates/remux-server/src/db/auth.rs)
- [Local user model and password verification](https://github.com/lostb1t/remux/blob/v0.35.1/crates/remux-server/src/db/user.rs)
- [Jellyfin authentication and user endpoints](https://github.com/lostb1t/remux/blob/v0.35.1/crates/remux-server/src/api/users.rs)
