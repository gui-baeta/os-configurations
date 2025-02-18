{
  ...
}:
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
  };
}
