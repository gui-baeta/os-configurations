{ config, pkgs, unstable-pkgs, ... }: {

  programs.helix.package = unstable-pkgs.helix;

  programs.helix = {
    enable = true;
    settings = {
      # catppuccin_frappe catppuccin_macchiato catppuccin_latte onedark sonokai      
      theme = "onedark";

      editor = {
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };

        auto-save = {
          focus-lost = false;
          after-delay.enable = false;
          after-delay.timeout = 500;
        };

        indent-guides = {
          character = "⸽";
          render = true;
        };

        shell = [ "fish" "-c" ];
        path-completion = true; # Suggest file paths as autocompletions
        auto-format = true; # Auto format on save
        completion-trigger-len = 1;
        text-width = 80;
        default-line-ending = "lf";
        insert-final-newline = true;
      };

      keys.normal = {
        "esc" = [ "collapse_selection" ":w" ];
        "y" = "yank_main_selection_to_clipboard";
        "p" = "paste_clipboard_before";
      };

      keys.select = {
        "esc" = [ "collapse_selection" "normal_mode" ":w" ];
        "y" = "yank_main_selection_to_clipboard";
        "p" = "paste_clipboard_before";
      };

      keys.insert = { "esc" = [ "normal_mode" ":w" ]; };

      editor.file-picker = {
        hidden = false;
        git-ignore = true;
      };
      editor.auto-pairs = {
        "(" = ")";
        "{" = "}";
        "[" = "]";
        "\"" = ''"'';
        "`" = "`";
        "<" = ">";
      };
      editor.smart-tab = { enable = false; };
    };
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
        }
        {
          name = "typescript";
          language-servers = [
            {
              name = "efm";
              only-features = [ "diagnostics" "format" ];
            }
            {
              name = "typescript-language-server";
              except-features = [ "format" ];
            }
          ];
        }
      ];
      language-server = {
        eslint = {
          command =
            "${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server";
          config = {
            format = true;
            nodePath = "";
            onIgnoredFiles = "off";
            packageManager = "yarn";
            quiet = false;
            rulesCustomizations = [ ];
            run = "onType";
            useESLintClass = false;
            validate = "on";
            codeAction = {
              disableRuleComment = {
                enable = true;
                location = "separateLine";
              };
              showDocumentation = { enable = true; };
            };
            codeActionOnSave = { mode = "all"; };
            experimental = { };
            problems = { shortenToSingleLine = false; };
            workingDirectory = { mode = "auto"; };
          };
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
        efm = { command = "${pkgs.efm-langserver}/bin/efm-langserver"; };
      };
    };
  };
}
