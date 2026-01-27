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
          unitree-ros
        ];
        rosEnv = with pkgs.rosPackages.humble; buildEnv {
          paths = [
            rosPackages
          ];
        };
      in
      {
        packages.${system}.rosEnv = rosEnv;

        devShells.${system}.default = pkgs.mkShell {
          name = "Example project";
          packages = [
            pkgs.colcon
            # ... other non-ROS packages
            rosEnv
          ];
        };
      }
    );
  nixConfig = {
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };
}
