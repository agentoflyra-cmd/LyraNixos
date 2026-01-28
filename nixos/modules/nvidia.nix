{ config, pkgs, ... }:

{
  # NVIDIA 显卡配置
  hardware.graphics = {
    enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia.open = true; # see the note above
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false; # 使用闭源驱动（更稳定）
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # 如果是笔记本混合显卡
    # prime = {
    #   sync.enable = true;
    #   # 或者
    #   # offload.enable = true;
    #   intelBusId = "PCI:0:2:0";
    #   nvidiaBusId = "PCI:1:0:0";
    # };
  };

  # NVIDIA 特定的环境变量
  environment.variables = {
    # 让 Qt 应用使用 NVIDIA GPU
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # NVIDIA Wayland 支持（实验性）
    GBM_BACKEND = "nvidia-drm";
    __GL_GSYNC_ALLOWED = "1";
    __GL_VRR_ALLOWED = "0";
  };

  # Qt 支持
  environment.systemPackages = with pkgs; [
    qt5.qtwayland
    libsForQt5.qt5.qtwayland
  ];
}
