{
  pkgs ? null,
}:
let
  nix-ros-overlay = builtins.fetchTarball {
    url = "https://github.com/lopsided98/nix-ros-overlay/archive/master.tar.gz";
  };

  pkgs' = if pkgs != null then pkgs else import "${nix-ros-overlay}/." { };

  rosShell = import "${nix-ros-overlay}/examples/ros2-desktop.nix" {
    rosDistro = "humble";
    pkgs = pkgs';
  };
in
rosShell.overrideAttrs (old: {
  shellHook = (old.shellHook or "") + ''
    echo "Entered ROS 2 humble development shell"
  '';
})

