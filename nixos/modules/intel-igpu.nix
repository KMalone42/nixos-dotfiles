{ config, lib, pkgs, ... }:

{
  #### X11 driver (safe even if you mostly use Wayland)
  # services.xserver.videoDrivers = [ "modesetting" ];
  # If you *really* want the legacy intel DDX:
  services.xserver.videoDrivers = [ "intel" ];

  #### Graphics stack (NixOS ≥ 24.05 uses hardware.graphics)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # 32-bit userspace for Steam/Wine, etc.
    extraPackages = with pkgs; [
      intel-media-driver     # iHD VA-API driver for Gen9+
      libvdpau-va-gl         # VDPAU -> VA-API shim
      vaapiVdpau
      # intel-vaapi-driver   # (i965) only if you need pre-Gen8 fallback
    ];
    extraPackages32 = with pkgs.driversi686Linux; [
      intel-media-driver
      libvdpau-va-gl
      vaapiVdpau
    ];
  };

  #### Firmware & thermal tuning
  hardware.enableRedistributableFirmware = true;
  services.thermald.enable = true;

  #### Optional: Hint VA-API to use iHD (usually auto-detected)
  environment.variables.LIBVA_DRIVER_NAME = "iHD";
}

