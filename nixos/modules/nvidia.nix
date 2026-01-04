# modules/nvidia-legacy.nix
{ config, lib, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true; # don't use proprietary drivers for >20 series
    nvidiaSettings = true;
  };

  boot.kernelParams = [ "nvidia_drm.modeset=1" ];

  services.xserver.videoDrivers = [ "nvidia" ];
}
