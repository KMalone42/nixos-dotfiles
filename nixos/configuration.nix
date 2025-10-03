# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
in
{
  imports =
    [ 
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
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
    extraGroups = [ "networkmanager" "wheel"];
    packages = with pkgs; [];
  };

  # BEGIN Home-Manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.kmalone = { pkgs, ...}: {
    home.packages = [ pkgs.atool pkgs.httpie ];
    home.stateVersion = "25.05";
        programs.waybar.enable = true;
        home.file = {
          # Waybar
          ".config/waybar/config.jsonc".source = ./waybar/config.jsonc;
          ".config/waybar/style.css".source     = ./waybar/style.css;
          # Hypr
          ".config/hypr/hyprland.conf".source   = ./hypr/hyprland.conf;
          ".config/hypr/hyprpaper.conf".source  = ./hypr/hyprpaper.conf;
          ".config/hypr/hypridle.conf".source   = ./hypr/hypridle.conf;
          ".config/hypr/hyprlock.conf".source   = ./hypr/hyprlock.conf;
        };
        programs.tmux = {
            enable = true;
            terminal = "tmux-256color";
            extraConfig = builtins.readFile ./tmux.conf;
        };
        services.mpd = {
            enable = true;
            musicDirectory = "/home/kmalone/Digital_Media/Music/";
            extraConfig = ''
                # must specify one or more outputs in order to play audio!
                # (e.g. ALSA, PulseAudio, PipeWire), see next sections
                audio_output {
                    type "pipewire" 
                    name "My PipeWire Output"
                }
            '';
            # Optional:
            #network.listenAddress = "any"; # if you want to allow non-localhost
            #network.startWhenNeeded = true; # systemd feature: only start MPD service upon connection to its socket
        };
        programs.rmpc = {
            enable = true;
        };
  };
  # END Home-Manager

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # BEGIN Packages
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
  hyprpaper  # wallpaper
  hyprshade  # night mode
  hyprpicker # color select
  hypridle   # idle behavior -> hyprlock
  hyprlock   # screen locker
  hyprcursor # edit cursor

  # Customization
  nwg-look

  # Internet
  firefox
  vesktop # Unofficial Discord Client


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
  tlrc
  man
  cyme # Modern cross-platform lsusb
  gnumake42 # Tool to control the generation of non-source files from sources

  # Muh interpretted languages
  nodejs
  python314

  # dmenu
  wofi

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
  sof-firmware
  ## Control
  pavucontrol # maybe works better than pwvucontrol
  pwvucontrol # modern volume controller like pavucontrol 
  wireplumber # pipewire session manager
  easyeffects # pipewire audio effects
  alsa-utils  # troubleshooting, adds alsamixer

  # workflows
  tmux

  # kdePackages
  kdePackages.qtsvg
  kdePackages.dolphin # file manager GUI using qt
  kdePackages.kio-fuse # to mount remote filesystems via FUSE
  kdePackages.kio-extras # extra protocols support (sftp, fish and more)
  #kdePackages.kalk # calculator replaced with gnome-calculator
  kdePackages.plasma-systemmonitor # provides usage statistics such as CPU%
  kdePackages.kclock # clock
  kdePackages.gwenview # video and image viewer
  # things for me to figure out later
  # kdePackages.parititonmanager
  # powerdevil
  # fontviewer
  # filelight
  # kate or kwrite 
  gnome-calculator
  gnome-decoder # QR codes


  # Gaming
  vulkan-tools
  prismlauncher

  
  
  ];
  # END Packages

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.meslo-lg
    nerd-fonts.symbols-only
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    # Chinese
    wqy_zenhei
  ];

  environment.variables = {
    EDITOR = "nvim";
    SUDO_EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Hint Electron apps to use wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # i7 8th gen nvidia 1080 config
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # For steam/proton
  };

  programs.gamemode.enable = true;

  # List services that you want to enable:
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # (Optional) for graphical session
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true; # sddm is a greeter, manages signin
  programs.hyprland.enable = true;

  # Enable screen sharing
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };
  

  # Enable sound with pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
      #extraConfig = {
      #  pipewire."99-silent-bell.conf" = {
      #    "context.properties" = {
      #      "module.x11.bell" = false;
      #    };
      #  };
      #};
  };
  services.pipewire.wireplumber.configPackages = [

  ];

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Experimental features
  # --extra-experimental-features nix-command
  # experimental-features = nix-command flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Don't change unless required
}
