{
  description = "ROS2 dev shell (nix-ros-overlay)";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";
    nixpkgs.follows = "nix-ros-overlay/nixpkgs"; # IMPORTANT!!!
  };
  outputs =
    {
      self,
      flake-utils,
      nix-ros-overlay,
      nixpkgs,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nix-ros-overlay.overlays.default ];
        };
        rosPackages = with pkgs.rosPackages.humble; [
          ros-core
          # ... other ROS packages
          desktop
          rmw-cyclonedds-cpp
          unitree-ros
          realsense2-camera
          ament-cmake-core
          python-cmake-module
        ];
        rosEnv =
          with pkgs.rosPackages.humble;
          buildEnv {
            paths = rosPackages;
          };
      in
      {
        packages.rosEnv = rosEnv;

        devShells.default = pkgs.mkShell {
          name = "Example project";
          packages = [
            pkgs.colcon
            # ... other non-ROS packages
            rosEnv
          ];
          shellHook = ''
            if [[ ! $DIRENV_IN_ENVRC ]]; then
                eval "$(${pkgs.python3Packages.argcomplete}/bin/register-python-argcomplete ros2)"
                eval "$(${pkgs.python3Packages.argcomplete}/bin/register-python-argcomplete colcon)"
            fi
            source ${pkgs.rosPackages.humble.ros-core}/share/ros_core/local_setup.bash

            unset QT_QPA_PLATFORM
            export QT_QPA_PLATFORM=xcb
            echo "ROS2 ready!"
          '';
        };
      }
    );
  nixConfig = {
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };
}
