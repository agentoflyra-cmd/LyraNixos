{
  description = "cpp dev env";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.gcc
            pkgs.clang
            pkgs.clang-tools
            pkgs.lldb
            pkgs.cmake
            pkgs.gnumake
            pkgs.pkg-config
            pkgs.eigen
            pkgs.yaml-cpp
            pkgs.boost
            pkgs.spdlog
            pkgs.fmt
            pkgs.bear
            pkgs.git
            pkgs.gdb
          ];
          shellHook = ''
            echo "cpp dev env start"
          '';
        };
      }
    );
}
