{ inputs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${pkgs.system}.default
    fuzzel
    fastfetch
  ];
}

