// Prasanna OS — minimal floating dock-style panel.
// Opt-in: ./install.sh panel   (your current layout is backed up first)
// Layout:  [launcher] [pinned/running apps]  ·  [tray] [clock]
var old = panels();
var p = new Panel;
p.location = "bottom";
p.height = Math.round(gridUnit * 2.4);
try { p.floating = true; } catch (e) {}
try { p.lengthMode = "fit"; } catch (e) {}       // hug content, macOS-dock style
try { p.alignment = "center"; } catch (e) {}
try { p.hiding = "dodgewindows"; } catch (e) {}  // hides only when a window touches it

var launcher = p.addWidget("org.kde.plasma.kickoff");
launcher.currentConfigGroup = ["General"];
launcher.writeConfig("icon", "start-here-symbolic");

var tasks = p.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", [
    "applications:kitty.desktop",
    "applications:org.kde.dolphin.desktop",
    "applications:brave-browser.desktop",
    "applications:code.desktop"
].join(","));
tasks.writeConfig("indicateAudioStreams", "true");
tasks.writeConfig("iconSpacing", "1");

p.addWidget("org.kde.plasma.marginsseparator");
p.addWidget("org.kde.plasma.systemtray");
var clock = p.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("showDate", "false");

// Remove the previous panels only after the new one exists
for (var i = 0; i < old.length; i++) { old[i].remove(); }
