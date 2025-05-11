{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "mpv-gradual-pause";
  version = "0.2.0";

  # Source files from the local directory
  src = pkgs.lib.cleanSource ./.;

  # No unpacking needed
  dontUnpack = true;

  # Install only the script file
  installPhase = ''
    mkdir -p $out/share/mpv/scripts

    # Copy just the Lua script file
    cp ${./gradual-pause.lua} $out/share/mpv/scripts/gradual-pause.lua
  '';

  meta = {
    description = "MPV script that adds balanced gradual audio fade with position saving";
    platforms = pkgs.lib.platforms.all;
    maintainers = [ ];
  };

  # Important: This allows MPV to find the script
  passthru.scriptName = "gradual-pause.lua";
}
