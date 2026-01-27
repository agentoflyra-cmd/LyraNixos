{
  description = "Unitree SDK2 + dora-rs dev-shell";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      unitreeArchDir = if pkgs.stdenv.hostPlatform.isAarch64 then "aarch64" else "x86_64";

      dora-cli =
        let
          version = "0.4.1";
        in
        pkgs.rustPlatform.buildRustPackage rec {
          pname = "dora-cli";
          version = "0.4.1";
          src = pkgs.fetchFromGitHub {
            owner = "dora-rs";
            repo = "dora";
            rev = "v${version}";
            hash = "sha256-I3vI5IAp8BXrW/sZsAslBYwbBUx139PQuZ+c/mjjH+0=";
          };
          cargoHash = "sha256-Bj/Gniq1nArQUVvoOWUQiZQPbjLNjbFIl8SrmOrXL/k=";
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = [ pkgs.openssl ];
          OPENSSL_NO_VENDOR = 1;
          buildPhase = ''
            cargo build --release -p dora-cli
          '';
          installPhase = ''
            mkdir -p $out/bin
            cp target/release/dora $out/bin
          '';
          doCheck = false;
        };

      # 首先定义 CycloneDDS
      cyclonedds = pkgs.stdenv.mkDerivation {
        pname = "cyclonedds";
        version = "0.10.5";
        src = pkgs.fetchFromGitHub {
          owner = "eclipse-cyclonedds";
          repo = "cyclonedds";
          rev = "0.10.5";
          sha256 = "sha256-MQVUZ7PkxauoPpfxlhhAtsKztMe9tcZOpOzshuz/eb8=";
        };
        nativeBuildInputs = [ pkgs.cmake ];
        buildInputs = [ pkgs.openssl ]; # CycloneDDS 可能需要 SSL

        cmakeFlags = [
          "-DBUILD_SHARED_LIBS=ON"
          "-DCMAKE_BUILD_TYPE=Release"
          "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
          "-DBUILD_IDLC=ON" # 编译 IDL 编译器
          "-DENABLE_SECURITY=OFF" # 如果不需要安全特性可以关闭
          "-DENABLE_SSL=OFF" # 如果不需要 SSL 可以关闭
        ];

        # 修复 pkgconfig 文件中的双斜杠问题
        postFixup = ''
          # 修复 .pc 文件中的路径
          for pc in $out/lib/pkgconfig/*.pc; do
            if [ -f "$pc" ]; then
              sed -i "s|//nix/store|/nix/store|g" "$pc"
              sed -i "s|\''${prefix}//|\''${prefix}/|g" "$pc"
            fi
          done
        '';
      };

      # CycloneDDS C++ 绑定
      cyclonedds-cxx = pkgs.stdenv.mkDerivation {
        pname = "cyclonedds-cxx";
        version = "0.10.5";
        src = pkgs.fetchFromGitHub {
          owner = "eclipse-cyclonedds";
          repo = "cyclonedds-cxx";
          rev = "0.10.5";
          sha256 = "sha256-whFVEQec/Ca+dr6R7z9mMrNg315z3oIWchVT+vQ36So=";
        };
        nativeBuildInputs = [ pkgs.cmake ];
        buildInputs = [ cyclonedds ]; # 依赖 C 版本

        cmakeFlags = [
          "-DBUILD_SHARED_LIBS=ON"
          "-DCMAKE_BUILD_TYPE=Release"
          "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
          "-DCMAKE_PREFIX_PATH=${cyclonedds}"
        ];

        postFixup = ''
          for pc in $out/lib/pkgconfig/*.pc; do
            if [ -f "$pc" ]; then
              sed -i "s|//nix/store|/nix/store|g" "$pc"
              sed -i "s|\''${prefix}//|\''${prefix}/|g" "$pc"
            fi
          done
        '';
      };

      unitree_sdk2 = pkgs.stdenv.mkDerivation {
        pname = "unitree-sdk2";
        version = "git";
        src = pkgs.fetchFromGitHub {
          owner = "unitreerobotics";
          repo = "unitree_sdk2";
          rev = "master";
          sha256 = "sha256-GiM+dSBvC3REKtSE+V6We6Q/BGoB9fxftmm8vqT1XQg=";
        };

        nativeBuildInputs = [
          pkgs.cmake
          pkgs.gnumake
          pkgs.patchelf # 用于修复 RPATH
        ];
        buildInputs = [
          pkgs.eigen
        ];

        cmakeFlags = [
          "-DCMAKE_BUILD_TYPE=Release"
          "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
        ];

        # 修复 RPATH 问题
        # 我们需要在 NixOS 检查之前修复，所以用 preFixup
        dontPatchELF = false; # 让 NixOS 自动处理标准库

        # 在自动检查之前修复 RPATH
        preFixup = ''
          echo "=== Pre-fixing RPATH to remove /build/ references ==="
          for exe in $out/bin/*; do
            if [ -f "$exe" ] && [ -x "$exe" ]; then
              echo "Fixing $(basename $exe)"
              # 设置正确的 RPATH
              patchelf --set-rpath "$out/lib:${
                pkgs.lib.makeLibraryPath [
                  pkgs.stdenv.cc.cc
                  pkgs.eigen
                ]
              }" "$exe" 2>/dev/null || true
            fi
          done
        '';

        installPhase = ''
          mkdir -p $out/{lib,include,bin,share/examples}

          # Unitree SDK2 自带 CycloneDDS（thirdparty/lib），运行时必须优先使用它，
          # 否则会出现 C++ 符号不匹配（例如 EntityDelegate::listener_set）
          echo "=== Detecting bundled thirdparty libs ==="
          echo "PWD: $(pwd)"
          thirdparty_lib_dir=""
          for d in \
            "thirdparty/lib/${unitreeArchDir}" \
            "../thirdparty/lib/${unitreeArchDir}" \
            "../source/thirdparty/lib/${unitreeArchDir}"; do
            if [ -d "$d" ]; then
              thirdparty_lib_dir="$d"
              break
            fi
          done
          if [ -n "$thirdparty_lib_dir" ]; then
            echo "=== Installing bundled thirdparty libs from $thirdparty_lib_dir ==="
            cp -av "$thirdparty_lib_dir"/* $out/lib/ 2>&1 || true
          else
            echo "Warning: bundled thirdparty lib dir not found"
            echo "Tried: thirdparty/lib, ../thirdparty/lib, ../source/thirdparty/lib"
          fi

          # 复制库文件
          if [ -d "lib" ]; then
            cp -rv lib/* $out/lib/ 2>&1 || echo "No lib/ directory"
          fi

          # 复制头文件
          if [ -d "../include" ]; then
            cp -rv ../include/* $out/include/ 2>&1
          fi
          if [ -d "include" ]; then
            cp -rv include/* $out/include/ 2>&1
          fi

          # 复制源码中的示例（供参考）
          if [ -d "../example" ]; then
            cp -rv ../example/* $out/share/examples/ 2>&1
          fi

          # 复制编译好的可执行文件
          find . -type f -executable -exec file {} \; | grep ELF | cut -d: -f1 | while read exe; do
            exename=$(basename "$exe")
            cp -v "$exe" $out/bin/
          done

          echo "=== Installed examples ==="
          ls -l $out/bin/
        '';

        # 添加运行时需要的库到 RPATH
        postFixup = ''
          echo "=== Fixing RPATH for all binaries ==="
          for exe in $out/bin/*; do
            if [ -f "$exe" ] && [ -x "$exe" ]; then
              echo "Fixing $exe"
              # 获取当前 RPATH
              oldRpath=$(patchelf --print-rpath "$exe" || echo "")
              # 设置新的 RPATH，包含所有需要的库路径
              newRpath="$out/lib"
              # 添加标准库路径
              newRpath="$newRpath:${
                pkgs.lib.makeLibraryPath [
                  pkgs.stdenv.cc.cc
                  pkgs.eigen
                ]
              }"
              
              echo "  Old RPATH: $oldRpath"
              echo "  New RPATH: $newRpath"
              
              patchelf --set-rpath "$newRpath" "$exe" || true
            fi
          done

          echo "=== Fixing RPATH for bundled DDS libs ==="
          for lib in $out/lib/libddsc*.so*; do
            if [ -f "$lib" ]; then
              echo "Fixing $lib"
              patchelf --set-rpath "$out/lib:${
                pkgs.lib.makeLibraryPath [
                  pkgs.stdenv.cc.cc
                ]
              }" "$lib" 2>/dev/null || true
            fi
          done

          echo "=== Verifying dependencies ==="
          for exe in $out/bin/*; do
            if [ -f "$exe" ] && [ -x "$exe" ]; then
              echo "Checking $(basename $exe):"
              ldd "$exe" | grep -E "(ddsc|ddscxx)" || echo "  No DDS libraries found!"
            fi
          done
        '';
      };

    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.rustc
          pkgs.cargo
          pkgs.gcc
          pkgs.cmake
          pkgs.gnumake
          pkgs.pkg-config
          pkgs.eigen
          pkgs.git
          pkgs.gdb
          unitree_sdk2
          dora-cli
        ];

        shellHook = ''
          echo "╔════════════════════════════════════════════════════════════╗"
          echo "║  Unitree SDK2 + Dora-rs 开发环境                           ║"
          echo "╚════════════════════════════════════════════════════════════╝"
          echo ""
          echo "📦 Unitree SDK2 路径: ${unitree_sdk2}"
          echo ""
          echo "📂 可用目录:"
          echo "   • 库文件:    ${unitree_sdk2}/lib"
          echo "   • 头文件:    ${unitree_sdk2}/include"
          echo "   • 例程代码:  ${unitree_sdk2}/share/examples"
          echo "   • 可执行文件: ${unitree_sdk2}/bin"
          echo ""
          echo "🌐 配置 CycloneDDS 网络接口 (重要!)"
          echo "   当前接口: 未设置"
          echo "   设置方法: export CYCLONEDDS_URI='<CycloneDDS><Domain><General><Interfaces><NetworkInterface name=\"enp3s0\" priority=\"default\" multicast=\"default\" /></Interfaces></General></Domain></CycloneDDS>'"
          echo "   (将 enp3s0 替换为你的实际网络接口名)"
          echo ""
          echo "🤖 Go2 例程快速启动:"
          echo "   ${unitree_sdk2}/bin/go2_stand_example"
          echo "   ${unitree_sdk2}/bin/go2_low_level"
          echo ""
          echo "💡 查看所有例程:"
          echo "   ls ${unitree_sdk2}/bin/"
          echo ""
          echo "📝 查看示例源码:"
          echo "   ls ${unitree_sdk2}/share/examples/"
          echo ""
        '';
      };

      packages.${system} = {
        cyclonedds = cyclonedds;
        cyclonedds-cxx = cyclonedds-cxx;
        unitree_sdk2 = unitree_sdk2;
        dora-cli = dora-cli;
        default = unitree_sdk2;
      };
    };
}

