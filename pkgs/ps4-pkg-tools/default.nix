{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config

, llvmPackages_18

, qt6
, wrapQtAppsHook

, openssl
, zlib
, fmt
, cryptopp
, libpng
, vulkan-headers
, vulkan-utility-libraries
, glslang

, wayland
, wayland-protocols
, libxkbcommon

, enableQt ? true
}:

stdenv.mkDerivation rec {
  pname = "ps4-pkg-tools";
  version = "unstable-2026-01-24";

  src = fetchFromGitHub {
    owner = "xXJSONDeruloXx";
    repo = "ps4-pkg-tools";

    # Prefer system libraries instead of bundled submodules.
    fetchSubmodules = false;

    # Upstream doesn't appear to have a v0.1.8 tag, so build from the default branch.
    # If you want reproducibility + nicer versioning, pin this to a commit SHA and set
    # version to something like "unstable-YYYY-MM-DD".
    rev = "HEAD";

    # NOTE: If you change `rev`, you'll need to update this hash.
    hash = "sha256-GiP35dIbu+dRH85DCiAezzO1Vlv/E58crkdLEigx4U0=";
  };

  postPatch = ''
    # Upstream CMakeLists.txt assumes git submodules exist under `externals/*` and unconditionally
    # add_subdirectory()s them. For Nix we want to use nixpkgs-provided deps instead, so:
    # - replace the vendored zlib+cryptopp block with system find_package/find_library logic
    # - stop adding vendored include dirs
    # - link ZLIB::ZLIB instead of zlibstatic
    #
    # Keep this patch minimal and robust by using simple line-based substitutions.

    substituteInPlace CMakeLists.txt \
      --replace-fail 'set(ZLIB_BUILD_EXAMPLES OFF CACHE BOOL "Build zlib examples" FORCE)' \
                    'option(USE_SYSTEM_DEPS "Use system zlib and Crypto++ instead of vendored submodules" OFF)

if(USE_SYSTEM_DEPS)
  find_package(ZLIB REQUIRED)

  # Upstream includes "zlib/zlib.h" (vendored layout).
  # In Nix, zlib provides <zlib.h>, so point the include path at a tiny shim we add below.
  include_directories(build/nix-compat)

  find_package(cryptopp CONFIG QUIET)
  if(NOT TARGET cryptopp::cryptopp)
    add_library(cryptopp::cryptopp UNKNOWN IMPORTED)
    set_target_properties(cryptopp::cryptopp PROPERTIES
      IMPORTED_LOCATION "${cryptopp}/lib/libcryptopp.so"
      INTERFACE_INCLUDE_DIRECTORIES "${cryptopp.dev}/include"
    )
  endif()
else()
  set(ZLIB_BUILD_EXAMPLES OFF CACHE BOOL "Build zlib examples" FORCE)'

    substituteInPlace CMakeLists.txt \
      --replace-fail 'add_subdirectory('"$"'{'CMAKE_SOURCE_DIR'}/externals/zlib EXCLUDE_FROM_ALL)' \
                    'add_subdirectory(externals/zlib EXCLUDE_FROM_ALL)'

    substituteInPlace CMakeLists.txt \
      --replace-fail 'set(CRYPTOPP_SOURCES '"$"'{'CMAKE_SOURCE_DIR'}/externals/cryptopp)' \
                    'set(CRYPTOPP_SOURCES externals/cryptopp)'

    substituteInPlace CMakeLists.txt \
      --replace-fail 'add_subdirectory('"$"'{'CMAKE_SOURCE_DIR'}/externals/cryptopp-cmake EXCLUDE_FROM_ALL)' \
                    'add_subdirectory(externals/cryptopp-cmake EXCLUDE_FROM_ALL)
endif()'

    substituteInPlace CMakeLists.txt \
      --replace-fail 'include_directories(
  '"$"'{'CMAKE_SOURCE_DIR'}/src
  '"$"'{'CMAKE_SOURCE_DIR'}/externals                # cryptopp headers
  '"$"'{'CMAKE_SOURCE_DIR'}/externals/zlib           # zlib headers
)' \
                    'include_directories(
  '"$"'{'CMAKE_SOURCE_DIR'}/src
)
if(NOT USE_SYSTEM_DEPS)
  include_directories(
    '"$"'{'CMAKE_SOURCE_DIR'}/externals                # cryptopp headers
    '"$"'{'CMAKE_SOURCE_DIR'}/externals/zlib           # zlib headers
  )
endif()'

    substituteInPlace CMakeLists.txt \
      --replace-fail 'target_link_libraries(ps4_pkg_tool_core PUBLIC cryptopp::cryptopp zlibstatic)' \
                    'if(USE_SYSTEM_DEPS)
  target_link_libraries(ps4_pkg_tool_core PUBLIC cryptopp::cryptopp ZLIB::ZLIB)
else()
  target_link_libraries(ps4_pkg_tool_core PUBLIC cryptopp::cryptopp zlibstatic)
endif()'

    # Create a compat header so upstream "zlib/zlib.h" resolves in system-deps mode.
    mkdir -p build/nix-compat/zlib
    cat > build/nix-compat/zlib/zlib.h <<'EOF'
#include <zlib.h>
EOF
  '';

  nativeBuildInputs =
    [
      cmake
      pkg-config
      llvmPackages_18.clang
    ]
    ++ lib.optionals enableQt [
      wrapQtAppsHook
    ];

  buildInputs =
    [
      openssl
      zlib
      fmt
      cryptopp
      libpng
      vulkan-headers
      vulkan-utility-libraries
      glslang
    ]
    ++ lib.optionals enableQt [
      qt6.qtbase
      qt6.qttools
      qt6.qtmultimedia
      qt6.qtwayland
      wayland
      wayland-protocols
      libxkbcommon
    ];

  cmakeFlags =
    [
      "-DUSE_SYSTEM_DEPS=ON"
    ]
    ++ lib.optionals (!enableQt) [
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
