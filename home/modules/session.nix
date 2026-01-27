{ pkgs, ... }:
{
  home.sessionVariables = {
    EDITOR = "hx";
    TERM = "xterm-kitty";
  };

  home.sessionPath = [
    "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter"
  ];
}
