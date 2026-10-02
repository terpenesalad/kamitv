# KamiTV 📺

A 2000s-Foxtel-styled, CRT-emulating **full-screen live-TV front-end** for your own media library.

KamiTV turns [Tunarr](https://tunarr.com) (fake "live" channels built from your Plex/Jellyfin library) and your Jellyfin server into a nostalgic digital-TV experience: a bright channel guide, channel surfing, an on-screen channel-number entry, picture-in-picture preview, an On-Demand browser, and a full suite of CRT/scanline/chromatic-aberration effects — all in a single HTML file.

> It's the dumb TV you grew up with, playing the stuff *you* actually own. Mindless by design.

---

## ✨ Features

- **Live channel surfing** — arrow keys, mouse wheel, or type a channel number (`5` → `52` → `523`) and hit Enter.
- **Foxtel-style TV guide** (`g`) — dark EPG, gold "now playing" highlight, scroll ±12h with the arrows, infinite channel scrolling, and a **picture-in-picture** of the current channel in the corner.
- **On Demand** (`o`) — browse your Jellyfin Movies & TV libraries, with a proper transport bar (play/pause, scrub, skip).
- **Info card** (`i` twice) — a bottom info bar with the show/movie synopsis, season/episode; use ←/→ to read ahead through the schedule or across episodes.
- **Subtitles** (`t`) — English auto-on for On-Demand (if present), remembered across videos, burned in by Jellyfin.
- **CRT emulation** — scanlines, aperture-grille mask, bloom, chromatic aberration (+ an **extreme** broken-CRT mode), vignette, flicker, rolling hum bar. Fully tweakable; save your own default.
- **Custom channels** — add any direct HLS (`.m3u8`) / TS stream (e.g. free-to-air news) alongside your Tunarr channels, with editable number/name/logo.
- **Stream relay** (`KamiTV Stream Relay.bat`) — plays streams the browser normally can't: HEVC/AC3 codecs, or CORS/403/Referer-gated feeds, by transcoding them to H.264/AAC on localhost via FFmpeg.
- **Windowed or kiosk** — a movable/resizable window, or a locked full-screen TV mode. Double-click the picture to toggle full-screen.

---

## 🧩 Requirements

- **Windows** (the launchers are `.bat`; the HTML app itself is cross-platform).
- **[Google Chrome](https://www.google.com/chrome/)** — the launchers run KamiTV as a Chrome app window.
- **[Tunarr](https://tunarr.com)** running (default `http://localhost:8000`) for the live channels.
- **[Jellyfin](https://jellyfin.org)** (optional) for the On-Demand tab.
- **[FFmpeg](https://www.gyan.dev/ffmpeg/builds/)** in `C:\ffmpeg\bin` — needed by Tunarr, and by the relay. **Use the _release_ build (`ffmpeg-release-essentials.zip`), not the git/master build** (see Troubleshooting).

---

## 🚀 Quick start

1. Download/clone this repo (or grab the zip from [Releases](../../releases)).
2. Put the folder wherever you like, e.g. `C:\KamiTV\`.
3. Make sure **Tunarr** is running and has at least one channel.
4. Double-click **`Launch KamiTV.bat`** (windowed) or **`Launch KamiTV (TV Mode).bat`** (full-screen kiosk).
5. Click the power splash → you're watching TV.

The launcher finds `kamitv.html` sitting next to it automatically, so you don't need to edit any paths.

> **Why the launcher (not just opening the HTML)?** Browsers block a local page from fetching video off other servers (CORS). The launcher starts Chrome with `--disable-web-security` in an isolated profile so KamiTV can reach Tunarr, Jellyfin and custom streams. Opening `kamitv.html` directly will load the UI but fail to play anything.

### Pointing it at Tunarr / Jellyfin

- **Tunarr:** defaults to `http://localhost:8000`. If yours differs, open Settings (`s`) and set the URL, or launch with `?url=http://HOST:8000`.
- **Jellyfin (On Demand):** open Settings (`s`) → On Demand, and enter your Jellyfin URL + an API key (Jellyfin → Dashboard → API Keys).

---

## ⌨️ Hotkeys

| Key | Action |
|-----|--------|
| `↑` / `↓` / wheel | Change channel |
| `0–9` then `Enter` | Jump to channel number |
| `g` | TV Guide |
| `o` | On Demand |
| `i` | Info banner → press again for full synopsis (←/→ to browse) |
| `t` | Subtitles on/off |
| `space` | Play/pause (On Demand) |
| `←` / `→` | Seek (On Demand) / scroll hours (Guide) / browse info (card) |
| `−` / `=` | Volume down / up |
| `m` | Mute |
| `z` / middle-click | Screen fit (fill / letterbox / stretch) |
| `c` | CRT effects on/off |
| `s` | Settings |
| `f` / double-click | Fullscreen |

---

## 🔧 The Stream Relay (HEVC / AC3 / blocked streams)

Some streams won't play in any browser — **HEVC/H.265 video**, **AC3 audio**, or feeds that **403 / need a Referer / block CORS**. `KamiTV Stream Relay.bat` fixes these by having FFmpeg pull the stream server-side and re-serve it as browser-friendly H.264/AAC on `localhost`.

1. Edit the `DEFINE STREAMS` block — add a line per stream with a **unique port**.
2. Choose an encoder: `A` = CPU H.264 (always works), `B` = Nvidia GPU, `C` = copy video (audio-only fix, lightest).
3. For 403-gated channels (e.g. SBS), set a `REFn` Referer.
4. Run the relay, then add a KamiTV custom channel pointing at `http://127.0.0.1:<port>/kami.ts`.

---

## 🛠️ Troubleshooting

**Guide shows programs but nothing plays / "Can't load stream".**
Your media drive most likely changed drive letter (common after unplugging a USB/external drive). Tunarr's guide comes from its database, but the files are now at a path it can't reach. Fix: **Disk Management → Change Drive Letter** back to the original, restart Jellyfin/Tunarr. Prevent it by assigning the drive a fixed high letter (e.g. `Z:`).

**"FFmpeg not found" / "ffmpeg version unknown is unrecognized".**
You downloaded the **git/master** FFmpeg build (version string like `2026-06-15-git-…`). Tunarr wants a real release. Download **`ffmpeg-release-essentials.zip`** from [gyan.dev](https://www.gyan.dev/ffmpeg/builds/), extract to `C:\ffmpeg`, and point Tunarr's FFmpeg + FFprobe paths at `C:\ffmpeg\bin`. Minimum FFmpeg 6.1, recommended 7.1+.

**"Codec not supported by browser (HEVC / AC3)".**
Browser can't decode it. Route the stream through the relay (encoder `A`, or `C` if only the audio is AC3).

**"Can't load stream — CORS/blocked".**
Make sure you launched via the `.bat` (not by opening the HTML). If it still fails, the stream is 403/Referer/token-gated — route it through the relay with a `REF` Referer, or the token has expired.

**On Demand is empty.**
The API key's account needs library access. KamiTV tries each Jellyfin user automatically; if still empty, check the key belongs to an account that can see your Movies/TV libraries.

---

## 📦 What's in here

```
kamitv.html                  The whole app (self-contained)
Launch KamiTV.bat            Windowed launcher
Launch KamiTV (TV Mode).bat  Full-screen kiosk launcher
KamiTV Stream Relay.bat      FFmpeg relay for HEVC/AC3/blocked streams
```

---

## ⚖️ License & disclaimer

Released under the [MIT License](LICENSE).

KamiTV is a front-end for **your own** media and for **publicly, legally available** streams (e.g. free-to-air broadcaster feeds listed by [iptv-org](https://github.com/iptv-org/iptv)). It does not provide, host, or endorse any pirated or subscription-circumventing streams. What you point it at is on you.

Not affiliated with Foxtel, Tunarr, Jellyfin, or any broadcaster. "Foxtel" and channel names/logos belong to their respective owners; the retro styling is an homage.
