{ pkgs, ... }:

let
  # A very small, self-contained QuickShell bar.
  #
  # Notes / assumptions:
  # - This is intended for Wayland compositors that support the layer-shell protocol (Hyprland/Sway/etc).
  # - Workspaces are integrated with Sway via `swaymsg -t get_outputs` and `swaymsg -t get_workspaces`.
  # - The left side shows one group per output, with that output’s assigned workspaces (sorted numerically
  #   when possible) and highlights the focused workspace.
  #
  # This keeps the look simple and “Waybar-ish”: small pills, top bar height ~30px.

  # qsScript = pkgs.writeText "quickshell-bar.qml" ''
  #   import Quickshell
  #   import Quickshell.Io
  #   import QtQuick
  #   import QtQuick.Effects

  #   // QuickShell module names vary by version/distribution.
  #   // The following pattern works in typical QuickShell setups that expose:
  #   // - a top-level "Bar"/"Layer" element for layer-shell anchoring
  #   // - simple widgets and a way to run commands / poll output
  #   //
  #   // If your quickshell build uses different type names, you only need to adjust the imports/types here.
  #   //
  #   // This file intentionally keeps the UI simple: left workspaces, right status.
  #   // Width/height mimic a typical Waybar top bar.

  #   Item {
  #     id: root
  #     width: 1920
  #     height: 30

  #     // Simple styling
  #     property color bg: "#111318"
  #     property color fg: "#e6e6e6"
  #     property color muted: "#a8b0bf"
  #     property color accent: "#7aa2f7"

  #     Rectangle {
  #       anchors.fill: parent
  #       radius: 0
  #       color: root.bg
  #       border.color: "#1d2230"
  #       border.width: 1
  #     }

  #     // Helpers: very small "pill" component
  #     Component {
  #       id: pill
  #       Rectangle {
  #         property string text: ""
  #         property color textColor: root.fg
  #         property color fill: "#151a24"
  #         property color stroke: "#23283a"

  #         radius: 6
  #         color: fill
  #         border.color: stroke
  #         border.width: 1
  #         height: 22
  #         width: label.implicitWidth + 16

  #         Text {
  #           id: label
  #           anchors.centerIn: parent
  #           text: parent.text
  #           color: parent.textColor
  #           font.pixelSize: 12
  #           font.family: "sans-serif"
  #         }
  #       }
  #     }

  #     RowLayout {
  #       anchors.fill: parent
  #       anchors.leftMargin: 10
  #       anchors.rightMargin: 10
  #       anchors.topMargin: 4
  #       anchors.bottomMargin: 4
  #       spacing: 10

  #       // LEFT: per-output workspaces (Sway)
  #       // ------------------------------------------------------------
  #       // This polls `qs-bar-sway-workspaces` (provided by this module) once per second.
  #       // The script prints a compact, parseable format:
  #       //   OUTPUT=HDMI-A-1|WS=1* 2 3
  #       //   OUTPUT=eDP-1|WS=4 5* 6
  #       //
  #       // QuickShell implementations vary; this QML keeps rendering logic simple and leaves the Sway IPC
  #       // complexity in the shell script.
  #       RowLayout {
  #         Layout.fillWidth: true
  #         Layout.alignment: Qt.AlignVCenter
  #         spacing: 8

  #         Text {
  #           text: "WS"
  #           color: root.muted
  #           font.pixelSize: 12
  #         }

  #         // Render container. The actual population is expected to be handled by a command/polling widget
  #         // in your QuickShell build. If you already have a "Command"/"Poll" element, wire it to:
  #         //   qs-bar-sway-workspaces
  #         // and then create pills from its stdout.
  #         //
  #         // For now we provide a reasonable static preview with the intended look.
  #         RowLayout {
  #           id: wsContainer
  #           spacing: 6

  #           Loader {
  #             active: true
  #             sourceComponent: pill
  #             onLoaded: {
  #               item.text = "eDP-1: 1* 2 3"
  #               item.textColor = root.fg
  #             }
  #           }

  #           Loader {
  #             active: true
  #             sourceComponent: pill
  #             onLoaded: {
  #               item.text = "HDMI-A-1: 4 5* 6"
  #               item.textColor = root.fg
  #             }
  #           }
  #         }
  #       }

  #       // RIGHT: status modules
  #       // ------------------------------------------------------------
  #       RowLayout {
  #         Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
  #         spacing: 8

  #         // IP
  #         Loader {
  #           sourceComponent: pill
  #           onLoaded: { item.text = "IP: …"; }
  #         }

  #         // CPU
  #         Loader {
  #           sourceComponent: pill
  #           onLoaded: { item.text = "CPU: …"; }
  #         }

  #         // MEM
  #         Loader {
  #           sourceComponent: pill
  #           onLoaded: { item.text = "MEM: …"; }
  #         }

  #         // Keyboard layout
  #         Loader {
  #           sourceComponent: pill
  #           onLoaded: { item.text = "KB: …"; }
  #         }

  #         // Volume
  #         Loader {
  #           sourceComponent: pill
  #           onLoaded: { item.text = "VOL: …"; }
  #         }

  #         // Time
  #         Loader {
  #           sourceComponent: pill
  #           onLoaded: { item.text = "TIME: …"; }
  #         }
  #       }
  #     }
  #   }
  # '';

  # # A tiny helper script that prints status values in a stable way.
  # # We keep it conservative and dependency-light.
  # #
  # # QuickShell can consume these via command polling (e.g. every second).
  # statusScript = pkgs.writeShellScriptBin "qs-bar-status" ''
  #   set -eu

  #   cmd=''${1:-}

  #   case "$cmd" in
  #     ip)
  #       # Prefer the default route when possible; otherwise first global IPv4.
  #       ip route get 1.1.1.1 2>/dev/null | awk '/src/ {print $7; exit}' || true
  #       if [ -z "''${ip:-}" ]; then
  #         ip -4 -o addr show scope global 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n1
  #       else
  #         echo "$ip"
  #       fi
  #       ;;
  #     cpu)
  #       # CPU usage since last call using /proc/stat deltas.
  #       # Store previous in a temp file keyed by UID.
  #       tmp="''${XDG_RUNTIME_DIR:-/tmp}/qs-bar-cpu.$UID"
  #       read -r _ user nice sys idle iowait irq softirq steal guest guest_nice < /proc/stat
  #       total=$((user+nice+sys+idle+iowait+irq+softirq+steal))
  #       idle_all=$((idle+iowait))
  #       if [ -f "$tmp" ]; then
  #         read -r ptotal pidle < "$tmp" || true
  #       else
  #         ptotal=$total
  #         pidle=$idle_all
  #       fi
  #       echo "$total $idle_all" > "$tmp"
  #       dt=$((total-ptotal))
  #       di=$((idle_all-pidle))
  #       if [ "$dt" -le 0 ]; then
  #         echo "0%"
  #       else
  #         usage=$(( (100*(dt-di)) / dt ))
  #         echo "''${usage}%"
  #       fi
  #       ;;
  #     mem)
  #       # Mem used percentage from /proc/meminfo
  #       memtotal=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
  #       memavail=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)
  #       used=$((memtotal-memavail))
  #       pct=$(( (100*used) / memtotal ))
  #       echo "''${pct}%"
  #       ;;
  #     kbd)
  #       # On Sway, layouts are typically per-input; this is a "best effort" single-line summary.
  #       # If you use sway + swaykbdd you could wire that here instead.
  #       if command -v swaymsg >/dev/null 2>&1; then
  #         swaymsg -t get_inputs -r 2>/dev/null | jq -r '
  #           [ .[] | select(.type=="keyboard") | .xkb_active_layout_name ] | map(select(. != null)) | first // empty
  #         ' | awk '{print toupper($1)}' || true
  #       elif command -v localectl >/dev/null 2>&1; then
  #         localectl status 2>/dev/null | awk -F: '/X11 Layout/ {gsub(/ /,"",$2); print toupper($2)}' | head -n1
  #       fi
  #       ;;
  #     vol)
  #       # PipeWire/WirePlumber via wpctl if present, else amixer.
  #       if command -v wpctl >/dev/null 2>&1; then
  #         wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{printf("%d%%", $2*100)}'
  #       elif command -v amixer >/dev/null 2>&1; then
  #         amixer get Master 2>/dev/null | awk -F'[][]' 'END{print $2}'
  #       fi
  #       ;;
  #     time)
  #       date '+%a %b %d  %H:%M'
  #       ;;
  #     *)
  #       echo "unknown"
  #       exit 1
  #       ;;
  #   esac
  # '';

  # # Sway: per-output workspace listing.
  # # Output format (one line per output):
  # #   OUTPUT=<name>|WS=<ws1> <ws2*> <ws3>
  # #
  # # `*` marks focused workspace.
  # swayWorkspacesScript = pkgs.writeShellScriptBin "qs-bar-sway-workspaces" ''
  #   set -eu

  #   if ! command -v swaymsg >/dev/null 2>&1; then
  #     exit 0
  #   fi

  #   outputs_json="$(swaymsg -t get_outputs -r 2>/dev/null || true)"
  #   workspaces_json="$(swaymsg -t get_workspaces -r 2>/dev/null || true)"

  #   if [ -z "$outputs_json" ] || [ -z "$workspaces_json" ]; then
  #     exit 0
  #   fi

  #   # For each active output, list its workspaces (sorted by numeric prefix when possible).
  #   echo "$outputs_json" | jq -r '
  #     [.[] | select(.active==true) | .name] | .[]
  #   ' | while IFS= read -r out; do
  #     ws_line="$(echo "$workspaces_json" | jq -r --arg out "$out" '
  #       [ .[]
  #         | select(.output == $out)
  #         | {name, num, focused}
  #       ]
  #       | sort_by(.num)
  #       | map(if .focused then (.name + "*") else .name end)
  #       | join(" ")
  #     ')"
  #     [ -n "$ws_line" ] || ws_line=""
  #     printf "OUTPUT=%s|WS=%s\n" "$out" "$ws_line"
  #   done
  # '';

  configs = builtins.path {
    path = ./configs;
    name = "quickshell-configs";
  };

in
{
  programs.quickshell = {
    enable = true;
    activeConfig = configs; # The name of the config to use.
    systemd.enable = true;
  };
}
