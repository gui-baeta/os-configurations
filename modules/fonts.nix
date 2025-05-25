{
  pkgs,
  ...
}:

let
  inter-gnome-v4 = pkgs.callPackage ../packages/inter-gnome-v4.nix { };
in
{
  # Available fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono

    cantarell-fonts
    inter-gnome-v4

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
