{
  description = "SimInTech - среда моделирования";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };

      simintech = pkgs.stdenv.mkDerivation rec {
        pname = "simintech";
        version = "2.23.13";
        src = builtins.fetchTarball {
          url = "http://kafpi.local/simintech.tar.gz"; # подставьте сюда свой адрес дистрибутива SimInTech
          sha256 = "sha256:17ya507nxr1jyyzjkb66s6z61fq7vs4dx1h0z9bgfa5kymql9s9b";
        };

        fhsEnv = pkgs.buildFHSEnv {
          name = "${pname}-fhs-env";
          targetPkgs = p: with p; [
            at-spi2-atk.out
            gdk-pixbuf.out
            glamoroustoolkit.out
            glib.out
            gtk2.out
            libGL.out
            libGLU.out
            pango.out
            xorg.libX11.out
            zlib.out
            (pkgs.writeShellScriptBin "firefox" "exec ${pkgs.chromium}/bin/chromium \"$@\"") # похоже, что SimInTech захардкодил Firefox, но не все так юзают Firefox
          ];
          runScript = "${src}/bin/mmain";
        };

        desktopItem = pkgs.makeDesktopItem {
          name = "SimInTech";
          exec = "simintech";
          desktopName = "SimInTech";
          categories = [ "Development" ];
          icon = "simintech";
          terminal = false;
          startupNotify = false;
          mimeTypes = [ "x-scheme-handler/prt" ];
        };

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          mkdir -p $out/share/applications
          cp ${fhsEnv}/bin/${pname}-fhs-env $out/bin/simintech
          cp ${desktopItem}/share/applications/*.desktop $out/share/applications
          runHook postInstall
        '';
      };
    in {
      packages.x86_64-linux.simintech = simintech;
      defaultPackage.x86_64-linux = simintech;
    };
}
