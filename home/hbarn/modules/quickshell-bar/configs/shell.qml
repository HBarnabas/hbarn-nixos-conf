import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Effects

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

        // LEFT: per-output workspaces (Sway)
        // ------------------------------------------------------------
        // This polls `qs-bar-sway-workspaces` (provided by this module) once per second.
        // The script prints a compact, parseable format:
        //   OUTPUT=HDMI-A-1|WS=1* 2 3
        //   OUTPUT=eDP-1|WS=4 5* 6
        //
        // QuickShell implementations vary; this QML keeps rendering logic simple and leaves the Sway IPC
        // complexity in the shell script.
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 8

            Text {
                text: "WS"
                color: root.muted
                font.pixelSize: 12
            }

            // Render container. The actual population is expected to be handled by a command/polling widget
            // in your QuickShell build. If you already have a "Command"/"Poll" element, wire it to:
            //   qs-bar-sway-workspaces
            // and then create pills from its stdout.
            //
            // For now we provide a reasonable static preview with the intended look.
            RowLayout {
            id: wsContainer
            spacing: 6

            Loader {
                active: true
                sourceComponent: pill
                onLoaded: {
                    item.text = "eDP-1: 1* 2 3"
                    item.textColor = root.fg
                }
            }

            Loader {
                active: true
                sourceComponent: pill
                onLoaded: {
                    item.text = "HDMI-A-1: 4 5* 6"
                    item.textColor = root.fg
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
