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
      theme = {
        background = "#1F2228";
        primary = "#ABB2BF";
        secondary = "#DCDCDC";
        title = "#E5C07B";
        playing = "#E5C07B";
        playing_selected = "#E5C07B";
        playing_bg = "#282C34";
        highlight = "#C6CBD4";
        highlight_bg = "#3B4048";
        error = "#E06C75";
        error_bg = "#1F2228";
        statusbar = "#E5C07B";
        statusbar_progress = "#ABB2BF";
        statusbar_bg = "#2C323C";
        cmdline = "#282C34";
        cmdline_bg = "#E5C07B";
      };
    };
  };
}
