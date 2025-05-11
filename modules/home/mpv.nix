{
  pkgs,
  unstable-pkgs,
  ...
}:
let
  # Import our custom script
  gradual-pause = import ./gradual-pause.nix { inherit pkgs; };
in
{

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "vdpau";
      vo = "gpu-next";
      fullscreen = true;
      sub-scale = 0.7;
      slang = [ "en" ];
      save-position-on-quit = true;
      # gpu-context=wayland
      # gpu-api=opengl
      # profile=gpu-hq
    };
    scripts = with unstable-pkgs; [
      # mpvScripts.autosub
      mpvScripts.thumbnail
      gradual-pause
    ];

    scriptOpts = {
      # Optional: script configuration
      # these are the defaults
      "gradual-pause" = {
        fade_out_duration = 0.45;
        fade_in_duration = 0.3;
        steps = 12;
        # NOTE: Make it so that it works on any pausing/unpausing event
        original_keybind = "space";
        fade_out_unpause = true;
        logarithmic_fade = true;
      };
    };
  };
}
