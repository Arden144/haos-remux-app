# Changelog

## 0.37.0.1

- Use a fourth numeric version component for packaging revisions so Home Assistant treats this release as newer than `0.37.0`.
- Retain Docker init and the wrapper pinned to upstream Remux `0.37.0`.

## 0.37.0-1

- Enable Docker init to forward termination signals to Remux and reap child processes.
- Build a minimal wrapper around the upstream Remux `0.37.0` image so app packaging revisions can be released independently.

## 0.37.0

- Update Remux to [v0.37.0](https://github.com/lostb1t/remux/releases/tag/v0.37.0).
- Add upstream stream filters for subtitles, bitrate, and cached availability.
- Include upstream fixes for playback version selection, subtitle matching, and library metadata.

## 0.35.1

- Initial Home Assistant app for Remux `v0.35.1`.
