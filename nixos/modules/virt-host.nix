# modules/virt-host.nix
{ config, pkgs, lib, ... }:
let
in
{
  # -- Virtualisation --
  # KVM/QEMU setup
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu = {
    package = pkgs.qemu_full;
    ovmf.enable = true;
    swtpm.enable = true; # Win11
    runAsRoot = false;
  };

  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true; # frontend


  # Network + Bridge
  networking.networkmanager.enable = false;
  systemd.network.enable = true;

  networking.useDHCP = false;

  systemd.network.netdevs."br0".netdevConfig = {
      Kind = "bridge";
      Name = "br0";
  };

  systemd.network.networks."10-uplink" = {
    # matchConfig.Name = "wlp6s0";
    matchConfig.Name = "enp0s31f6";
    networkConfig.Bridge = "br0";
  };

  systemd.network.networks."20-br0" = {
    matchConfig.Name = "br0";
    networkConfig.DHCP = "yes";
  };

  # access control list (ACL)
  environment.etc."qemu/bridge.conf".text = ''
    allow br0
  '';
  networking.firewall.trustedInterfaces = [ "br0" ];


  # -- VFIO / IOMMU (choose ONE of intel/amd) --
  boot.initrd.kernelModules = [ "vfio" "vfio_pci" "vfio_iommu_type1" "vfio_virqfd" ];

  # Intel
  boot.kernelParams = [ 
    "intel_iommu=on" "iommu=pt" 

    # Fetch with `lspci -nn | grep -E "VGA|Audio"`
    "vfio-pci.ids=10de:1abc,10de:1def"
  ];

  # NVIDIA GPU passthrough
  boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" "nvidia_uvm" ];

  # Alternate hardwares
  # AMD
  #boot.kernelParams = [ "amd_iommu=on" "iommu=pt" ];
  #boot.blacklistedKernelModules = [ "amdgpu" "radeon" ];

  # for guests
  #networking.bridges.br0.interfaces = [ "enp0s9" ];
  #networking.interfaces.br0.useDHCP = true;
}
