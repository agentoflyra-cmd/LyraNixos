# LyraNixos

集中式 NixOS + Home Manager + Dev Envs 配置目录。

## 目录结构

- `LyraNixos/flake.nix`: 顶层 flake（系统、Home Manager、devShell 导出都在这里）
- `LyraNixos/nixos/`: NixOS 配置
  - `LyraNixos/nixos/hosts/nixos/default.nix`: 主机入口（`nixosConfigurations.nixos`）
  - `LyraNixos/nixos/modules/`: 模块化系统配置（kernel/core/chinese/noctalia/niri…）
- `LyraNixos/home/`: Home Manager 配置
  - `LyraNixos/home/hosts/lyra/home.nix`: 用户入口
  - `LyraNixos/home/modules/`: 模块化 HM 配置（helix/kitty/yazi/session…）
- `LyraNixos/home/files/`: 非 Nix 原生配置文件（目前托管 niri/zellij/kitty theme）
- `LyraNixos/home/files/wallpapers/`: 你常用壁纸（从 `~/Pictures/Wallpapers` 复制进来，便于集中管理）
- `LyraNixos/dev/`: 开发环境
  - `LyraNixos/dev/dora-rs`: 子 flake（已导出到顶层 `nix develop .#dora-rs`）
  - `LyraNixos/dev/ros2-env`: `shell.nix`（备用/非 flake）

## 使用方式

### 1) 系统（NixOS）

应用整机配置（同时包含集成的 Home Manager）：

`sudo nixos-rebuild switch --flake /LyraNixos#nixos`

如果你把目录放在家目录下（例如 `~/LyraNixos`），把 `/LyraNixos` 换成对应路径即可。

### 2) Home Manager（standalone）

顶层 flake 已提供 `homeConfigurations.lyra`，可以直接：

`home-manager switch --flake /LyraNixos#lyra`

另外也保留了传统入口文件：

- `~/.config/home-manager/home.nix`（只做 import，实际配置在 `LyraNixos/home/hosts/lyra/home.nix`）

### 3) Dev Envs

#### dora-rs

顶层已导出：

`nix develop /LyraNixos#dora-rs`

#### ros2-env

当前仍为 `shell.nix`（便于快速进入）：

`nix-shell /LyraNixos/dev/ros2-env/shell.nix`

## 迁移到根目录（可选）

如果你希望最终形态是 `/LyraNixos`（与 `/etc`、`/home` 同级）：

1. `sudo mkdir -p /LyraNixos`
2. `sudo cp -a /home/lyra/LyraNixos/. /LyraNixos/`
3. 之后统一用 `/LyraNixos` 路径执行上面的命令

## 说明与约定

- `flake.lock`：建议用命令更新/生成（例如 `nix flake lock`、`nix flake update`），不要手改。
- niri 壁纸/主题：目前仍保留你现有 `~/.config/niri` 配置风格（配置文件纳入 HM 托管）；壁纸启动命令仍为注释，你后续想纯 Nix 化我再继续做。
- 壁纸路径：由 Home Manager 把 `~/Pictures/Wallpapers` 链接到 `LyraNixos/home/files/wallpapers/`，因此建议所有主题/程序都统一引用 `~/Pictures/Wallpapers/...`。
- 首次接管 dotfiles：集成式 Home Manager 已设置 `home-manager.backupFileExtension = "hm-bak"`，若目标文件已存在会自动改名为 `*.hm-bak` 再写入/链接，避免激活失败。
- zellij：仍托管 `config.kdl`（你提到它纯 nix 化成本较高；当前做法是“集中管理但不强行纯 nix”）。
