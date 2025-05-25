{
  pkgs,
  lib,
  stdenv,
}:

stdenv.mkDerivation {
  pname = "mpv-gradual-pause";
  version = "0.3.0";

  # Source files from the local directory
  src = pkgs.lib.cleanSource ./.;

  # Just copy the file to the right location
  installPhase = ''
    mkdir -p $out/share/mpv/scripts
    mkdir -p $out/share/mpv/script-opts

    # Copy the main script
    cp ${./gradual_pause.lua} $out/share/mpv/scripts/gradual_pause.lua

    # Create a simple config file if needed
    cat > $out/share/mpv/script-opts/gradual_pause.conf << EOF
    fade_out_duration=0.45
    fade_in_duration=0.3
    steps=12
    logarithmic_fade=yes
    debug_mode=no
    EOF
  '';

  meta = {
    description = "MPV script that adds gradual audio fade when pausing/unpausing";
    homepage = "https://github.com/gui-baeta/mpv-gradual-pause";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = [ ];
  };

  # This allows MPV to find the script
  passthru.scriptName = "gradual_pause.lua";
}
