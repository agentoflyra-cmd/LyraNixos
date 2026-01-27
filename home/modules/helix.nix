{ lib, pkgs, ... }:
{
  programs.helix = {
    enable = true;

    settings = lib.mkForce {
      theme = "base16_terminal";
      editor = {
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
        true-color = true;
        line-number = "relative";
        text-width = 100;
        soft-wrap.enable = true;
        auto-save = true;
        auto-format = true;
        statusline.mode.normal = "bufferline";
        bufferline = "always";
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
      };
      keys.insert = {
        "C-h" = "move_char_left";
        "C-j" = "move_line_down";
        "C-k" = "move_line_up";
        "C-l" = "move_char_right";
      };
    };

    languages = lib.mkForce {
      language = [
        {
          name = "python";
          auto-format = true;
          formatter = {
            command = "ruff";
            args = [ "format" "--stdin-filename" "$FILENAME" ];
          };
          language-servers = [ "jedi" "ruff" ];
        }
        {
          name = "rust";
          auto-format = true;
          roots = [ "Cargo.toml" ];
          formatter = {
            command = "rustfmt";
            args = [ "--edition" "2021" ];
          };
          language-servers = [ "rust-analyzer" ];

          debugger = {
            command = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
            name = "codelldb";
            port-arg = "--port {}";
            transport = "tcp";
            templates = [
              {
                name = "binary";
                request = "launch";
                completion = [
                  {
                    completion = "filename";
                    name = "binary";
                  }
                ];
                args = {
                  program = "{0}";
                  runInTerminal = true;
                };
              }
            ];
          };
        }
        {
          name = "nix";
          auto-format = true;
          formatter.command = "nixfmt";
          language-servers = [ "nil" ];
        }
        {
          name = "cpp";
          formatter = {
            command = "clang-format";
            args = [ "--style=file" ];
          };
          roots = [ "CMakeLists.txt" ];
          indent = { tab-width = 4; unit = " "; };
          file-types = [ "cpp" "h" "hpp" "c" ];
          language-servers = [ "clangd" ];
          comment-token = "//";
        }
      ];

      language-server.clangd.command = "clangd";
      language-server.ruff = {
        command = "ruff";
        args = [ "server" ];
      };
      language-server.jedi.command = "jedi-language-server";
      language-server.rust-analyzer = {
        command = "rust-analyzer";
        config = {
          checkOnSave = false;
          cargo.features = "all";
          procMacro.enable = true;
          files.watcher = "client";
        };
      };
    };
  };
}
