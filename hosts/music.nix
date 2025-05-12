{ inputs, ... }:

let
  radioStreams = builtins.attrNames (builtins.readDir "${inputs.my-music}/radio-streams");
  #
  # - Replace spaces with \\x20 instead of \ to avoid Nix's string interpretation issues
  # - Keep target path unescaped since target path uses literal nix store path
  # - "\x20" (the hexadecimal ASCII code for a space) is how `_systemd-tmpfiles_` represents spaces.
  #   So, unlike in bash/shell where one can use double quotes very freely
  #    to represent file paths with spaces.
  #   When dealing with `_systemd_` functions like the `_systemd-tmpfiles_`,
  #    one has to encode spaces with `\x20`
  #
  #  * By using nix repl, I can see the config output of a specific tmpfiles.rules element):
  #
  #     ```nix
  #     nix-repl> :lf . # load flake from this directory
  #     Added 13 variables.
  #     nix-repl> (builtins.elemAt outputs.nixosConfigurations.pen-and-paper.config.systemd.tmpfiles.rules 0)
  #     L+ /run/radio-streams/Very\\x20Cool\\x20Radio.pls - - - - /nix/store/d1msmx3z4zd3fisdb0jsn1mb93k62dlb-source/radio-streams/Very Cool Radio.pls
  #     ```
  #  * I can also see the final computed string:
  #
  #     ```nix
  #     nix-repl> builtins.trace (builtins.elemAt outputs.nixosConfigurations.pen-and-paper.config.systemd.tmpfiles.rules 0) {}
  #     trace: L+ /run/radio-streams/Very\x20Cool\x20Radio.pls - - - - /nix/store/d1msmx3z4zd3fisdb0jsn1mb93k62dlb-source/radio-streams/Very Cool Radio.pls
  #     { }
  #     ```
  #
  #  * From the above output in nix-repl, we can see that the before stubborn double backsplash is parsed by nix and only one lives _to tell this tale_.
  #   The target path contains spaces, which is OK since that path will end up wrapped in double quotes:
  #
  #     ```bash
  #     > ls -la /run/radio-streams/
  #     total 0
  #     drwxr-xr-x  2 root root 100 mai 12 22:36  ./
  #     drwxr-xr-x 32 root root 920 mai 12 22:36  ../
  #     lrwxrwxrwx  1 root root 119 mai 12 22:36 'Very Cool Radio.pls' -> '/nix/store/d1msmx3z4zd3fisdb0jsn1mb93k62dlb-source/radio-streams/Very Cool Radio.pls'
  #     lrwxrwxrwx  1 root root 107 mai 12 22:36 'Some Other Radio - The Artist.pls' -> '/nix/store/d1msmx3z4zd3fisdb0jsn1mb93k62dlb-source/radio-streams/Some Other Radio - The Artist.pls'
  #     ```
  #
  escapeTmpfilePath = s: builtins.replaceStrings [ " " ] [ "\\x20" ] s;
in
{
  systemd.tmpfiles.rules = map (
    file:
    "L+ /run/radio-streams/${escapeTmpfilePath file} - - - - ${inputs.my-music}/radio-streams/${file}"
  ) radioStreams;
}
