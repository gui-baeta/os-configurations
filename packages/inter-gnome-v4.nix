{
  lib,
  stdenvNoCC,
  fetchzip,
}:
#
# FROM: https://gitlab.gnome.org/Teams/Design/initiatives/-/issues/152
#
stdenvNoCC.mkDerivation {
  pname = "inter-font";
  version = "4.0";

  src = fetchzip {
    url = "https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip";
    stripRoot = false;
    hash = "sha256-hFK7xFJt69n+98+juWgMvt+zeB9nDkc8nsR8vohrFIc=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp Inter.ttc InterVariable*.ttf $out/share/fonts/truetype
  '';

  meta = with lib; {
    homepage = "https://rsms.me/inter/";
    description = "Typeface specially designed for user interfaces - Custom version to test with Gnome";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
