{
  pkgs,
  ...
}:
let
  gradual-pause = pkgs.callPackage ../../packages/gradual-pause/package.nix { };
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
    scripts = with pkgs; [
      # mpvScripts.autosub
      # unstable.mpvScripts.thumbnail
      mpvScripts.mpris
      gradual-pause
    ];

    scriptOpts = {
      # # Optional: script configuration
      # # these are the defaults
      # "gradual_pause" = {
      #   fade_out_duration = 0.45;
      #   fade_in_duration = 0.3;
      #   steps = 12;
      #   logarithmic_fade = true;
      # };
    };
  };
}
