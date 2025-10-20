# NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
in
{
  imports =
  [ 
    ./hardware-configuration.nix
    (import "${home-manager}/nixos")
  ]
  #++ lib.optionals (builtins.pathExists ./modules/nvidia.nix)     [ ./modules/nvidia.nix ]
  #++ lib.optionals (builtins.pathExists ./modules/intel-igpu.nix) [ ./modules/intel-igpu.nix ]
  ;
    
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
  # KdeConnect Groups = uinput, input
  # input also associated with qemu/kvm 
  users.users.kmalone = {
    isNormalUser = true;
    description = "kmalone";
    extraGroups = [ "networkmanager" "wheel" "uinput" "input" "libvirtd" "kvm"];
    packages = with pkgs; [];
  };

  # BEGIN Home-Manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";

  home-manager.users.kmalone = { pkgs, ...}: {
    home.packages = [ pkgs.atool pkgs.httpie ];
    home.stateVersion = "25.05";

    home.file = {
      # Waybar
      ".config/waybar/config.jsonc".source = ./waybar/config.jsonc;
      ".config/waybar/style.css".source     = ./waybar/style.css;
      # Hypr
      ".config/hypr/hyprland.conf".source   = ./hypr/hyprland.conf;
      ".config/hypr/hyprpaper.conf".source  = ./hypr/hyprpaper.conf;
      ".config/hypr/hypridle.conf".source   = ./hypr/hypridle.conf;
      ".config/hypr/hyprlock.conf".source   = ./hypr/hyprlock.conf;
      # Wofi
      ".config/wofi/config".source = ./wofi/config;
      ".config/wofi/style.css".source = ./wofi/style.css;
      # Kitty
      ".config/kitty/Gruvbox_Dark.conf".source = ./kitty/Gruvbox_Dark.conf;
      ".config/kitty/kitty.conf".source = ./kitty/kitty.conf;
      # Bash
      ".bashrc".source = ./bashrc;
    };
    programs.waybar.enable = true;
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
    gtk = {
      enable = true;
      theme = {
        name = "Gruvbox-Dark";
        package = pkgs.gruvbox-dark-gtk;
      };
      iconTheme = {
        name = "Mint-L";
        package = pkgs.mint-l-icons;
      };
    };
  };
  # END Home-Manager

        #  gtk = {
        #    enable = true;
        #    theme = {
        #      name = "Adwaita-dark";
        #      package = pkgs.gnome.gnome-themes-extra;
        #    };
    #  };

        #  qt = {
        #    enable = true;
        #    platform = "qtct";
        #    style = "kvantum";
    #  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # BEGIN Packages
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    # Hyprland dependencies
    swww # for wallpapers may not actually be a dependency/needed
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    xwayland # compatibility layer for X.Org within Wayland
    brightnessctl
    meson
    wayland-protocols
    wayland-utils
    wl-clipboard
    wlroots
    wofi # dmenu replacement for wayland environments
    dunst # notification daemon
    kitty # terminal emulator
    #cage # Dependency for Wayland based greetd setups
    #greetd.regreet # a greeter

    # Hyprland / Hypr-ecosystem
    hyprland 
    hyprpaper  # wallpaper
    hyprshade  # night mode
    hyprpicker # color select
    hypridle   # idle behavior -> hyprlock
    hyprlock   # screen locker
    hyprcursor # edit cursor

    # Productivity
    bitwarden-desktop # Password Manager
    chromium # Open source web browser from Google
    firefox  # Mozilla's Firefox web browser
    gimp3    # GNU Image Manipulation Program
    inkscape # Vector graphics editor
    neovim      # Vim-fork focused on extensbility and usability
    tree-sitter # CLI for :TSInstallFromGrammar
    rclone      # Command line program to sync files and directories to and from major cloud storage
    thunderbird # Mozilla's "Full-featured e-mail client"
    tmux        # a terminal multiplexer
    vesktop     # Unofficial Discord Client
    libreoffice-qt6-fresh # Comprehensive, professional-quality productivity suite, a variant of openoffice.org
    newsflash

    # Homelabbing
    kdePackages.kdeconnect-kde
    syncthing syncthingtray

    # Rice
    cava
    gotop
    fastfetch
    
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
    parted # Create, destroy, resize, check, and copy partitions
    man-pages
    man-pages-posix
    linux-manual
    unzip

    # Muh interpretted languages
    nodejs
    (python313.withPackages (ps: with ps; [
      pip mutagen numpy scipy pandas matplotlib jupyterlab ipython 
      scikit-learn pillow requests sqlalchemy aiosqlite opencv4
    ]))

    # screenshots
    grim slurp

    ### Sound
    sof-firmware
    ## Control
    pavucontrol # maybe works better than pwvucontrol
    pwvucontrol # modern volume controller like pavucontrol 
    wireplumber # pipewire session manager
    easyeffects # pipewire audio effects, channel mixer
    alsa-utils  # troubleshooting, adds alsamixer

    gtk4 # Multi-platform toolkit for creating graphical user interfaces
    qbittorrent # Torrent file manager

    # kdePackages
    kdePackages.qtsvg

    kdePackages.isoimagewriter
    kdePackages.kio-gdrive # KIO Worker to access Google Drive
    kdePackages.kio-fuse   # to mount remote filesystems via FUSE
    kdePackages.kio-extras # extra protocols support (sftp, fish and more)
    kdePackages.gwenview   # video and image viewer
    kdePackages.kdenlive   # Free and open source video editor, based on MLT Framework and KDE Frameworks
    # things for me to figure out later
    # kdePackages.parititonmanager
    # powerdevil
    # fontviewer
    # filelight
    # kate or kwrite 
    # Themes
    kdePackages.breeze
    kdePackages.breeze-gtk
    kdePackages.breeze-icons
    bibata-cursors
    themechanger # Theme changing utility for Linux
    libsForQt5.qtstyleplugin-kvantum kdePackages.qtstyleplugin-kvantum # SVG-based Qt5 theme engine plus a config tool and extra themes
    mint-themes mint-l-icons mint-x-icons mint-y-icons # mint icon and themes
    nemo
    gruvbox-dark-gtk
    gruvbox-gtk-theme
    gruvbox-material-gtk-theme
    gruvbox-dark-icons-gtk
    gruvbox-kvantum


    
    # Calculators
      # Default
      gnome-calculator  # Calculator for GNOME
      #kdePackages.kalk # Calculator for KDE

    # GNOME pkgs
    gnome-decoder # QR codes
    gtg
    gnome-frog

    # Webcams
      #GNOME
      cheese
      #KDE
      webcamoid
      kdePackages.kamera

    # Clocks
      #GNOME
      gnome-clocks
      gnome-solanum
      gnome-pomodoro
      #KDE
      kdePackages.kclock # Clock
      kronometer
      ktimetracker
      kdePackages.ktimer
    # To compare
    # gnome-clocks vs kclock
    # gnome-solanum vs gnome-pomodoro
    # kronometer vs idk
    # 

    # Development
      #GNOME
      gitg # GNOME GUI client to view git repositories
      # nix currently missing kommit sadge. 


    # Pdfs and OCR
      #GNOME
      ocrfeeder          # an OCR GUI for GNOME (uses tesceract)
      evince             # a pdf reader for GNOME
      #KDE
      kdePackages.okular # a pdf reader for KDE
      karp # pdf arranger for KDE

    # Gaming
    vulkan-tools
    prismlauncher

    # Recording
    obs-studio

    # AI
    ollama-cuda # Run large language models locally, using CUDA for NVIDIA GPU acceleration
    kdePackages.alpaka # Kirigami client for Ollama
    # File Manager
    nautilus
    kdePackages.dolphin # file manager GUI using qt

    # NOT WORKING
    #kdePackages.plasma-systemmonitor # provides usage statistics such as CPU%
    #kdePackages.kamoso
    #nwg-look # a GTK3 settings editor adapted to work in the wlroots environment

    # Virtualization
    qemu_kvm virtio-win  # Windows virtio drivers ISO
    spice-gtk           # SPICE client libs
    quickemu quickgui   # zero-friction VM creation
    docker_28
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

  # Environment Variables
  environment = {
    variables.EDITOR = "nvim";
    variables.SUDO_EDITOR = "nvim";
    variables.VISUAL = "nvim";
    variables.WLR_NO_HARDWARE_CURSORS = "1";
    sessionVariables.NIXOS_OZONE_WL = "1"; # Hint Electron apps to use wayland
    sessionVariables.KVANTUM_THEME = "Gruvbox";
    #sessionVariables.GTK_THEME= "Mint-Y-Dark";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.enable = true; # XOrg compatibility # maybe not required
  services.libinput.enable = true; # Required with lightdm for whatever reason

  # Display Server -> Display Manager/Greeter -> DesktopEnv/WindowManager

  services.displayManager.sddm = {
      enable = true;
      theme = "breeze";
  };

  programs.hyprland.enable = true;
  services.dbus.enable = true; # Enable screen sharing
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    wlr.enable = true; # need this for kdeconnect maybe
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
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
  services.pipewire.wireplumber.configPackages = [];

  # -- Miscelanious Services --
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.upower.enable = true;
  services.udisks2.enable = true;

  # KDE Connect daemon/service
  programs.kdeconnect = {
    enable = true;
    package = pkgs.kdePackages.kdeconnect-kde;
  };
  hardware.uinput.enable = true; # required for phone -> mouse input may not be required
  boot.kernelModules = [ "uinput" ];
  networking.firewall = {
    allowedTCPPorts = [ 1714 1764 ];
    allowedUDPPorts = [ 1714 1764 ];
  };
  # Needed for input plugin (uinput access)
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
  '';

  # Syncthing Daemon
  services.syncthing = {
    enable = true;
    package = pkgs.syncthing;
    user = "kmalone";
    dataDir = "/home/kmalone";
    configDir = "/home/kmalone/.config/syncthing";
    openDefaultPorts = true;
  };

  # KVM/QEMU setup
  virtualisation = {
    docker.enable = true; # Not needed for the rest of the qemu setup
    libvirtd.enable = true;
    libvirtd.qemu = {
      package = pkgs.qemu_kvm;
      ovmf.enable = true;
      swtpm.enable = true;
      runAsRoot = false;
    };
    spiceUSBRedirection.enable = true;
  };
  programs.virt-manager.enable = true;

  # Steam
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Required for Steam Remote Play
    dedicatedServer.openFirewall = true; # Required for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Required for Steam Local Network Transfers
  };

  documentation.man = {
    enable = true;
    generateCaches = true;
  };

  # List services that you want to enable:
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Experimental features
  # --extra-experimental-features nix-command
  # experimental-features = nix-command flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Don't change unless required
}
