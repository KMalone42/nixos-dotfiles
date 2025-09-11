# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kmalone = {
    isNormalUser = true;
    description = "kmalone";
    extraGroups = [ "networkmanager" "wheel" "networkmanager"];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

  # Hyprland dependencies
  swww # for wallpapers
  xdg-desktop-portal-gtk
  xdg-desktop-portal-hyprland
  xwayland
  brightnessctl
  meson
  wayland-protocols
  wayland-utils
  wl-clipboard
  wlroots

  # Hyprland / Hypr-ecosystem
  hyprland 
  hyprshade # night mode
  hyprpicker # color select
  hypridle # idle behavior -> hyprlock
  hyprlock # screen locker
  hyprcursor # edit cursor

  # Customization
  nwg-look

  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  # browser
  firefox
  # editor
  neovim
  
  # common utils
  wget 
  gcc
  git
  mpv
  busybox
  scdoc
  cmake
  efibootmgr

  # asset packs
  kdePackages.qtsvg
  
  # app launchers
  rofi-wayland
  # wofi

  # notification daemon 
  dunst

  # terminal emulator
  kitty

  # screenshots
  grim
  slurp

  # password manager
  bitwarden-desktop

  ### Sound
  ## Control
  pwvucontrol # pavucontrol-like for pipewire
  easyeffects # pipewire audio effects
  alsa-utils
  pulseaudio # for pactl

  # Nix Configuration Tracking
  atuin

  # workflows
  tmux

  # kdePackages
  kdePackages.dolphin # file manager GUI using qt
  kdePackages.kio-fuse # to mount remote filesystems via FUSE
  kdePackages.kio-extras # extra protocols support (sftp, fish and more)
  kdePackages.kalk # calculator
  kdePackages.plasma-systemmonitor # provides usage statistics such as CPU%
  kdePackages.kclock # clock
  kdePackages.gwenview # video and image viewer
  # things for me to figure out later
  # kdePackages.parititonmanager
  # powerdevil
  # fontviewer
  # filelight
  # kate or kwrite 
];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  programs.hyprland.enable = true;
  #programs.hyprland = {
    #enable = true;
    ## commenting cause deprech
    ## xwayland.hidpi = true;
    #xwayland.enable = true;
  #};

  # Waybar
  programs.waybar.enable = true;

  # Hint Electron apps to use wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # (Optional) for graphical session
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  # services.xserver.windowManager.hyprland.enable = true;

  # Doing this for login into hyprland 
  #services.displayManager.sddm.enable = true;
  #services.displaymanager.defaultSession = "hyprland";

  # Opengl and other graphics libraries
  hardware.opengl.enable = true;

  # Enable screen sharing
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };
  
  # commenting this out, font packages have been changed so i'll figure it out later...
  ## Enable meslo-lgs-nf
  #fonts.fonts = with pkgs; [
    #nerdfonts
    #meslo-lgs-nf
  #];

  # Enable sound with pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  # Experimental features
  # --extra-experimental-features nix-command
  # experimental-features = nix-command flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
