{ config, lib, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;              # proprietary driver for CUDA
    nvidiaSettings = false;
    powerManagement.enable = true;
  };
}

