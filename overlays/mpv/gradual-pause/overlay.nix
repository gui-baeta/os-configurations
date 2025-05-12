final: prev:

{
  mpvScripts = prev.mpvScripts // {
    gradual-pause = final.callPackage ./package.nix { };
  };
}
