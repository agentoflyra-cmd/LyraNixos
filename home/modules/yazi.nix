{ lib, ... }:
{
  programs.yazi = {
    enable = true;
    settings = lib.mkForce {
      log.enabled = false;
      mgr.show_hidden = false;
      flavor.use = "noctalia";
    };
  };
}

