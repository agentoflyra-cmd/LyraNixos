{ pkgs, ... }:
{
  programs.niri.enable = true;
  # ===== 关键：启用 XWayland 支持 =====
  programs.xwayland.enable = true;

  # X11 基础设施（XWayland 需要）
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
  };

  # 图形支持
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa
    ];
  };

  # 必要的 X11 工具
  environment.systemPackages = with pkgs; [
    xwayland
    xwayland-satellite
    xorg.xauth
    xorg.xhost
    xorg.xinit
    xorg.xrandr
    mesa-demos

    # 调试工具
    xorg.xeyes
    xorg.xclock
  ];

  # 环境变量
  environment.variables = {
    # 让应用知道在 Wayland 下运行
    GDK_BACKEND = "wayland,x11";
    CLUTTER_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    # Qt Wayland 支持
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  # D-Bus（必需）
  services.dbus.enable = true;

}
