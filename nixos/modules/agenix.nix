{ inputs, pkgs, config, ... }:
let
  nixConf = "/etc/nix/nix.conf";
  nixRuntimeConf = "/run/agenix/nix.conf";
  tokenFile = config.age.secrets.github-token.path;
in
{
  imports = [ inputs.agenix.nixosModules.default ];

  # Load a runtime-only config so tokens don't end up in the Nix store.
  nix.extraOptions = ''
    !include ${nixRuntimeConf}
  '';

  environment.systemPackages = [
    inputs.agenix.packages.${pkgs.system}.default
  ];

  age.identityPaths = [ "/etc/agenix/age.key" ];

  age.secrets.github-token = {
    file = ../../secrets/github-token.age;
    owner = "root";
    group = "root";
    mode = "0400";
  };

  system.activationScripts.githubAccessToken.text = ''
    install -d -m 0755 /run/agenix
    token="$(cat ${tokenFile})"
    echo "access-tokens = github.com=$token" > ${nixRuntimeConf}
  '';
}
