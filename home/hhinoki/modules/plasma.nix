{ pkgs, ... }:

# Apple-ish ("iOS-like") Plasma 6 setup, managed declaratively via plasma-manager.
#
# Look: WhiteSur global theme (the de-facto macOS/iOS theme for KDE),
# top bar with global menu, floating centered dock at the bottom,
# window buttons on the left.
{
  home.packages = with pkgs; [
    whitesur-kde # global theme / look-and-feel
    whitesur-icon-theme
    whitesur-cursors
    whitesur-gtk-theme # so GTK apps match
  ];

  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "com.github.vinceliuice.WhiteSur";
      iconTheme = "WhiteSur";
      cursor = {
        theme = "WhiteSur-cursors";
        size = 24;
      };
    };

    panels = [
      # macOS-style menu bar at the top
      {
        location = "top";
        height = 28;
        floating = false;
        widgets = [
          {
            kickoff = {
              icon = "start-here-kde-symbolic";
            };
          }
          "org.kde.plasma.appmenu" # global menu, like the macOS menu bar
          "org.kde.plasma.panelspacer"
          "org.kde.plasma.systemtray"
          {
            digitalClock = {
              time.format = "12h";
            };
          }
        ];
      }
      # Floating, centered dock at the bottom
      {
        location = "bottom";
        height = 56;
        floating = true;
        alignment = "center";
        lengthMode = "fit";
        hiding = "dodgewindows";
        widgets = [
          {
            iconTasks = {
              launchers = [
                "applications:google-chrome.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:org.kde.konsole.desktop"
                "applications:systemsettings.desktop"
              ];
            };
          }
        ];
      }
    ];

    configFile = {
      # Window buttons on the left, macOS order: close, minimize, maximize
      kwinrc."org.kde.kdecoration2" = {
        ButtonsOnLeft = "XIA";
        ButtonsOnRight = "";
      };
      # Export the menubar to the global menu widget in the top panel
      kdeglobals.General.menuBar = "Global";
    };
  };
}
