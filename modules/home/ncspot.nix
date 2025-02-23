{ unstable-pkgs, ... }:
{
  programs.ncspot = {
    enable = true;
    package = unstable-pkgs.ncspot;
    settings = {
      flip-status-indicators = false;
      hide_display_names = true;
      statusbar_format = "%artists / %album - %title";
      backend = "pulseaudio";
      bitrate = 320;
      gapless = false;
      keybindings = {
        "g" = "move top";
        "Shift+g" = "move bottom";
        "Shift+q" = "quit";
        "Shift+s" = "noop";
        "q" = "quit";
        "9" = "voldown 2";
        "0" = "volup 2";
      };
    };
  };
}
