{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  buildInputs = [
    (pkgs.callPackage ./package.nix { })
  ];

  shellHook = ''
    echo "Photo organizer environment loaded!"
    echo "Usage: po <source_dir> <target_parent_dir>"
  '';
}
