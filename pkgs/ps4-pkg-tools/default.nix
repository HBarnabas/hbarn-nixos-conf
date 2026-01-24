{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, llvmPackages_18 ? null
, clang ? (if llvmPackages_18 != null then llvmPackages_18.clang else throw "clang is required (pass llvmPackages_18 or clang)")
, qt6 ? null
, wrapQtAppsHook ? null
, openssl
, zlib
, fmt
, libpng
, vulkan-headers
, vulkan-utility-libraries
, glslang
, wayland ? null
, wayland-protocols ? null
, libxkbcommon ? null
, enableQt ? true
}:

stdenv.mkDerivation rec {
  pname = "ps4-pkg-tools";
  version = "0.1.8"; # keep in sync with upstream when bumping

  src = fetchFromGitHub {
    owner = "xXJSONDeruloXx";
    repo = "ps4-pkg-tools";
    rev = "v${version}";
    # Replace with the real hash:
    # 1) temporarily set to lib.fakeSha256
    # 2) run: nix build .#ps4-pkg-tools (or whatever target uses this derivation)
    # 3) copy the "got: sha256-..." into here
    hash = lib.fakeSha256;
  };

  nativeBuildInputs =
    [
      cmake
      pkg-config
      clang
    ]
    ++ lib.optionals enableQt ([
      (lib.assertMsg (wrapQtAppsHook != null) "wrapQtAppsHook is required when enableQt = true") wrapQtAppsHook
    ]);

  buildInputs =
    [
      openssl
      zlib
      fmt
      libpng
      vulkan-headers
      vulkan-utility-libraries
      glslang
    ]
    ++ lib.optionals enableQt (
      (lib.assertMsg (qt6 != null) "qt6 is required when enableQt = true") [
        qt6.qtbase
        qt6.qttools
        qt6.qtmultimedia
        qt6.qtwayland
        wayland
        wayland-protocols
        libxkbcommon
      ]
    );

  cmakeFlags = lib.optionals (!enableQt) [
    "-DENABLE_GUI=OFF"
  ];

  # CMake projects typically provide an install target; keep default phases.

  meta = {
    description = "Standalone PS4 PKG extraction tool";
    homepage = "https://github.com/xXJSONDeruloXx/ps4-pkg-tools";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "ps4-pkg-tool";
  };
}
