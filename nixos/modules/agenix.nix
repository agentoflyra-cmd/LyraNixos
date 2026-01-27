{ inputs, pkgs, config, ... }:
let
  nixConf = "/etc/nix/nix.conf";
  tokenFile = config.age.secrets.github-token.path;
in
{
  imports = [ inputs.agenix.nixosModules.default ];

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
    install -d -m 0755 /etc/nix
    touch ${nixConf}
    token="$(cat ${tokenFile})"
    if grep -q '^access-tokens = ' ${nixConf}; then
      if grep -q 'github.com=' ${nixConf}; then
        sed -i "s#github.com=[^ ]*#github.com=$token#g" ${nixConf}
      else
        sed -i "s#^access-tokens = #&github.com=$token #g" ${nixConf}
      fi
    else
      echo "access-tokens = github.com=$token" >> ${nixConf}
    fi
  '';
}
