{ self, mkTest, lib, alejandra, }:
let inherit (lib.sources) sourceFilesBySuffices;
in mkTest {
  name = "lint-alejandra";
  src = sourceFilesBySuffices self [ ".nix" ];
  checkInputs = [ alejandra ];
  checkPhase = ''
    mkdir -p $out
    alejandra --check \
        --exclude ./nixos-config/pen-and-paper/hardware-configuration.nix \
        --exclude ./nixos-config/light-bulb/hardware-configuration.nix \
        . \
    | tee $out/test.log
  '';
}
