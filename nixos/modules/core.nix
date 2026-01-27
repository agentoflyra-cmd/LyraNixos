{ pkgs, ... }:
{
  # Bootloader (保持 systemd-boot)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 网络
  networking.networkmanager.enable = true;
  networking.nameservers = [ "8.8.8.8" "114.114.114.114" "9.9.9.9" "1.1.1.1" ];

  # 时区
  time.timeZone = "Asia/Shanghai";

  programs.nix-ld.enable = true;

  # Nix 设置（镜像与 flakes，保留原有）
  nix.settings = {
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=10"
      "https://mirrors.ustc.edu.cn/nix-channels/store?priority=5"
      "https://cache.nixos.org/"
    ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  # sound (pipewire)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.dnsmasq = {
    enable = true;
    settings.server = [ "8.8.8.8" "1.1.1.1" ];
  };

  programs.firefox.enable = true;
  services.flatpak.enable = true;

  services.mihomo = {
    enable = true;
    tunMode = true;
    configFile = "/home/lyra/.config/mihomo/config.yaml";
    webui = pkgs.metacubexd;
  };

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main = {
          capslock = "overload(control, esc)";
          esc = "capslock";
        };
        otherlayer = { };
      };
      extraConfig = ''
        # extra-config
      '';
    };
  };

  nixpkgs.config.allowUnfree = true;

  users.users.lyra = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "input" "networkmanager" ];
    packages = with pkgs; [
      pavucontrol
      papirus-icon-theme
      materia-theme
      adwaita-icon-theme
    ];
  };

  environment.systemPackages = with pkgs; [
    helix
    home-manager
    wget
    curl
    git
    kitty
    mihomo
    mpv
    wl-clipboard
    grim
    swayimg
    slurp
    sway-contrib.grimshot
    xdg-utils
  ];

  environment.sessionVariables = {
    HTTP_PROXY = "http://127.0.0.1:7890";
    HTTPS_PROXY = "http://127.0.0.1:7890";
    ALL_PROXY = "http://127.0.0.1:7890";
  };

  services.openssh.enable = true;
}
