{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";

    utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      #      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, fenix, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            fenix.overlays.default
            (final: prev: {

              llvmPackages = final.llvmPackages_19;
              #              racket = prev.racket.overrideAttrs (oldAttrs: {
              #                configureFlags = prev.lib.lists.remove "--disable-libs"
              #                 oldAttrs.configureFlags;
              #              });
            })
          ];
        };
        # lib = nixpkgs.lib;
      in {
        packages.cosmic-screenshot =
          pkgs.callPackage ./cosmic-screenshot.nix { };
        devShells.default = pkgs.mkShell {
          #          stdenv = pkgs.llvmPackages_19.stdenv;
          nativeBuildInputs = with pkgs; [
            libcosmicAppHook
            #            slint-lsp
            fenix.packages.${system}.complete.toolchain
            rust-analyzer-nightly
            vulkan-loader
            vulkan-headers
            vulkan-tools
            #            cudatoolkit
            #            cudaPackages.cudnn
            #            cudaPackages.cuda_cudart
            # Package location
            pkg-config
            # Window and Input
            # x11
            #            xorg.libXcursor
            #            xorg.libXi
            vulkan-validation-layers
            pipewire
            bzip2
            #            libdrm
            libxkbcommon
            #            xorg.libXext
            #            xorg.libX11
            #            xorg.libXv
            #            xorg.libXrandr
            #            xorg.libxcb
            zlib
            #            stdenv.cc.cc
            wayland
            mesa
            #            libGL
            #            libGL.dev
            #            mesa_glu
            openssl
            fontconfig
            dbus # for nvidia-powerd
            alsa-lib # Sound support
            udev # device management
            #              clangStdenv
            llvmPackages_20.llvm
            llvmPackages_20.stdenv
            llvmPackages_20.stdenv.cc
            llvmPackages_20.stdenv.cc.cc.lib
            #            tcl-8_6
            #            tcl-9_0
            #            tclPackages.tcllib
            #            tclPackages.tclx
            #            libffi
            #            libxml2
            zlib
            ncurses
            #            openssl
            #           racket
            #				      lld # fast linker
            #            kdePackages.kwayland
            #            leptonica
            #            tesseract4
            # qt6.qtbase
            #            qt6.qtmultimedia
            #            qt6.qtscxml
            #            qt6.qtspeech
            ffmpeg_7-full
            freetype
            #            qt6.qttools
            #            qt6.wrapQtAppsHook
            #            freeglut
            #            glfw
            #            glew
            #            cmake
            #            mesa
            #            libGL
            #            libglvnd
            #            libGLU
            #            glfw
            #            glew
            #            SDL

            egl-wayland
            egl-wayland.dev
          ];
          #dontWrapQtApps = true;
          APPEND_LIBRARY_PATH = with pkgs;
            lib.makeLibraryPath [
              #              cudatoolkit
              bzip2
              fenix.packages.${system}.complete.toolchain
              llvmPackages_20.llvm
              ncurses
              stdenv.cc.cc.lib
              llvmPackages_20.stdenv.cc
              llvmPackages_20.stdenv.cc.cc
              llvmPackages_20.stdenv.cc.cc.lib
              openssl
              fontconfig
              freetype
              #              libffi
              #              libxml2
              zlib
              #              tcl
              #              racket
              #              ncurses
              #              libstd
              #             libGL
              libxkbcommon
              vulkan-loader
              #              xorg.libX11
              #              xorg.libxcb
              #              xorg.libXcursor
              #              xorg.libXi
              #              xorg.libXrandr
              #              glfw
              #              glew
              cmake
              mesa
              wayland
              #              libGL.dev
              #              libglvnd
              #              libGLU
              #              glfw
              #              glew
              #              SDL
              egl-wayland.dev
              egl-wayland
              #              cudaPackages.cudnn
              #              cudaPackages.cuda_cudart
              "/run/opengl-driver" # Needed to find libGL.so
            ];

          shellHook = ''
            export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$APPEND_LIBRARY_PATH"
            #eval $(echo "''${qtWrapperArgs[@]}"|perl -n -e '$_ =~ s/--prefix (\w+) : ([\w-.\/]+)/export ''${1}="''${2}:\''${''${1}}";/g;print')
            libcosmicAppWrapperArgsHook
            eval $(echo "''${libcosmicAppWrapperArgs[@]}"|perl -n -e '$_ =~ s/--prefix (\w+) : ([\w-.\/\:]+)/export ''${1}="''${2}:\''${''${1}}";/g;$_ =~ s/--suffix (\w+) : ([\w-.\/\:]+)/export ''${1}="\''${''${1}}:''${\''${2}}";/g;print')
          '';

        };
      });
}
