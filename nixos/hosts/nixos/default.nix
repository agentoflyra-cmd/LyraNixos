{ config, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/kernel.nix
    ../../modules/core.nix
    ../../modules/chinese.nix
    ../../modules/noctalia.nix
    ../../modules/niri.nix
    ../../modules/agenix.nix
    ../../modules/system_graphics.nix
  ]
  ++ lib.optional (builtins.pathExists ./.use-nvidia) ../../modules/nvidia.nix;

  networking.hostName = "nixos";

  # 保持与当前系统版本一致（见 /etc/os-release: 26.05）
  system.stateVersion = "26.05";
}
