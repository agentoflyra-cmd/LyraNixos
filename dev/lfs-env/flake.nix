{
  description = "LFS build env";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # 给 LFS 伪造 awk/yacc/sh 的“期望别名”
        mkShim = name: target: ''
          mkdir -p .lfs-bin
          cat > .lfs-bin/${name} <<'EOF'
          #!/usr/bin/env bash
          exec ${target} "$@"
          EOF
          chmod +x .lfs-bin/${name}
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            bash
            gcc
            binutils
            bison
            coreutils
            diffutils
            findutils
            gnumake
            gawk
            gnugrep
            gzip
            linuxHeaders
            m4
            patch
            perl
            python3
            gnutar
            xz
            gnused
            texinfo
          ];

          shellHook = ''
            # 让 awk/yacc/sh 满足 LFS 书里的“必须是 gawk/bison/bash”的检查语义
            ${mkShim "awk" "${pkgs.gawk}/bin/gawk"}
            ${mkShim "yacc" "${pkgs.bison}/bin/bison"}
            ${mkShim "bash" "${pkgs.bash}/bin/bash"}
            export PATH="$PWD/.lfs-bin:$PATH"

            echo "[LFS devShell] awk=$(command -v awk) yacc=$(command -v yacc) bash=$(command -v bash)"
            echo "[LFS devShell] gcc=$(gcc --version | head -n1)"
            echo "[LFS devShell] ld=$(ld --version | head -n1)"
          '';
        };
      }

    );

}
