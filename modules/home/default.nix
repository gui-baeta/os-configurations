{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;

  home.stateVersion = "24.11";

  home.username = "guibaeta";
  home.homeDirectory = "/home/guibaeta";

  programs.helix = {
    enable = true;
    settings = {
      # catppuccin_frappe catppuccin_macchiato catppuccin_latte onedark sonokai      
      theme = "onedark";
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
      editor.auto-save = {
        focus-lost = false;
        after-delay.enable = false;
        after-delay.timeout = 500;
      };

      editor.indent-guides = {
        character = "⸽";
        render = true;
      };

      keys.normal = { "esc" = [ "collapse_selection" ":w" ]; };

      keys.select = { "esc" = [ "collapse_selection" "normal_mode" ":w" ]; };

      keys.insert = { "esc" = [ "normal_mode" ":w" ]; };

      editor.file-picker = { hidden = false; };
      editor.smart-tab = { enable = true; };
    };
    languages = {
      language = [{
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
      }];
      language-server = {
        eslint = {
          command =
            "${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server";
        };
        json = {
          command =
            "${pkgs.vscode-langservers-extracted}/bin/vscode-json-language-server";
        };
        html = {
          command =
            "${pkgs.vscode-langservers-extracted}/bin/vscode-html-language-server";
        };
        css = {
          command =
            "${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server";
        };
      };
    };
  };
}
