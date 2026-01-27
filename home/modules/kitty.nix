{ lib, ... }:
{
  programs.kitty = {
    enable = true;
    settings = lib.mkForce {
      include = "current-theme.conf";
      font_family = "JetBrains Mono NerdFont";
      font_size = 14;
      background_opacity = "0.8";
    };
  };
}

