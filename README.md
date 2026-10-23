# Remux Home Assistant App

Home Assistant app repository for [Remux](https://github.com/lostb1t/remux), a Jellyfin-compatible media server.

## Install

[![Add this app repository to Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FArden144%2Fhaos-remux-app)

Use the button above to add the repository, or follow these steps on Home Assistant OS:

1. In Home Assistant, open **Settings** > **Apps** > **Install app** (or **Add-ons** > **Add-on Store** on older versions).
2. Select the overflow menu, choose **Repositories**, and add `https://github.com/Arden144/haos-remux-app`.
3. Install **Remux** and start it.
4. Open the Remux dashboard at `http://<home-assistant-ip>:3000/admin/`, or connect a Jellyfin-compatible client to `http://<home-assistant-ip>:3000/web/`.

Supports **aarch64** and **amd64**. Remux state is stored persistently in `/data`, and Home Assistant media is available read-only at `/media`.

See [`remux/DOCS.md`](remux/DOCS.md) for storage, client, and account details. [`RESEARCH.md`](RESEARCH.md) records the Home Assistant convention review and the account-management decision.
