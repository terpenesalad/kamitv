# KamiTV 📺

A 2000s-Foxtel-styled, CRT-emulating **live-TV front-end** for your own media, packaged as a Windows desktop app.

KamiTV turns [Tunarr](https://tunarr.com) (fake "live" channels built from your Plex/Jellyfin library) and your Jellyfin server into a nostalgic digital-TV experience: a bright channel guide, channel surfing, number-pad channel entry, picture-in-picture preview, an On-Demand browser, and a full suite of CRT/scanline/chromatic-aberration effects.

Now shipped as a real **`KamiTV.exe`** — no browser flags, no `.bat` files. Because it runs in its own Electron window with web-security disabled, it talks to Tunarr, Jellyfin and custom streams directly (the old CORS headache is gone).

---

## ⬇️ Get the app

**Download the latest `KamiTV.exe` from the [Releases page](../../releases).** Two builds are produced:

- **`KamiTV Setup x.y.z.exe`** — installer (adds a Start-menu + desktop shortcut).
- **`KamiTV-portable-x.y.z.exe`** — single portable exe, no install.

> The `.exe` is built automatically on GitHub's Windows servers (see *Building* below), so a fresh one appears on every release.

---

## 🧩 What you still need

KamiTV is the *front-end*. It plays channels from:

- **[Tunarr](https://tunarr.com)** running (default `http://localhost:8000`) — your live channels.
- **[Jellyfin](https://jellyfin.org)** (optional) — for the On-Demand tab.
- **[FFmpeg](https://www.gyan.dev/ffmpeg/builds/)** in `C:\ffmpeg\bin` — used by Tunarr, and by the optional stream relay. Use the **release** build (`ffmpeg-release-essentials.zip`), not the git/master build.

Start Tunarr, then launch KamiTV. Point it at Tunarr/Jellyfin from **Settings** (`s`) inside the app.

---

## ⌨️ Hotkeys

| Key | Action |
|-----|--------|
| `↑` / `↓` / wheel | Change channel |
| `0–9` then `Enter` | Jump to channel number |
| `g` | TV Guide |
| `o` | On Demand |
| `i` | Info banner → again for full synopsis (←/→ to browse) |
| `t` | Subtitles |
| `space` | Play/pause (On Demand) |
| `←` / `→` | Seek (OD) / scroll hours (Guide) / browse info (card) |
| `−` / `=` | Volume · `m` Mute |
| `z` / middle-click | Screen fit · `c` CRT effects |
| `s` | Settings · `f` / double-click | Fullscreen (also F11) |

---

## ⚙️ Optional config

Drop a `config.json` next to `KamiTV.exe` (copy `config.example.json`) to customise:

```json
{
  "tunarrUrl": "http://localhost:8000",
  "startFullscreen": false,
  "tunarrExe": "C:\\Path\\to\\tunarr.exe",
  "tunarrArgs": []
}
```

- **`tunarrUrl`** — where Tunarr lives (if not the default).
- **`startFullscreen`** — open in kiosk/fullscreen.
- **`tunarrExe`** — if set, KamiTV **auto-launches Tunarr** when it starts and closes it on exit, so the two feel like one app. (KamiTV doesn't bundle Tunarr — Tunarr is its own server with FFmpeg; this just starts your existing copy for you.)

---

## 🔧 Stream relay (HEVC / AC3 / blocked streams)

Some live streams won't play in any browser engine — **HEVC/H.265 video**, **AC3 audio**, or feeds that **403 / need a Referer**. `tools/KamiTV Stream Relay.bat` uses FFmpeg to pull them server-side and re-serve as H.264/AAC on `localhost`; add the resulting `http://127.0.0.1:<port>/kami.ts` as a KamiTV custom channel. See the comments in that file.

---

## 🛠️ Building the .exe yourself

You don't have to — GitHub builds it. But to build locally on Windows:

```bash
npm install
npm run dist      # outputs installer + portable exe to dist/
```

To run in dev mode (any OS with Node):

```bash
npm install
npm start
```

### How the automatic build works
`.github/workflows/build.yml` runs on a **Windows runner**:
- every push to `main` → uploads the `.exe` as a downloadable **Actions artifact**;
- pushing a **version tag** (`git tag v1.0.0 && git push --tags`) → publishes a **Release** with the `.exe` attached.

So after you push this repo to GitHub, go to the **Actions** tab to grab a build, or tag a version to cut a Release.

---

## 📦 Repo layout

```
main.js                     Electron main process (window, CORS-off, optional Tunarr launch)
package.json                deps + electron-builder config
app/kamitv.html             the whole front-end (self-contained)
tools/KamiTV Stream Relay.bat   FFmpeg relay for HEVC/AC3/blocked streams
config.example.json         copy to config.json to customise
.github/workflows/build.yml CI that builds the Windows .exe
```

---

## ⚖️ License & disclaimer

[MIT](LICENSE). KamiTV is a front-end for **your own** media and for **publicly, legally available** streams (e.g. free-to-air feeds listed by [iptv-org](https://github.com/iptv-org/iptv)). It does not provide, host, or endorse pirated or subscription-circumventing streams. Not affiliated with Foxtel, Tunarr or Jellyfin; the retro styling is an homage.
