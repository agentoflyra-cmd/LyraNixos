{
  pkgs,
  ...
}:
{
  hardware.graphics = {
    enable = true;
    
  };

  # 确保 Qt Wayland 支持
  environment.systemPackages = with pkgs; [
    qt5.qtwayland
    libsForQt5.qt5.qtwayland
  ];
}
