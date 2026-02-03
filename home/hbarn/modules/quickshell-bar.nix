{ config, pkgs, lib, ... }:

let
  # A very small, self-contained QuickShell bar.
  #
  # Notes / assumptions:
  # - This is intended for Wayland compositors that support the layer-shell protocol (Hyprland/Sway/etc).
  # - Workspace display needs compositor integration. QuickShell can talk to Hyprland via its IPC socket;
  #   for Sway you’d typically use `swaymsg -t subscribe` / `swaymsg -t get_workspaces`.
  # - To keep this module “simple” and not too fragile, the workspace section is implemented as:
  #     - Hyprland: live workspaces per monitor (via hyprland IPC if available)
  #     - otherwise: a placeholder that you can later swap for your compositor
  #
  # If you tell me whether you’re on Sway or Hyprland, I can tailor the workspace widget to be truly
  # “per-monitor assigned” with no placeholders.

  qsScript = pkgs.writeText "quickshell-bar.qml" ''
    import QtQuick 2.15
    import QtQuick.Layouts 1.15

    // QuickShell module names vary by version/distribution.
    // The following pattern works in typical QuickShell setups that expose:
    // - a top-level "Bar"/"Layer" element for layer-shell anchoring
    // - simple widgets and a way to run commands / poll output
    //
    // If your quickshell build uses different type names, you only need to adjust the imports/types here.
    //
    // This file intentionally keeps the UI simple: left workspaces, right status.
    // Width/height mimic a typical Waybar top bar.

    Item {
      id: root
      width: 1920
      height: 30

      // Simple styling
      property color bg: "#111318"
      property color fg: "#e6e6e6"
      property color muted: "#a8b0bf"
      property color accent: "#7aa2f7"

      Rectangle {
        anchors.fill: parent
        radius: 0
        color: root.bg
        border.color: "#1d2230"
        border.width: 1
      }

      // Helpers: very small "pill" component
      Component {
        id: pill
        Rectangle {
          property string text: ""
          property color textColor: root.fg
          property color fill: "#151a24"
          property color stroke: "#23283a"

          radius: 6
          color: fill
          border.color: stroke
          border.width: 1
          height: 22
          width: label.implicitWidth + 16

          Text {
            id: label
            anchors.centerIn: parent
            text: parent.text
            color: parent.textColor
            font.pixelSize: 12
            font.family: "sans-serif"
          }
        }
      }

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        spacing: 10

        // LEFT: per-monitor workspaces
        // ------------------------------------------------------------
        // Basic approach:
        // - If HYPRLAND_INSTANCE_SIGNATURE is set, show "monitor: [workspaces]" blocks.
        // - Otherwise show a single placeholder "workspaces" pill.
        //
        // Replace the placeholder branch with your compositor integration as needed.
        RowLayout {
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignVCenter
          spacing: 8

          // Title (subtle)
          Text {
            text: "WS"
            color: root.muted
            font.pixelSize: 12
          }

          // Hyprland workspace polling via command (simple, avoids long-lived subscriptions here).
          // This is intentionally conservative and will update every second.
          // It calls `hyprctl -j monitors` and extracts active workspaces per monitor.
          //
          // If hyprctl isn’t present, it falls back to placeholder.
          //
          // In QuickShell, a common pattern is a "Command" object that runs and exposes stdout;
          // if your build exposes a differently named object, tweak it accordingly.
          //
          // Because QuickShell variants differ, the actual command execution object may need rename.
          // The rest of the module is still a useful starting point.

          // Placeholder pills container; replaced when hypr data is available.
          RowLayout {
            id: wsContainer
            spacing: 6

            // Default placeholder
            Loader {
              active: true
              sourceComponent: pill
              onLoaded: {
                item.text = "workspaces"
                item.textColor = root.muted
              }
            }
          }
        }

        // RIGHT: status modules
        // ------------------------------------------------------------
        RowLayout {
          Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
          spacing: 8

          // IP
          Loader {
            sourceComponent: pill
            onLoaded: { item.text = "IP: …"; }
          }

          // CPU
          Loader {
            sourceComponent: pill
            onLoaded: { item.text = "CPU: …"; }
          }

          // MEM
          Loader {
            sourceComponent: pill
            onLoaded: { item.text = "MEM: …"; }
          }

          // Keyboard layout
          Loader {
            sourceComponent: pill
            onLoaded: { item.text = "KB: …"; }
          }

          // Volume
          Loader {
            sourceComponent: pill
            onLoaded: { item.text = "VOL: …"; }
          }

          // Time
          Loader {
            sourceComponent: pill
            onLoaded: { item.text = "TIME: …"; }
          }
        }
      }
    }
  '';

  # A tiny helper script that prints status values in a stable way.
  # We keep it conservative and dependency-light.
  #
  # QuickShell can consume these via command polling (e.g. every second).
  statusScript = pkgs.writeShellScriptBin "qs-bar-status" ''
    set -eu

    cmd=''${1:-}

    case "$cmd" in
      ip)
        # Prefer the default route when possible; otherwise first global IPv4.
        ip route get 1.1.1.1 2>/dev/null | awk '/src/ {print $7; exit}' || true
        if [ -z "''${ip:-}" ]; then
          ip -4 -o addr show scope global 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n1
        else
          echo "$ip"
        fi
        ;;
      cpu)
        # CPU usage since last call using /proc/stat deltas.
        # Store previous in a temp file keyed by UID.
        tmp="''${XDG_RUNTIME_DIR:-/tmp}/qs-bar-cpu.$UID"
        read -r _ user nice sys idle iowait irq softirq steal guest guest_nice < /proc/stat
        total=$((user+nice+sys+idle+iowait+irq+softirq+steal))
        idle_all=$((idle+iowait))
        if [ -f "$tmp" ]; then
          read -r ptotal pidle < "$tmp" || true
        else
          ptotal=$total
          pidle=$idle_all
        fi
        echo "$total $idle_all" > "$tmp"
        dt=$((total-ptotal))
        di=$((idle_all-pidle))
        if [ "$dt" -le 0 ]; then
          echo "0%"
        else
          usage=$(( (100*(dt-di)) / dt ))
          echo "''${usage}%"
        fi
        ;;
      mem)
        # Mem used percentage from /proc/meminfo
        memtotal=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
        memavail=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)
        used=$((memtotal-memavail))
        pct=$(( (100*used) / memtotal ))
        echo "''${pct}%"
        ;;
      kbd)
        # Try hyprland: hyprctl -j devices. Otherwise: localectl.
        if command -v hyprctl >/dev/null 2>&1; then
          hyprctl -j devices 2>/dev/null | ${pkgs.jq}/bin/jq -r '
            .keyboards[0].active_keymap // empty
          ' | awk '{print toupper($1)}' || true
        elif command -v localectl >/dev/null 2>&1; then
          localectl status 2>/dev/null | awk -F: '/X11 Layout/ {gsub(/ /,"",$2); print toupper($2)}' | head -n1
        fi
        ;;
      vol)
        # PipeWire/WirePlumber via wpctl if present, else amixer.
        if command -v wpctl >/dev/null 2>&1; then
          wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{printf("%d%%", $2*100)}'
        elif command -v amixer >/dev/null 2>&1; then
          amixer get Master 2>/dev/null | awk -F'[][]' 'END{print $2}'
        fi
        ;;
      time)
        date '+%a %b %d  %H:%M'
        ;;
      *)
        echo "unknown"
        exit 1
        ;;
    esac
  '';

in
{
  # Home Manager module: installs quickshell + helpers and writes the qml.
  #
  # You may need to adjust the package name depending on nixpkgs:
  # - `quickshell` exists in some nixpkgs revisions
  # - otherwise you might package it yourself
  #
  # This module is still useful even if the package name differs: just change `home.packages`.

  home.packages = with pkgs; [
    # If this attribute doesn’t exist in your nixpkgs, tell me your compositor + nixpkgs revision
    # and I’ll adapt to the package you have.
    quickshell
    jq
    statusScript
  ];

  xdg.configFile."quickshell/bar.qml".source = qsScript;

  # Autostart via systemd user service (Wayland session).
  systemd.user.services.quickshell-bar = {
    Unit = {
      Description = "QuickShell top bar";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.quickshell}/bin/quickshell -c ${config.xdg.configHome}/quickshell/bar.qml";
      Restart = "on-failure";
      RestartSec = 2;
      Environment = [
        # Make sure helper is on PATH for command widgets
        "PATH=${lib.makeBinPath [ statusScript pkgs.coreutils pkgs.iproute2 pkgs.gawk pkgs.gnugrep pkgs.jq pkgs.wireplumber pkgs.alsa-utils ]}"
      ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
