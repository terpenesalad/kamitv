# KamiTV — project brief

Context for any Claude session working on KamiTV. Keep it current when something important changes.
(This repo is public: never put API keys, IP addresses, emails or other personal details in this file.)

## What KamiTV is

A Windows desktop app (Electron) that turns a home media server into a 2000s Foxtel-style TV:
channel surfing, a dark EPG with gold highlights, number-pad channel entry, a picture-in-picture
preview in the guide, an On Demand browser, and CRT effects (scanlines, aperture mask, bloom,
chromatic aberration incl. an "extreme" broken-CRT mode, vignette, flicker, hum bar).

- Live channels come from **Tunarr**; On Demand comes straight from **Jellyfin**.
- Brand: "KamiTV" wordmark with "mindless" subtext. Icon: minimal mustard-yellow retro TV on a dark tile.
- Owner's machine: Windows 11, NVIDIA GTX 1660 SUPER, Sydney, Australia.

## Repo layout

```
main.js                       Electron main: window, webSecurity off (no CORS), autoplay, optional config.json
package.json                  electron + electron-builder config (NSIS installer + portable, icon build/icon.ico)
app/kamitv.html               the entire front-end in one file (HTML/CSS/JS, fonts embedded)
build/icon.ico, icon.png      app icon
tools/KamiTV Stream Relay.bat FFmpeg relay for streams the browser can't play
config.example.json           copy to config.json next to the exe: tunarrUrl, startFullscreen, tunarrExe (auto-launch)
legacy/                       old Chrome --disable-web-security .bat launchers (superseded)
.github/workflows/build.yml   CI: build + publish Release
```

## Releasing

- Push to `main` -> GitHub Actions (windows-latest) -> `electron-builder --win` -> creates Release
  `v1.0.<run_number>` (marked latest) with `KamiTV.Setup.1.0.0.exe` + `KamiTV-portable-1.0.0.exe`.
- The filename says 1.0.0 because package.json's version isn't bumped; the release tag is the real version.
- Put `[skip ci]` in the commit message for docs-only changes so no release is cut.
- From Claude's cloud sessions: branch pushes work, but pushing tags and GitHub write-API calls are blocked.
  That's why the workflow creates the tag itself.
- The exe is unsigned, so Chrome/SmartScreen show a scary "virus/unrecognised" warning. It's a false
  positive: Keep -> Run anyway.
- Owner's flow: Claude pushes, CI releases, owner downloads the Setup exe from Releases and installs over the top.

## How app/kamitv.html works

- **Data:** fetches Tunarr `/api/channels.m3u` + `/api/xmltv.xml` -> `channels[]`, each with `progs[]`
  `{start, stop, title, desc}`. Tunarr URL: Settings, `?url=`, or config.json.
- **Playback:** hls.js 1.5.13 (live config: `liveSyncDurationCount:2, liveMaxLatencyDurationCount:60`,
  no `maxLiveSyncPlaybackRate`; a tighter sync with 1.5x catch-up made it skip forward after tune-in),
  mpegts.js for `.ts`, native fallback. Both libs load from jsdelivr.
  Stream errors are classified (codec vs network/CORS) and shown as a toast.
- **Guide:** timeline EPG. 90-minute window (`GWIN`), 30-minute steps, up to 12h ahead (`GMAX`).
  State `sel = {r: row, at: focus time ms, w: window start ms}`. Blocks sized by real start/stop,
  gold now-line, past programmes dimmed, left/right = previous/next programme, up/down keeps the time.
  Rows wrap infinitely. The current channel plays as a PiP in the top-right while the guide is open.
- **Info:** `i` = banner; `i` again = bottom info card; left/right browses the schedule or episodes.
  The card follows channel changes.
- **On Demand:** Jellyfin `/Items` (tries each user), `/Shows/{id}/Episodes`, playback via
  `/Videos/{id}/master.m3u8` (H.264/AAC transcode). English subtitles auto-on if present, burned in
  (`SubtitleMethod=Encode`); `t` toggles and the choice is remembered.
- **Audio:** `src -> [leveller: AGC gain -> DynamicsCompressor] -> boost gain -> speakers`.
  Leveller is on by default (`settings.level`): target about -20 dBFS RMS, +/-12 dB, ducks fast and raises
  slowly, resets on channel change. Tested: -34 / -8 dBFS inputs come out at -17.3 / -14.7 dBFS.
- **Custom channels** (any HLS/TS URL) live in localStorage `tv_custom` and get a synthetic 48h programme.
- **Settings** persist in localStorage `tv_settings`; "save as my default" uses `tv_userdefault`.
  Hotkeys are ignored while Settings is open or while typing in a field.
- **Hotkeys:** up/down/wheel channel - digits+Enter jump to channel - g guide - o On Demand - i info -
  t subtitles - space play/pause - left/right seek or browse - -/= volume - m mute - z or middle-click fit -
  c CRT - s settings - f or double-click fullscreen.

## Testing changes

- `node --check` on the extracted `<script>` for syntax.
- For UI: run a tiny fake Tunarr (python http.server serving an M3U + XMLTV with odd programme
  lengths, CORS `*`), open the page in headless Chromium via Playwright with `--disable-web-security`,
  click `#power`, press keys, screenshot. Chromium is preinstalled at /opt/pw-browsers.
- For audio: play quiet/loud test tones and measure output RMS with an AnalyserNode on the node
  connected to `AudioContext.destination`.

## Owner's server setup

- **Tunarr 1.3.7** (Windows standalone), port **8000**, data in `%APPDATA%\tunarr` (`db.db` = SQLite).
  Never replace `db.db` while Tunarr is running (that corrupted it once).
- **Jellyfin** on port **8096**. Tunarr's media source URL must be `http://localhost:8096`.
  Pointing it at 8000 (Tunarr itself) still showed a green "healthy" cloud but no libraries.
- **FFmpeg:** gyan.dev **release** essentials build in `C:\ffmpeg\bin`. The git/master build shows as
  "version unknown" in Tunarr.
- **Transcode config "Default":** H.264, Nvidia (CUDA). Recommended 1280x720 or 960x540 at 1200-2000 kbps
  for quick channel changes and remote viewing.
- **Media:** `D:\Dying Harddrive (E)\TV` and `\Movies`. The original E: drive physically failed
  (Jellyfin logged "fatal device hardware error"); readable files were copied to D: and gaps were
  refilled from a friend's drive.
- **Channels** were rebuilt on a fresh Tunarr db in Oct 2026: 101 CRANE TV (Frasier), 102 CHILDHOOD,
  103 PRETTY GOOD TV, 104 [AS], 105 FOXTEL, 106 UK-TV, 107 KITCHEN SLOP, 108 AL JAZEERA LIVE,
  109 ABC NEWS 24.
- Uses Foxtel-style Time Slots with Pad Times (:00/:30), a 1960s US ads file as filler, and a test-pattern
  fallback with a 50/100 Hz hum soundtrack.
- **Remote viewing:** a friend in another house watches via a Tailscale share of the host machine and sets
  KamiTV's Tunarr URL to the host's Tailscale `100.x` address on port 8000. Never port-forward 8000/8096.

## Lessons learned

- Changing the media drive's letter changes Jellyfin item IDs, so Tunarr requests 404. Keep the media
  drive on a fixed letter (Disk Management).
- Jellyfin IDs can't be recomputed from paths. Remapping Tunarr's DB by filename works but is fiddly;
  rebuilding channels was simpler.
- Browsers can't decode HEVC or AC3. Tunarr transcodes its channels; external streams that need it go
  through the relay. Streams gated on a Referer/User-Agent (e.g. SBS) also need the relay.
- Only use legitimate public streams (iptv-org, i.mjh.nz, Free-TV/IPTV). No pirated IPTV or Xtream logins.

## Working style

The owner iterates feature by feature, chats casually, and often sends screenshots. They want changes
pushed so CI publishes a Release. Explain in plain language, give honest caveats, keep replies short.

## Ideas / backlog

- First-run "Where's your Tunarr server?" prompt (useful for friends).
- Bump package.json's version each release so the installer filename matches the tag.
- Code signing, to remove the SmartScreen warning.
- Phone viewing: the Jellyfin app over Tailscale works today. A KamiTV mobile version would need a reverse
  proxy (one origin, no CORS) plus a touch UI.
