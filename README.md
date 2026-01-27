# LyraNixos

集中式 NixOS + Home Manager + Dev Envs 配置目录。

## 目录结构（表格）

| 路径 | 说明 |
| --- | --- |
| `LyraNixos/flake.nix` | 顶层 flake（系统、Home Manager、devShell 导出） |
| `LyraNixos/nixos/` | NixOS 配置 |
| `LyraNixos/nixos/hosts/nixos/default.nix` | 主机入口（`nixosConfigurations.nixos`） |
| `LyraNixos/nixos/modules/` | 模块化系统配置（kernel/core/chinese/noctalia/niri…） |
| `LyraNixos/home/` | Home Manager 配置 |
| `LyraNixos/home/hosts/lyra/home.nix` | 用户入口 |
| `LyraNixos/home/modules/` | 模块化 HM 配置（helix/kitty/yazi/session…） |
| `LyraNixos/home/files/` | 非 Nix 原生配置文件（当前托管 niri/zellij/kitty theme） |
| `LyraNixos/home/files/wallpapers/` | 常用壁纸（从 `~/Pictures/Wallpapers` 复制以便集中管理） |
| `LyraNixos/dev/` | 开发环境 |
| `LyraNixos/dev/dora-rs` | 子 flake（顶层 `nix develop .#dora-rs`） |
| `LyraNixos/dev/ros2-env` | `shell.nix`（备用/非 flake） |

## 目录结构（树形）

```
LyraNixos/
├─ flake.nix
├─ nixos/
│  ├─ hosts/
│  │  └─ nixos/
│  │     └─ default.nix
│  └─ modules/
├─ home/
│  ├─ hosts/
│  │  └─ lyra/
│  │     └─ home.nix
│  ├─ modules/
│  └─ files/
│     └─ wallpapers/
└─ dev/
   ├─ dora-rs/
   └─ ros2-env/
```

## 快速使用（命令卡片）

| 场景 | 命令 | 备注 |
| --- | --- | --- |
| 系统（NixOS） | `sudo nixos-rebuild switch --flake /LyraNixos#nixos` | 含集成的 Home Manager |
| Home Manager（standalone） | `home-manager switch --flake /LyraNixos#lyra` | 入口：`LyraNixos/home/hosts/lyra/home.nix` |
| Dev Env：dora-rs（flake） | `nix develop /LyraNixos#dora-rs` | 顶层已导出 |
| Dev Env：ros2-env（shell.nix） | `nix-shell /LyraNixos/dev/ros2-env/shell.nix` | 备用/非 flake |

路径不在根目录时，将 `/LyraNixos` 替换为实际路径（如 `~/LyraNixos`）。

传统入口文件保留为：
- `~/.config/home-manager/home.nix`（仅 import，实际配置在 `LyraNixos/home/hosts/lyra/home.nix`）

## 迁移到根目录（可选）

目标位置：`/LyraNixos`（与 `/etc`、`/home` 同级）

1. `sudo mkdir -p /LyraNixos`
2. `sudo cp -a /home/lyra/LyraNixos/. /LyraNixos/`
3. 之后统一使用 `/LyraNixos` 路径

## 说明与约定（表格）

| 项 | 说明 |
| --- | --- |
| `flake.lock` | 用命令更新/生成（如 `nix flake lock`、`nix flake update`），不手改 |
| niri 壁纸/主题 | 保留既有 `~/.config/niri` 风格（配置纳入 HM 托管）；壁纸启动命令仍为注释 |
| 壁纸路径 | Home Manager 将 `~/Pictures/Wallpapers` 链接到 `LyraNixos/home/files/wallpapers/`，建议统一引用 `~/Pictures/Wallpapers/...` |
| 首次接管 dotfiles | 集成式 Home Manager 已设置 `home-manager.backupFileExtension = "hm-bak"`，目标文件存在时会改名为 `*.hm-bak` 再写入/链接 |
| zellij | 仍托管 `config.kdl`，保持“集中管理但不强行纯 Nix” |
