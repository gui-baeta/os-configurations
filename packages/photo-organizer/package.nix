{
  pkgs ? import <nixpkgs> { },
}:

pkgs.python3.pkgs.buildPythonApplication rec {
  pname = "photo-organizer";
  version = "1.0.0";

  src = ./.;

  format = "other";

  propagatedBuildInputs = with pkgs.python3.pkgs; [
    pillow
  ];

  buildInputs = with pkgs; [
    python3
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp po.py $out/bin/po
    chmod +x $out/bin/po

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "po - Photo organizer with burst detection and date-based sorting";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
  };
}
