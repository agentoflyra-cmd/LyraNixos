{ config, lib, pkgs, ... }:
{
  imports = [
    ../../modules/helix.nix
    ../../modules/kitty.nix
    ../../modules/yazi.nix
    ../../modules/session.nix
  ];

  home.username = "lyra";
  home.homeDirectory = "/home/lyra";
  home.stateVersion = "25.11";

  home.packages = [
    pkgs.dnsmasq
    pkgs.clang
    pkgs.nil
    pkgs.nixfmt
    pkgs.yazi
    pkgs.python313Packages.jedi
    pkgs.python3Packages.jedi-language-server
    pkgs.ruff
    pkgs.rust-analyzer
    pkgs.zellij
    pkgs.opencode
    pkgs.codex
    pkgs.lldb
    pkgs.vscode-extensions.vadimcn.vscode-lldb
  ];

  systemd.user.startServices = "sd-switch";

  # 把“非纯 nix”的配置文件也纳入 Home Manager 管理（集中在 LyraNixos 目录）
  xdg.configFile."niri/config.kdl" = {
    source = ../../files/niri/config.kdl;
    force = true;
  };
  # noctalia 需要写入该文件，避免放进 Nix store 的只读 symlink
  xdg.configFile."zellij/config.kdl" = {
    source = ../../files/zellij/config.kdl;
    force = true;
  };
  xdg.configFile."kitty/current-theme.conf" = {
    source = ../../files/kitty/current-theme.conf;
    force = true;
  };

  home.file.".oh-my-bash".source = pkgs.fetchFromGitHub {
    owner = "ohmybash";
    repo = "oh-my-bash";
    rev = "63ebf657816a76a9422b2262289bd8eb5eed2c72";
    sha256 = "0qd6kplhabwcjrafa4anjzwxrl1zdcfczqsv2aj33aawvnxq0y23";
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      case $- in
        *i*) ;;
          *) return;;
      esac

      export OSH="$HOME/.oh-my-bash"
      OSH_THEME="font"
      OMB_USE_SUDO=true

      completions=(
        git
        composer
        ssh
        bundler
        rake
      )

      aliases=(
        general
      )

      plugins=(
        git
        bashmarks
      )

      source "$OSH"/oh-my-bash.sh

      if [ -f "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]; then
        source "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
      elif [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
        source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi

      . "$HOME/.cargo/env"
    '';
  };

  home.activation.noctaliaWritableConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="$HOME/.config/niri/noctalia.kdl"
    if [ -f "/LyraNixos/home/files/niri/noctalia.kdl" ]; then
      source="/LyraNixos/home/files/niri/noctalia.kdl"
    else
      source="${config.home.homeDirectory}/LyraNixos/home/files/niri/noctalia.kdl"
    fi

    if [ -L "$target" ]; then
      link="$(readlink "$target")"
      case "$link" in
        /nix/store/*)
          mv "$target" "$target.bak"
          ;;
      esac
    fi

    if [ ! -e "$target" ] && [ -f "$source" ]; then
      install -D -m 0644 "$source" "$target"
    fi
  '';

  # 统一壁纸入口：让所有配置都引用 ~/Pictures/Wallpapers/...
  # 注意：如果 ~/Pictures/Wallpapers 已存在且非空，请先手动备份/移动，避免激活时冲突。
  home.file."Pictures/Wallpapers".source = ../../files/wallpapers;

  programs.home-manager.enable = true;
}
