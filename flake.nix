{
  description = "Lyra NixOS + Home Manager (centralized)";

  inputs = {
    # 保持你原来的 nixpkgs 来源（清华 git 镜像）
    nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git?ref=nixos-unstable&shallow=1";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 本地开发环境（作为子 flake 暴露到顶层，便于 `nix develop .#dora-rs`）
    dora-rs-dev = {
      url = "path:./dev/dora-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ros2-env-dev = {
      url = "path:./dev/ros2-env";
      inputs = {
        nixpkgs.follows = "nix-ros-overlay/nixpkgs";
        nix-ros-overlay.follows = "nix-ros-overlay";
      };
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.nixos = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/hosts/nixos
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # 避免首次接管 dotfiles 时因已有文件而失败：自动把旧文件重命名为 *.hm-bak
            home-manager.backupFileExtension = "hm-bak";
            home-manager.users.lyra = import ./home/hosts/lyra/home.nix;
          }
        ];
      };

      devShells.${system}.dora-rs = inputs.dora-rs-dev.devShells.${system}.default;

      homeConfigurations.lyra = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home/hosts/lyra/home.nix
        ];
      };
    };
}
