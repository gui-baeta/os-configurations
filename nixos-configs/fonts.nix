{ pkgs, ... }:

{
  fonts = {
    # TODO This config is a try to fix problem in jebtrain IDEs where fira-code
    # TODO  only shows up in light weight. IDK if this fixes that.
    # TODO  Remove and test if it fixes it or not
    enableGhostscriptFonts = true;

    # Link all fonts to /run/current-system/sw/share/X11/fonts
    fontDir.enable = true;

    # Fonts
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })

      corefonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf

      vistafonts
      mplus-outline-fonts.githubRelease

      dina-font
      proggyfonts
    ];
  };
}
