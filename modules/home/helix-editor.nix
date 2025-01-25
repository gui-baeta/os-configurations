{
  config,
  pkgs,
  unstable-pkgs,
  ...
}:
{

  programs.helix.package = unstable-pkgs.helix;

  home.packages =
    (with pkgs; [
      # generic
      efm-langserver
      # generic
      prettierd
      # yaml linting
      yaml-language-server
      # html, json, css, eslint
      vscode-langservers-extracted
      # toml
      taplo
      # nixfmt
      nixfmt-rfc-style
      # Type checking: comments and text
      harper
      # terraform
      terraform-ls
      # fast python linting
      ruff
    ])
    ++
      # Packages from unstable-pkgs
      (with unstable-pkgs; [
        # bash
        bash-language-server
        # Dockerfile
        dockerfile-language-server-nodejs
        # docker compose
        docker-compose-language-service
        # markdown
        # - robust LS
        marksman
        # - grammar and spelling
        ltex-ls-plus

        # typst
        tinymist
      ])
    ++
      # Python 3.12 Packages
      (with pkgs.python312Packages; [
        # Python linting, using pylsp and ruff in the back
        python-lsp-ruff
      ]);

  programs.helix = {
    enable = true;
    # Configure as default editor by setting `EDITOR` env. variable
    defaultEditor = true;
    settings = {
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

        shell = [
          "fish"
          "-c"
        ];
        path-completion = true; # Suggest file paths as autocompletions
        auto-format = true; # Auto format on save
        completion-trigger-len = 1;
        text-width = 80;
        default-line-ending = "lf";
        insert-final-newline = true;

        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "error";
          other-lines = "error";
        };
      };

      keys.normal = {
        "esc" = [
          "collapse_selection"
          ":w"
        ];
        # "Alt-u" = [ ];
        # NOTE Should try to also customise the Shift-y and Shitf-p ones
        # "y" = "yank_main_selection_to_clipboard";
        # NOTE On delete: Yank to main clipboard
        # "d" = ""
        # NOTE On change: Yank to main clipboard
        # "c" = ""
        # NOTE Does this paste using main clipboard?
        # "p" = "paste_clipboard_before";
      };

      keys.select = {
        "esc" = [
          "collapse_selection"
          "normal_mode"
          ":w"
        ];
        # "y" = "yank_main_selection_to_clipboard";
        # "p" = "paste_clipboard_before";
      };

      keys.insert = {
        # NOTE Test "Don't save when coming out of the insert mode"
        # "esc" = [ "normal_mode" ":w" ];
        "esc" = [ "normal_mode" ];
      };

      editor.file-picker = {
        hidden = false;
        git-ignore = true;
      };
      editor.auto-pairs = {
        "(" = ")";
        "{" = "}";
        "[" = "]";
        "\"" = ''"'';
        "'" = "'";
        "`" = "`";
        "<" = ">";
      };
      editor.smart-tab = {
        enable = false;
      };
    };
    languages = {
      language = [
        {
          name = "hcl";
          language-servers = [ "terraform-ls" ];
          language-id = "terraform";
        }
        {
          name = "tfvars";
          language-servers = [ "terraform-ls" ];
          language-id = "terraform-vars";
        }
        {
          name = "markdown";
          language-servers = [
            "marksman"
            "ltex-ls"
          ];
        }
        {
          name = "yaml";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "yaml"
            ];
          };
        }
        {
          name = "toml";
          formatter = {
            command = "taplo";
            args = [
              "fmt"
              "-"
            ];
          };
        }
        {
          name = "nix";
          auto-format = true;
          formatter.command = "nixfmt";
        }
        {
          name = "typescript";
          language-servers = [
            {
              name = "efm";
              only-features = [
                "diagnostics"
                "format"
              ];
            }
            {
              name = "typescript-language-server";
              except-features = [ "format" ];
            }
          ];
        }
      ];
      language-server = {
        terraform-ls = {
          command = "terraform-ls";
          args = [ "serve" ];
        };
        vscode-json-language-server = {
          config = {
            provideFormatter = true;
            json = {
              keepLines = {
                enable = true;
              };
            };
          };
        };
        ltex-ls = {
          config = {
            ltex.disabledRules = {
              en-US = [ "PROFANITY" ];
              en-GB = [ "PROFANITY" ];
            };
            ltex.dictionary = {
              en-US = [ "builtin" ];
              en-GB = [ "builtin" ];
            };
          };
        };
        yaml-language-server = {
          config = {
            yaml = {
              format.enable = false;
              validation = true;
              schemas = {
                "https://json.schemastore.org/github-workflow.json" = ".github/workflows/*.{yml,yaml}";
                "https://raw.githubusercontent.com/ansible-community/schemas/main/f/ansible-tasks.json" =
                  "roles/{tasks,handlers}/*.{yml,yaml}";
              };
            };
          };
        };
        harper-ls = {
          command = "harper-ls";
          args = [ "--stdio" ];
          config = {
            harper-ls = {
              diagnosticSeverity = "warning";
              linters = {
                # Words should be separated by at most one space.
                spaces = false;
                # Spelled numbers less than 10.
                spelled_numbers = true;
                correct_number_suffix = true;
                sentence_capitalization = true;
                unclosed_quotes = true;
                # NOTE Not sure about this one
                # The key on the keyboard often used as
                #  a quotation mark is actually a double-apostrophe.
                # Use the correct character.
                wrong_quotes = true;
                avoid_curses = false;

                spell_check = true;
                currency_placement = true;
              };
            };
          };
        };
      };
    };
  };
}
