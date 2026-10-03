// KamiTV — Electron main process
// Wraps the KamiTV HTML app in a real desktop window.
// webSecurity:false cleanly removes the CORS wall (no more --disable-web-security Chrome flag),
// so Tunarr, Jellyfin and custom streams work out of the box.

const { app, BrowserWindow, Menu, shell } = require("electron");
const path = require("path");
const fs = require("fs");
const { spawn } = require("child_process");

// --- command-line switches that matter for playback ---
app.commandLine.appendSwitch("autoplay-policy", "no-user-gesture-required");
app.commandLine.appendSwitch("disable-features", "OutOfBlinkCors"); // belt-and-braces CORS relief

let win;
let tunarrProc = null;

// Optional: auto-launch Tunarr and/or relay streams from config.json (all optional).
function loadConfig() {
  try {
    const p = path.join(app.getPath("userData"), "config.json");
    if (fs.existsSync(p)) return JSON.parse(fs.readFileSync(p, "utf8"));
  } catch (e) {}
  // also allow a config.json shipped next to the exe
  try {
    const p2 = path.join(path.dirname(app.getPath("exe")), "config.json");
    if (fs.existsSync(p2)) return JSON.parse(fs.readFileSync(p2, "utf8"));
  } catch (e) {}
  return {};
}

function maybeStartTunarr(cfg) {
  if (!cfg.tunarrExe) return;
  try {
    if (!fs.existsSync(cfg.tunarrExe)) return;
    tunarrProc = spawn(cfg.tunarrExe, cfg.tunarrArgs || [], {
      detached: false,
      stdio: "ignore",
      windowsHide: true,
    });
  } catch (e) {
    console.error("Could not start Tunarr:", e.message);
  }
}

function createWindow() {
  const cfg = loadConfig();
  maybeStartTunarr(cfg);

  win = new BrowserWindow({
    width: 1366,
    height: 768,
    backgroundColor: "#000000",
    autoHideMenuBar: true,
    title: "KamiTV",
    webPreferences: {
      webSecurity: false,              // <- kills CORS cleanly
      allowRunningInsecureContent: true,
      backgroundThrottling: false,     // keep video/audio running when not focused
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  // query string lets you override the Tunarr URL, e.g. ?url=http://localhost:8000
  const extra = cfg.tunarrUrl ? ("?url=" + encodeURIComponent(cfg.tunarrUrl)) : "";
  win.loadFile(path.join(__dirname, "app", "kamitv.html"), extra ? { search: extra } : {});

  // open target=_blank etc. in the system browser, never a new Electron window
  win.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: "deny" };
  });

  if (cfg.startFullscreen) win.setFullScreen(true);
}

// Minimal menu: fullscreen + reload + devtools, nothing else.
function buildMenu() {
  const template = [
    {
      label: "KamiTV",
      submenu: [
        { role: "reload" },
        { role: "forceReload" },
        { type: "separator" },
        { role: "togglefullscreen" }, // F11
        { role: "toggleDevTools" },
        { type: "separator" },
        { role: "quit" },
      ],
    },
  ];
  Menu.setApplicationMenu(Menu.buildFromTemplate(template));
}

app.whenReady().then(() => {
  buildMenu();
  createWindow();
  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on("window-all-closed", () => {
  if (tunarrProc) { try { tunarrProc.kill(); } catch (e) {} }
  if (process.platform !== "darwin") app.quit();
});
