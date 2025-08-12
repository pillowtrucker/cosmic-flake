{ lib, rustPlatform, pkg-config, just, makeBinaryWrapper, libcosmicAppHook
, libxkbcommon, wayland, vulkan-loader, libglvnd, mesa, libinput, fontconfig
, freetype, xorg, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "cosmic-screenshot";
  version = "b7773e1713c3949e10d9aa28c0c3c29ba3dc497b";
  src = fetchFromGitHub {
    owner = "pillowtrucker";
    repo = "cosmic-screenshot";
    rev = "${version}";
    hash = "sha256-oTaIGgpV12sBTo/Ow4HUmwf30db4WeKDQlXqEo3rYVE=";
    fetchSubmodules = true;
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "accesskit-0.16.0" =
        "sha256-yeBzocXxuvHmuPGMRebbsYSKSvN+8sUsmaSKlQDpW4w=";
      "atomicwrites-0.4.2" =
        "sha256-QZSuGPrJXh+svMeFWqAXoqZQxLq/WfIiamqvjJNVhxA=";
      "clipboard_macos-0.1.0" =
        "sha256-+8CGmBf1Gl9gnBDtuKtkzUE5rySebhH7Bsq/kNlJofY=";
      "cosmic-client-toolkit-0.1.0" =
        "sha256-7EFXDQ6aHiXq0qrjeyjqtOuC3B5JLpHQTXbPwtC+fRo=";
      "cosmic-config-0.1.0" =
        "sha256-55B8FN6hJgppfYRdT5cucAKzMeNfu4WQZ7aEm1/Vl9k=";
      "cosmic-freedesktop-icons-0.3.0" =
        "sha256-XAcoKxMp1fyclalkkqVMoO7+TVekj/Tq2C9XFM9FFCk=";
      "cosmic-settings-daemon-0.1.0" =
        "sha256-CEmzl/09rD11kgnoHP2Q6N/emDhEK4wQiqSXmIlsbPE=";
      "cosmic-text-0.14.2" =
        "sha256-Nq2JMe9dNUxU7WokRSCnkPG7FdmLgB3jKDpAswqJ+L8=";
      "dpi-0.1.1" = "sha256-whi05/2vc3s5eAJTZ9TzVfGQ/EnfPr0S4PZZmbiYio0=";
      "iced_glyphon-0.6.0" =
        "sha256-u1vnsOjP8npQ57NNSikotuHxpi4Mp/rV9038vAgCsfQ=";
      "smithay-clipboard-0.8.0" =
        "sha256-4InFXm0ahrqFrtNLeqIuE3yeOpxKZJZx+Bc0yQDtv34=";
      "softbuffer-0.4.1" =
        "sha256-a0bUFz6O8CWRweNt/OxTvflnPYwO5nm6vsyc/WcXyNg=";
      "taffy-0.3.11" = "sha256-SCx9GEIJjWdoNVyq+RZAGn0N71qraKZxf9ZWhvyzLaI=";
    };
  };

  nativeBuildInputs = [ pkg-config just makeBinaryWrapper libcosmicAppHook ];

  buildInputs = [
    # Core Wayland/Graphics support
    libxkbcommon
    wayland
    vulkan-loader
    libglvnd
    mesa

    # System Integration
    libinput

    # Text rendering
    fontconfig
    freetype

    # X11 compatibility for mixed environments
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
  ];

  # Use just for building (following COSMIC conventions)
  buildPhase = ''
    runHook preBuild
    just build-release
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Install the binary
    install -Dm755 target/release/cosmic-screenshot $out/bin/cosmic-screenshot

    # Install the library files (for use by other applications)
    install -Dm644 target/release/libcosmic_screenshot.rlib $out/lib/libcosmic_screenshot.rlib
    install -Dm755 target/release/libcosmic_screenshot.so $out/lib/libcosmic_screenshot.so

    # Install desktop file
    install -Dm644 resources/com.system76.CosmicScreenshot.desktop \
      $out/share/applications/com.system76.CosmicScreenshot.desktop

    # Install D-Bus service file
    install -Dm644 resources/com.system76.CosmicScreenshot.service \
      $out/share/dbus-1/services/com.system76.CosmicScreenshot.service

    # Install D-Bus interface definition
    install -Dm644 resources/com.system76.CosmicScreenshot.xml \
      $out/share/dbus-1/interfaces/com.system76.CosmicScreenshot.xml

    runHook postInstall
  '';

  # Runtime configuration for COSMIC applications
  postInstall = ''
    wrapProgram "$out/bin/cosmic-screenshot" \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          xorg.libX11
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr
          vulkan-loader
          libxkbcommon
          wayland
          libglvnd
          mesa
        ]
      }
    cp $out/share/applications/com.system76.CosmicScreenshot.desktop $out/share/applications/com.system76.CosmicScreenshot-Dev.desktop
    substituteInPlace $out/share/applications/com.system76.CosmicScreenshot-Dev.desktop \
      --replace 'Exec=cosmic-screenshot' "Exec=/home/wrath/cosmic-flake/cosmic-screenshot/target/release/cosmic-screenshot"
    substituteInPlace $out/share/applications/com.system76.CosmicScreenshot.desktop \
      --replace 'Exec=cosmic-screenshot' "Exec=$out/bin/cosmic-screenshot"
  '';

  doCheck = false; # Skip tests for now

  meta = with lib; {
    description =
      "Screenshot functionality for COSMIC desktop with GUI, D-Bus service, and multi-backend support";
    longDescription = ''
      cosmic-screenshot is a comprehensive screenshot tool built for the COSMIC desktop environment.
      It provides multi-backend screenshot capabilities (KWin, Freedesktop Portal), interactive 
      region selection, D-Bus service interface, CLI tool, and professional GUI application.

      Features include:
      - Multiple screenshot backends with automatic fallback
      - Interactive region selection with fullscreen overlay  
      - D-Bus service interface for system integration
      - Professional COSMIC UI with persistent settings
      - CLI interface with all screenshot types supported
      - Library API for integration with other applications
    '';
    homepage = "https://github.com/pop-os/cosmic-screenshot";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "cosmic-screenshot";
  };
}
