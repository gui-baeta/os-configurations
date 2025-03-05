{
  pkgs,
  ...
}:

{
  # Available fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "DroidSansMono"
      ];
    })

    corefonts
    vistafonts

    # TODO Add Netflix Sans Medium (to be used in mpv)
    # NOTE Maybe do this in the mpv module?
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];
}
