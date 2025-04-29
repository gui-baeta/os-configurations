{
  pkgs,
  unstable-pkgs,
  ...
}:
{

  programs.helix.package = unstable-pkgs.helix;
  programs.helix.extraPackages = with unstable-pkgs; [
    simple-completion-language-server
  ];

  home.packages =
    (with pkgs; [
      # generic
      efm-langserver
      # yaml linting
      yaml-language-server
      # toml
      taplo
      # nixfmt
      nixfmt-rfc-style
      # Type checking: comments and text
      harper
      # terraform
      terraform-ls
    ])
    ++
      # Packages from unstable-pkgs
      (with unstable-pkgs; [
        # language server integrating LLMs
        lsp-ai
        # generic-ish lang server
        nodePackages.prettier
        # bash
        bash-language-server
        # Dockerfile
        dockerfile-language-server-nodejs
        # docker compose
        docker-compose-language-service
        # markdown
        # - robust LS
        marksman
        # typst
        tinymist
        # Nix LS
        nil
        # fast python linting
        ruff
      ])
    ++
      # Python 3.12 Packages
      (with pkgs.python312Packages; [
        # Python linting, using pylsp and ruff in the back
        python-lsp-ruff
      ]);

  home.file = {
    "helix" = {
      source = ./snippets.toml;
      target = ".config/helix/external-snippets.toml";
    };
  };

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
        enable = true;
      };
    };
    languages = {
      #
      # Languages
      #
      language = [
        {
          name = "hcl";
          language-servers = [ "terraform-ls" ];
          language-id = "terraform";
        }
        {
          name = "git-commit";
          language-servers = [ "scls" ];
        }
        {
          # introduce a new language to enable completion on any doc by forcing set language with :set-language stub
          name = "whatever";
          scope = "text.whatever";
          file-types = [ ];
          shebangs = [ ];
          roots = [ ];
          auto-format = false;
          language-servers = [ "scls" ];
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
            "scls"
          ];
          # Remove trailing whitespaces. See: https://www.reddit.com/r/HelixEditor/comments/1c9lg73/highlight_trailing_whitespace_only/
          formatter = {
            command = "sed";
            args = [ "s/[[:space:]]*$//" ];
          };
          auto-format = true;
        }
        {
          name = "yaml";

          # Remove trailing whitespaces
          formatter = {
            command = "sed";
            args = [ "s/[[:space:]]*$//" ];
          };
          auto-format = true;

          # formatter = {
          #   command = "prettier";
          #   args = [
          #     "--parser"
          #     "yaml"
          #   ];
          # };
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
          name = "html";
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "html"
            ];
          };
          language-servers = [ "scls" ];
        }
        {
          name = "json";
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "json"
            ];
          };
          language-servers = [ "scls" ];
        }
        {
          name = "css";
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "css"
            ];
          };
          language-servers = [ "scls" ];
        }
      ];
      #
      # Language Servers
      #
      language-server = {
        scls = {
          command = "simple-completion-language-server";
          config = {
            max_completion_items = 100; # set max completion results len for each group: words, snippets, unicode-input
            feature_words = true; # enable completion by word
            feature_snippets = true; # enable snippets
            snippets_first = true; # completions will return before snippets by default
            snippets_inline_by_word_tail = false; # suggest snippets by WORD tail, for example text `xsq|` become `x^2|` when snippet `sq` has body `^2`
            feature_unicode_input = false; # enable "unicode input"
            feature_paths = false; # enable path completion
            feature_citations = false; # enable citation completion (only on `citation` feature enabled)
            environment = {
              RUST_LOG = "info,simple-completion-language-server=info";
              LOG_FILE = "/tmp/completion.log";
            };
          };
        };
        terraform-ls = {
          command = "terraform-ls";
          args = [ "serve" ];
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
        pylsp = {
          config.pylsp.plugins = {
            flake8 = {
              enabled = false;
            };
            autopep8 = {
              enabled = false;
            };
            mccabe = {
              enabled = false;
            };
            pycodestyle = {
              enabled = false;
            };
            pyflakes = {
              enabled = false;
            };
            pylint = {
              enabled = false;
            };
            yapf = {
              enabled = false;
            };
            ruff = {
              enabled = true;
              select = [
                "E"
                "F"
                "UP"
                "B"
                "SIM"
                "I"
                "PD"
                "NPY"
                "PERF"
                "FURB"
                "DOC"
                "TRY"
                "W"
                "R"
                "PL"
                "TCH"
                "Q"
                "PT"
                "ICN"
                "C4"
                "COM"
                "FBT"
                "S"
                "N"
              ];
              ignore = [ "F401" ];
              lineLength = 120;
            };
          };
        };
        ruff = {
          command = "ruff-lsp";
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
